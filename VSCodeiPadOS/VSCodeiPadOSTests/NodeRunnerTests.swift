import XCTest
@testable import VSCodeiPadOS

/// Unit tests for NodeRunner class
/// Tests SSH-based Node.js operations including version detection, TypeScript compilation,
/// package.json script execution, package manager detection, ESM handling, debug flags, and error parsing
@MainActor
final class NodeRunnerTests: XCTestCase {
    
    // MARK: - Mock Types
    
    /// Mock SSHConnection for testing without actual remote connections
    class MockSSHConnection: SSHConnection {
        var commands: [String] = []
        var responses: [String: (stdout: String, stderr: String, exitCode: Int32)] = [:]
        var shouldFail = false
        var failError: Error?
        
        override init(host: String, username: String, password: String? = nil, privateKey: String? = nil) {
            super.init(host: host, username: username, password: password, privateKey: privateKey)
        }
        
        override func execute(command: String) async throws -> (stdout: String, stderr: String, exitCode: Int32) {
            commands.append(command)
            
            if shouldFail {
                throw failError ?? SSHError.commandFailed("Mock command failed")
            }
            
            if let response = responses[command] {
                return response
            }
            
            // Default response for unknown commands
            return ("", "", 0)
        }
        
        func setResponse(for command: String, stdout: String = "", stderr: String = "", exitCode: Int32 = 0) {
            responses[command] = (stdout, stderr, exitCode)
        }
    }
    
    // MARK: - Properties
    
    var mockSSH: MockSSHConnection!
    var nodeRunner: NodeRunner!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockSSH = MockSSHConnection(host: "test.local", username: "testuser")
        nodeRunner = NodeRunner(sshConnection: mockSSH)
    }
    
    override func tearDown() {
        mockSSH = nil
        nodeRunner = nil
        super.tearDown()
    }
    
    // MARK: - Test 1: Node Version Detection
    
    func testNodeVersionDetection_Success() async throws {
        // Given
        let expectedVersion = "v18.17.0"
        mockSSH.setResponse(
            for: "node --version",
            stdout: expectedVersion,
            stderr: "",
            exitCode: 0
        )
        
        // When
        let version = try await nodeRunner.detectNodeVersion()
        
        // Then
        XCTAssertEqual(version, expectedVersion)
        XCTAssertEqual(mockSSH.commands.last, "node --version")
    }
    
    func testNodeVersionDetection_NotInstalled() async {
        // Given
        mockSSH.setResponse(
            for: "node --version",
            stdout: "",
            stderr: "command not found: node",
            exitCode: 127
        )
        
        // When/Then
        do {
            _ = try await nodeRunner.detectNodeVersion()
            XCTFail("Expected error to be thrown")
        } catch NodeRunnerError.nodeNotInstalled {
            // Success
        } catch {
            XCTFail("Expected NodeRunnerError.nodeNotInstalled, got \(error)")
        }
    }
    
    func testNodeVersionDetection_MalformedVersion() async throws {
        // Given - version without 'v' prefix
        mockSSH.setResponse(
            for: "node --version",
            stdout: "18.17.0",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let version = try await nodeRunner.detectNodeVersion()
        
        // Then - should normalize to include 'v' prefix
        XCTAssertEqual(version, "v18.17.0")
    }
    
    func testNodeVersionDetection_ParseSemver() async throws {
        // Given
        mockSSH.setResponse(
            for: "node --version",
            stdout: "v20.5.1",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let versionInfo = try await nodeRunner.parseNodeVersion()
        
        // Then
        XCTAssertEqual(versionInfo.major, 20)
        XCTAssertEqual(versionInfo.minor, 5)
        XCTAssertEqual(versionInfo.patch, 1)
        XCTAssertTrue(versionInfo.supportsESM)
    }
    
    // MARK: - Test 2: TypeScript Compilation
    
    func testTypeScriptCompilation_Success() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "cd \(projectPath) && npx tsc --noEmit",
            stdout: "",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let result = try await nodeRunner.compileTypeScript(at: projectPath)
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.errors.count, 0)
        XCTAssertEqual(mockSSH.commands.last, "cd \(projectPath) && npx tsc --noEmit")
    }
    
    func testTypeScriptCompilation_WithErrors() async throws {
        // Given
        let projectPath = "/home/user/project"
        let tsErrorOutput = """
        src/index.ts(10,5): error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
        src/utils.ts(25,12): error TS2304: Cannot find name 'console'.
        """
        mockSSH.setResponse(
            for: "cd \(projectPath) && npx tsc --noEmit",
            stdout: "",
            stderr: tsErrorOutput,
            exitCode: 1
        )
        
        // When
        let result = try await nodeRunner.compileTypeScript(at: projectPath)
        
        // Then
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.errors.count, 2)
        
        let firstError = result.errors[0]
        XCTAssertEqual(firstError.file, "src/index.ts")
        XCTAssertEqual(firstError.line, 10)
        XCTAssertEqual(firstError.column, 5)
        XCTAssertEqual(firstError.code, "TS2345")
        
        let secondError = result.errors[1]
        XCTAssertEqual(secondError.file, "src/utils.ts")
        XCTAssertEqual(secondError.line, 25)
    }
    
    func testTypeScriptCompilation_GlobalTSC() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "which tsc",
            stdout: "/usr/local/bin/tsc",
            stderr: "",
            exitCode: 0
        )
        mockSSH.setResponse(
            for: "cd \(projectPath) && tsc --noEmit",
            stdout: "",
            stderr: "",
            exitCode: 0
        )
        
        // When
        _ = try await nodeRunner.compileTypeScript(at: projectPath, preferGlobal: true)
        
        // Then
        XCTAssertTrue(mockSSH.commands.contains("which tsc"))
    }
    
    func testTypeScriptCompilation_WatchMode() async throws {
        // Given
        let projectPath = "/home/user/project"
        
        // When
        let command = nodeRunner.buildTypeScriptCommand(at: projectPath, watch: true)
        
        // Then
        XCTAssertTrue(command.contains("--watch") || command.contains("-w"))
    }
    
    // MARK: - Test 3: Package.json Script Execution
    
    func testPackageScriptExecution_Success() async throws {
        // Given
        let projectPath = "/home/user/project"
        let scriptName = "build"
        mockSSH.setResponse(
            for: "cd \(projectPath) && npm run build",
            stdout: "> my-app@1.0.0 build\n> tsc\n\nBuild successful",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let result = try await nodeRunner.runPackageScript(scriptName, at: projectPath)
        
        // Then
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertTrue(result.stdout.contains("Build successful"))
    }
    
    func testPackageScriptExecution_ScriptNotFound() async {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "cd \(projectPath) && npm run nonexistent",
            stdout: "",
            stderr: "npm ERR! Missing script: nonexistent",
            exitCode: 1
        )
        
        // When/Then
        do {
            _ = try await nodeRunner.runPackageScript("nonexistent", at: projectPath)
            XCTFail("Expected error to be thrown")
        } catch NodeRunnerError.scriptNotFound(let name) {
            XCTAssertEqual(name, "nonexistent")
        } catch {
            XCTFail("Expected scriptNotFound error, got \(error)")
        }
    }
    
    func testPackageScriptExecution_WithEnvironmentVariables() async throws {
        // Given
        let projectPath = "/home/user/project"
        let envVars = ["NODE_ENV": "production", "API_KEY": "secret123"]
        
        // When
        let command = nodeRunner.buildScriptCommand(
            "start",
            at: projectPath,
            environment: envVars,
            packageManager: .npm
        )
        
        // Then
        XCTAssertTrue(command.contains("NODE_ENV=production"))
        XCTAssertTrue(command.contains("API_KEY=secret123"))
        XCTAssertTrue(command.contains("npm run start"))
    }
    
    func testPackageJsonParsing() async throws {
        // Given
        let projectPath = "/home/user/project"
        let packageJsonContent = """
        {
            "name": "test-project",
            "version": "1.0.0",
            "scripts": {
                "start": "node dist/index.js",
                "build": "tsc",
                "test": "jest",
                "dev": "nodemon src/index.ts"
            },
            "dependencies": {
                "express": "^4.18.0"
            }
        }
        """
        mockSSH.setResponse(
            for: "cat \(projectPath)/package.json",
            stdout: packageJsonContent,
            stderr: "",
            exitCode: 0
        )
        
        // When
        let packageInfo = try await nodeRunner.readPackageJson(at: projectPath)
        
        // Then
        XCTAssertEqual(packageInfo.name, "test-project")
        XCTAssertEqual(packageInfo.version, "1.0.0")
        XCTAssertEqual(packageInfo.scripts.count, 4)
        XCTAssertEqual(packageInfo.scripts["build"], "tsc")
        XCTAssertNotNil(packageInfo.dependencies?["express"])
    }
    
    // MARK: - Test 4: npm/yarn/pnpm Detection
    
    func testPackageManagerDetection_NPM() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "ls -a \(projectPath)",
            stdout: ". .. src package.json package-lock.json node_modules",
            stderr: "",
            exitCode: 0
        )
        mockSSH.setResponse(
            for: "which npm",
            stdout: "/usr/bin/npm",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let packageManager = try await nodeRunner.detectPackageManager(at: projectPath)
        
        // Then
        XCTAssertEqual(packageManager, .npm)
    }
    
    func testPackageManagerDetection_Yarn() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "ls -a \(projectPath)",
            stdout: ". .. src package.json yarn.lock node_modules",
            stderr: "",
            exitCode: 0
        )
        mockSSH.setResponse(
            for: "which yarn",
            stdout: "/usr/bin/yarn",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let packageManager = try await nodeRunner.detectPackageManager(at: projectPath)
        
        // Then
        XCTAssertEqual(packageManager, .yarn)
    }
    
    func testPackageManagerDetection_Pnpm() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "ls -a \(projectPath)",
            stdout: ". .. src package.json pnpm-lock.yaml node_modules",
            stderr: "",
            exitCode: 0
        )
        mockSSH.setResponse(
            for: "which pnpm",
            stdout: "/usr/bin/pnpm",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let packageManager = try await nodeRunner.detectPackageManager(at: projectPath)
        
        // Then
        XCTAssertEqual(packageManager, .pnpm)
    }
    
    func testPackageManagerDetection_Priority() async throws {
        // Given - multiple lock files exist, should prefer pnpm > yarn > npm
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "ls -a \(projectPath)",
            stdout: ". .. package.json yarn.lock pnpm-lock.yaml",
            stderr: "",
            exitCode: 0
        )
        mockSSH.setResponse(
            for: "which pnpm",
            stdout: "/usr/bin/pnpm",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let packageManager = try await nodeRunner.detectPackageManager(at: projectPath)
        
        // Then
        XCTAssertEqual(packageManager, .pnpm)
    }
    
    func testPackageManagerCommandGeneration() {
        // Given
        let projectPath = "/home/user/project"
        
        // Then
        XCTAssertEqual(
            nodeRunner.buildInstallCommand(at: projectPath, packageManager: .npm),
            "cd \(projectPath) && npm install"
        )
        XCTAssertEqual(
            nodeRunner.buildInstallCommand(at: projectPath, packageManager: .yarn),
            "cd \(projectPath) && yarn install"
        )
        XCTAssertEqual(
            nodeRunner.buildInstallCommand(at: projectPath, packageManager: .pnpm),
            "cd \(projectPath) && pnpm install"
        )
    }
    
    func testPackageManager_RunScriptVariations() {
        // Given
        let projectPath = "/home/user/project"
        let script = "build"
        
        // Then
        XCTAssertEqual(
            nodeRunner.buildScriptCommand(script, at: projectPath, packageManager: .npm),
            "cd \(projectPath) && npm run build"
        )
        XCTAssertEqual(
            nodeRunner.buildScriptCommand(script, at: projectPath, packageManager: .yarn),
            "cd \(projectPath) && yarn build"
        )
        XCTAssertEqual(
            nodeRunner.buildScriptCommand(script, at: projectPath, packageManager: .pnpm),
            "cd \(projectPath) && pnpm run build"
        )
    }
    
    // MARK: - Test 5: ESM Module Handling
    
    func testESMDetection_TypeModule() async throws {
        // Given
        let projectPath = "/home/user/esm-project"
        let packageJson = """
        {
            "name": "esm-project",
            "type": "module",
            "main": "index.js"
        }
        """
        mockSSH.setResponse(
            for: "cat \(projectPath)/package.json",
            stdout: packageJson,
            stderr: "",
            exitCode: 0
        )
        
        // When
        let isESM = try await nodeRunner.isESMProject(at: projectPath)
        
        // Then
        XCTAssertTrue(isESM)
    }
    
    func testESMDetection_MJSExtension() async throws {
        // Given
        let projectPath = "/home/user/esm-project"
        let packageJson = """
        {
            "name": "esm-project",
            "main": "index.mjs"
        }
        """
        mockSSH.setResponse(
            for: "cat \(projectPath)/package.json",
            stdout: packageJson,
            stderr: "",
            exitCode: 0
        )
        
        // When
        let isESM = try await nodeRunner.isESMProject(at: projectPath)
        
        // Then
        XCTAssertTrue(isESM)
    }
    
    func testESMDetection_CommonJS() async throws {
        // Given
        let projectPath = "/home/user/cjs-project"
        let packageJson = """
        {
            "name": "cjs-project",
            "type": "commonjs",
            "main": "index.js"
        }
        """
        mockSSH.setResponse(
            for: "cat \(projectPath)/package.json",
            stdout: packageJson,
            stderr: "",
            exitCode: 0
        )
        
        // When
        let isESM = try await nodeRunner.isESMProject(at: projectPath)
        
        // Then
        XCTAssertFalse(isESM)
    }
    
    func testESMExecution_FlagInjection() async throws {
        // Given
        let filePath = "/home/user/project/index.mjs"
        let nodeVersion = VersionInfo(major: 18, minor: 0, patch: 0)
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            esmMode: true,
            nodeVersion: nodeVersion
        )
        
        // Then
        // Node 18+ doesn't need --experimental-vm-modules for most ESM
        XCTAssertFalse(command.contains("--experimental-vm-modules"))
        XCTAssertTrue(command.contains("node"))
        XCTAssertTrue(command.contains(filePath))
    }
    
    func testESMExecution_LegacyNode() async throws {
        // Given - Node 12.x needs experimental flags
        let filePath = "/home/user/project/index.mjs"
        let nodeVersion = VersionInfo(major: 12, minor: 0, patch: 0)
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            esmMode: true,
            nodeVersion: nodeVersion
        )
        
        // Then
        XCTAssertTrue(command.contains("--experimental-vm-modules") || command.contains("--experimental-modules"))
    }
    
    func testESMImportMapSupport() async throws {
        // Given
        let projectPath = "/home/user/project"
        mockSSH.setResponse(
            for: "ls \(projectPath)",
            stdout: "import-map.json package.json src",
            stderr: "",
            exitCode: 0
        )
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: "\(projectPath)/src/index.js",
            esmMode: true,
            importMap: "\(projectPath)/import-map.json"
        )
        
        // Then
        XCTAssertTrue(command.contains("--import-map"))
    }
    
    // MARK: - Test 6: Debug Flag Integration
    
    func testDebugFlag_Inspector() async throws {
        // Given
        let filePath = "/home/user/project/index.js"
        let debugConfig = DebugConfiguration(
            enabled: true,
            port: 9229,
            breakOnStart: false
        )
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            debug: debugConfig
        )
        
        // Then
        XCTAssertTrue(command.contains("--inspect=9229"))
        XCTAssertFalse(command.contains("--inspect-brk"))
    }
    
    func testDebugFlag_InspectorBreak() async throws {
        // Given
        let filePath = "/home/user/project/index.js"
        let debugConfig = DebugConfiguration(
            enabled: true,
            port: 9229,
            breakOnStart: true
        )
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            debug: debugConfig
        )
        
        // Then
        XCTAssertTrue(command.contains("--inspect-brk=9229"))
    }
    
    func testDebugFlag_CustomHost() async throws {
        // Given
        let filePath = "/home/user/project/index.js"
        let debugConfig = DebugConfiguration(
            enabled: true,
            port: 9229,
            host: "0.0.0.0",
            breakOnStart: false
        )
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            debug: debugConfig
        )
        
        // Then
        XCTAssertTrue(command.contains("--inspect=0.0.0.0:9229"))
    }
    
    func testDebugFlag_Disabled() async throws {
        // Given
        let filePath = "/home/user/project/index.js"
        let debugConfig = DebugConfiguration(enabled: false)
        
        // When
        let command = nodeRunner.buildNodeCommand(
            file: filePath,
            debug: debugConfig
        )
        
        // Then
        XCTAssertFalse(command.contains("--inspect"))
        XCTAssertFalse(command.contains("--inspect-brk"))
    }
    
    func testDebugFlag_WithTypeScript() async throws {
        // Given
        let projectPath = "/home/user/project"
        let debugConfig = DebugConfiguration(
            enabled: true,
            port: 9230,
            breakOnStart: true
        )
        
        // When
        let command = nodeRunner.buildDebugCommand(
            at: projectPath,
            entryPoint: "src/index.ts",
            debug: debugConfig,
            useTSNode: true
        )
        
        // Then
        XCTAssertTrue(command.contains("--inspect-brk=9230"))
        XCTAssertTrue(command.contains("ts-node") || command.contains("tsx"))
    }
    
    // MARK: - Test 7: Error Parsing
    
    func testErrorParsing_NodeStackTrace() {
        // Given
        let stderr = """
        /home/user/project/index.js:10
            console.log(undefinedVariable);
                        ^
        
        ReferenceError: undefinedVariable is not defined
            at Object.<anonymous> (/home/user/project/index.js:10:21)
            at Module._compile (internal/modules/cjs/loader.js:1063:30)
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 1)
        let error = errors[0]
        XCTAssertEqual(error.type, .referenceError)
        XCTAssertEqual(error.message, "undefinedVariable is not defined")
        XCTAssertEqual(error.file, "/home/user/project/index.js")
        XCTAssertEqual(error.line, 10)
        XCTAssertEqual(error.column, 21)
    }
    
    func testErrorParsing_TypeScriptErrors() {
        // Given
        let stderr = """
        src/components/Button.tsx(15,23): error TS2322: Type 'string' is not assignable to type 'number'.
        src/utils/helpers.ts(42,8): error TS2307: Cannot find module './missing' or its corresponding type declarations.
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 2)
        
        let firstError = errors[0]
        XCTAssertEqual(firstError.type, .typeError)
        XCTAssertEqual(firstError.code, "TS2322")
        XCTAssertEqual(firstError.file, "src/components/Button.tsx")
        
        let secondError = errors[1]
        XCTAssertEqual(secondError.type, .moduleNotFound)
        XCTAssertEqual(secondError.code, "TS2307")
    }
    
    func testErrorParsing_SyntaxError() {
        // Given
        let stderr = """
        /home/user/project/index.js:5
        const x = {
                  ^
        
        SyntaxError: Unexpected token '}'
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 1)
        let error = errors[0]
        XCTAssertEqual(error.type, .syntaxError)
        XCTAssertEqual(error.message, "Unexpected token '}'")
        XCTAssertEqual(error.line, 5)
    }
    
    func testErrorParsing_ModuleNotFound() {
        // Given
        let stderr = """
        internal/modules/cjs/loader.js:905
          throw err;
          ^
        
        Error: Cannot find module 'express'
        Require stack:
        - /home/user/project/server.js
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 1)
        let error = errors[0]
        XCTAssertEqual(error.type, .moduleNotFound)
        XCTAssertEqual(error.message, "Cannot find module 'express'")
        XCTAssertTrue(error.suggestion?.contains("npm install") ?? false)
    }
    
    func testErrorParsing_NPMErrors() {
        // Given
        let stderr = """
        npm ERR! code E404
        npm ERR! 404 Not Found - GET https://registry.npmjs.org/nonexistent-pkg - Not found
        npm ERR! 404  'nonexistent-pkg@latest' is not in the npm registry.
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 1)
        let error = errors[0]
        XCTAssertEqual(error.type, .packageNotFound)
        XCTAssertEqual(error.code, "E404")
        XCTAssertTrue(error.message.contains("Not Found"))
    }
    
    func testErrorParsing_MultipleErrors() {
        // Given
        let stderr = """
        Error 1: First error message
        Error 2: Second error message
        Warning: This is just a warning
        """
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        // Should extract multiple errors, ignore warnings
        XCTAssertTrue(errors.count >= 1)
    }
    
    func testErrorParsing_EmptyOutput() {
        // Given
        let stderr = ""
        
        // When
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 1)
        
        // Then
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].type, .unknown)
        XCTAssertEqual(errors[0].message, "Command failed with exit code 1")
    }
    
    func testErrorParsing_SuccessExitCode() {
        // Given
        let stderr = "Some warning message"
        
        // When - exit code 0 should not produce errors even if stderr has content
        let errors = nodeRunner.parseErrors(from: stderr, exitCode: 0)
        
        // Then
        XCTAssertEqual(errors.count, 0)
    }
    
    // MARK: - Integration Tests
    
    func testFullWorkflow_BuildAndRun() async throws {
        // Given - simulate a full build and run workflow
        let projectPath = "/home/user/myapp"
        
        // Mock: Detect Node version
        mockSSH.setResponse(for: "node --version", stdout: "v18.17.0", exitCode: 0)
        
        // Mock: Detect package manager
        mockSSH.setResponse(
            for: "ls -a \(projectPath)",
            stdout: "package.json package-lock.json",
            exitCode: 0
        )
        
        // Mock: Read package.json
        mockSSH.setResponse(
            for: "cat \(projectPath)/package.json",
            stdout: """
            {"name": "myapp", "scripts": {"build": "tsc", "start": "node dist/index.js"}}
            """,
            exitCode: 0
        )
        
        // Mock: Build
        mockSSH.setResponse(
            for: "cd \(projectPath) && npm run build",
            stdout: "> myapp@1.0.0 build\n> tsc",
            exitCode: 0
        )
        
        // Mock: Run
        mockSSH.setResponse(
            for: "cd \(projectPath) && npm run start",
            stdout: "Server running on port 3000",
            exitCode: 0
        )
        
        // When - Execute workflow
        let version = try await nodeRunner.detectNodeVersion()
        let packageManager = try await nodeRunner.detectPackageManager(at: projectPath)
        let packageInfo = try await nodeRunner.readPackageJson(at: projectPath)
        let buildResult = try await nodeRunner.runPackageScript("build", at: projectPath)
        let runResult = try await nodeRunner.runPackageScript("start", at: projectPath)
        
        // Then
        XCTAssertEqual(version, "v18.17.0")
        XCTAssertEqual(packageManager, .npm)
        XCTAssertEqual(packageInfo.name, "myapp")
        XCTAssertEqual(buildResult.exitCode, 0)
        XCTAssertTrue(runResult.stdout.contains("Server running"))
    }
    
    func testSSHFailurePropagation() async {
        // Given
        mockSSH.shouldFail = true
        mockSSH.failError = SSHError.connectionFailed("Connection refused")
        
        // When/Then
        do {
            _ = try await nodeRunner.detectNodeVersion()
            XCTFail("Expected SSH error to propagate")
        } catch {
            XCTAssertTrue(error is SSHError)
        }
    }
}

// MARK: - Supporting Types (Expected from NodeRunner implementation)

enum NodeRunnerError: Error {
    case nodeNotInstalled
    case scriptNotFound(String)
    case packageJsonNotFound
    case invalidPackageJson
    case compilationFailed([NodeError])
}

enum PackageManager {
    case npm
    case yarn
    case pnpm
}

struct VersionInfo {
    let major: Int
    let minor: Int
    let patch: Int
    
    var supportsESM: Bool {
        return major >= 13 || (major == 12 && minor >= 20)
    }
}

struct DebugConfiguration {
    let enabled: Bool
    let port: Int?
    let host: String?
    let breakOnStart: Bool
    
    init(enabled: Bool, port: Int? = nil, host: String? = nil, breakOnStart: Bool = false) {
        self.enabled = enabled
        self.port = port
        self.host = host
        self.breakOnStart = breakOnStart
    }
}

struct PackageInfo {
    let name: String
    let version: String
    let scripts: [String: String]
    let dependencies: [String: String]?
    let devDependencies: [String: String]?
    let type: String?
}

enum ErrorType {
    case syntaxError
    case referenceError
    case typeError
    case moduleNotFound
    case packageNotFound
    case unknown
}

struct NodeError {
    let type: ErrorType
    let message: String
    let file: String?
    let line: Int?
    let column: Int?
    let code: String?
    let suggestion: String?
}

struct CompilationResult {
    let success: Bool
    let errors: [NodeError]
}

enum SSHError: Error {
    case connectionFailed(String)
    case commandFailed(String)
    case authenticationFailed
}

// MARK: - Expected NodeRunner Protocol/Class Interface

protocol NodeRunnerProtocol {
    func detectNodeVersion() async throws -> String
    func parseNodeVersion() async throws -> VersionInfo
    func compileTypeScript(at path: String, preferGlobal: Bool) async throws -> CompilationResult
    func buildTypeScriptCommand(at path: String, watch: Bool) -> String
    func runPackageScript(_ script: String, at path: String) async throws -> ProcessResult
    func readPackageJson(at path: String) async throws -> PackageInfo
    func detectPackageManager(at path: String) async throws -> PackageManager
    func buildInstallCommand(at path: String, packageManager: PackageManager) -> String
    func buildScriptCommand(_ script: String, at path: String, environment: [String: String]?, packageManager: PackageManager) -> String
    func isESMProject(at path: String) async throws -> Bool
    func buildNodeCommand(file: String, esmMode: Bool, nodeVersion: VersionInfo?, importMap: String?, debug: DebugConfiguration?) -> String
    func buildDebugCommand(at path: String, entryPoint: String, debug: DebugConfiguration, useTSNode: Bool) -> String
    func parseErrors(from stderr: String, exitCode: Int32) -> [NodeError]
}

struct ProcessResult {
    let stdout: String
    let stderr: String
    let exitCode: Int32
}

// Placeholder class - to be replaced by actual implementation
class NodeRunner: NodeRunnerProtocol {
    let sshConnection: SSHConnection
    
    init(sshConnection: SSHConnection) {
        self.sshConnection = sshConnection
    }
    
    func detectNodeVersion() async throws -> String { return "" }
    func parseNodeVersion() async throws -> VersionInfo { return VersionInfo(major: 0, minor: 0, patch: 0) }
    func compileTypeScript(at path: String, preferGlobal: Bool = false) async throws -> CompilationResult {
        return CompilationResult(success: false, errors: [])
    }
    func buildTypeScriptCommand(at path: String, watch: Bool) -> String { return "" }
    func runPackageScript(_ script: String, at path: String) async throws -> ProcessResult {
        return ProcessResult(stdout: "", stderr: "", exitCode: 0)
    }
    func readPackageJson(at path: String) async throws -> PackageInfo {
        return PackageInfo(name: "", version: "", scripts: [:], dependencies: nil, devDependencies: nil, type: nil)
    }
    func detectPackageManager(at path: String) async throws -> PackageManager { return .npm }
    func buildInstallCommand(at path: String, packageManager: PackageManager) -> String { return "" }
    func buildScriptCommand(_ script: String, at path: String, environment: [String: String]? = nil, packageManager: PackageManager) -> String { return "" }
    func isESMProject(at path: String) async throws -> Bool { return false }
    func buildNodeCommand(file: String, esmMode: Bool = false, nodeVersion: VersionInfo? = nil, importMap: String? = nil, debug: DebugConfiguration? = nil) -> String { return "" }
    func buildDebugCommand(at path: String, entryPoint: String, debug: DebugConfiguration, useTSNode: Bool) -> String { return "" }
    func parseErrors(from stderr: String, exitCode: Int32) -> [NodeError] { return [] }
}

// Placeholder SSHConnection base class
class SSHConnection {
    let host: String
    let username: String
    let password: String?
    let privateKey: String?
    
    init(host: String, username: String, password: String? = nil, privateKey: String? = nil) {
        self.host = host
        self.username = username
        self.password = password
        self.privateKey = privateKey
    }
    
    func execute(command: String) async throws -> (stdout: String, stderr: String, exitCode: Int32) {
        return ("", "", 0)
    }
}
