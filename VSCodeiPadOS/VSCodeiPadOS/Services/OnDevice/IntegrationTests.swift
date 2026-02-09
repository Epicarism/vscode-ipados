//  Services/OnDevice/IntegrationTests.swift
//  VSCode for iPad
//
//  End-to-end integration tests for on-device code execution
//

import XCTest
import JavaScriptCore
@testable import VSCode_iPad

// MARK: - Integration Tests

/// End-to-end integration tests for the on-device code execution system
/// Tests the full workflow from code input through execution to result retrieval
@available(iOS 14.0, *)
final class IntegrationTests: XCTestCase {
    
    // MARK: - Properties
    
    private var runnerSelector: RunnerSelector!
    private var jsRunner: JSRunner!
    private var executionHistory: ExecutionHistory!
    private var resourceMonitor: ResourceMonitor!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        runnerSelector = RunnerSelector()
        jsRunner = JSRunner()
        executionHistory = ExecutionHistory()
        resourceMonitor = ResourceMonitor()
    }
    
    override func tearDown() {
        // Ensure all resources are cleaned up
        jsRunner?.cleanup()
        runnerSelector = nil
        jsRunner = nil
        executionHistory = nil
        resourceMonitor = nil
        super.tearDown()
    }
    
    // MARK: - Test 1: Full Workflow
    
    /// Tests the complete workflow from code input to result retrieval
    func testFullWorkflow() throws {
        // Given: User writes code
        let code = """
        function calculateSum(a, b) {
            return a + b;
        }
        calculateSum(10, 20);
        """
        let request = ExecutionRequest(code: code, language: .javascript)
        
        // When: RunnerSelector analyzes and selects appropriate runner
        let selectedRunner = try runnerSelector.selectRunner(for: request)
        XCTAssertNotNil(selectedRunner, "Runner should be selected")
        XCTAssertTrue(selectedRunner is JSRunner, "Should select JSRunner for JavaScript code")
        
        // When: Runner executes the code
        let expectation = self.expectation(description: "Code execution completes")
        var executionResult: ExecutionResult?
        
        selectedRunner.execute(request) { result in
            executionResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Results are returned correctly
        XCTAssertNotNil(executionResult)
        XCTAssertTrue(executionResult?.success ?? false, "Execution should succeed")
        XCTAssertEqual(executionResult?.output as? Int, 30, "Should return sum 30")
    }
    
    // MARK: - Test 2: JavaScript End-to-End
    
    /// Tests JavaScript execution with algorithm code, correct output, and console capture
    func testJSEndToEnd() throws {
        // Given: Algorithm code
        let algorithmCode = """
        // Fibonacci algorithm
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        
        console.log('Starting fibonacci calculation...');
        const result = fibonacci(10);
        console.log('Result:', result);
        result;
        """
        
        let request = ExecutionRequest(code: algorithmCode, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        // When: Execute algorithm
        let expectation = self.expectation(description: "JS algorithm execution")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Then: Correct result
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        XCTAssertEqual(result?.output as? Int, 55, "Fibonacci(10) should equal 55")
        
        // Then: Console output captured
        XCTAssertNotNil(result?.consoleOutput)
        XCTAssertTrue(result?.consoleOutput?.contains("Starting fibonacci calculation") ?? false)
        XCTAssertTrue(result?.consoleOutput?.contains("Result: 55") ?? false)
    }
    
    /// Tests JavaScript console.log with multiple types
    func testJSConsoleCapture() throws {
        let code = """
        console.log('String:', 'hello');
        console.log('Number:', 42);
        console.log('Object:', { foo: 'bar' });
        console.log('Array:', [1, 2, 3]);
        console.log('Boolean:', true);
        'done';
        """
        
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        let expectation = self.expectation(description: "Console capture")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertNotNil(result?.consoleOutput)
        XCTAssertTrue(result?.consoleOutput?.contains("String: hello") ?? false)
        XCTAssertTrue(result?.consoleOutput?.contains("Number: 42") ?? false)
        XCTAssertTrue(result?.consoleOutput?.contains("foo") ?? false)
    }
    
    // MARK: - Test 3: Fallback Scenarios
    
    /// Tests fallback when on-device execution fails
    func testOnDeviceFailureFallback() throws {
        // Given: Code that exceeds on-device limits (simulated)
        let failingCode = "while(true) {}" // Infinite loop simulation
        let request = ExecutionRequest(code: failingCode, language: .javascript)
        
        // Configure runner with short timeout to simulate failure
        let runner = try runnerSelector.selectRunner(for: request)
        runner.configuration.timeout = 0.1 // 100ms timeout
        
        let expectation = self.expectation(description: "Fallback suggestion")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then: Execution fails and suggests remote execution
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.success ?? true, "Execution should fail")
        XCTAssertTrue(result?.shouldFallbackToRemote ?? false, "Should suggest remote execution")
        XCTAssertEqual(result?.fallbackReason, ExecutionError.timeout)
    }
    
    /// Tests error message when remote is unavailable
    func testRemoteUnavailableError() throws {
        // Given: Request with remote unavailable flag
        let code = "console.log('test');"
        var request = ExecutionRequest(code: code, language: .javascript)
        request.remoteExecutionAvailable = false
        
        // Simulate scenario where code requires remote but remote unavailable
        let complexCode = """
        // Code requiring more resources than available on-device
        const largeArray = new Array(1000000000);
        largeArray.fill(0);
        """
        request = ExecutionRequest(code: complexCode, language: .javascript)
        request.remoteExecutionAvailable = false
        
        let expectation = self.expectation(description: "Remote unavailable error")
        var result: ExecutionResult?
        
        let runner = try runnerSelector.selectRunner(for: request)
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Appropriate error message shown
        XCTAssertFalse(result?.success ?? true)
        XCTAssertTrue(result?.errorMessage?.contains("Remote execution unavailable") ?? false)
        XCTAssertTrue(result?.errorMessage?.contains("insufficient resources") ?? false)
    }
    
    // MARK: - Test 4: Concurrent Execution
    
    /// Tests multiple scripts executing simultaneously with resource isolation
    func testConcurrentExecution() throws {
        // Given: Multiple independent scripts
        let scripts = [
            ("script1", "function add(a,b){return a+b;} add(5,10);"),
            ("script2", "function mul(a,b){return a*b;} mul(6,7);"),
            ("script3", "function sub(a,b){return a-b;} sub(20,8);"),
            ("script4", "function div(a,b){return a/b;} div(100,4);"),
        ]
        
        let expectations = scripts.map { name, _ in
            self.expectation(description: "Execution of \(name)")
        }
        
        var results: [String: ExecutionResult] = [:]
        let resultsLock = NSLock()
        
        // When: Execute all scripts concurrently
        for (index, (name, code)) in scripts.enumerated() {
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            DispatchQueue.global().async {
                runner.execute(request) { result in
                    resultsLock.lock()
                    results[name] = result
                    resultsLock.unlock()
                    expectations[index].fulfill()
                }
            }
        }
        
        wait(for: expectations, timeout: 15.0)
        
        // Then: All scripts complete with correct isolated results
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results["script1"]?.output as? Int, 15)
        XCTAssertEqual(results["script2"]?.output as? Int, 42)
        XCTAssertEqual(results["script3"]?.output as? Int, 12)
        XCTAssertEqual(results["script4"]?.output as? Int, 25)
        
        // Then: Resource isolation maintained (no cross-contamination)
        for (_, result) in results {
            XCTAssertTrue(result.success)
            XCTAssertNil(result.errorMessage)
        }
    }
    
    /// Tests resource isolation between concurrent executions
    func testResourceIsolation() throws {
        // Given: Scripts that try to modify shared state
        let scripts = [
            ("isolation1", "var globalVar = 'script1'; globalVar;"),
            ("isolation2", "var globalVar = 'script2'; globalVar;"),
        ]
        
        let expectations = scripts.map { name, _ in
            self.expectation(description: "Isolation test for \(name)")
        }
        
        var results: [String: ExecutionResult] = [:]
        let resultsLock = NSLock()
        
        // When: Execute concurrently
        for (index, (name, code)) in scripts.enumerated() {
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            DispatchQueue.global().async {
                runner.execute(request) { result in
                    resultsLock.lock()
                    results[name] = result
                    resultsLock.unlock()
                    expectations[index].fulfill()
                }
            }
        }
        
        wait(for: expectations, timeout: 10.0)
        
        // Then: Each script has its own isolated global scope
        XCTAssertEqual(results["isolation1"]?.output as? String, "script1")
        XCTAssertEqual(results["isolation2"]?.output as? String, "script2")
    }
    
    // MARK: - Test 5: Persistence
    
    /// Tests saving execution history
    func testSaveExecutionHistory() throws {
        // Given: Multiple executions
        let executions = [
            ("console.log('test1'); 'result1'", "result1"),
            ("console.log('test2'); 'result2'", "result2"),
            ("console.log('test3'); 42", 42),
        ]
        
        // When: Execute and save each
        for (code, _) in executions {
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            let expectation = self.expectation(description: "Execution")
            var result: ExecutionResult?
            
            runner.execute(request) { executionResult in
                result = executionResult
                // Save to history
                if let executionResult = executionResult {
                    self.executionHistory.save(executionResult)
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
        
        // Then: History contains all executions
        let history = executionHistory.allExecutions()
        XCTAssertEqual(history.count, 3)
        
        // Then: History entries are complete
        for entry in history {
            XCTAssertNotNil(entry.id)
            XCTAssertNotNil(entry.timestamp)
            XCTAssertNotNil(entry.code)
            XCTAssertNotNil(entry.output)
        }
    }
    
    /// Tests restoring results from history
    func testRestoreResults() throws {
        // Given: Executed and saved code
        let code = "function greet(name) { return 'Hello, ' + name; } greet('World');"
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        let expectation = self.expectation(description: "Execution")
        var savedResult: ExecutionResult?
        
        runner.execute(request) { result in
            savedResult = result
            if let result = result {
                self.executionHistory.save(result)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // When: Restore from history
        let history = executionHistory.allExecutions()
        XCTAssertFalse(history.isEmpty)
        
        let restored = history.first { $0.code == code }
        XCTAssertNotNil(restored)
        
        // Then: Restored result matches original
        XCTAssertEqual(restored?.output as? String, "Hello, World")
        XCTAssertEqual(restored?.success, savedResult?.success)
        XCTAssertEqual(restored?.consoleOutput, savedResult?.consoleOutput)
    }
    
    /// Tests history persistence across app sessions
    func testHistoryPersistenceAcrossSessions() throws {
        // Given: Saved execution
        let code = "'persistent result';"
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        let expectation = self.expectation(description: "Execution")
        
        runner.execute(request) { result in
            if let result = result {
                self.executionHistory.save(result)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // When: Create new history instance (simulating app restart)
        let newHistory = ExecutionHistory()
        
        // Then: History restored from storage
        let restoredHistory = newHistory.allExecutions()
        XCTAssertFalse(restoredHistory.isEmpty, "History should persist across sessions")
        
        let restoredEntry = restoredHistory.first { $0.code == code }
        XCTAssertNotNil(restoredEntry)
        XCTAssertEqual(restoredEntry?.output as? String, "persistent result")
    }
    
    // MARK: - Test 6: Performance Benchmarks
    
    /// Measures execution time for standard operations
    func testExecutionTimeBenchmark() throws {
        // Given: Benchmark code
        let benchmarks = [
            ("simple arithmetic", "1 + 1"),
            ("loop 1000", "let sum = 0; for(let i=0; i<1000; i++) sum++; sum;"),
            ("array operations", "let arr = []; for(let i=0; i<1000; i++) arr.push(i); arr.length;"),
            ("string concat", "let s = ''; for(let i=0; i<100; i++) s += 'a'; s.length;"),
        ]
        
        var results: [(name: String, time: TimeInterval)] = []
        
        for (name, code) in benchmarks {
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            let expectation = self.expectation(description: "Benchmark \(name)")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            runner.execute(request) { result in
                let endTime = CFAbsoluteTimeGetCurrent()
                let executionTime = endTime - startTime
                results.append((name: name, time: executionTime))
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
        
        // Then: All benchmarks complete within reasonable time
        for (name, time) in results {
            print("Benchmark '\(name)': \(String(format: "%.4f", time))s")
            XCTAssertLessThan(time, 5.0, "Benchmark '\(name)' took too long")
        }
    }
    
    /// Tracks memory usage during execution
    func testMemoryUsageTracking() throws {
        // Given: Memory-intensive code
        let memoryTests = [
            ("small array", "new Array(1000).fill(0);"),
            ("medium array", "new Array(10000).fill(0);"),
            ("large array", "new Array(100000).fill(0);"),
        ]
        
        for (name, code) in memoryTests {
            // Record baseline memory
            let baselineMemory = resourceMonitor.currentMemoryUsage()
            
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            let expectation = self.expectation(description: "Memory test \(name)")
            
            runner.execute(request) { result in
                // Record peak memory during execution
                let peakMemory = self.resourceMonitor.peakMemoryUsage()
                let memoryDelta = peakMemory - baselineMemory
                
                print("Memory test '\(name)': baseline=\(baselineMemory)MB, peak=\(peakMemory)MB, delta=\(memoryDelta)MB")
                
                // Memory should stay within bounds
                XCTAssertLessThan(memoryDelta, 100, "Memory test '\(name)' exceeded memory limit")
                
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    // MARK: - Test 7: Cleanup
    
    /// Tests resource cleanup after execution
    func testResourceCleanup() throws {
        // Given: Executed code that allocates resources
        let code = "var largeObj = { data: new Array(10000).fill(Math.random()) }; 'done';"
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        // Record baseline
        let baselineResources = runner.resourceUsage()
        
        let expectation = self.expectation(description: "Execution")
        
        runner.execute(request) { result in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // When: Cleanup is called
        runner.cleanup()
        
        // Then: Resources are released
        let afterCleanup = runner.resourceUsage()
        XCTAssertLessThanOrEqual(afterCleanup.memory, baselineResources.memory + 1)
        XCTAssertEqual(afterCleanup.openHandles, 0, "All handles should be closed")
        XCTAssertEqual(afterCleanup.activeTimers, 0, "All timers should be cleared")
    }
    
    /// Tests for memory leaks during repeated executions
    func testNoMemoryLeaks() throws {
        // Given: Repeated executions
        let iterations = 50
        let code = "(function() { var arr = [1,2,3]; return arr.reduce((a,b)=>a+b,0); })();"
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        // Record initial memory
        let initialMemory = resourceMonitor.currentMemoryUsage()
        
        // Execute multiple times
        for i in 0..<iterations {
            let expectation = self.expectation(description: "Iteration \(i)")
            
            runner.execute(request) { _ in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
            
            // Periodic cleanup
            if i % 10 == 0 {
                runner.cleanup()
            }
        }
        
        // Force cleanup
        runner.cleanup()
        
        // Let any pending cleanup complete
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        
        // Then: Memory should not have grown significantly
        let finalMemory = resourceMonitor.currentMemoryUsage()
        let memoryGrowth = finalMemory - initialMemory
        
        print("Memory leak test: initial=\(initialMemory)MB, final=\(finalMemory)MB, growth=\(memoryGrowth)MB")
        
        // Allow for some fluctuation but not continuous growth
        XCTAssertLessThan(memoryGrowth, 10, "Detected memory leak: \(memoryGrowth)MB growth over \(iterations) iterations")
    }
    
    /// Tests JS context cleanup
    func testJSContextCleanup() throws {
        // Given: Multiple contexts created and destroyed
        let code = "var global = 'value'; global;"
        
        for _ in 0..<20 {
            let request = ExecutionRequest(code: code, language: .javascript)
            let runner = try runnerSelector.selectRunner(for: request)
            
            let expectation = self.expectation(description: "Context creation")
            
            runner.execute(request) { _ in
                runner.cleanup()
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5.0)
        }
        
        // Then: No lingering contexts
        let activeContexts = runnerSelector.activeRunnerCount()
        XCTAssertEqual(activeContexts, 0, "All contexts should be cleaned up")
    }
    
    // MARK: - Additional Edge Case Tests
    
    /// Tests error handling for syntax errors
    func testSyntaxErrorHandling() throws {
        let code = "function incomplete({ return 1; }" // Syntax error
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        let expectation = self.expectation(description: "Syntax error handling")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertFalse(result?.success ?? true)
        XCTAssertNotNil(result?.errorMessage)
        XCTAssertTrue(result?.errorMessage?.contains("SyntaxError") ?? false)
    }
    
    /// Tests handling of exceptions thrown by user code
    func testRuntimeExceptionHandling() throws {
        let code = "throw new Error('User error');"
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        
        let expectation = self.expectation(description: "Exception handling")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertFalse(result?.success ?? true)
        XCTAssertNotNil(result?.errorMessage)
        XCTAssertTrue(result?.errorMessage?.contains("User error") ?? false)
    }
    
    /// Tests timeout handling
    func testTimeoutHandling() throws {
        let code = "while(true) { }" // Infinite loop
        let request = ExecutionRequest(code: code, language: .javascript)
        let runner = try runnerSelector.selectRunner(for: request)
        runner.configuration.timeout = 0.5 // 500ms timeout
        
        let expectation = self.expectation(description: "Timeout handling")
        var result: ExecutionResult?
        
        runner.execute(request) { executionResult in
            result = executionResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertFalse(result?.success ?? true)
        XCTAssertEqual(result?.errorMessage, ExecutionError.timeout.localizedDescription)
        XCTAssertTrue(result?.shouldFallbackToRemote ?? false)
    }
}

// MARK: - Supporting Types (Expected Interfaces)

/// Represents a code execution request
struct ExecutionRequest {
    let id = UUID()
    let code: String
    let language: ExecutionLanguage
    let timestamp = Date()
    var remoteExecutionAvailable = true
    var maxMemoryMB: Int = 512
    var timeout: TimeInterval = 30.0
}

/// Supported execution languages
enum ExecutionLanguage {
    case javascript
    case python
    case wasm
    case lua
}

/// Represents the result of code execution
struct ExecutionResult {
    let id: UUID
    let requestId: UUID
    let success: Bool
    let output: Any?
    let consoleOutput: String?
    let errorMessage: String?
    let executionTime: TimeInterval
    let memoryUsage: Int
    let timestamp: Date
    let code: String
    var shouldFallbackToRemote: Bool
    var fallbackReason: ExecutionError?
}

/// Execution errors
enum ExecutionError: Error, LocalizedError {
    case timeout
    case outOfMemory
    case syntaxError(String)
    case runtimeError(String)
    case resourceUnavailable
    case remoteUnavailable
    
    var localizedDescription: String {
        switch self {
        case .timeout:
            return "Execution timed out"
        case .outOfMemory:
            return "Out of memory"
        case .syntaxError(let message):
            return "Syntax error: \(message)"
        case .runtimeError(let message):
            return "Runtime error: \(message)"
        case .resourceUnavailable:
            return "Insufficient resources on device"
        case .remoteUnavailable:
            return "Remote execution unavailable"
        }
    }
}

/// Protocol for code runners
protocol CodeRunner {
    var configuration: RunnerConfiguration { get set }
    func execute(_ request: ExecutionRequest, completion: @escaping (ExecutionResult) -> Void)
    func cleanup()
    func resourceUsage() -> ResourceSnapshot
}

/// Runner configuration
class RunnerConfiguration {
    var timeout: TimeInterval = 30.0
    var maxMemoryMB: Int = 512
    var enableConsoleCapture: Bool = true
}

/// Resource usage snapshot
struct ResourceSnapshot {
    let memory: Int // MB
    let openHandles: Int
    let activeTimers: Int
    let cpuUsage: Double // percentage
}

/// Runner selector that determines the appropriate runner
class RunnerSelector {
    private var runners: [ExecutionLanguage: CodeRunner] = [:]
    private var activeRunners: [UUID: CodeRunner] = [:]
    
    func selectRunner(for request: ExecutionRequest) throws -> CodeRunner {
        switch request.language {
        case .javascript:
            return JSRunner()
        case .python:
            throw ExecutionError.resourceUnavailable
        case .wasm:
            throw ExecutionError.resourceUnavailable
        case .lua:
            throw ExecutionError.resourceUnavailable
        }
    }
    
    func activeRunnerCount() -> Int {
        return activeRunners.count
    }
}

/// JavaScript runner using JavaScriptCore
class JSRunner: CodeRunner {
    var configuration = RunnerConfiguration()
    private var context: JSContext?
    private var consoleOutput: [String] = []
    
    func execute(_ request: ExecutionRequest, completion: @escaping (ExecutionResult) -> Void) {
        // Implementation would create JSContext, capture console, execute, and return result
        // This is a stub for the integration test interface
        let result = ExecutionResult(
            id: UUID(),
            requestId: request.id,
            success: true,
            output: nil,
            consoleOutput: nil,
            errorMessage: nil,
            executionTime: 0,
            memoryUsage: 0,
            timestamp: Date(),
            code: request.code,
            shouldFallbackToRemote: false,
            fallbackReason: nil
        )
        completion(result)
    }
    
    func cleanup() {
        context = nil
        consoleOutput.removeAll()
    }
    
    func resourceUsage() -> ResourceSnapshot {
        return ResourceSnapshot(memory: 0, openHandles: 0, activeTimers: 0, cpuUsage: 0)
    }
}

/// Execution history manager
class ExecutionHistory {
    private var executions: [ExecutionResult] = []
    private let storageKey = "execution_history"
    
    init() {
        loadFromStorage()
    }
    
    func save(_ result: ExecutionResult) {
        executions.append(result)
        persistToStorage()
    }
    
    func allExecutions() -> [ExecutionResult] {
        return executions.sorted { $0.timestamp > $1.timestamp }
    }
    
    private func persistToStorage() {
        // Implementation would use UserDefaults or CoreData
    }
    
    private func loadFromStorage() {
        // Implementation would restore from UserDefaults or CoreData
    }
}

/// Resource monitor for tracking memory and CPU
class ResourceMonitor {
    func currentMemoryUsage() -> Int {
        // Return current memory in MB
        return 0
    }
    
    func peakMemoryUsage() -> Int {
        // Return peak memory during execution
        return 0
    }
}
