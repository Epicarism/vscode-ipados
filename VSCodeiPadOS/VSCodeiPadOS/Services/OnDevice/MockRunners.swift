import Foundation
import JavaScriptCore
import WebKit

/// MARK: - Protocol Definitions

/// Protocol for all code runners (real and mock)
public protocol CodeRunner: Actor {
    associatedtype ResultType
    
    var runnerId: String { get }
    var language: String { get }
    var isAvailable: Bool { get }
    
    /// Execute code and return result
    func execute(code: String, timeout: TimeInterval?) async throws -> ResultType
    
    /// Cancel ongoing execution
    func cancel() async
    
    /// Get current execution status
    func getStatus() async -> ExecutionStatus
}

/// Execution status enum
public enum ExecutionStatus: String, Sendable {
    case idle = "idle"
    case running = "running"
    case completed = "completed"
    case cancelled = "cancelled"
    case failed = "failed"
}

/// Protocol for configurable mock runners
public protocol MockConfigurable {
    var shouldSucceed: Bool { get set }
    var delay: TimeInterval { get set }
    var predefinedResponse: Any? { get set }
    var shouldSimulateTimeout: Bool { get set }
}

// MARK: - Mock JS Runner

/// Mock implementation of JSRunner for testing
@MainActor
public final class MockJSRunner: CodeRunner, MockConfigurable {
    public typealias ResultType = JSValue
    
    public let runnerId: String
    public let language: String = "javascript"
    
    public var isAvailable: Bool = true
    public var shouldSucceed: Bool = true
    public var delay: TimeInterval = 0.1
    public var predefinedResponse: Any? = nil
    public var shouldSimulateTimeout: Bool = false
    
    // Tracking
    public private(set) var executedCodes: [String] = []
    public private(set) var callCount: Int = 0
    public private(set) var lastExecutionTime: Date?
    public private(set) var consoleLogs: [ConsoleLog] = []
    
    // Callbacks
    public var onExecute: ((String) -> Void)?
    public var onCancel: (() -> Void)?
    
    private var currentTask: Task<Void, Never>?
    private var currentStatus: ExecutionStatus = .idle
    private let lock = NSLock()
    
    public init(
        runnerId: String = "mock-js-runner",
        shouldSucceed: Bool = true,
        delay: TimeInterval = 0.1
    ) {
        self.runnerId = runnerId
        self.shouldSucceed = shouldSucceed
        self.delay = delay
    }
    
    public func execute(code: String, timeout: TimeInterval?) async throws -> JSValue {
        lock.lock()
        currentStatus = .running
        lock.unlock()
        
        callCount += 1
        executedCodes.append(code)
        lastExecutionTime = Date()
        
        onExecute?(code)
        
        // Simulate delay
        if delay > 0 {
            currentTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            await currentTask?.value
        }
        
        // Check cancellation
        if Task.isCancelled || shouldSimulateTimeout {
            lock.lock()
            currentStatus = .cancelled
            lock.unlock()
            throw MockRunnerError.executionTimeout
        }
        
        guard shouldSucceed else {
            lock.lock()
            currentStatus = .failed
            lock.unlock()
            throw MockRunnerError.executionFailed("Mock execution failed")
        }
        
        lock.lock()
        currentStatus = .completed
        lock.unlock()
        
        // Return predefined response or default success value
        return createJSValue(from: predefinedResponse ?? "mock-result")
    }
    
    public func cancel() async {
        currentTask?.cancel()
        onCancel?()
        
        lock.lock()
        currentStatus = .cancelled
        lock.unlock()
    }
    
    public func getStatus() async -> ExecutionStatus {
        lock.lock()
        defer { lock.unlock() }
        return currentStatus
    }
    
    /// Configure console output for next execution
    public func addConsoleLog(message: String, level: ConsoleLog.Level = .log) {
        consoleLogs.append(ConsoleLog(message: message, level: level, timestamp: Date()))
    }
    
    /// Reset all tracking state
    public func reset() {
        executedCodes.removeAll()
        callCount = 0
        lastExecutionTime = nil
        consoleLogs.removeAll()
        currentStatus = .idle
        currentTask = nil
    }
    
    /// Verify that specific code was executed
    public func verifyExecution(of code: String) -> Bool {
        return executedCodes.contains(where: { $0 == code })
    }
    
    /// Verify execution count
    public func verifyCallCount(_ expected: Int) -> Bool {
        return callCount == expected
    }
    
    private func createJSValue(from value: Any) -> JSValue {
        // In real implementation, this would be actual JSValue
        // For mock, we create a simple wrapper
        return MockJSValue(wrapped: value)
    }
}

// MARK: - Mock Python Runner

/// Mock implementation of PythonRunner for testing
@MainActor
public final class MockPythonRunner: CodeRunner, MockConfigurable {
    public typealias ResultType = String
    
    public let runnerId: String
    public let language: String = "python"
    
    public var isAvailable: Bool = false // Python not available on iOS by default
    public var shouldSucceed: Bool = true
    public var delay: TimeInterval = 0.2
    public var predefinedResponse: Any? = nil
    public var shouldSimulateTimeout: Bool = false
    public var simulatePlatformAvailable: Bool = false
    
    // Tracking
    public private(set) var executedCodes: [String] = []
    public private(set) var callCount: Int = 0
    public private(set) var outputHistory: [String] = []
    
    // Detection results
    public var detectedImports: [String] = []
    public var detectedNumpy: Bool = false
    public var detectedPandas: Bool = false
    
    public var onExecute: ((String) -> Void)?
    public var onOutput: ((String) -> Void)?
    
    private var currentTask: Task<Void, Never>?
    private var currentStatus: ExecutionStatus = .idle
    private let lock = NSLock()
    
    public init(
        runnerId: String = "mock-python-runner",
        simulateAvailable: Bool = false
    ) {
        self.runnerId = runnerId
        self.simulatePlatformAvailable = simulateAvailable
        self.isAvailable = simulateAvailable
    }
    
    public func execute(code: String, timeout: TimeInterval?) async throws -> String {
        guard simulatePlatformAvailable else {
            throw MockRunnerError.platformNotAvailable("Python not available on iOS")
        }
        
        lock.lock()
        currentStatus = .running
        lock.unlock()
        
        callCount += 1
        executedCodes.append(code)
        
        onExecute?(code)
        
        // Simulate import detection
        analyzeImports(in: code)
        
        // Simulate delay
        if delay > 0 {
            currentTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            await currentTask?.value
        }
        
        if Task.isCancelled || shouldSimulateTimeout {
            lock.lock()
            currentStatus = .cancelled
            lock.unlock()
            throw MockRunnerError.executionTimeout
        }
        
        guard shouldSucceed else {
            lock.lock()
            currentStatus = .failed
            lock.unlock()
            throw MockRunnerError.executionFailed("Python execution failed")
        }
        
        let output = predefinedResponse as? String ?? "mock-python-output"
        outputHistory.append(output)
        onOutput?(output)
        
        lock.lock()
        currentStatus = .completed
        lock.unlock()
        
        return output
    }
    
    public func cancel() async {
        currentTask?.cancel()
        lock.lock()
        currentStatus = .cancelled
        lock.unlock()
    }
    
    public func getStatus() async -> ExecutionStatus {
        lock.lock()
        defer { lock.unlock() }
        return currentStatus
    }
    
    /// Simulate setting output handler
    public func setOutputHandler(_ handler: @escaping (String) -> Void) {
        onOutput = handler
    }
    
    /// Configure platform availability
    public func setPlatformAvailable(_ available: Bool) {
        simulatePlatformAvailable = available
        isAvailable = available
    }
    
    /// Reset all tracking state
    public func reset() {
        executedCodes.removeAll()
        callCount = 0
        outputHistory.removeAll()
        detectedImports.removeAll()
        detectedNumpy = false
        detectedPandas = false
        currentStatus = .idle
    }
    
    private func analyzeImports(in code: String) {
        let patterns = [
            "numpy": "(?m)^(?:import numpy|from numpy)",
            "pandas": "(?m)^(?:import pandas|from pandas)",
            "requests": "(?m)^(?:import requests|from requests)",
            "os": "(?m)^(?:import os|from os)",
            "sys": "(?m)^(?:import sys|from sys)"
        ]
        
        for (name, pattern) in patterns {
            if code.range(of: pattern, options: .regularExpression) != nil {
                detectedImports.append(name)
                if name == "numpy" { detectedNumpy = true }
                if name == "pandas" { detectedPandas = true }
            }
        }
    }
}

// MARK: - Mock WASM Runner

/// Mock implementation of WASMRunner for testing
@MainActor
public final class MockWASMRunner: CodeRunner, MockConfigurable {
    public typealias ResultType = Any
    
    public let runnerId: String
    public let language: String = "wasm"
    
    public var isAvailable: Bool = true
    public var shouldSucceed: Bool = true
    public var delay: TimeInterval = 0.15
    public var predefinedResponse: Any? = nil
    public var shouldSimulateTimeout: Bool = false
    
    // Memory simulation
    public var simulateMemoryLimit: Int = 64 * 1024 * 1024 // 64MB
    public var currentMemoryUsage: Int = 0
    
    // Tracking
    public private(set) var loadedModules: [String] = []
    public private(set) var executedFunctions: [(function: String, args: [Any])] = []
    public private(set) var exposedHostFunctions: [String] = []
    public private(set) var callCount: Int = 0
    
    public var onLoad: ((Data) -> Void)?
    public var onExecute: ((String, [Any]) -> Void)?
    
    private var currentTask: Task<Void, Never>?
    private var currentStatus: ExecutionStatus = .idle
    private let lock = NSLock()
    
    public init(runnerId: String = "mock-wasm-runner") {
        self.runnerId = runnerId
    }
    
    /// Mock load WASM module
    public func load(wasmData: Data) async throws {
        guard shouldSucceed else {
            throw MockRunnerError.executionFailed("Failed to load WASM module")
        }
        
        // Simulate memory check
        if wasmData.count > simulateMemoryLimit {
            throw MockRunnerError.memoryLimitExceeded
        }
        
        let moduleId = "module-\(loadedModules.count + 1)"
        loadedModules.append(moduleId)
        currentMemoryUsage += wasmData.count
        
        onLoad?(wasmData)
    }
    
    public func execute(code: String, timeout: TimeInterval?) async throws -> Any {
        return try await execute(function: "main", args: [])
    }
    
    /// Mock execute WASM function
    public func execute(function: String, args: [Any]) async throws -> Any {
        lock.lock()
        currentStatus = .running
        lock.unlock()
        
        callCount += 1
        executedFunctions.append((function: function, args: args))
        onExecute?(function, args)
        
        // Simulate delay
        if delay > 0 {
            currentTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
            await currentTask?.value
        }
        
        if Task.isCancelled || shouldSimulateTimeout {
            lock.lock()
            currentStatus = .cancelled
            lock.unlock()
            throw MockRunnerError.executionTimeout
        }
        
        guard shouldSucceed else {
            lock.lock()
            currentStatus = .failed
            lock.unlock()
            throw MockRunnerError.executionFailed("WASM execution failed")
        }
        
        lock.lock()
        currentStatus = .completed
        lock.unlock()
        
        return predefinedResponse ?? ["mock-wasm-result", function, args]
    }
    
    /// Mock expose host function
    public func exposeHostFunction(name: String, handler: @escaping ([Any]) -> Any) {
        exposedHostFunctions.append(name)
    }
    
    public func cancel() async {
        currentTask?.cancel()
        lock.lock()
        currentStatus = .cancelled
        lock.unlock()
    }
    
    public func getStatus() async -> ExecutionStatus {
        lock.lock()
        defer { lock.unlock() }
        return currentStatus
    }
    
    /// Mock unload module
    public func unload() {
        if !loadedModules.isEmpty {
            loadedModules.removeLast()
        }
        currentMemoryUsage = 0
    }
    
    /// Reset all state
    public func reset() {
        loadedModules.removeAll()
        executedFunctions.removeAll()
        exposedHostFunctions.removeAll()
        callCount = 0
        currentMemoryUsage = 0
        currentStatus = .idle
    }
    
    /// Verify function was called with specific args
    public func verifyFunctionCalled(_ name: String, withArgs args: [Any]? = nil) -> Bool {
        return executedFunctions.contains { call in
            if call.function == name {
                if let expectedArgs = args {
                    return String(describing: call.args) == String(describing: expectedArgs)
                }
                return true
            }
            return false
        }
    }
}

// MARK: - Mock Runner Factory

/// Factory for creating configured mock runners
public enum MockRunnerFactory {
    
    public enum TestScenario {
        case success(delay: TimeInterval)
        case failure(error: String)
        case timeout
        case slow(delay: TimeInterval)
        case memoryIntensive
        case unavailable
    }
    
    /// Create a mock JS runner configured for a test scenario
    public static func makeJSRunner(
        scenario: TestScenario,
        runnerId: String = "mock-js"
    ) -> MockJSRunner {
        let runner = MockJSRunner(runnerId: runnerId)
        
        switch scenario {
        case .success(let delay):
            runner.shouldSucceed = true
            runner.delay = delay
            runner.predefinedResponse = "success"
            
        case .failure(let error):
            runner.shouldSucceed = false
            runner.delay = 0.05
            
        case .timeout:
            runner.shouldSimulateTimeout = true
            runner.delay = 0.5
            
        case .slow(let delay):
            runner.shouldSucceed = true
            runner.delay = delay
            
        case .memoryIntensive:
            runner.shouldSucceed = true
            runner.delay = 0.2
            // Simulate memory by adding large predefined response
            runner.predefinedResponse = Array(repeating: "x", count: 1000000).joined()
            
        case .unavailable:
            runner.isAvailable = false
        }
        
        return runner
    }
    
    /// Create a mock Python runner configured for a test scenario
    public static func makePythonRunner(
        scenario: TestScenario,
        runnerId: String = "mock-python"
    ) -> MockPythonRunner {
        let runner = MockPythonRunner(runnerId: runnerId)
        
        switch scenario {
        case .success(let delay):
            runner.setPlatformAvailable(true)
            runner.shouldSucceed = true
            runner.delay = delay
            runner.predefinedResponse = "mock-python-result"
            
        case .failure:
            runner.setPlatformAvailable(true)
            runner.shouldSucceed = false
            
        case .timeout:
            runner.setPlatformAvailable(true)
            runner.shouldSimulateTimeout = true
            
        case .slow(let delay):
            runner.setPlatformAvailable(true)
            runner.delay = delay
            
        case .memoryIntensive:
            runner.setPlatformAvailable(true)
            runner.delay = 0.2
            
        case .unavailable:
            runner.setPlatformAvailable(false)
        }
        
        return runner
    }
    
    /// Create a mock WASM runner configured for a test scenario
    public static func makeWASMRunner(
        scenario: TestScenario,
        runnerId: String = "mock-wasm"
    ) -> MockWASMRunner {
        let runner = MockWASMRunner(runnerId: runnerId)
        
        switch scenario {
        case .success(let delay):
            runner.shouldSucceed = true
            runner.delay = delay
            runner.predefinedResponse = ["result": 42]
            
        case .failure:
            runner.shouldSucceed = false
            
        case .timeout:
            runner.shouldSimulateTimeout = true
            
        case .slow(let delay):
            runner.delay = delay
            
        case .memoryIntensive:
            runner.simulateMemoryLimit = 1 * 1024 * 1024 // 1MB
            
        case .unavailable:
            runner.isAvailable = false
        }
        
        return runner
    }
}

// MARK: - Supporting Types

/// Mock error types for testing
public enum MockRunnerError: Error, LocalizedError {
    case executionTimeout
    case executionFailed(String)
    case platformNotAvailable(String)
    case memoryLimitExceeded
    case invalidWASMModule
    
    public var errorDescription: String? {
        switch self {
        case .executionTimeout:
            return "Execution timed out"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        case .platformNotAvailable(let reason):
            return "Platform not available: \(reason)"
        case .memoryLimitExceeded:
            return "Memory limit exceeded"
        case .invalidWASMModule:
            return "Invalid WASM module"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .executionTimeout:
            return "Try increasing the timeout or optimizing the code"
        case .executionFailed:
            return "Check the code for errors and try again"
        case .platformNotAvailable:
            return "Consider using remote execution instead"
        case .memoryLimitExceeded:
            return "Reduce memory usage or run on a device with more RAM"
        case .invalidWASMModule:
            return "Verify the WASM module is valid and compatible"
        }
    }
}

/// Console log entry for tracking
public struct ConsoleLog: Equatable {
    public enum Level: String, Equatable {
        case log = "log"
        case error = "error"
        case warn = "warn"
        case info = "info"
        case debug = "debug"
    }
    
    public let message: String
    public let level: Level
    public let timestamp: Date
    
    public init(message: String, level: Level, timestamp: Date) {
        self.message = message
        self.level = level
        self.timestamp = timestamp
    }
}

/// Mock JSValue for testing
public struct MockJSValue {
    public let wrapped: Any
    
    public var isString: Bool { wrapped is String }
    public var isNumber: Bool { wrapped is NSNumber }
    public var isArray: Bool { wrapped is [Any] }
    public var isObject: Bool { wrapped is [String: Any] }
    public var isNull: Bool { wrapped is NSNull }
    public var isUndefined: Bool { false }
    
    public var toString: String { String(describing: wrapped) }
    public var toInt32: Int32 { (wrapped as? NSNumber)?.int32Value ?? 0 }
    public var toDouble: Double { (wrapped as? NSNumber)?.doubleValue ?? 0 }
    public var toBool: Bool { (wrapped as? NSNumber)?.boolValue ?? false }
}

// MARK: - Usage Examples

/*
 // Example 1: Basic mock JS runner usage
 let mockJS = MockJSRunner()
 mockJS.predefinedResponse = 42
 
 let result = try await mockJS.execute(code: "2 + 2", timeout: 5.0)
 assert(mockJS.verifyCallCount(1))
 assert(mockJS.verifyExecution(of: "2 + 2"))
 
 // Example 2: Testing error scenarios
 let failingJS = MockRunnerFactory.makeJSRunner(scenario: .failure(error: "Syntax error"))
 do {
     _ = try await failingJS.execute(code: "invalid", timeout: 5.0)
 } catch {
     // Handle expected error
 }
 
 // Example 3: Testing timeout
 let slowJS = MockRunnerFactory.makeJSRunner(scenario: .timeout)
 do {
     _ = try await slowJS.execute(code: "while(true) {}", timeout: 1.0)
 } catch MockRunnerError.executionTimeout {
     // Expected timeout
 }
 
 // Example 4: Mock Python runner with platform simulation
 let mockPython = MockRunnerFactory.makePythonRunner(scenario: .success(delay: 0.1))
 mockPython.setPlatformAvailable(true)
 
 let output = try await mockPython.execute(code: "print('hello')", timeout: 5.0)
 assert(mockPython.detectedPandas == false)
 
 // Example 5: WASM runner with function verification
 let mockWASM = MockWASMRunner()
 try await mockWASM.load(wasmData: Data())
 mockWASM.exposeHostFunction(name: "hostAdd") { args in
     guard args.count >= 2,
           let a = args[0] as? Int,
           let b = args[1] as? Int else { return 0 }
     return a + b
 }
 
 _ = try await mockWASM.execute(function: "add", args: [1, 2])
 assert(mockWASM.verifyFunctionCalled("add", withArgs: [1, 2]))
 
 // Example 6: Concurrent testing
 let runner = MockJSRunner()
 await withTaskGroup(of: Int.self) { group in
     for i in 0..<10 {
         group.addTask {
             _ = try? await runner.execute(code: "\(i)", timeout: 1.0)
             return i
         }
     }
 }
 assert(runner.callCount == 10)
 
 // Example 7: Memory limit testing
 let memoryWASM = MockRunnerFactory.makeWASMRunner(scenario: .memoryIntensive)
 let largeData = Data(repeating: 0, count: 2 * 1024 * 1024) // 2MB
 do {
     try await memoryWASM.load(wasmData: largeData)
 } catch MockRunnerError.memoryLimitExceeded {
     // Expected: exceeds 1MB limit
 }
 */

// MARK: - Thread Safety Notes

/*
 All mock implementations use NSLock for thread-safe state access:
 - MockJSRunner: lock protects status and tracking arrays
 - MockPythonRunner: lock protects status and tracking
 - MockWASMRunner: lock protects status and tracking
 
 These mocks are designed to be used with Swift's structured concurrency:
 - @MainActor annotation ensures UI-related operations happen on main thread
 - Async/await patterns support concurrent testing scenarios
 - Task cancellation is properly handled for timeout simulation
 */
