//
//  TunnelLSPProxy.swift
//  VSCodeiPadOS
//
//  LSP (Language Server Protocol) proxy over the tunnel WebSocket.
//  Forwards JSON-RPC 2.0 messages to remote language servers for
//  completions, hover, diagnostics, definitions, references, etc.
//

import Foundation
import Combine
import os

// MARK: - LSP Types

struct LSPPosition: Codable, Equatable, Hashable {
    let line: Int
    let character: Int
}

struct LSPRange: Codable, Equatable {
    let start: LSPPosition
    let end: LSPPosition
}

struct LSPLocation: Codable, Equatable, Identifiable {
    var id: String { "\(uri):\(range.start.line):\(range.start.character)" }
    let uri: String
    let range: LSPRange
}

struct LSPTextEdit: Codable {
    let range: LSPRange
    let newText: String
}

// MARK: - Diagnostics

enum LSPDiagnosticSeverity: Int, Codable {
    case error = 1
    case warning = 2
    case information = 3
    case hint = 4
    
    var icon: String {
        switch self {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .information: return "info.circle.fill"
        case .hint: return "lightbulb.fill"
        }
    }
}

struct LSPDiagnostic: Codable, Identifiable, Equatable {
    var id: String { "\(range.start.line):\(range.start.character):\(message.prefix(50))" }
    let range: LSPRange
    let severity: LSPDiagnosticSeverity?
    let code: LSPDiagnosticCode?
    let source: String?
    let message: String
    let relatedInformation: [LSPDiagnosticRelatedInfo]?
    
    static func == (lhs: LSPDiagnostic, rhs: LSPDiagnostic) -> Bool {
        lhs.id == rhs.id
    }
}

enum LSPDiagnosticCode: Codable, Equatable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            self = .string("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let v): try container.encode(v)
        case .string(let v): try container.encode(v)
        }
    }
}

struct LSPDiagnosticRelatedInfo: Codable, Equatable {
    let location: LSPLocation
    let message: String
}

// MARK: - Completion

enum LSPCompletionItemKind: Int, Codable {
    case text = 1, method, function, constructor, field, variable
    case classKind = 7, interface, module, property, unit, value
    case enumKind = 13, keyword, snippet, color, file, reference
    case folder = 19, enumMember, constant, structKind, event, `operator`
    case typeParameter = 25
    
    var icon: String {
        switch self {
        case .method, .function: return "f.square"
        case .variable, .field, .property: return "v.square"
        case .classKind, .structKind, .interface: return "c.square"
        case .enumKind, .enumMember: return "e.square"
        case .keyword: return "k.square"
        case .snippet: return "curlybraces.square"
        case .constant: return "number.square"
        case .module: return "m.square"
        case .typeParameter: return "t.square"
        default: return "doc.text"
        }
    }
}

enum LSPInsertTextFormat: Int, Codable {
    case plainText = 1
    case snippet = 2
}

struct LSPCompletionItem: Codable, Identifiable, Equatable {
    var id: String { "\(label):\(sortText ?? "")" }
    let label: String
    let kind: LSPCompletionItemKind?
    let detail: String?
    let documentation: LSPDocumentation?
    let deprecated: Bool?
    let preselect: Bool?
    let sortText: String?
    let filterText: String?
    let insertText: String?
    let insertTextFormat: LSPInsertTextFormat?
    let textEdit: LSPTextEdit?
    let additionalTextEdits: [LSPTextEdit]?
    
    static func == (lhs: LSPCompletionItem, rhs: LSPCompletionItem) -> Bool {
        lhs.id == rhs.id
    }
}

enum LSPDocumentation: Codable, Equatable {
    case string(String)
    case markup(LSPMarkupContent)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let markup = try? container.decode(LSPMarkupContent.self) {
            self = .markup(markup)
        } else {
            self = .string("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .markup(let m): try container.encode(m)
        }
    }
    
    var plainText: String {
        switch self {
        case .string(let s): return s
        case .markup(let m): return m.value
        }
    }
}

struct LSPMarkupContent: Codable, Equatable {
    let kind: String  // "plaintext" or "markdown"
    let value: String
}

struct LSPCompletionList: Codable {
    let isIncomplete: Bool
    let items: [LSPCompletionItem]
}

// MARK: - Hover

struct LSPHoverResult: Codable {
    let contents: LSPDocumentation
    let range: LSPRange?
}

// MARK: - Signature Help

struct LSPSignatureHelp: Codable {
    let signatures: [LSPSignatureInformation]
    let activeSignature: Int?
    let activeParameter: Int?
}

struct LSPSignatureInformation: Codable {
    let label: String
    let documentation: LSPDocumentation?
    let parameters: [LSPParameterInformation]?
}

struct LSPParameterInformation: Codable {
    let label: LSPParameterLabel
    let documentation: LSPDocumentation?
}

enum LSPParameterLabel: Codable {
    case string(String)
    case offsets(Int, Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let arr = try? container.decode([Int].self), arr.count == 2 {
            self = .offsets(arr[0], arr[1])
        } else {
            self = .string("")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let s): try container.encode(s)
        case .offsets(let a, let b): try container.encode([a, b])
        }
    }
}

// MARK: - Code Actions

struct LSPCodeAction: Codable, Identifiable {
    var id: String { title }
    let title: String
    let kind: String?
    let diagnostics: [LSPDiagnostic]?
    let isPreferred: Bool?
    let edit: LSPWorkspaceEdit?
}

struct LSPWorkspaceEdit: Codable {
    let changes: [String: [LSPTextEdit]]?  // uri -> edits
}

// MARK: - Formatting

struct LSPFormattingOptions: Codable {
    let tabSize: Int
    let insertSpaces: Bool
    let trimTrailingWhitespace: Bool?
    let insertFinalNewline: Bool?
    let trimFinalNewlines: Bool?
}

// MARK: - Server Capabilities

struct LSPServerCapabilities: Codable {
    let completionProvider: LSPCompletionOptions?
    let hoverProvider: Bool?
    let signatureHelpProvider: LSPSignatureHelpOptions?
    let definitionProvider: Bool?
    let referencesProvider: Bool?
    let documentFormattingProvider: Bool?
    let codeActionProvider: Bool?
    let documentSymbolProvider: Bool?
    let renameProvider: Bool?
    let diagnosticProvider: LSPDiagnosticOptions?
    
    var supportsCompletion: Bool { completionProvider != nil }
    var supportsHover: Bool { hoverProvider ?? false }
    var supportsDefinition: Bool { definitionProvider ?? false }
    var supportsReferences: Bool { referencesProvider ?? false }
    var supportsFormatting: Bool { documentFormattingProvider ?? false }
}

struct LSPCompletionOptions: Codable {
    let triggerCharacters: [String]?
    let resolveProvider: Bool?
}

struct LSPSignatureHelpOptions: Codable {
    let triggerCharacters: [String]?
    let retriggerCharacters: [String]?
}

struct LSPDiagnosticOptions: Codable {
    let interFileDependencies: Bool?
    let workspaceDiagnostics: Bool?
}

// MARK: - Document Sync

struct LSPTextDocumentContentChange: Codable {
    let range: LSPRange?
    let rangeLength: Int?
    let text: String
}

// MARK: - JSON-RPC 2.0

private struct JSONRPCRequest: Codable {
    let jsonrpc: String = "2.0"
    let id: Int?
    let method: String
    let params: [String: AnyCodable]?
}

private struct JSONRPCResponse: Codable {
    let jsonrpc: String
    let id: Int?
    let result: AnyCodable?
    let error: JSONRPCError?
}

private struct JSONRPCError: Codable {
    let code: Int
    let message: String
    let data: AnyCodable?
}

// MARK: - LSP Errors

enum LSPError: Error, LocalizedError {
    case notInitialized
    case serverError(Int, String)
    case requestFailed(String)
    case timeout(String)
    case invalidResponse(String)
    case tunnelDisconnected
    case languageNotSupported(String)
    
    var errorDescription: String? {
        switch self {
        case .notInitialized: return "LSP server not initialized"
        case .serverError(let code, let msg): return "LSP server error \(code): \(msg)"
        case .requestFailed(let msg): return "LSP request failed: \(msg)"
        case .timeout(let method): return "LSP request timed out: \(method)"
        case .invalidResponse(let msg): return "Invalid LSP response: \(msg)"
        case .tunnelDisconnected: return "Tunnel disconnected"
        case .languageNotSupported(let lang): return "Language not supported: \(lang)"
        }
    }
}

// MARK: - LSP Server Instance

/// Represents a connection to a single language server
private class LSPServerConnection {
    let languageId: String
    var capabilities: LSPServerCapabilities?
    var isInitialized: Bool = false
    var openDocuments: Set<String> = []  // Set of open document URIs
    var documentVersions: [String: Int] = []
    
    init(languageId: String) {
        self.languageId = languageId
    }
}

// MARK: - Tunnel LSP Proxy

@MainActor
final class TunnelLSPProxy: ObservableObject {
    static let shared = TunnelLSPProxy()
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "TunnelLSP")
    
    // MARK: - Published State
    
    @Published var isInitialized: Bool = false
    @Published var diagnostics: [String: [LSPDiagnostic]] = [:]  // uri -> diagnostics
    @Published var activeLSPServers: [String] = []  // language IDs with active servers
    @Published var lastError: String?
    
    // MARK: - Private State
    
    private let webSocket: TunnelWebSocketClient
    private var requestId: Int = 0
    private var pendingRequests: [Int: CheckedContinuation<AnyCodable?, Error>] = [:]
    private var servers: [String: LSPServerConnection] = [:]  // languageId -> connection
    private var notificationTask: Task<Void, Never>?
    
    // Caching
    private var completionCache: [String: (items: [LSPCompletionItem], timestamp: Date)] = [:]
    private var hoverCache: [String: (result: LSPHoverResult, timestamp: Date)] = [:]
    private let cacheTTL: TimeInterval = 5  // 5 seconds
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    // MARK: - Init
    
    private init(webSocket: TunnelWebSocketClient = .shared) {
        self.webSocket = webSocket
        // Register this proxy as the LSP formatting provider for CodeFormatter
        CodeFormatter.shared.registerLSPProvider { [weak self] uri, languageId, tabSize, insertSpaces in
            guard let self = self else {
                throw NSError(domain: "CodeFormatter", code: -1, userInfo: [NSLocalizedDescriptionKey: "LSP proxy released"])
            }
            guard self.isInitialized, self.activeLSPServers.contains(languageId) else {
                return []  // No active server for this language
            }
            let options = LSPFormattingOptions(
                tabSize: tabSize,
                insertSpaces: insertSpaces,
                trimTrailingWhitespace: nil,
                insertFinalNewline: nil,
                trimFinalNewlines: nil
            )
            let edits = try await self.formatting(uri: uri, languageId: languageId, options: options)
            return edits.map { FormatterTextEdit(
                rangeStartLine: $0.range.start.line,
                rangeStartChar: $0.range.start.character,
                rangeEndLine: $0.range.end.line,
                rangeEndChar: $0.range.end.character,
                newText: $0.newText
            ) }
        }
        startListeningForNotifications()
    }
    
    // MARK: - Server Lifecycle
    
    /// Initialize an LSP server for a language
    func initialize(
        languageId: String,
        rootUri: String,
        workspaceFolders: [String] = []
    ) async throws -> LSPServerCapabilities {
        Self.logger.info("Initializing LSP for \(languageId) at \(rootUri)")
        
        let params: [String: AnyCodable] = [
            "processId": AnyCodable(NSNull()),
            "rootUri": AnyCodable(rootUri),
            "capabilities": AnyCodable([
                "textDocument": AnyCodable([
                    "completion": AnyCodable([
                        "completionItem": AnyCodable([
                            "snippetSupport": AnyCodable(true),
                            "documentationFormat": AnyCodable(["markdown", "plaintext"])
                        ])
                    ]),
                    "hover": AnyCodable([
                        "contentFormat": AnyCodable(["markdown", "plaintext"])
                    ]),
                    "signatureHelp": AnyCodable([
                        "signatureInformation": AnyCodable([
                            "documentationFormat": AnyCodable(["markdown", "plaintext"])
                        ])
                    ]),
                    "synchronization": AnyCodable([
                        "didSave": AnyCodable(true),
                        "willSave": AnyCodable(false)
                    ]),
                    "codeAction": AnyCodable([
                        "codeActionLiteralSupport": AnyCodable([
                            "codeActionKind": AnyCodable([
                                "valueSet": AnyCodable(["quickfix", "refactor", "source"])
                            ])
                        ])
                    ])
                ]),
                "workspace": AnyCodable([
                    "workspaceFolders": AnyCodable(true)
                ])
            ]),
            "workspaceFolders": AnyCodable(
                workspaceFolders.isEmpty
                    ? [AnyCodable(["uri": AnyCodable(rootUri), "name": AnyCodable("workspace")])]
                    : workspaceFolders.map { AnyCodable(["uri": AnyCodable($0), "name": AnyCodable($0)]) }
            ),
            "languageId": AnyCodable(languageId)
        ]
        
        let result = try await sendRequest("initialize", params: params, languageId: languageId)
        
        // Parse capabilities
        let resultData = try encoder.encode(result)
        let initResult = try decoder.decode(LSPInitializeResult.self, from: resultData)
        
        // Send initialized notification
        sendNotification("initialized", params: [:], languageId: languageId)
        
        let server = LSPServerConnection(languageId: languageId)
        server.capabilities = initResult.capabilities
        server.isInitialized = true
        servers[languageId] = server
        
        activeLSPServers = Array(servers.keys)
        isInitialized = true
        
        Self.logger.info("LSP initialized for \(languageId)")
        return initResult.capabilities
    }
    
    /// Shutdown an LSP server
    func shutdown(languageId: String) async throws {
        Self.logger.info("Shutting down LSP for \(languageId)")
        
        let _ = try await sendRequest("shutdown", params: [:], languageId: languageId)
        sendNotification("exit", params: [:], languageId: languageId)
        
        servers.removeValue(forKey: languageId)
        activeLSPServers = Array(servers.keys)
        
        if servers.isEmpty {
            isInitialized = false
        }
    }
    
    // MARK: - Document Synchronization
    
    func didOpen(uri: String, languageId: String, version: Int, text: String) {
        guard let server = servers[languageId] else { return }
        
        server.openDocuments.insert(uri)
        server.documentVersions[uri] = version
        
        sendNotification("textDocument/didOpen", params: [
            "textDocument": AnyCodable([
                "uri": AnyCodable(uri),
                "languageId": AnyCodable(languageId),
                "version": AnyCodable(version),
                "text": AnyCodable(text)
            ])
        ], languageId: languageId)
    }
    
    func didChange(
        uri: String,
        languageId: String,
        version: Int,
        changes: [LSPTextDocumentContentChange]
    ) {
        guard let server = servers[languageId] else { return }
        server.documentVersions[uri] = version
        
        // Invalidate caches for this document
        invalidateCaches(for: uri)
        
        let changesArray = changes.map { change -> AnyCodable in
            var dict: [String: AnyCodable] = ["text": AnyCodable(change.text)]
            if let range = change.range {
                dict["range"] = AnyCodable([
                    "start": AnyCodable(["line": AnyCodable(range.start.line), "character": AnyCodable(range.start.character)]),
                    "end": AnyCodable(["line": AnyCodable(range.end.line), "character": AnyCodable(range.end.character)])
                ])
            }
            return AnyCodable(dict)
        }
        
        sendNotification("textDocument/didChange", params: [
            "textDocument": AnyCodable([
                "uri": AnyCodable(uri),
                "version": AnyCodable(version)
            ]),
            "contentChanges": AnyCodable(changesArray)
        ], languageId: languageId)
    }
    
    func didSave(uri: String, languageId: String, text: String?) {
        var params: [String: AnyCodable] = [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)])
        ]
        if let text = text {
            params["text"] = AnyCodable(text)
        }
        
        sendNotification("textDocument/didSave", params: params, languageId: languageId)
    }
    
    func didClose(uri: String, languageId: String) {
        servers[languageId]?.openDocuments.remove(uri)
        servers[languageId]?.documentVersions.removeValue(forKey: uri)
        
        sendNotification("textDocument/didClose", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)])
        ], languageId: languageId)
        
        // Clean up caches
        invalidateCaches(for: uri)
        diagnostics.removeValue(forKey: uri)
    }
    
    // MARK: - Language Features
    
    /// Get completions at a position
    func completion(
        uri: String,
        position: LSPPosition,
        languageId: String
    ) async throws -> [LSPCompletionItem] {
        // Check cache
        let cacheKey = "\(uri):\(position.line):\(position.character)"
        if let cached = completionCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.items
        }
        
        let result = try await sendRequest("textDocument/completion", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)])
        ], languageId: languageId)
        
        let resultData = try encoder.encode(result)
        
        // Response can be CompletionItem[] or CompletionList
        let items: [LSPCompletionItem]
        if let list = try? decoder.decode(LSPCompletionList.self, from: resultData) {
            items = list.items
        } else if let arr = try? decoder.decode([LSPCompletionItem].self, from: resultData) {
            items = arr
        } else {
            items = []
        }
        
        completionCache[cacheKey] = (items, Date())
        return items
    }
    
    /// Get hover information
    func hover(
        uri: String,
        position: LSPPosition,
        languageId: String
    ) async throws -> LSPHoverResult? {
        let cacheKey = "\(uri):\(position.line):\(position.character):hover"
        if let cached = hoverCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.result
        }
        
        let result = try await sendRequest("textDocument/hover", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)])
        ], languageId: languageId)
        
        guard let result = result else { return nil }
        
        let resultData = try encoder.encode(result)
        let hover = try decoder.decode(LSPHoverResult.self, from: resultData)
        
        hoverCache[cacheKey] = (hover, Date())
        return hover
    }
    
    /// Go to definition
    func definition(
        uri: String,
        position: LSPPosition,
        languageId: String
    ) async throws -> [LSPLocation] {
        let result = try await sendRequest("textDocument/definition", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)])
        ], languageId: languageId)
        
        guard let result = result else { return [] }
        
        let resultData = try encoder.encode(result)
        
        // Response can be Location, Location[], or LocationLink[]
        if let location = try? decoder.decode(LSPLocation.self, from: resultData) {
            return [location]
        } else if let locations = try? decoder.decode([LSPLocation].self, from: resultData) {
            return locations
        }
        return []
    }
    
    /// Find references
    func references(
        uri: String,
        position: LSPPosition,
        languageId: String,
        includeDeclaration: Bool = true
    ) async throws -> [LSPLocation] {
        let result = try await sendRequest("textDocument/references", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)]),
            "context": AnyCodable(["includeDeclaration": AnyCodable(includeDeclaration)])
        ], languageId: languageId)
        
        guard let result = result else { return [] }
        
        let resultData = try encoder.encode(result)
        return (try? decoder.decode([LSPLocation].self, from: resultData)) ?? []
    }
    
    /// Format document
    func formatting(
        uri: String,
        languageId: String,
        options: LSPFormattingOptions
    ) async throws -> [LSPTextEdit] {
        let result = try await sendRequest("textDocument/formatting", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "options": AnyCodable([
                "tabSize": AnyCodable(options.tabSize),
                "insertSpaces": AnyCodable(options.insertSpaces)
            ])
        ], languageId: languageId)
        
        guard let result = result else { return [] }
        
        let resultData = try encoder.encode(result)
        return (try? decoder.decode([LSPTextEdit].self, from: resultData)) ?? []
    }
    
    /// Get code actions
    func codeAction(
        uri: String,
        range: LSPRange,
        languageId: String,
        diagnostics: [LSPDiagnostic] = []
    ) async throws -> [LSPCodeAction] {
        let diagData = try encoder.encode(diagnostics)
        let diagCodable = try decoder.decode([AnyCodable].self, from: diagData)
        
        let result = try await sendRequest("textDocument/codeAction", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "range": AnyCodable([
                "start": AnyCodable(["line": AnyCodable(range.start.line), "character": AnyCodable(range.start.character)]),
                "end": AnyCodable(["line": AnyCodable(range.end.line), "character": AnyCodable(range.end.character)])
            ]),
            "context": AnyCodable(["diagnostics": AnyCodable(diagCodable)])
        ], languageId: languageId)
        
        guard let result = result else { return [] }
        
        let resultData = try encoder.encode(result)
        return (try? decoder.decode([LSPCodeAction].self, from: resultData)) ?? []
    }
    
    /// Signature help
    func signatureHelp(
        uri: String,
        position: LSPPosition,
        languageId: String
    ) async throws -> LSPSignatureHelp? {
        let result = try await sendRequest("textDocument/signatureHelp", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)])
        ], languageId: languageId)
        
        guard let result = result else { return nil }
        
        let resultData = try encoder.encode(result)
        return try? decoder.decode(LSPSignatureHelp.self, from: resultData)
    }
    
    /// Rename symbol
    func rename(
        uri: String,
        position: LSPPosition,
        languageId: String,
        newName: String
    ) async throws -> LSPWorkspaceEdit? {
        let result = try await sendRequest("textDocument/rename", params: [
            "textDocument": AnyCodable(["uri": AnyCodable(uri)]),
            "position": AnyCodable(["line": AnyCodable(position.line), "character": AnyCodable(position.character)]),
            "newName": AnyCodable(newName)
        ], languageId: languageId)
        guard let result = result else { return nil }
        let resultData = try encoder.encode(result)
        return try? decoder.decode(LSPWorkspaceEdit.self, from: resultData)
    }
    
    // MARK: - JSON-RPC Transport
    
    private func sendRequest(
        _ method: String,
        params: [String: AnyCodable],
        languageId: String,
        timeout: TimeInterval = 30
    ) async throws -> AnyCodable? {
        requestId += 1
        let id = requestId
        
        var fullParams = params
        fullParams["_languageId"] = AnyCodable(languageId)
        
        let rpcRequest = JSONRPCRequest(id: id, method: method, params: fullParams)
        let requestData = try encoder.encode(rpcRequest)
        
        let message = TunnelMessage(
            type: .lspRequest,
            channel: "lsp.\(languageId)",
            payload: [
                "jsonrpc": AnyCodable(requestData.base64EncodedString())
            ]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            pendingRequests[id] = continuation
            
            Task {
                do {
                    try await webSocket.send(message)
                } catch {
                    pendingRequests.removeValue(forKey: id)
                    continuation.resume(throwing: LSPError.requestFailed(error.localizedDescription))
                    return
                }
                
                // Timeout
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if let pending = pendingRequests.removeValue(forKey: id) {
                    pending.resume(throwing: LSPError.timeout(method))
                }
            }
        }
    }
    
    private func sendNotification(
        _ method: String,
        params: [String: AnyCodable],
        languageId: String
    ) {
        var fullParams = params
        fullParams["_languageId"] = AnyCodable(languageId)
        
        let rpcRequest = JSONRPCRequest(id: nil, method: method, params: fullParams)
        
        Task {
            do {
                let requestData = try encoder.encode(rpcRequest)
                let message = TunnelMessage(
                    type: .lspRequest,
                    channel: "lsp.\(languageId)",
                    payload: [
                        "jsonrpc": AnyCodable(requestData.base64EncodedString())
                    ]
                )
                try await webSocket.send(message)
            } catch {
                Self.logger.warning("Failed to send LSP notification \(method): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Handling
    
    private func startListeningForNotifications() {
        notificationTask = Task { [weak self] in
            guard let self = self else { return }
            let stream = await self.webSocket.subscribe(to: .lspResponse)
            
            for await message in stream {
                await self.handleLSPMessage(message)
            }
        }
    }
    
    private func handleLSPMessage(_ message: TunnelMessage) {
        guard let jsonrpcBase64 = message.payload["jsonrpc"]?.stringValue,
              let jsonrpcData = Data(base64Encoded: jsonrpcBase64) else {
            return
        }
        
        // Try to decode as response (has id)
        if let response = try? decoder.decode(JSONRPCResponse.self, from: jsonrpcData) {
            if let id = response.id, let continuation = pendingRequests.removeValue(forKey: id) {
                if let error = response.error {
                    continuation.resume(throwing: LSPError.serverError(error.code, error.message))
                } else {
                    continuation.resume(returning: response.result)
                }
            }
            return
        }
        
        // Try to decode as notification (no id)
        if let notification = try? decoder.decode(JSONRPCRequest.self, from: jsonrpcData) {
            handleNotification(notification)
        }
    }
    
    private func handleNotification(_ notification: JSONRPCRequest) {
        switch notification.method {
        case "textDocument/publishDiagnostics":
            handleDiagnosticsNotification(notification.params)
            
        case "window/logMessage", "window/showMessage":
            if let message = notification.params?["message"]?.stringValue {
                Self.logger.info("LSP: \(message)")
            }
            
        default:
            Self.logger.debug("Unhandled LSP notification: \(notification.method)")
        }
    }
    
    private func handleDiagnosticsNotification(_ params: [String: AnyCodable]?) {
        guard let uri = params?["uri"]?.stringValue else { return }
        
        do {
            let diagsData = try encoder.encode(params?["diagnostics"])
            let diags = try decoder.decode([LSPDiagnostic].self, from: diagsData)
            diagnostics[uri] = diags
        } catch {
            Self.logger.warning("Failed to parse diagnostics for \(uri): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Management
    
    private func invalidateCaches(for uri: String) {
        completionCache = completionCache.filter { !$0.key.hasPrefix(uri) }
        hoverCache = hoverCache.filter { !$0.key.hasPrefix(uri) }
    }
    
    func clearAllCaches() {
        completionCache.removeAll()
        hoverCache.removeAll()
    }
}

// MARK: - Helper Types

private struct LSPInitializeResult: Codable {
    let capabilities: LSPServerCapabilities
}
