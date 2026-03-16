//
//  AIAgentTools.swift
//  VSCodeiPadOS
//
//  AI Agent with tool calling capabilities for code editing
//

import Foundation

// MARK: - Tool Definitions

enum AITool: String, CaseIterable, Codable {
    case readFile = "read_file"
    case writeFile = "write_file"
    case listDirectory = "list_directory"
    case searchFiles = "search_files"
    case createFile = "create_file"
    case getCurrentFile = "get_current_file"
    case getOpenTabs = "get_open_tabs"
    case getWorkspaceInfo = "get_workspace_info"
    case insertCode = "insert_code"
    case replaceSelection = "replace_selection"
    
    var description: String {
        switch self {
        case .readFile: return "Read the contents of a file at the given path"
        case .writeFile: return "Write content to a file at the given path"
        case .listDirectory: return "List files and folders in a directory"
        case .searchFiles: return "Search for text across files in the workspace"
        case .createFile: return "Create a new file with the given content"
        case .getCurrentFile: return "Get the currently active file's content and metadata"
        case .getOpenTabs: return "Get list of all open tabs with their filenames"
        case .getWorkspaceInfo: return "Get information about the current workspace"
        case .insertCode: return "Insert code at the current cursor position"
        case .replaceSelection: return "Replace the currently selected text with new content"
        }
    }
    
    var parameters: [[String: Any]] {
        switch self {
        case .readFile:
            return [["name": "path", "type": "string", "description": "Path to the file to read", "required": true]]
        case .writeFile:
            return [
                ["name": "path", "type": "string", "description": "Path to the file to write", "required": true],
                ["name": "content", "type": "string", "description": "Content to write to the file", "required": true]
            ]
        case .listDirectory:
            return [["name": "path", "type": "string", "description": "Path to the directory (empty for workspace root)", "required": false]]
        case .searchFiles:
            return [
                ["name": "query", "type": "string", "description": "Text to search for", "required": true],
                ["name": "glob", "type": "string", "description": "File pattern to search (e.g. *.swift)", "required": false]
            ]
        case .createFile:
            return [
                ["name": "path", "type": "string", "description": "Path for the new file", "required": true],
                ["name": "content", "type": "string", "description": "Initial content for the file", "required": true]
            ]
        case .getCurrentFile:
            return []
        case .getOpenTabs:
            return []
        case .getWorkspaceInfo:
            return []
        case .insertCode:
            return [["name": "code", "type": "string", "description": "Code to insert at cursor position", "required": true]]
        case .replaceSelection:
            return [["name": "content", "type": "string", "description": "Content to replace the selection with", "required": true]]
        }
    }
    
    // OpenAI function calling format
    var openAIFunction: [String: Any] {
        var properties: [String: Any] = [:]
        var required: [String] = []
        
        for param in parameters {
            let name = param["name"] as? String ?? ""
            properties[name] = [
                "type": param["type"] as? String ?? "string",
                "description": param["description"] as? String ?? ""
            ]
            if param["required"] as? Bool == true {
                required.append(name)
            }
        }
        
        return [
            "type": "function",
            "function": [
                "name": rawValue,
                "description": description,
                "parameters": [
                    "type": "object",
                    "properties": properties,
                    "required": required
                ]
            ]
        ]
    }
    
    // Anthropic tool format
    var anthropicTool: [String: Any] {
        var inputSchema: [String: Any] = ["type": "object"]
        var properties: [String: Any] = [:]
        var required: [String] = []
        
        for param in parameters {
            let name = param["name"] as? String ?? ""
            properties[name] = [
                "type": param["type"] as? String ?? "string",
                "description": param["description"] as? String ?? ""
            ]
            if param["required"] as? Bool == true {
                required.append(name)
            }
        }
        
        inputSchema["properties"] = properties
        inputSchema["required"] = required
        
        return [
            "name": rawValue,
            "description": description,
            "input_schema": inputSchema
        ]
    }
}

// MARK: - Tool Call Request/Response

struct ToolCall: Identifiable, Codable {
    let id: String
    let tool: AITool
    let arguments: [String: String]
    
    init(id: String = UUID().uuidString, tool: AITool, arguments: [String: String]) {
        self.id = id
        self.tool = tool
        self.arguments = arguments
    }
}

struct ToolResult: Identifiable, Codable {
    let id: String
    let toolCallId: String
    let success: Bool
    let output: String
    let error: String?
    
    init(toolCallId: String, success: Bool, output: String, error: String? = nil) {
        self.id = UUID().uuidString
        self.toolCallId = toolCallId
        self.success = success
        self.output = output
        self.error = error
    }
}

// MARK: - AI Agent Context

struct AIAgentContext: Codable {
    let workspacePath: String?
    let workspaceName: String?
    let currentFile: CurrentFileInfo?
    let openTabs: [OpenTabInfo]
    let selection: SelectionInfo?
    
    struct CurrentFileInfo: Codable {
        let path: String
        let name: String
        let language: String
        let content: String
        let lineCount: Int
        let cursorLine: Int
        let cursorColumn: Int
    }
    
    struct OpenTabInfo: Codable {
        let name: String
        let path: String?
        let language: String
        let isUnsaved: Bool
        let isActive: Bool
    }
    
    struct SelectionInfo: Codable {
        let text: String
        let startLine: Int
        let endLine: Int
    }
    
    func toSystemPromptSection() -> String {
        var sections: [String] = []
        
        if let workspace = workspaceName, let path = workspacePath {
            sections.append("## Workspace\nName: \(workspace)\nPath: \(path)")
        }
        
        if !openTabs.isEmpty {
            let tabList = openTabs.map { tab in
                let marker = tab.isActive ? "→ " : "  "
                let unsaved = tab.isUnsaved ? "●" : ""
                return "\(marker)\(tab.name) [\(tab.language)]\(unsaved)"
            }.joined(separator: "\n")
            sections.append("## Open Tabs\n\(tabList)")
        }
        
        if let file = currentFile {
            sections.append("## Current File\nPath: \(file.path)\nLanguage: \(file.language)\nLines: \(file.lineCount)\nCursor: Line \(file.cursorLine), Column \(file.cursorColumn)")
            
            // Include file content (truncated if very long)
            let maxLines = 500
            let lines = file.content.components(separatedBy: "\n")
            if lines.count <= maxLines {
                sections.append("## Current File Content\n```\(file.language)\n\(file.content)\n```")
            } else {
                // Show context around cursor
                let startLine = max(0, file.cursorLine - 100)
                let endLine = min(lines.count, file.cursorLine + 100)
                let visibleLines = lines[startLine..<endLine].joined(separator: "\n")
                sections.append("## Current File Content (lines \(startLine+1)-\(endLine) of \(lines.count))\n```\(file.language)\n\(visibleLines)\n```")
            }
        }
        
        if let sel = selection, !sel.text.isEmpty {
            sections.append("## Selected Text (lines \(sel.startLine)-\(sel.endLine))\n```\n\(sel.text)\n```")
        }
        
        return sections.joined(separator: "\n\n")
    }
}

// MARK: - Tool Executor

class AIToolExecutor {
    weak var editorCore: EditorCore?
    var fileNavigator: FileSystemNavigator?
    
    init(editorCore: EditorCore? = nil, fileNavigator: FileSystemNavigator? = nil) {
        self.editorCore = editorCore
        self.fileNavigator = fileNavigator
    }
    
    func execute(_ toolCall: ToolCall) async -> ToolResult {
        do {
            let output = try await executeTool(toolCall.tool, arguments: toolCall.arguments)
            return ToolResult(toolCallId: toolCall.id, success: true, output: output)
        } catch {
            return ToolResult(toolCallId: toolCall.id, success: false, output: "", error: error.localizedDescription)
        }
    }
    
    private func executeTool(_ tool: AITool, arguments: [String: String]) async throws -> String {
        switch tool {
        case .readFile:
            return try await readFile(path: arguments["path"] ?? "")
        case .writeFile:
            return try await writeFile(path: arguments["path"] ?? "", content: arguments["content"] ?? "")
        case .listDirectory:
            return try await listDirectory(path: arguments["path"])
        case .searchFiles:
            return try await searchFiles(query: arguments["query"] ?? "", glob: arguments["glob"])
        case .createFile:
            return try await createFile(path: arguments["path"] ?? "", content: arguments["content"] ?? "")
        case .getCurrentFile:
            return getCurrentFile()
        case .getOpenTabs:
            return getOpenTabs()
        case .getWorkspaceInfo:
            return getWorkspaceInfo()
        case .insertCode:
            return await insertCode(code: arguments["code"] ?? "")
        case .replaceSelection:
            return await replaceSelection(content: arguments["content"] ?? "")
        }
    }
    
    // MARK: - Tool Implementations
    
    private func readFile(path: String) async throws -> String {
        // First try to read from open tabs (works without workspace)
        if let tab = await MainActor.run(body: { editorCore?.tabs.first(where: { $0.fileName == path || $0.url?.lastPathComponent == path }) }) {
            return tab.content
        }
        
        // If workspace is open, read from filesystem
        if let rootURL = fileNavigator?.rootURL {
            let fileURL = rootURL.appendingPathComponent(path)
            let didStart = fileURL.startAccessingSecurityScopedResource()
            defer { if didStart { fileURL.stopAccessingSecurityScopedResource() } }
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw ToolError.fileNotFound(path)
            }
            
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return content
        }
        
        // List available files for the user
        let availableFiles = await MainActor.run(body: { editorCore?.tabs.map { $0.fileName }.joined(separator: ", ") }) ?? "none"
        throw ToolError.fileNotFound("\(path) (available files: \(availableFiles))")
    }
    
    private func writeFile(path: String, content: String) async throws -> String {
        // First check if it's an open tab
        let updated = await MainActor.run { () -> Bool in
            if let index = editorCore?.tabs.firstIndex(where: { $0.fileName == path || $0.url?.lastPathComponent == path }) {
                editorCore?.tabs[index].content = content
                editorCore?.tabs[index].isUnsaved = true
                return true
            }
            return false
        }
        
        if updated {
            return "Successfully updated \(path) (\(content.count) characters). File is unsaved - user should save it."
        }
        
        // If workspace is open, write to filesystem
        guard let rootURL = fileNavigator?.rootURL else {
            // No workspace - create a new in-memory tab
            await MainActor.run {
                let newTab = Tab(fileName: path, content: content)  // language auto-detected
                editorCore?.tabs.append(newTab)
                editorCore?.activeTabId = newTab.id
            }
            return "Created new tab '\(path)' with \(content.count) characters (in-memory, no workspace open)"
        }
        
        let fileURL = rootURL.appendingPathComponent(path)
        try fileNavigator?.writeFile(at: fileURL, content: content)
        
        // Update tab if file is open
        await MainActor.run {
            if let index = editorCore?.tabs.firstIndex(where: { $0.url == fileURL }) {
                editorCore?.tabs[index].content = content
            }
        }
        
        return "Successfully wrote \(content.count) characters to \(path)"
    }
    
    private func listDirectory(path: String?) async throws -> String {
        // If workspace is open, list filesystem
        if let rootURL = fileNavigator?.rootURL {
            let dirURL = path.flatMap { $0.isEmpty ? nil : rootURL.appendingPathComponent($0) } ?? rootURL
            let didStart = dirURL.startAccessingSecurityScopedResource()
            defer { if didStart { dirURL.stopAccessingSecurityScopedResource() } }
            
            let contents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
            
            let items = try contents.map { url -> String in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let icon = isDir ? "📁" : "📄"
                return "\(icon) \(url.lastPathComponent)"
            }.sorted()
            
            return items.isEmpty ? "(empty directory)" : items.joined(separator: "\n")
        }
        
        // No workspace - list open tabs instead
        let tabs = await MainActor.run { editorCore?.tabs ?? [] }
        if tabs.isEmpty {
            return "No workspace open and no files in editor."
        }
        
        var result = "📋 Open tabs (no workspace folder open):\n"
        for tab in tabs {
            let icon = "📄"
            result += "\(icon) \(tab.fileName)\n"
        }
        result += "\nTip: Open a folder to browse the full filesystem."
        return result
    }
    
    private func searchFiles(query: String, glob: String?) async throws -> String {
        guard let rootURL = fileNavigator?.rootURL else {
            throw ToolError.noWorkspace
        }
        
        var results: [String] = []
        let fm = FileManager.default
        
        let enumerator = fm.enumerator(at: rootURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
        
        while let fileURL = enumerator?.nextObject() as? URL {
            // Skip directories
            guard let isFile = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile, isFile else { continue }
            
            // Check glob pattern if provided
            if let glob = glob, !glob.isEmpty {
                let ext = "*." + fileURL.pathExtension
                if !glob.contains(ext) && glob != "*" {
                    continue
                }
            }
            
            // Read and search file
            guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else { continue }
            
            let lines = content.components(separatedBy: "\n")
            for (index, line) in lines.enumerated() {
                if line.localizedCaseInsensitiveContains(query) {
                    let relativePath = fileURL.path.replacingOccurrences(of: rootURL.path + "/", with: "")
                    let preview = line.trimmingCharacters(in: .whitespaces).prefix(100)
                    results.append("\(relativePath):\(index + 1): \(preview)")
                    
                    if results.count >= 50 {
                        results.append("... (truncated, more than 50 matches)")
                        return results.joined(separator: "\n")
                    }
                }
            }
        }
        
        if results.isEmpty {
            return "No matches found for '\(query)'"
        }
        return results.joined(separator: "\n")
    }
    
    private func createFile(path: String, content: String) async throws -> String {
        guard let rootURL = fileNavigator?.rootURL else {
            throw ToolError.noWorkspace
        }
        
        let fileURL = rootURL.appendingPathComponent(path)
        
        // Ensure parent directory exists
        let parentDir = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parentDir, withIntermediateDirectories: true)
        
        // Write file
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Refresh file tree
        await MainActor.run {
            fileNavigator?.refreshFileTree()
        }
        
        return "Created file: \(path)"
    }
    
    private func getCurrentFile() -> String {
        guard let tab = editorCore?.activeTab else {
            return "No file is currently open"
        }
        
        return """
        File: \(tab.fileName)
        Language: \(tab.language.displayName)
        Lines: \(tab.lineCount)
        Unsaved: \(tab.isUnsaved)
        
        Content:
        ```\(tab.language.rawValue)
        \(tab.content)
        ```
        """
    }
    
    private func getOpenTabs() -> String {
        guard let tabs = editorCore?.tabs, !tabs.isEmpty else {
            return "No tabs are open"
        }
        
        let activeId = editorCore?.activeTabId
        let tabList = tabs.map { tab in
            let active = tab.id == activeId ? "→ " : "  "
            let unsaved = tab.isUnsaved ? " ●" : ""
            return "\(active)\(tab.fileName) [\(tab.language.displayName)]\(unsaved)"
        }.joined(separator: "\n")
        
        return tabList
    }
    
    private func getWorkspaceInfo() -> String {
        guard let rootURL = fileNavigator?.rootURL else {
            return "No workspace is open. Ask the user to open a folder first."
        }
        
        // Count files
        var fileCount = 0
        var folderCount = 0
        if let enumerator = FileManager.default.enumerator(at: rootURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) {
            while let url = enumerator.nextObject() as? URL {
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if isDir { folderCount += 1 } else { fileCount += 1 }
            }
        }
        
        return """
        Workspace: \(rootURL.lastPathComponent)
        Path: \(rootURL.path)
        Files: \(fileCount)
        Folders: \(folderCount)
        """
    }
    
    @MainActor
    private func insertCode(code: String) async -> String {
        guard let editorCore = editorCore,
              let index = editorCore.activeTabIndex else {
            return "Error: No active file to insert code into"
        }
        
        let content = editorCore.tabs[index].content
        let lines = content.components(separatedBy: "\n")
        let cursorLine = min(editorCore.cursorPosition.line, lines.count)
        
        var newLines = lines
        if cursorLine < newLines.count {
            newLines.insert(code, at: cursorLine)
        } else {
            newLines.append(code)
        }
        
        editorCore.tabs[index].content = newLines.joined(separator: "\n")
        editorCore.tabs[index].isUnsaved = true
        
        return "Inserted \(code.components(separatedBy: "\n").count) lines at line \(cursorLine)"
    }
    
    @MainActor
    private func replaceSelection(content: String) async -> String {
        guard let editorCore = editorCore,
              let index = editorCore.activeTabIndex,
              let range = editorCore.currentSelectionRange else {
            return "Error: No text selected"
        }
        
        let originalContent = editorCore.tabs[index].content
        guard let swiftRange = Range(range, in: originalContent) else {
            return "Error: Invalid selection range"
        }
        
        let newContent = originalContent.replacingCharacters(in: swiftRange, with: content)
        editorCore.tabs[index].content = newContent
        editorCore.tabs[index].isUnsaved = true
        
        return "Replaced \(range.length) characters with \(content.count) characters"
    }
}

// MARK: - Tool Errors

enum ToolError: LocalizedError {
    case noWorkspace
    case fileNotFound(String)
    case permissionDenied(String)
    case invalidPath(String)
    
    var errorDescription: String? {
        switch self {
        case .noWorkspace:
            return "No workspace is open. Please open a folder first."
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        }
    }
}
