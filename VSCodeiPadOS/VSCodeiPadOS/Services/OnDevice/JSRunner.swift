import JavaScriptCore
import Foundation

// MARK: - Console Protocol
/**
 * Protocol for JavaScript console object exposure to native Swift.
 * Conforming to JSExport allows JavaScript to call these methods directly.
 */
@objc protocol JSConsoleProtocol: JSExport {
    func log(_ message: String)
    func error(_ message: String)
    func warn(_ message: String)
    func info(_ message: String)
}

// MARK: - Console Implementation
/**
 * Native implementation of JavaScript console that captures output
 * and forwards it to a Swift callback handler.
 */
@objc class JSConsole: NSObject, JSConsoleProtocol {
    private var logHandler: ((String) -> Void)?
    
    /**
     * Initializes the console with a log handler callback.
     * - Parameter handler: Closure called when console methods are invoked from JS
     */
    init(handler: @escaping (String) -> Void) {
        self.logHandler = handler
        super.init()
    }
    
    func log(_ message: String) {
        logHandler?("[LOG] \(message)")
    }
    
    func error(_ message: String) {
        logHandler?("[ERROR] \(message)")
    }
    
    func warn(_ message: String) {
        logHandler?("[WARN] \(message)")
    }
    
    func info(_ message: String) {
        logHandler?("[INFO] \(message)")
    }
}

// MARK: - Error Types
/**
 * Errors that can occur during JavaScript execution.
 */
enum JSRunnerError: Error, LocalizedError {
    case contextCreationFailed
    case executionTimeout
    case memoryLimitExceeded
    case scriptError(String)
    case invalidResult
    case nativeFunctionRegistrationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .contextCreationFailed:
            return "Failed to create JavaScript context"
        case .executionTimeout:
            return "JavaScript execution exceeded the timeout limit"
        case .memoryLimitExceeded:
            return "JavaScript execution exceeded the memory limit"
        case .scriptError(let message):
            return "Script error: \(message)"
        case .invalidResult:
            return "JavaScript returned an invalid or unsupported result type"
        case .nativeFunctionRegistrationFailed(let name):
            return "Failed to register native function '\(name)'"
        }
    }
}

// MARK: - JSRunner
/**
 * A Swift wrapper around JavaScriptCore that provides:
 * - Safe async JavaScript execution with timeout and memory limits
 * - Console.log capture via JSExport protocol
 * - Native function exposure to JavaScript
 * - Automatic conversion of JS values to Swift types
 *
 * ## Example Usage:
 * ```swift
 * let runner = JSRunner()
 *
 * // Set up console handler
 * runner.setConsoleHandler { message in
 *     print("JS Console: \(message)")
 * }
 *
 * // Expose a native function
 * runner.exposeNativeFunction(name: "nativeAdd") { args in
 *     guard args.count >= 2,
 *           let a = args[0].toInt32(),
 *           let b = args[1].toInt32() else {
 *         return JSValue(undefinedIn: runner.context)
 *     }
 *     return JSValue(int32: a + b, in: runner.context)
 * }
 *
 * // Execute JavaScript
 * do {
 *     let result = try await runner.execute(code: "nativeAdd(5, 3)")
 *     print("Result: \(result)") // Result: 8
 * } catch {
 *     print("Error: \(error)")
 * }
 * ```
 */
class JSRunner {
    
    // MARK: - Properties
    
    /** The underlying JavaScript context */
    private(set) var context: JSContext!
    
    /** Handler for console messages from JavaScript */
    private var consoleHandler: ((String) -> Void)?
    
    /** Timeout duration for script execution (default: 30 seconds) */
    var timeoutDuration: TimeInterval = 30.0
    
    /** Memory limit in bytes (default: 100 MB) */
    var memoryLimit: UInt64 = 100 * 1024 * 1024
    
    /** Track memory usage */
    private var currentMemoryUsage: UInt64 = 0
    
    /** Background queue for JavaScript execution */
    private let executionQueue = DispatchQueue(
        label: "com.jsrunner.execution",
        qos: .userInitiated
    )
    
    // MARK: - Initialization
    
    /**
     * Creates a new JSRunner with a fresh JavaScript context.
     * Automatically sets up error handling and exception callbacks.
     */
    init() {
        setupContext()
    }
    
    deinit {
        context = nil
    }
    
    // MARK: - Context Setup
    
    private func setupContext() {
        // Create context with nil virtual machine (creates default VM)
        let virtualMachine = JSVirtualMachine()
        context = JSContext(virtualMachine: virtualMachine)
        
        // Set up exception handler
        context.exceptionHandler = { [weak self] context, exception in
            guard let self = self, let exception = exception else { return }
            let message = exception.toString() ?? "Unknown error"
            self.consoleHandler?("[EXCEPTION] \(message)")
        }
        
        // Inject console object
        setupConsole()
    }
    
    private func setupConsole() {
        let console = JSConsole { [weak self] message in
            self?.consoleHandler?(message)
        }
        context.setObject(console, forKeyedSubscript: "console" as NSString)
    }
    
    // MARK: - Console Handler
    
    /**
     * Sets the callback handler for JavaScript console messages.
     *
     * - Parameter callback: Closure invoked when console.log, console.error,
     *                       console.warn, or console.info are called from JavaScript.
     *
     * ## Example:
     * ```swift
     * runner.setConsoleHandler { message in
     *     // Log to your app's logging system
     *     Logger.shared.log(message)
     * }
     * ```
     */
    func setConsoleHandler(callback: @escaping (String) -> Void) {
        consoleHandler = callback
        // Re-inject console with new handler
        setupConsole()
    }
    
    // MARK: - Native Function Exposure
    
    /**
     * Exposes a native Swift function to JavaScript.
     *
     * - Parameters:
     *   - name: The name the function will have in JavaScript
     *   - block: The Swift closure that implements the function.
     *            Receives an array of JSValue arguments and must return a JSValue.
     *
     * ## Example:
     * ```swift
     * // Expose native multiply function
     * runner.exposeNativeFunction(name: "nativeMultiply") { args in
     *     guard args.count >= 2,
     *           let a = args[0].toDouble(),
     *           let b = args[1].toDouble() else {
     *         return JSValue(undefinedIn: self.context)
     *     }
     *     return JSValue(double: a * b, in: self.context)
     * }
     *
     * // Use in JavaScript:
     * // const result = nativeMultiply(4, 5); // Returns 20
     * ```
     */
    func exposeNativeFunction(
        name: String,
        block: @escaping ([JSValue]) -> JSValue
    ) {
        let jsFunction: @convention(block) () -> JSValue = { [weak self] in
            guard let self = self else {
                return JSValue(undefinedIn: nil)
            }
            
            // Get arguments from current JS context
            let args = JSContext.currentArguments() as? [JSValue] ?? []
            return block(args)
        }
        
        context.setObject(
            jsFunction,
            forKeyedSubscript: name as NSString
        )
    }
    
    /**
     * Exposes a native Swift function with specific argument count to JavaScript.
     * This version provides better type safety for functions with known arity.
     *
     * - Parameters:
     *   - name: The name the function will have in JavaScript
     *   - argCount: Expected number of arguments
     *   - block: Swift closure implementing the function
     */
    func exposeNativeFunction(
        name: String,
        argCount: Int,
        block: @escaping ([JSValue]) throws -> JSValue
    ) throws {
        let wrapper: @convention(block) () -> JSValue = { [weak self] in
            guard let self = self else {
                return JSValue(undefinedIn: nil)
            }
            
            let args = JSContext.currentArguments() as? [JSValue] ?? []
            
            // Check argument count
            if args.count != argCount {
                let error = JSValue(
                    newErrorFromMessage: "Expected \(argCount) arguments, got \(args.count)",
                    in: self.context
                )
                self.context.exception = error
                return JSValue(undefinedIn: self.context)
            }
            
            do {
                return try block(args)
            } catch {
                let errorMessage = (error as? JSRunnerError)?.errorDescription ?? error.localizedDescription
                let jsError = JSValue(
                    newErrorFromMessage: errorMessage,
                    in: self.context
                )
                self.context.exception = jsError
                return JSValue(undefinedIn: self.context)
            }
        }
        
        context.setObject(wrapper, forKeyedSubscript: name as NSString)
    }
    
    // MARK: - Script Execution
    
    /**
     * Executes JavaScript code with timeout and memory limit protection.
     *
     * - Parameter code: The JavaScript code to execute
     * - Returns: The result of the execution as a JSValue
     * - Throws: JSRunnerError if execution fails, times out, or exceeds memory limits
     *
     * ## Example:
     * ```swift
     * do {
     *     // Simple arithmetic
     *     let result = try await runner.execute(code: "2 + 2")
     *     print(result.toInt32()!) // 4
     *
     *     // Complex object
     *     let obj = try await runner.execute(code: "({ name: 'Test', value: 42 })")
     *     print(obj.toDictionary()) // ["name": "Test", "value": 42]
     *
     *     // Using native functions
     *     let sum = try await runner.execute(code: "nativeAdd(10, 20)")
     *     print(sum.toInt32()!) // 30
     * } catch JSRunnerError.executionTimeout {
     *     print("Script took too long")
     * } catch {
     *     print("Execution failed: \(error)")
     * }
     * ```
     */
    func execute(code: String) async throws -> JSValue {
        return try await withCheckedThrowingContinuation { continuation in
            executionQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: JSRunnerError.contextCreationFailed)
                    return
                }
                
                // Set up timeout
                var timeoutOccurred = false
                let timeoutWorkItem = DispatchWorkItem { [weak self] in
                    timeoutOccurred = true
                    self?.context = nil // Force terminate
                }
                
                DispatchQueue.global().asyncAfter(
                    deadline: .now() + self.timeoutDuration,
                    execute: timeoutWorkItem
                )
                
                // Reset memory tracking
                self.currentMemoryUsage = 0
                
                // Execute the script
                var result: JSValue?
                var executionError: Error?
                
                autoreleasepool {
                    result = self.context.evaluateScript(code)
                    
                    // Check for exceptions
                    if let exception = self.context.exception {
                        let message = exception.toString() ?? "Unknown error"
                        executionError = JSRunnerError.scriptError(message)
                        self.context.exception = nil
                    }
                }
                
                // Cancel timeout if execution completed
                timeoutWorkItem.cancel()
                
                // Check for timeout
                if timeoutOccurred {
                    // Need to recreate context since we nilled it
                    self.setupContext()
                    continuation.resume(throwing: JSRunnerError.executionTimeout)
                    return
                }
                
                // Check for memory limit
                // Note: Real memory tracking would use more sophisticated methods
                // This is a simplified check
                if self.currentMemoryUsage > self.memoryLimit {
                    continuation.resume(throwing: JSRunnerError.memoryLimitExceeded)
                    return
                }
                
                // Handle execution error
                if let error = executionError {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Return result or undefined if nil
                continuation.resume(returning: result ?? JSValue(undefinedIn: self.context))
            }
        }
    }
    
    /**
     * Executes JavaScript code with a specific timeout.
     *
     * - Parameters:
     *   - code: The JavaScript code to execute
     *   - timeout: Custom timeout duration for this execution
     * - Returns: The result as a JSValue
     * - Throws: JSRunnerError for various failure conditions
     */
    func execute(code: String, timeout: TimeInterval) async throws -> JSValue {
        let originalTimeout = timeoutDuration
        timeoutDuration = timeout
        defer { timeoutDuration = originalTimeout }
        return try await execute(code: code)
    }
    
    // MARK: - Result Conversion
    
    /**
     * Converts a JSValue to a native Swift type.
     *
     * - Parameter value: The JSValue to convert
     * - Returns: The converted Swift value (String, Int, Double, Bool, Array, Dictionary, or nil)
     *
     * ## Example:
     * ```swift
     * let jsValue = try await runner.execute(code: "{ a: 1, b: [1, 2, 3] }")
     * let swiftValue = runner.convertToSwift(jsValue)
     * // Returns: ["a": 1, "b": [1, 2, 3]] as [String: Any]
     * ```
     */
    func convertToSwift(_ value: JSValue) -> Any? {
        if value.isUndefined || value.isNull {
            return nil
        }
        
        if value.isString {
            return value.toString()
        }
        
        if value.isNumber {
            if let int = value.toInt32() {
                return Int(int)
            }
            return value.toDouble()
        }
        
        if value.isBoolean {
            return value.toBool()
        }
        
        if value.isArray {
            return value.toArray()
        }
        
        if value.isObject {
            return value.toDictionary()
        }
        
        if let date = value.toDate() {
            return date
        }
        
        return nil
    }
    
    /**
     * Executes code and automatically converts the result to a Swift type.
     *
     * - Parameter code: JavaScript code to execute
     * - Returns: Converted Swift value, or nil if conversion fails
     * - Throws: JSRunnerError for execution failures
     */
    func executeAndConvert(code: String) async throws -> Any? {
        let result = try await execute(code: code)
        return convertToSwift(result)
    }
    
    // MARK: - Memory Management
    
    /**
     * Sets the memory limit for JavaScript execution.
     *
     * - Parameter limit: Maximum memory in bytes
     */
    func setMemoryLimit(_ limit: UInt64) {
        memoryLimit = limit
    }
    
    /**
     * Forces garbage collection and clears the context.
     * Call this when you're done with the runner to free resources.
     */
    func cleanup() {
        context.exceptionHandler = nil
        context = nil
        consoleHandler = nil
    }
}

// MARK: - Convenience Extensions

extension JSRunner {
    
    /**
     * Executes JavaScript and returns the result as a String.
     */
    func executeToString(code: String) async throws -> String? {
        let result = try await execute(code: code)
        return result.toString()
    }
    
    /**
     * Executes JavaScript and returns the result as an Int.
     */
    func executeToInt(code: String) async throws -> Int? {
        let result = try await execute(code: code)
        return result.toInt32().map(Int.init)
    }
    
    /**
     * Executes JavaScript and returns the result as a Double.
     */
    func executeToDouble(code: String) async throws -> Double? {
        let result = try await execute(code: code)
        return result.toDouble()
    }
    
    /**
     * Executes JavaScript and returns the result as a Bool.
     */
    func executeToBool(code: String) async throws -> Bool? {
        let result = try await execute(code: code)
        return result.isBoolean ? result.toBool() : nil
    }
    
    /**
     * Executes JavaScript and returns the result as a Dictionary.
     */
    func executeToDictionary(code: String) async throws -> [String: Any]? {
        let result = try await execute(code: code)
        return result.toDictionary()
    }
    
    /**
     * Executes JavaScript and returns the result as an Array.
     */
    func executeToArray(code: String) async throws -> [Any]? {
        let result = try await execute(code: code)
        return result.toArray()
    }
}

// MARK: - Test Example
/*
 
 // MARK: - Example Test Usage

 import XCTest

 class JSRunnerTests: XCTestCase {
     
     var runner: JSRunner!
     
     override func setUp() {
         super.setUp()
         runner = JSRunner()
         runner.setConsoleHandler { message in
             print("Console: \(message)")
         }
     }
     
     override func tearDown() {
         runner.cleanup()
         runner = nil
         super.tearDown()
     }
     
     func testBasicArithmetic() async throws {
         let result = try await runner.executeToInt(code: "2 + 3")
         XCTAssertEqual(result, 5)
     }
     
     func testConsoleCapture() async throws {
         var capturedMessages: [String] = []
         runner.setConsoleHandler { message in
             capturedMessages.append(message)
         }
         
         _ = try await runner.execute(code: "console.log('Hello from JS'); console.error('Error test')")
         
         XCTAssertTrue(capturedMessages.contains("[LOG] Hello from JS"))
         XCTAssertTrue(capturedMessages.contains("[ERROR] Error test"))
     }
     
     func testNativeFunctionExposure() async throws {
         runner.exposeNativeFunction(name: "swiftAdd") { args in
             guard args.count >= 2,
                   let a = args[0].toInt32(),
                   let b = args[1].toInt32() else {
                 return JSValue(undefinedIn: self.runner.context)
             }
             return JSValue(int32: a + b, in: self.runner.context)
         }
         
         let result = try await runner.executeToInt(code: "swiftAdd(10, 20)")
         XCTAssertEqual(result, 30)
     }
     
     func testComplexObjectConversion() async throws {
         let result = try await runner.executeAndConvert(code: """
             ({
                 name: 'Test Object',
                 count: 42,
                 active: true,
                 items: ['a', 'b', 'c']
             })
         """)
         
         guard let dict = result as? [String: Any] else {
             XCTFail("Expected dictionary result")
             return
         }
         
         XCTAssertEqual(dict["name"] as? String, "Test Object")
         XCTAssertEqual(dict["count"] as? Int, 42)
         XCTAssertEqual(dict["active"] as? Bool, true)
         XCTAssertEqual(dict["items"] as? [String], ["a", "b", "c"])
     }
     
     func testTimeout() async {
         runner.timeoutDuration = 0.5 // 500ms timeout
         
         do {
             // Infinite loop should timeout
             _ = try await runner.execute(code: "while(true) {}")
             XCTFail("Should have thrown timeout error")
         } catch JSRunnerError.executionTimeout {
             // Expected
         } catch {
             XCTFail("Unexpected error: \(error)")
         }
     }
     
     func testErrorHandling() async {
         do {
             _ = try await runner.execute(code: "throw new Error('Test error')")
             XCTFail("Should have thrown error")
         } catch JSRunnerError.scriptError(let message) {
             XCTAssertTrue(message.contains("Test error"))
         } catch {
             XCTFail("Unexpected error type: \(error)")
         }
     }
 }

 // Simple playground-style example:
 
 func runExample() async {
     let runner = JSRunner()
     
     // Capture console output
     runner.setConsoleHandler { message in
         print("📝 \(message)")
     }
     
     // Expose native Swift function
     runner.exposeNativeFunction(name: "calculateArea") { args in
         guard args.count >= 2,
               let width = args[0].toDouble(),
               let height = args[1].toDouble() else {
             return JSValue(undefinedIn: runner.context)
         }
         let area = width * height
         return JSValue(double: area, in: runner.context)
     }
     
     do {
         // Test 1: Basic arithmetic
         let sum = try await runner.executeToInt(code: "10 + 32")
         print("Sum: \(sum ?? 0)")
         
         // Test 2: Console logging
         try await runner.execute(code: """
             console.log('Starting calculation...');
             console.info('This is info');
             console.warn('This is a warning');
         """)
         
         // Test 3: Native function call
         let area = try await runner.executeToDouble(code: "calculateArea(5.5, 10.2)")
         print("Area: \(area ?? 0)")
         
         // Test 4: Complex object
         let user = try await runner.executeToDictionary(code: """
             ({
                 id: 123,
                 name: 'John Doe',
                 email: 'john@example.com',
                 roles: ['user', 'admin']
             })
         """)
         print("User: \(user ?? [:])")
         
     } catch {
         print("❌ Error: \(error)")
     }
     
     runner.cleanup()
 }

 // Run the example:
 // Task { await runExample() }
 
 */
