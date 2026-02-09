import Foundation
import SwiftUI

// MARK: - Launch Config Model

enum LaunchRequest: String, Codable, CaseIterable {
    case launch
    case attach
}

struct LaunchConfig: Identifiable, Codable, Hashable {
    var id: UUID = UUID()

    var name: String
    var type: String
    var request: LaunchRequest

    /// Path to the program/script/executable.
    /// - For Swift: could be a built product or a swift script.
    /// - For Node: typically a .js file.
    /// - For Python: typically a .py file.
    var program: String?

    /// Arguments passed to the program.
    var args: [String]?

    /// Environment variables.
    var env: [String: String]?

    /// Working directory.
    var cwd: String?

    enum CodingKeys: String, CodingKey {
        case name, type, request, program, args, env, cwd
    }

    init(
        id: UUID = UUID(),
        name: String,
        type: String,
        request: LaunchRequest,
        program: String? = nil,
        args: [String]? = nil,
        env: [String: String]? = nil,
        cwd: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.request = request
        self.program = program
        self.args = args
        self.env = env
        self.cwd = cwd
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
        self.request = try container.decode(LaunchRequest.self, forKey: .request)
        self.program = try container.decodeIfPresent(String.self, forKey: .program)
        self.args = try container.decodeIfPresent([String].self, forKey: .args)
        self.env = try container.decodeIfPresent([String: String].self, forKey: .env)
        self.cwd = try container.decodeIfPresent(String.self, forKey: .cwd)
    }
}

extension LaunchConfig {
    static var builtInTemplates: [LaunchConfig] {
        [
            LaunchConfig(
                name: "Swift: Launch",
                type: "swift",
                request: .launch,
                program: "${workspaceFolder}/.build/debug/App",
                args: [],
                env: [:],
                cwd: "${workspaceFolder}"
            ),
            LaunchConfig(
                name: "Node.js: Launch Program",
                type: "node",
                request: .launch,
                program: "${workspaceFolder}/index.js",
                args: [],
                env: [:],
                cwd: "${workspaceFolder}"
            ),
            LaunchConfig(
                name: "Python: Current File",
                type: "python",
                request: .launch,
                program: "${file}",
                args: [],
                env: [:],
                cwd: "${workspaceFolder}"
            )
        ]
    }
}

// MARK: - Launch JSON Container

private struct LaunchJSON: Codable {
    var version: String?
    var configurations: [LaunchConfig]
}

// MARK: - Launch Manager

@MainActor
final class LaunchManager: ObservableObject {
    static let shared = LaunchManager()

    @Published private(set) var configs: [LaunchConfig] = LaunchConfig.builtInTemplates
    @Published var activeConfigId: LaunchConfig.ID?

    /// Workspace root used to resolve `.vscode/launch.json`.
    @Published private(set) var workspaceRootURL: URL?

    @Published var lastErrorMessage: String?

    private let activeConfigNameKey = "launch.activeConfigName"

    var activeConfig: LaunchConfig? {
        guard let activeConfigId else { return nil }
        return configs.first { $0.id == activeConfigId }
    }

    private init() {
        // default active config
        if let first = configs.first {
            activeConfigId = first.id
        }
    }

    // MARK: Workspace

    func setWorkspaceRoot(_ url: URL?) {
        workspaceRootURL = url
        reload()
    }

    // MARK: Load / Reload

    func reload() {
        lastErrorMessage = nil

        guard let workspaceRootURL else {
            // No workspace: keep templates.
            if configs.isEmpty {
                configs = LaunchConfig.builtInTemplates
            }
            ensureActiveConfigValid()
            return
        }

        let launchURL = workspaceRootURL
            .appendingPathComponent(".vscode", isDirectory: true)
            .appendingPathComponent("launch.json", isDirectory: false)

        do {
            let data = try Data(contentsOf: launchURL)
            let raw = String(decoding: data, as: UTF8.self)
            let stripped = Self.stripJSONComments(raw)
            let decoded = try JSONDecoder().decode(LaunchJSON.self, from: Data(stripped.utf8))
            configs = decoded.configurations
            ensureActiveConfigValid(preferName: UserDefaults.standard.string(forKey: activeConfigNameKey))
        } catch {
            // Fall back to templates if the file doesn't exist or can't be read.
            configs = LaunchConfig.builtInTemplates
            ensureActiveConfigValid()
            lastErrorMessage = "Couldn’t load .vscode/launch.json"
        }
    }

    private func ensureActiveConfigValid(preferName: String? = nil) {
        if let preferName,
           let match = configs.first(where: { $0.name == preferName }) {
            activeConfigId = match.id
            return
        }

        if let activeConfigId, configs.contains(where: { $0.id == activeConfigId }) {
            return
        }

        activeConfigId = configs.first?.id

        if let active = activeConfig {
            UserDefaults.standard.set(active.name, forKey: activeConfigNameKey)
        }
    }

    func setActiveConfig(_ config: LaunchConfig) {
        activeConfigId = config.id
        UserDefaults.standard.set(config.name, forKey: activeConfigNameKey)
    }

    func addTemplate(_ template: LaunchConfig) {
        configs.append(template)
        setActiveConfig(template)
    }

    // MARK: - Editing

    func updateConfig(_ config: LaunchConfig) {
        guard let idx = configs.firstIndex(where: { $0.id == config.id }) else { return }
        configs[idx] = config

        if activeConfigId == config.id {
            UserDefaults.standard.set(config.name, forKey: activeConfigNameKey)
        }
    }

    // MARK: - Debug Session

    func startActiveDebugSession() {
        guard let cfg = activeConfig else {
            lastErrorMessage = "No launch configuration selected"
            return
        }
        startDebugSession(using: cfg)
    }

    func startDebugSession(using config: LaunchConfig) {
        lastErrorMessage = nil

        switch config.request {
        case .launch:
            // NOTE: Real debug adapter integration will be implemented later.
            // For now, this wires into the existing UI-only DebugManager.
            DebugManager.shared.play()

        case .attach:
            // Not implemented yet.
            lastErrorMessage = "Attach request is not supported yet"
        }
    }

    // MARK: - JSONC helpers

    /// VS Code `launch.json` often uses JSON with comments (JSONC). This strips
    /// both `//` line comments and `/* ... */` block comments.
    private static func stripJSONComments(_ input: String) -> String {
        // Remove block comments first.
        let blockPattern = "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/"
        let linePattern = "(?m)//.*$"

        let withoutBlocks = input.replacingOccurrences(of: blockPattern, with: "", options: .regularExpression)
        let withoutLines = withoutBlocks.replacingOccurrences(of: linePattern, with: "", options: .regularExpression)
        return withoutLines
    }
}
