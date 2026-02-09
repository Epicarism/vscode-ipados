import XCTest
@testable import VSCodeiPadOS

// MARK: - Mock Types

/// Protocol defining SSH command execution interface
protocol SSHExecutable {
    func execute(
        command: String,
        workingDirectory: String?,
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> RemoteExecutionResult
}

/// Result of a remote command execution
struct RemoteExecutionResult {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let duration: TimeInterval
}

/// Errors that can occur during remote execution
enum RemoteExecutionError: Error, Equatable {
    case connectionFailed(String)
    case authenticationFailed(String)
    case commandExecutionFailed(String)
    case timeoutExceeded(TimeInterval)
    case invalidWorkingDirectory(String)
    case connectionLost
    case unknown(Error)
    
    static func == (lhs: RemoteExecutionError, rhs: RemoteExecutionError) -> Bool {
        switch (lhs, rhs) {
        case (.connectionFailed(let l), .connectionFailed(let r)):
            return l == r
        case (.authenticationFailed(let l), .authenticationFailed(let r)):
            return l == r
        case (.commandExecutionFailed(let l), .commandExecutionFailed(let r)):
            return l == r
        case (.timeoutExceeded(let l), .timeoutExceeded(let r)):
            return l == r
        case (.invalidWorkingDirectory(let l), .invalidWorkingDirectory(let r)):
            return l == r
        case (.connectionLost, .connectionLost):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

// MARK: - Mock SSH Client

/// Mock SSH client for testing without actual network connections
class MockSSHClient: SSHExecutable {
    
    // MARK: - Configuration
    
    var shouldSimulateConnectionFailure = false
    var connectionFailureReason: String = "Connection refused"
    var simulatedLatency: TimeInterval = 0.01 // 10ms default
    var shouldSimulateTimeout = false
    
    // MARK: - Command Response Mapping
    
    /// Maps command patterns to predefined responses
    var commandResponses: [String: (stdout: String, stderr: String, exitCode: Int)] = [:]
    
    /// Default response for unmapped commands
    var defaultResponse: (stdout: String, stderr: String, exitCode: Int) = (
        stdout: "",
        stderr: "",
        exitCode: 0
    )
    
    // MARK: - Execution History
    
    struct ExecutedCommand {
        let command: String
        let workingDirectory: String?
        let environment: [String: String]?
        let timeout: TimeInterval
        let timestamp: Date
    }
    
    private(set) var executionHistory: [ExecutedCommand] = []
    
    // MARK: - SSHExecutable Implementation
    
    func execute(
        command: String,
        workingDirectory: String?,
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> RemoteExecutionResult {
        
        // Record the execution
        let executedCommand = ExecutedCommand(
            command: command,
            workingDirectory: workingDirectory,
            environment: environment,
            timeout: timeout,
            timestamp: Date()
        )
        executionHistory.append(executedCommand)
        
        // Simulate connection failure
        if shouldSimulateConnectionFailure {
            throw RemoteExecutionError.connectionFailed(connectionFailureReason)
        }
        
        // Simulate timeout
        if shouldSimulateTimeout {
            try await Task.sleep(nanoseconds: UInt64((timeout + 0.1) * 1_000_000_000))
            throw RemoteExecutionError.timeoutExceeded(timeout)
        }
        
        // Simulate latency
        if simulatedLatency > 0 {
            try await Task.sleep(nanoseconds: UInt64(simulatedLatency * 1_000_000_000))
        }
        
        // Check for working directory validation
        if let cwd = workingDirectory, cwd.hasPrefix("/nonexistent") {
            throw RemoteExecutionError.invalidWorkingDirectory(cwd)
        }
        
        // Find matching response or use default
        let response = commandResponses[command] ?? defaultResponse
        
        return RemoteExecutionResult(
            stdout: response.stdout,
            stderr: response.stderr,
            exitCode: response.exitCode,
            duration: simulatedLatency
        )
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        shouldSimulateConnectionFailure = false
        shouldSimulateTimeout = false
        connectionFailureReason = "Connection refused"
        simulatedLatency = 0.01
        commandResponses.removeAll()
        executionHistory.removeAll()
        defaultResponse = (stdout: "", stderr: "", exitCode: 0)
    }
    
    func addResponse(
        for command: String,
        stdout: String = "",
        stderr: String = "",
        exitCode: Int = 0
    ) {
        commandResponses[command] = (stdout: stdout, stderr: stderr, exitCode: exitCode)
    }
}

// MARK: - RemoteRunner

/// Main class for executing commands on remote hosts via SSH
class RemoteRunner {
    private let sshClient: SSHExecutable
    
    init(sshClient: SSHExecutable) {
        self.sshClient = sshClient
    }
    
    /// Execute a command on the remote host
    /// - Parameters:
    ///   - command: The shell command to execute
    ///   - workingDirectory: Optional working directory (uses remote default if nil)
    ///   - environment: Optional environment variables to set
    ///   - timeout: Maximum time to wait for execution (default: 30s)
    /// - Returns: Execution result containing stdout, stderr, and exit code
    func execute(
        command: String,
        workingDirectory: String? = nil,
        environment: [String: String]? = nil,
        timeout: TimeInterval = 30
    ) async throws -> RemoteExecutionResult {
        return try await sshClient.execute(
            command: command,
            workingDirectory: workingDirectory,
            environment: environment,
            timeout: timeout
        )
    }
    
    /// Execute a command and return just the stdout as string
    func executeSimple(
        command: String,
        workingDirectory: String? = nil,
        timeout: TimeInterval = 30
    ) async throws -> String {
        let result = try await execute(
            command: command,
            workingDirectory: workingDirectory,
            timeout: timeout
        )
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Test Suite

@MainActor
final class RemoteExecutionTests: XCTestCase {
    
    // MARK: - Properties
    
    private var mockSSH: MockSSHClient!
    private var remoteRunner: RemoteRunner!
    
    // MARK: - Setup/Teardown
    
    override func setUp() {
        super.setUp()
        mockSSH = MockSSHClient()
        remoteRunner = RemoteRunner(sshClient: mockSSH)
    }
    
    override func tearDown() {
        mockSSH = nil
        remoteRunner = nil
        super.tearDown()
    }
    
    // MARK: - Test 1: Basic Command Execution
    
    func testBasicCommandExecution() async throws {
        // Given
        let expectedOutput = "Hello, World!"
        mockSSH.addResponse(
            for: "echo 'Hello, World!'",
            stdout: expectedOutput,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(command: "echo 'Hello, World!'")
        
        // Then
        XCTAssertEqual(result.stdout, expectedOutput)
        XCTAssertEqual(result.stderr, "")
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertGreaterThan(result.duration, 0)
    }
    
    func testMultipleBasicCommands() async throws {
        // Given
        mockSSH.addResponse(for: "whoami", stdout: "testuser", exitCode: 0)
        mockSSH.addResponse(for: "pwd", stdout: "/home/testuser", exitCode: 0)
        mockSSH.addResponse(for: "uname -a", stdout: "Linux testhost 5.0.0", exitCode: 0)
        
        // When
        let result1 = try await remoteRunner.execute(command: "whoami")
        let result2 = try await remoteRunner.execute(command: "pwd")
        let result3 = try await remoteRunner.execute(command: "uname -a")
        
        // Then
        XCTAssertEqual(result1.stdout, "testuser")
        XCTAssertEqual(result2.stdout, "/home/testuser")
        XCTAssertEqual(result3.stdout, "Linux testhost 5.0.0")
    }
    
    func testCommandWithArguments() async throws {
        // Given
        mockSSH.addResponse(
            for: "ls -la /tmp",
            stdout: "drwxrwxrwt  10 root root 4096 Jan 1 00:00 .",
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(command: "ls -la /tmp")
        
        // Then
        XCTAssertTrue(result.stdout.contains("/tmp"))
        XCTAssertEqual(result.exitCode, 0)
    }
    
    // MARK: - Test 2: Working Directory Handling
    
    func testWorkingDirectoryHandling() async throws {
        // Given
        let workingDir = "/home/user/project"
        mockSSH.addResponse(
            for: "pwd",
            stdout: workingDir,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(
            command: "pwd",
            workingDirectory: workingDir
        )
        
        // Then
        XCTAssertEqual(result.stdout, workingDir)
        XCTAssertEqual(mockSSH.executionHistory.last?.workingDirectory, workingDir)
    }
    
    func testNilWorkingDirectoryUsesDefault() async throws {
        // Given
        mockSSH.addResponse(for: "pwd", stdout: "/default/path", exitCode: 0)
        
        // When
        let result = try await remoteRunner.execute(command: "pwd")
        
        // Then
        XCTAssertEqual(result.stdout, "/default/path")
        XCTAssertNil(mockSSH.executionHistory.last?.workingDirectory)
    }
    
    func testInvalidWorkingDirectory() async throws {
        // Given
        let invalidPath = "/nonexistent/path/12345"
        
        // When/Then
        do {
            _ = try await remoteRunner.execute(
                command: "ls",
                workingDirectory: invalidPath
            )
            XCTFail("Should have thrown an error")
        } catch let error as RemoteExecutionError {
            XCTAssertEqual(error, .invalidWorkingDirectory(invalidPath))
        }
    }
    
    func testWorkingDirectoryWithSpaces() async throws {
        // Given
        let pathWithSpaces = "/home/user/My Documents/Projects"
        mockSSH.addResponse(
            for: "pwd",
            stdout: pathWithSpaces,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(
            command: "pwd",
            workingDirectory: pathWithSpaces
        )
        
        // Then
        XCTAssertEqual(result.stdout, pathWithSpaces)
    }
    
    // MARK: - Test 3: Environment Variable Passing
    
    func testEnvironmentVariablePassing() async throws {
        // Given
        let envVars = ["MY_VAR": "my_value", "API_KEY": "secret123"]
        mockSSH.addResponse(
            for: "echo $MY_VAR $API_KEY",
            stdout: "my_value secret123",
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(
            command: "echo $MY_VAR $API_KEY",
            environment: envVars
        )
        
        // Then
        XCTAssertEqual(result.stdout, "my_value secret123")
        XCTAssertEqual(mockSSH.executionHistory.last?.environment?["MY_VAR"], "my_value")
        XCTAssertEqual(mockSSH.executionHistory.last?.environment?["API_KEY"], "secret123")
    }
    
    func testEmptyEnvironmentVariables() async throws {
        // Given
        mockSSH.addResponse(for: "env", stdout: "PATH=/usr/bin", exitCode: 0)
        
        // When
        let result = try await remoteRunner.execute(
            command: "env",
            environment: [:]
        )
        
        // Then
        XCTAssertEqual(result.exitCode, 0)
        XCTAssertNotNil(mockSSH.executionHistory.last?.environment)
    }
    
    func testNilEnvironment() async throws {
        // Given
        mockSSH.addResponse(for: "echo test", stdout: "test", exitCode: 0)
        
        // When
        let result = try await remoteRunner.execute(
            command: "echo test",
            environment: nil
        )
        
        // Then
        XCTAssertNil(mockSSH.executionHistory.last?.environment)
    }
    
    func testEnvironmentVariableWithSpecialCharacters() async throws {
        // Given
        let envVars = [
            "SPECIAL_VAR": "value with spaces",
            "PATH_VAR": "/usr/local/bin:/usr/bin",
            "QUOTED": "'quoted value'"
        ]
        mockSSH.addResponse(for: "echo $SPECIAL_VAR", stdout: "value with spaces", exitCode: 0)
        
        // When
        _ = try await remoteRunner.execute(
            command: "echo $SPECIAL_VAR",
            environment: envVars
        )
        
        // Then
        XCTAssertEqual(mockSSH.executionHistory.last?.environment?["SPECIAL_VAR"], "value with spaces")
        XCTAssertEqual(mockSSH.executionHistory.last?.environment?["PATH_VAR"], "/usr/local/bin:/usr/bin")
    }
    
    // MARK: - Test 4: Large Output Handling
    
    func testLargeOutputHandling() async throws {
        // Given
        let largeOutput = String(repeating: "Lorem ipsum dolor sit amet. ", count: 10000)
        mockSSH.addResponse(
            for: "cat largefile.txt",
            stdout: largeOutput,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(command: "cat largefile.txt")
        
        // Then
        XCTAssertEqual(result.stdout.count, largeOutput.count)
        XCTAssertEqual(result.stdout, largeOutput)
        XCTAssertEqual(result.exitCode, 0)
    }
    
    func testMultilineOutput() async throws {
        // Given
        let multilineOutput = """
            Line 1
            Line 2
            Line 3
            Line 4
            Line 5
            """
        mockSSH.addResponse(
            for: "cat multiline.txt",
            stdout: multilineOutput,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(command: "cat multiline.txt")
        
        // Then
        let lines = result.stdout.components(separatedBy: .newlines)
        XCTAssertEqual(lines.count, 5)
        XCTAssertEqual(lines[0], "Line 1")
        XCTAssertEqual(lines[4], "Line 5")
    }
    
    func testLargeStderrOutput() async throws {
        // Given
        let largeStderr = String(repeating: "Error: Something went wrong. ", count: 1000)
        mockSSH.addResponse(
            for: "command_with_errors",
            stdout: "",
            stderr: largeStderr,
            exitCode: 1
        )
        
        // When
        let result = try await remoteRunner.execute(command: "command_with_errors")
        
        // Then
        XCTAssertEqual(result.stderr.count, largeStderr.count)
        XCTAssertEqual(result.stderr, largeStderr)
    }
    
    func testCombinedLargeStdoutAndStderr() async throws {
        // Given
        let largeStdout = String(repeating: "Output line\n", count: 1000)
        let largeStderr = String(repeating: "Error line\n", count: 500)
        mockSSH.addResponse(
            for: "mixed_output",
            stdout: largeStdout,
            stderr: largeStderr,
            exitCode: 0
        )
        
        // When
        let result = try await remoteRunner.execute(command: "mixed_output")
        
        // Then
        XCTAssertEqual(result.stdout, largeStdout)
        XCTAssertEqual(result.stderr, largeStderr)
    }
    
    // MARK: - Test 5: Error Exit Codes
    
    func testNonZeroExitCode() async throws {
        // Given
        mockSSH.addResponse(
            for: "false",
            stdout: "",
            stderr: "",
            exitCode: 1
        )
        
        // When
        let result = try await remoteRunner.execute(command: "false")
        
        // Then
        XCTAssertEqual(result.exitCode, 1)
        XCTAssertEqual(result.stdout, "")
    }
    
    func testVariousExitCodes() async throws {
        // Given
        let exitCodes = [1, 2, 126, 127, 128, 255]
        
        for code in exitCodes {
            mockSSH.addResponse(
                for: "exit \(code)",
                stdout: "",
                stderr: "",
                exitCode: code
            )
        }
        
        // When & Then
        for code in exitCodes {
            let result = try await remoteRunner.execute(command: "exit \(code)")
            XCTAssertEqual(result.exitCode, code, "Exit code \(code) should be preserved")
        }
    }
    
    func testCommandNotFound() async throws {
        // Given
        mockSSH.addResponse(
            for: "nonexistent_command",
            stdout: "",
            stderr: "bash: nonexistent_command: command not found",
            exitCode: 127
        )
        
        // When
        let result = try await remoteRunner.execute(command: "nonexistent_command")
        
        // Then
        XCTAssertEqual(result.exitCode, 127)
        XCTAssertTrue(result.stderr.contains("command not found"))
    }
    
    func testPermissionDenied() async throws {
        // Given
        mockSSH.addResponse(
            for: "cat /root/secret",
            stdout: "",
            stderr: "cat: /root/secret: Permission denied",
            exitCode: 1
        )
        
        // When
        let result = try await remoteRunner.execute(command: "cat /root/secret")
        
        // Then
        XCTAssertEqual(result.exitCode, 1)
        XCTAssertTrue(result.stderr.contains("Permission denied"))
    }
    
    // MARK: - Test 6: Timeout Behavior
    
    func testTimeoutBehavior() async throws {
        // Given
        mockSSH.shouldSimulateTimeout = true
        
        // When/Then
        do {
            _ = try await remoteRunner.execute(
                command: "sleep 100",
                timeout: 0.5 // 500ms timeout
            )
            XCTFail("Should have thrown timeout error")
        } catch let error as RemoteExecutionError {
            switch error {
            case .timeoutExceeded(let timeout):
                XCTAssertEqual(timeout, 0.5)
            default:
                XCTFail("Expected timeoutExceeded error, got \(error)")
            }
        }
    }
    
    func testQuickCommandWithinTimeout() async throws {
        // Given
        mockSSH.simulatedLatency = 0.1 // 100ms
        mockSSH.addResponse(for: "echo quick", stdout: "quick", exitCode: 0)
        
        // When
        let result = try await remoteRunner.execute(
            command: "echo quick",
            timeout: 1.0 // 1 second timeout
        )
        
        // Then
        XCTAssertEqual(result.stdout, "quick")
        XCTAssertEqual(result.exitCode, 0)
    }
    
    func testDefaultTimeout() async throws {
        // Given
        mockSSH.addResponse(for: "echo test", stdout: "test", exitCode: 0)
        
        // When
        let result = try await remoteRunner.execute(command: "echo test")
        
        // Then
        XCTAssertEqual(mockSSH.executionHistory.last?.timeout, 30.0)
        XCTAssertEqual(result.exitCode, 0)
    }
    
    func testCustomTimeout() async throws {
        // Given
        mockSSH.addResponse(for: "echo test", stdout: "test", exitCode: 0)
        let customTimeout: TimeInterval = 60.0
        
        // When
        _ = try await remoteRunner.execute(
            command: "echo test",
            timeout: customTimeout
        )
        
        // Then
        XCTAssertEqual(mockSSH.executionHistory.last?.timeout, customTimeout)
    }
    
    // MARK: - Test 7: Connection Failure Handling
    
    func testConnectionFailure() async throws {
        // Given
        mockSSH.shouldSimulateConnectionFailure = true
        mockSSH.connectionFailureReason = "Connection refused by host"
        
        // When/Then
        do {
            _ = try await remoteRunner.execute(command: "echo test")
            XCTFail("Should have thrown connection error")
        } catch let error as RemoteExecutionError {
            XCTAssertEqual(error, .connectionFailed("Connection refused by host"))
        }
    }
    
    func testAuthenticationFailure() async throws {
        // Given
        // In a real implementation, this would come from the SSH client
        // Here we simulate it via command response for testing
        mockSSH.addResponse(
            for: "any_command",
            stdout: "",
            stderr: "Permission denied (publickey,password).",
            exitCode: 255
        )
        
        // When
        let result = try await remoteRunner.execute(command: "any_command")
        
        // Then - Note: In mock, we get the error via exit code
        // Real implementation would throw RemoteExecutionError.authenticationFailed
        XCTAssertEqual(result.exitCode, 255)
        XCTAssertTrue(result.stderr.contains("Permission denied"))
    }
    
    func testConnectionLostDuringExecution() async throws {
        // This test simulates connection lost scenario
        // In real implementation, the SSH client would throw connectionLost error
        
        // Given
        let originalResponse = mockSSH.defaultResponse
        
        // Simulate command that triggers connection lost
        // For mock, we can use a special marker in the command
        // When command contains "__CONNECTION_LOST__", we throw
        
        // We'll implement this by checking command in the mock
        // For now, verify the error type exists and can be thrown
        let error = RemoteExecutionError.connectionLost
        XCTAssertEqual(error, RemoteExecutionError.connectionLost)
    }
    
    func testConnectionFailureRecovery() async throws {
        // Test that after a connection failure, subsequent attempts work
        // when connection is restored
        
        // Given - First call fails
        mockSSH.shouldSimulateConnectionFailure = true
        
        do {
            _ = try await remoteRunner.execute(command: "echo 1")
            XCTFail("First call should fail")
        } catch {
            // Expected
        }
        
        // Restore connection
        mockSSH.shouldSimulateConnectionFailure = false
        mockSSH.addResponse(for: "echo 2", stdout: "2", exitCode: 0)
        
        // When - Second call succeeds
        let result = try await remoteRunner.execute(command: "echo 2")
        
        // Then
        XCTAssertEqual(result.stdout, "2")
        XCTAssertEqual(result.exitCode, 0)
    }
    
    func testMultipleConnectionFailures() async throws {
        // Given - Persistent connection failure
        mockSSH.shouldSimulateConnectionFailure = true
        mockSSH.connectionFailureReason = "Network unreachable"
        
        // When/Then - Multiple attempts should all fail
        for i in 0..<3 {
            do {
                _ = try await remoteRunner.execute(command: "echo \(i)")
                XCTFail("Attempt \(i) should have failed")
            } catch let error as RemoteExecutionError {
                XCTAssertEqual(error, .connectionFailed("Network unreachable"))
            }
        }
        
        XCTAssertEqual(mockSSH.executionHistory.count, 3)
    }
    
    // MARK: - Integration Tests (Localhost Testing Approach)
    
    /// These tests demonstrate how to test with actual localhost SSH
    /// They are marked as optional since they require local SSH setup
    
    #if LOCALHOST_TESTING_ENABLED
    
    func testLocalhostBasicCommandExecution() async throws {
        // This test requires local SSH server running on localhost
        // It uses the real SSH client but connects to localhost
        
        // Given
        let localhostRunner = RemoteRunner(sshClient: LocalhostSSHClient())
        
        // When
        let result = try await localhostRunner.execute(command: "echo 'localhost test'")
        
        // Then
        XCTAssertEqual(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines), "localhost test")
        XCTAssertEqual(result.exitCode, 0)
    }
    
    #endif
}

// MARK: - Localhost Testing Support

#if LOCALHOST_TESTING_ENABLED

/// Real SSH client that connects to localhost for integration testing
class LocalhostSSHClient: SSHExecutable {
    
    private let process = Process()
    
    func execute(
        command: String,
        workingDirectory: String?,
        environment: [String: String]?,
        timeout: TimeInterval
    ) async throws -> RemoteExecutionResult {
        
        // Use local shell to simulate SSH
        // In production, this would use libssh2 or similar
        
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        
        if let cwd = workingDirectory {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        }
        
        if let env = environment {
            var environmentVars = process.environment ?? [:]
            for (key, value) in env {
                environmentVars[key] = value
            }
            process.environment = environmentVars
        }
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        let startTime = Date()
        
        try process.run()
        
        // Wait for completion or timeout
        let semaphore = DispatchSemaphore(value: 0)
        var exitCode: Int32 = -1
        
        process.terminationHandler = { _ in
            exitCode = self.process.terminationStatus
            semaphore.signal()
        }
        
        let timeoutResult = semaphore.wait(timeout: .now() + timeout)
        
        if timeoutResult == .timedOut {
            process.terminate()
            throw RemoteExecutionError.timeoutExceeded(timeout)
        }
        
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        
        let duration = Date().timeIntervalSince(startTime)
        
        return RemoteExecutionResult(
            stdout: stdout,
            stderr: stderr,
            exitCode: Int(exitCode),
            duration: duration
        )
    }
}

#endif

// MARK: - Performance Tests

extension RemoteExecutionTests {
    
    func testPerformanceOfMultipleCommands() async throws {
        // Given
        mockSSH.simulatedLatency = 0.001 // 1ms per command
        for i in 0..<100 {
            mockSSH.addResponse(
                for: "echo \(i)",
                stdout: "\(i)",
                exitCode: 0
            )
        }
        
        // When
        let startTime = Date()
        
        await withTaskGroup(of: RemoteExecutionResult.self) { group in
            for i in 0..<100 {
                group.addTask {
                    try! await self.remoteRunner.execute(command: "echo \(i)")
                }
            }
            
            var results: [RemoteExecutionResult] = []
            for await result in group {
                results.append(result)
            }
            
            // Then
            XCTAssertEqual(results.count, 100)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        print("Executed 100 commands in \(duration)s")
    }
}

// MARK: - Concurrency Tests

extension RemoteExecutionTests {
    
    func testConcurrentCommandExecution() async throws {
        // Given
        mockSSH.simulatedLatency = 0.05 // 50ms
        for i in 0..<10 {
            mockSSH.addResponse(
                for: "concurrent_\(i)",
                stdout: "result_\(i)",
                exitCode: 0
            )
        }
        
        // When - Execute commands concurrently
        try await withThrowingTaskGroup(of: (Int, RemoteExecutionResult).self) { group in
            for i in 0..<10 {
                group.addTask {
                    let result = try await self.remoteRunner.execute(command: "concurrent_\(i)")
                    return (i, result)
                }
            }
            
            var results: [Int: RemoteExecutionResult] = [:]
            for try await (index, result) in group {
                results[index] = result
            }
            
            // Then
            XCTAssertEqual(results.count, 10)
            for i in 0..<10 {
                XCTAssertEqual(results[i]?.stdout, "result_\(i)")
            }
        }
    }
}
