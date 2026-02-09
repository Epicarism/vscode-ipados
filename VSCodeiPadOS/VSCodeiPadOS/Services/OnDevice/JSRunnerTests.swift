import XCTest
@testable import VSCodeiPadOS

/// Unit tests for the JSRunner JavaScript execution engine
/// Tests basic execution, error handling, console capture, memory limits,
/// native function exposure, and async/await patterns
@MainActor
final class JSRunnerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var runner: JSRunner!
    
    // MARK: - Setup/Teardown
    
    override func setUp() async throws {
        try await super.setUp()
        runner = JSRunner()
    }
    
    override func tearDown() async throws {
        runner = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Execution Tests
    
    func testSimpleArithmetic() async throws {
        // Test addition
        let result = try await runner.execute("2 + 2")
        XCTAssertEqual(result.toInt32(), 4)
        
        // Test multiplication
        let multResult = try await runner.execute("5 * 10")
        XCTAssertEqual(multResult.toInt32(), 50)
        
        // Test division
        let divResult = try await runner.execute("100 / 4")
        XCTAssertEqual(divResult.toDouble(), 25.0)
    }
    
    func testStringManipulation() async throws {
        // Test string concatenation
        let concat = try await runner.execute("'Hello' + ' ' + 'World'")
        XCTAssertEqual(concat.toString(), "Hello World")
        
        // Test string methods
        let upper = try await runner.execute("'hello'.toUpperCase()")
        XCTAssertEqual(upper.toString(), "HELLO")
        
        let lower = try await runner.execute("'WORLD'.toLowerCase()")
        XCTAssertEqual(lower.toString(), "world")
        
        // Test string length
        let length = try await runner.execute("'JavaScript'.length")
        XCTAssertEqual(length.toInt32(), 10)
    }
    
    func testArrayOperations() async throws {
        // Test array creation and access
        let first = try await runner.execute("[10, 20, 30][0]")
        XCTAssertEqual(first.toInt32(), 10)
        
        // Test array methods
        let pushed = try await runner.execute("
            var arr = [1, 2];
            arr.push(3);
            arr.length;
        ")
        XCTAssertEqual(pushed.toInt32(), 3)
        
        // Test map
        let mapped = try await runner.execute("[1, 2, 3].map(x => x * 2)")
        let arrayValue = mapped.toArray() as? [Int32]
        XCTAssertEqual(arrayValue, [2, 4, 6])
        
        // Test reduce
        let sum = try await runner.execute("[1, 2, 3, 4].reduce((a, b) => a + b, 0)")
        XCTAssertEqual(sum.toInt32(), 10)
    }
    
    // MARK: - Error Handling Tests
    
    func testSyntaxError() async {
        do {
            _ = try await runner.execute("function incomplete() { return")
            XCTFail("Expected syntax error to be thrown")
        } catch let error as JSRunnerError {
            switch error {
            case .syntaxError(let message):
                XCTAssertTrue(message.contains("Syntax"))
            default:
                XCTFail("Expected syntax error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRuntimeErrorUndefinedVariable() async {
        do {
            _ = try await runner.execute("undefinedVariable + 1")
            XCTFail("Expected runtime error to be thrown")
        } catch let error as JSRunnerError {
            switch error {
            case .runtimeError(let message):
                XCTAssertTrue(
                    message.contains("undefined") || message.contains("ReferenceError"),
                    "Error message should indicate undefined variable: \(message)"
                )
            default:
                XCTFail("Expected runtime error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testRuntimeErrorTypeError() async {
        do {
            _ = try await runner.execute("null.foo()")
            XCTFail("Expected runtime error to be thrown")
        } catch let error as JSRunnerError {
            switch error {
            case .runtimeError(let message):
                XCTAssertTrue(
                    message.contains("TypeError") || message.contains("null"),
                    "Error message should indicate type error: \(message)"
                )
            default:
                XCTFail("Expected runtime error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testInfiniteLoopTimeout() async {
        // Set a short timeout for this test
        let shortTimeoutRunner = JSRunner(timeout: 0.1)
        
        do {
            _ = try await shortTimeoutRunner.execute("while(true) {}")
            XCTFail("Expected timeout error to be thrown")
        } catch let error as JSRunnerError {
            switch error {
            case .timeout:
                // Expected
                break
            default:
                XCTFail("Expected timeout error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testDeepRecursionTimeout() async {
        let shortTimeoutRunner = JSRunner(timeout: 0.1)
        
        do {
            // Recursive function that will cause stack overflow
            _ = try await shortTimeoutRunner.execute("
                function recurse(n) {
                    return recurse(n + 1) + recurse(n + 1);
                }
                recurse(0);
            ")
            XCTFail("Expected timeout or stack overflow error to be thrown")
        } catch let error as JSRunnerError {
            // Either timeout or runtime error is acceptable
            XCTAssertTrue(
                error.isTimeout || error.isRuntimeError,
                "Expected timeout or runtime error, got: \(error)"
            )
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Console Capture Tests
    
    func testConsoleLogSingleArg() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.log('hello')")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.level, .log)
        XCTAssertEqual(logs.first?.message, "hello")
    }
    
    func testConsoleLogMultipleArgs() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.log('value:', 42, true, null)")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.message, "value: 42 true null")
    }
    
    func testMultipleConsoleCalls() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("
                console.log('first');
                console.log('second');
                console.log('third');
            ")
        }
        
        XCTAssertEqual(logs.count, 3)
        XCTAssertEqual(logs.map(\.message), ["first", "second", "third"])
    }
    
    func testConsoleError() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.error('error occurred')")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.level, .error)
        XCTAssertEqual(logs.first?.message, "error occurred")
    }
    
    func testConsoleWarn() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.warn('warning message')")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.level, .warn)
        XCTAssertEqual(logs.first?.message, "warning message")
    }
    
    func testConsoleInfo() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.info('info message')")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertEqual(logs.first?.level, .info)
        XCTAssertEqual(logs.first?.message, "info message")
    }
    
    func testConsoleWithObjects() async throws {
        let logs = try await runner.captureConsole { runner in
            _ = try await runner.execute("console.log({foo: 'bar', num: 123})")
        }
        
        XCTAssertEqual(logs.count, 1)
        XCTAssertTrue(logs.first?.message.contains("foo") ?? false)
        XCTAssertTrue(logs.first?.message.contains("bar") ?? false)
    }
    
    // MARK: - Memory Limit Tests
    
    func testLargeArrayCreation() async throws {
        // Should be able to create reasonably large arrays
        let result = try await runner.execute("
            var arr = new Array(1000000);
            arr.fill(1);
            arr.length;
        ")
        XCTAssertEqual(result.toInt32(), 1_000_000)
    }
    
    func testMemoryExhaustionHandling() async {
        let memoryLimitedRunner = JSRunner(memoryLimitMB: 10)
        
        do {
            // Try to allocate more memory than allowed
            _ = try await memoryLimitedRunner.execute("
                var hugeArray = [];
                for (var i = 0; i < 100000000; i++) {
                    hugeArray.push(new Array(1000).fill('x'.repeat(100)));
                }
            ")
            XCTFail("Expected memory limit error to be thrown")
        } catch let error as JSRunnerError {
            switch error {
            case .memoryLimitExceeded:
                // Expected
                break
            default:
                // Also acceptable: runtime error or timeout
                XCTAssertTrue(
                    error.isRuntimeError || error.isTimeout,
                    "Expected memory, runtime, or timeout error, got: \(error)"
                )
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Native Function Exposure Tests
    
    func testExposeNativeFunction() async throws {
        // Create expectation for callback
        let expectation = expectation(description: "Native function called")
        var receivedArgs: [Any] = []
        
        // Expose a Swift function to JavaScript
        runner.expose(
            name: "swiftEcho",
            function: { args in
                receivedArgs = args
                expectation.fulfill()
                return "echo: \(args.map { String(describing: $0) }.joined(separator: ", "))"
            }
        )
        
        // Call from JavaScript
        let result = try await runner.execute("swiftEcho('hello', 42, true)")
        
        // Wait for async callback
        await fulfillment(of: [expectation], timeout: 5.0)
        
        // Verify result
        XCTAssertEqual(result.toString(), "echo: hello, 42, true")
        XCTAssertEqual(receivedArgs.count, 3)
    }
    
    func testExposeNativeFunctionReturningValue() async throws {
        runner.expose(
            name: "swiftAdd",
            function: { args in
                guard args.count == 2,
                      let a = args[0] as? NSNumber,
                      let b = args[1] as? NSNumber else {
                    return NSNull()
                }
                return a.intValue + b.intValue
            }
        )
        
        let result = try await runner.execute("swiftAdd(10, 32)")
        XCTAssertEqual(result.toInt32(), 42)
    }
    
    func testExposeNativeFunctionReturningObject() async throws {
        runner.expose(
            name: "swiftGetUser",
            function: { _ in
                return [
                    "name": "John Doe",
                    "age": 30,
                    "active": true
                ]
            }
        )
        
        let result = try await runner.execute("
            var user = swiftGetUser();
            user.name + ' is ' + user.age + ' years old';
        ")
        XCTAssertEqual(result.toString(), "John Doe is 30 years old")
    }
    
    func testExposeNativeFunctionErrorHandling() async throws {
        runner.expose(
            name: "swiftThrow",
            function: { _ in
                throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Intentional test error"])
            }
        )
        
        let result = try await runner.execute("
            try {
                swiftThrow();
                'no error';
            } catch (e) {
                'caught: ' + e.message;
            }
        ")
        XCTAssertTrue(result.toString().contains("caught:"))
    }
    
    func testMultipleExposedFunctions() async throws {
        runner.expose(name: "funcA", function: { _ in return "A" })
        runner.expose(name: "funcB", function: { _ in return "B" })
        runner.expose(name: "funcC", function: { _ in return "C" })
        
        let result = try await runner.execute("funcA() + funcB() + funcC()")
        XCTAssertEqual(result.toString(), "ABC")
    }
    
    // MARK: - Async/Await Tests
    
    func testAsyncExecute() async throws {
        // Test that execute() properly supports async/await
        async let result1: JSValue = runner.execute("1 + 1")
        async let result2: JSValue = runner.execute("2 + 2")
        async let result3: JSValue = runner.execute("3 + 3")
        
        let values = try await [result1, result2, result3]
        XCTAssertEqual(values[0].toInt32(), 2)
        XCTAssertEqual(values[1].toInt32(), 4)
        XCTAssertEqual(values[2].toInt32(), 6)
    }
    
    func testConcurrentExecution() async throws {
        // Test that runner can handle concurrent execution safely
        let iterations = 10
        try await withThrowingTaskGroup(of: Int32.self) { group in
            for i in 0..<iterations {
                group.addTask {
                    let result = try await self.runner.execute("\(i) * 2")
                    return result.toInt32()
                }
            }
            
            var results: [Int32] = []
            for try await result in group {
                results.append(result)
            }
            
            XCTAssertEqual(results.count, iterations)
            XCTAssertEqual(results.sorted(), [0, 2, 4, 6, 8, 10, 12, 14, 16, 18])
        }
    }
    
    func testAsyncWithNativeCallback() async throws {
        let expectation = expectation(description: "Async native callback")
        
        runner.expose(
            name: "asyncOperation",
            function: { _ in
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    expectation.fulfill()
                }
                return "started"
            }
        )
        
        let result = try await runner.execute("asyncOperation()")
        XCTAssertEqual(result.toString(), "started")
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    // MARK: - Mock and Expectation Tests
    
    func testMockExpectationForCallback() async throws {
        let mockFunction = MockJSFunction()
        mockFunction.expectCall(withArgs: ["test", 123])
        
        runner.expose(
            name: "mockFunc",
            function: mockFunction.handler
        )
        
        _ = try await runner.execute("mockFunc('test', 123)")
        
        await mockFunction.verify()
    }
    
    func testMultipleMockExpectations() async throws {
        let mockFunction = MockJSFunction()
        mockFunction.expectCalls(
            [.init(args: ["first"]), .init(args: ["second"]), .init(args: ["third"])]
        )
        
        runner.expose(name: "multiCall", function: mockFunction.handler)
        
        _ = try await runner.execute("
            multiCall('first');
            multiCall('second');
            multiCall('third');
        ")
        
        await mockFunction.verify()
    }
    
    func testMockExpectationWithReturnValue() async throws {
        let mockFunction = MockJSFunction()
        mockFunction.expectCall(
            withArgs: [5, 10],
            andReturn: 50
        )
        
        runner.expose(name: "multiply", function: mockFunction.handler)
        
        let result = try await runner.execute("multiply(5, 10)")
        XCTAssertEqual(result.toInt32(), 50)
        
        await mockFunction.verify()
    }
}

// MARK: - Test Helpers

/// Error types thrown by JSRunner
enum JSRunnerError: Error, Equatable {
    case syntaxError(String)
    case runtimeError(String)
    case timeout
    case memoryLimitExceeded
    case invalidScript
    
    var isTimeout: Bool {
        if case .timeout = self { return true }
        return false
    }
    
    var isRuntimeError: Bool {
        if case .runtimeError = self { return true }
        return false
    }
    
    var isSyntaxError: Bool {
        if case .syntaxError = self { return true }
        return false
    }
}

/// Console log entry
struct ConsoleLog: Equatable {
    enum Level: String, Equatable {
        case log, error, warn, info, debug
    }
    
    let level: Level
    let message: String
    let timestamp: Date
}

/// Mock function for testing native function exposure
final class MockJSFunction {
    struct Expectation {
        let args: [Any]
        let returnValue: Any?
        
        init(args: [Any], returnValue: Any? = nil) {
            self.args = args
            self.returnValue = returnValue
        }
    }
    
    private var expectations: [Expectation] = []
    private var callCount = 0
    private var actualCalls: [[Any]] = []
    
    func expectCall(withArgs args: [Any], andReturn returnValue: Any? = nil) {
        expectations.append(Expectation(args: args, returnValue: returnValue))
    }
    
    func expectCalls(_ calls: [Expectation]) {
        expectations = calls
    }
    
    var handler: ([Any]) throws -> Any {
        return { [weak self] args in
            guard let self = self else { return NSNull() }
            
            self.actualCalls.append(args)
            
            if self.callCount < self.expectations.count {
                let expectation = self.expectations[self.callCount]
                self.callCount += 1
                return expectation.returnValue ?? NSNull()
            }
            
            return NSNull()
        }
    }
    
    func verify() async {
        // Allow for async processing
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        XCTAssertEqual(actualCalls.count, expectations.count, 
                      "Expected \(expectations.count) calls but got \(actualCalls.count)")
        
        for (index, (actual, expected)) in zip(actualCalls, expectations).enumerated() {
            XCTAssertEqual(actual.count, expected.args.count,
                          "Call \(index + 1): Argument count mismatch")
            
            for (argIndex, (actualArg, expectedArg)) in zip(actual, expected.args).enumerated() {
                let actualString = String(describing: actualArg)
                let expectedString = String(describing: expectedArg)
                XCTAssertEqual(actualString, expectedString,
                              "Call \(index + 1), arg \(argIndex + 1): Expected \(expectedString) but got \(actualString)")
            }
        }
    }
}

// MARK: - JSRunner Extensions for Testing

extension JSRunner {
    /// Execute with console capture
    func captureConsole(
        operation: (JSRunner) async throws -> Void
    ) async throws -> [ConsoleLog] {
        var logs: [ConsoleLog] = []
        let startTime = Date()
        
        // Set up console capture
        self.expose(name: "_captureLog") { args in
            let levelString = args.first as? String ?? "log"
            let message = args.dropFirst().map { String(describing: $0) }.joined(separator: " ")
            let level = ConsoleLog.Level(rawValue: levelString) ?? .log
            logs.append(ConsoleLog(level: level, message: message, timestamp: Date()))
            return NSNull()
        }
        
        // Inject console capture script
        _ = try? self.execute("""
            (function() {
                const levels = ['log', 'error', 'warn', 'info', 'debug'];
                levels.forEach(level => {
                    const original = console[level];
                    console[level] = function(...args) {
                        _captureLog(level, ...args);
                        if (original) original.apply(console, args);
                    };
                });
            })();
        """)
        
        try await operation(self)
        
        // Filter logs to only include those from this operation
        return logs.filter { $0.timestamp >= startTime }
    }
}

// MARK: - Placeholder Types (to be implemented in actual JSRunner)

/// Placeholder JSRunner class for testing structure
/// In real implementation, this would use JavaScriptCore's JSContext
class JSRunner {
    private let timeout: TimeInterval
    private let memoryLimitMB: Int
    
    init(timeout: TimeInterval = 30.0, memoryLimitMB: Int = 256) {
        self.timeout = timeout
        self.memoryLimitMB = memoryLimitMB
    }
    
    func execute(_ script: String) async throws -> JSValue {
        // Placeholder - actual implementation would use JavaScriptCore
        fatalError("JSRunner.execute() must be implemented")
    }
    
    func expose(name: String, function: @escaping ([Any]) throws -> Any) {
        // Placeholder - actual implementation would register with JSContext
        fatalError("JSRunner.expose() must be implemented")
    }
}

/// Placeholder JSValue for testing structure
/// In real implementation, this would wrap JavaScriptCore's JSValue
class JSValue {
    func toInt32() -> Int32 { fatalError("Must be implemented") }
    func toDouble() -> Double { fatalError("Must be implemented") }
    func toString() -> String { fatalError("Must be implemented") }
    func toArray() -> [Any]? { fatalError("Must be implemented") }
}
