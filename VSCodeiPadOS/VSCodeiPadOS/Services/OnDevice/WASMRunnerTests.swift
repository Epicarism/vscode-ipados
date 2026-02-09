import XCTest
@testable import VSCodeiPadOS

/// Tests for WebAssembly execution via WASMRunner
/// Comprehensive coverage of WASM loading, execution, host functions, and resource limits
final class WASMRunnerTests: XCTestCase {
    
    // MARK: - Sample WASM Bytes
    
    /// Simple add function: (i32, i32) -> i32
    /// WAT: (module (func $add (param i32 i32) (result i32) local.get 0 local.get 1 i32.add) (export "add" (func $add)))
    static let simpleAddWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D,  // magic: \0asm
        0x01, 0x00, 0x00, 0x00,  // version: 1
        0x01, 0x07, 0x01,        // type section
        0x60, 0x02, 0x7F, 0x7F, 0x01, 0x7F,  // func type: (i32, i32) -> i32
        0x03, 0x02, 0x01, 0x00,  // function section: 1 function of type 0
        0x07, 0x07, 0x01,        // export section
        0x03, 0x61, 0x64, 0x64,  // name: "add"
        0x00, 0x00,              // kind: func, index: 0
        0x0A, 0x09, 0x01,        // code section
        0x07, 0x00,              // function body size: 7, no locals
        0x20, 0x00,              // local.get 0
        0x20, 0x01,              // local.get 1
        0x6A,                    // i32.add
        0x0B                     // end
    ]
    
    /// Simple multiply function: (i32, i32) -> i32
    static let multiplyWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x07, 0x01, 0x60, 0x02, 0x7F, 0x7F, 0x01, 0x7F,
        0x03, 0x02, 0x01, 0x00,
        0x07, 0x0B, 0x01, 0x08, 0x6D, 0x75, 0x6C, 0x74, 0x69, 0x70, 0x6C, 0x79, 0x00, 0x00,
        0x0A, 0x09, 0x01, 0x07, 0x00,
        0x20, 0x00,
        0x20, 0x01,
        0x6C,  // i32.mul
        0x0B
    ]
    
    /// WASM with memory: stores and loads i32
    /// (module
    ///   (memory 1)
    ///   (func $store (param i32 i32) (i32.store (local.get 0) (local.get 1)))
    ///   (func $load (param i32) (result i32) (i32.load (local.get 0)))
    ///   (export "store" (func $store))
    ///   (export "load" (func $load))
    /// )
    static let memoryWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x0B, 0x02,  // type section with 2 types
        0x60, 0x02, 0x7F, 0x7F, 0x00,  // store: (i32, i32) -> ()
        0x60, 0x01, 0x7F, 0x01, 0x7F,  // load: (i32) -> i32
        0x03, 0x03, 0x02, 0x00, 0x01,  // function section
        0x05, 0x03, 0x01, 0x00, 0x01,  // memory section: 1 page min
        0x07, 0x11, 0x02,  // export section with 2 exports
        0x05, 0x73, 0x74, 0x6F, 0x72, 0x65, 0x00, 0x00,  // "store"
        0x04, 0x6C, 0x6F, 0x61, 0x64, 0x00, 0x01,  // "load"
        0x0A, 0x11, 0x02,  // code section with 2 functions
        0x06, 0x00, 0x20, 0x00, 0x20, 0x01, 0x36, 0x02, 0x00, 0x0B,  // store body
        0x07, 0x00, 0x20, 0x00, 0x28, 0x02, 0x00, 0x0B  // load body
    ]
    
    /// WASM that imports a host function and calls it
    /// Expects host to provide: extern "env" "host_log" (i32)
    static let hostFunctionWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x08, 0x02,  // type section
        0x60, 0x01, 0x7F, 0x00,  // host_log type: (i32) -> ()
        0x60, 0x01, 0x7F, 0x00,  // call_log type: (i32) -> ()
        0x02, 0x0D, 0x01,  // import section
        0x03, 0x65, 0x6E, 0x76,  // module: "env"
        0x08, 0x68, 0x6F, 0x73, 0x74, 0x5F, 0x6C, 0x6F, 0x67,  // name: "host_log"
        0x00, 0x00,  // kind: func, type index 0
        0x03, 0x02, 0x01, 0x01,  // function section
        0x07, 0x0D, 0x01,  // export section
        0x08, 0x63, 0x61, 0x6C, 0x6C, 0x5F, 0x6C, 0x6F, 0x67, 0x00, 0x01,  // "call_log"
        0x0A, 0x06, 0x01,  // code section
        0x04, 0x00, 0x20, 0x00, 0x10, 0x00, 0x0B  // call imported func 0
    ]
    
    /// WASM with string in memory - exports pointer and length
    static let stringWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x60, 0x01, 0x7F, 0x01, 0x7F,  // (i32) -> i32
        0x03, 0x02, 0x01, 0x00,
        0x05, 0x03, 0x01, 0x00, 0x01,  // memory 1 page
        0x07, 0x10, 0x02,  // exports
        0x07, 0x67, 0x65, 0x74, 0x50, 0x74, 0x72, 0x00, 0x00,  // "getPtr"
        0x09, 0x67, 0x65, 0x74, 0x4C, 0x65, 0x6E, 0x00, 0x01,  // "getLen"
        0x0A, 0x0A, 0x02,
        0x02, 0x00, 0x41, 0x00, 0x0B,  // getPtr returns 0 (offset)
        0x04, 0x00, 0x41, 0x0D, 0x0B,  // getLen returns 13 ("Hello, WASM!")
        0x0B, 0x14, 0x01,  // data section
        0x00, 0x41, 0x00, 0x0B,  // passive, offset 0
        0x0D, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x41, 0x53, 0x4D, 0x21, 0x00  // "Hello, WASM!\0"
    ]
    
    /// Invalid WASM - corrupted magic number
    static let invalidWASM: [UInt8] = [
        0x00, 0x00, 0x00, 0x00,  // invalid magic
        0x01, 0x00, 0x00, 0x00
    ]
    
    /// Invalid WASM - truncated
    static let truncatedWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D,  // magic
        0x01, 0x00, 0x00, 0x00,  // version
        0x01, 0x07, 0x01         // incomplete type section
    ]
    
    /// WASM with infinite loop (for timeout testing)
    /// (loop (br 0))
    static let infiniteLoopWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x04, 0x01, 0x60, 0x00, 0x00,  // () -> ()
        0x03, 0x02, 0x01, 0x00,
        0x07, 0x07, 0x01, 0x04, 0x6C, 0x6F, 0x6F, 0x70, 0x00, 0x00,  // "loop"
        0x0A, 0x06, 0x01, 0x04, 0x00,
        0x03, 0x40,  // loop
        0x0C, 0x00,  // br 0
        0x0B,        // end
        0x0B         // end
    ]
    
    /// WASM that allocates a lot of memory
    /// Calls memory.grow repeatedly
    static let memoryHogWASM: [UInt8] = [
        0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x05, 0x01, 0x60, 0x01, 0x7F, 0x00,  // (i32) -> ()
        0x03, 0x02, 0x01, 0x00,
        0x05, 0x03, 0x01, 0x00, 0x01,  // memory 1 page
        0x07, 0x0A, 0x01, 0x06, 0x67, 0x72, 0x6F, 0x77, 0x00, 0x00,  // "grow"
        0x0A, 0x08, 0x01, 0x06, 0x00,
        0x20, 0x00,  // local.get 0 (pages to grow)
        0x40, 0x00,  // memory.grow
        0x1A,        // drop
        0x0B
    ]
    
    // MARK: - Properties
    
    var runner: WASMRunner!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        runner = WASMRunner()
    }
    
    override func tearDown() {
        runner = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases: WASM Loading
    
    /// Test loading a valid WASM module
    func testLoadValidWASM() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        XCTAssertNotNil(module)
    }
    
    /// Test loading WASM with multiple functions
    func testLoadMultipleFunctions() throws {
        let data = Data(WASMRunnerTests.multiplyWASM)
        let module = try runner.loadModule(from: data)
        XCTAssertNotNil(module)
        
        // Verify exported function exists
        let exports = try runner.getExports(module)
        XCTAssertTrue(exports.contains("multiply"))
    }
    
    /// Test error handling for invalid/corrupted WASM
    func testLoadInvalidWASM() {
        let data = Data(WASMRunnerTests.invalidWASM)
        XCTAssertThrowsError(try runner.loadModule(from: data)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .invalidMagic)
        }
    }
    
    /// Test error handling for truncated WASM
    func testLoadTruncatedWASM() {
        let data = Data(WASMRunnerTests.truncatedWASM)
        XCTAssertThrowsError(try runner.loadModule(from: data)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .truncatedModule)
        }
    }
    
    /// Test loading empty data
    func testLoadEmptyData() {
        let data = Data()
        XCTAssertThrowsError(try runner.loadModule(from: data)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .emptyModule)
        }
    }
    
    /// Test loading oversized WASM (if there's a limit)
    func testLoadOversizedWASM() {
        // Create a large invalid WASM-like blob
        var largeData = Data(repeating: 0x00, count: 100 * 1024 * 1024)  // 100MB
        largeData[0] = 0x00
        largeData[1] = 0x61
        largeData[2] = 0x73
        largeData[3] = 0x6D  // magic
        largeData[4] = 0x01
        largeData[5] = 0x00
        largeData[6] = 0x00
        largeData[7] = 0x00  // version
        
        XCTAssertThrowsError(try runner.loadModule(from: largeData)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .moduleTooLarge)
        }
    }
    
    // MARK: - Test Cases: Function Execution
    
    /// Test simple add function execution
    func testExecuteSimpleAdd() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        let result = try runner.call(instance, function: "add", args: [5, 3])
        XCTAssertEqual(result, .i32(8))
    }
    
    /// Test multiply function with different values
    func testExecuteMultiply() throws {
        let data = Data(WASMRunnerTests.multiplyWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        let result1 = try runner.call(instance, function: "multiply", args: [7, 6])
        XCTAssertEqual(result1, .i32(42))
        
        let result2 = try runner.call(instance, function: "multiply", args: [0, 100])
        XCTAssertEqual(result2, .i32(0))
        
        let result3 = try runner.call(instance, function: "multiply", args: [-5, 3])
        XCTAssertEqual(result3, .i32(-15))
    }
    
    /// Test calling non-existent function
    func testExecuteNonExistentFunction() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        XCTAssertThrowsError(try runner.call(instance, function: "nonexistent", args: [])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .functionNotFound("nonexistent"))
        }
    }
    
    /// Test calling with wrong number of arguments
    func testExecuteWrongArgumentCount() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        XCTAssertThrowsError(try runner.call(instance, function: "add", args: [1])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .invalidArgumentCount(expected: 2, got: 1))
        }
    }
    
    /// Test calling with wrong argument types
    func testExecuteWrongArgumentTypes() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Try to pass f64 instead of i32 (if runner supports type checking)
        XCTAssertThrowsError(try runner.call(instance, function: "add", args: [5.5, 3.3])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .typeMismatch)
        }
    }
    
    // MARK: - Test Cases: Memory Operations
    
    /// Test memory store and load operations
    func testMemoryOperations() throws {
        let data = Data(WASMRunnerTests.memoryWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Store value at offset 0
        try runner.call(instance, function: "store", args: [0, 42])
        
        // Load value back
        let result = try runner.call(instance, function: "load", args: [0])
        XCTAssertEqual(result, .i32(42))
        
        // Store at different offset
        try runner.call(instance, function: "store", args: [4, 100])
        let result2 = try runner.call(instance, function: "load", args: [4])
        XCTAssertEqual(result2, .i32(100))
    }
    
    /// Test reading string from WASM memory
    func testReadStringFromMemory() throws {
        let data = Data(WASMRunnerTests.stringWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Get pointer and length
        let ptrResult = try runner.call(instance, function: "getPtr", args: [])
        let lenResult = try runner.call(instance, function: "getLen", args: [])
        
        guard case .i32(let ptr) = ptrResult,
              case .i32(let len) = lenResult else {
            XCTFail("Expected i32 results")
            return
        }
        
        // Read string from memory
        let string = try runner.readString(from: instance, offset: Int(ptr), length: Int(len))
        XCTAssertEqual(string, "Hello, WASM!")
    }
    
    /// Test writing string to WASM memory
    func testWriteStringToMemory() throws {
        let data = Data(WASMRunnerTests.memoryWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        let testString = "Test"
        try runner.writeString(to: instance, offset: 16, string: testString)
        
        // Verify by reading back (if we had a function to read it)
        // For now, just verify no error was thrown
    }
    
    /// Test out-of-bounds memory access
    func testOutOfBoundsMemoryAccess() throws {
        let data = Data(WASMRunnerTests.memoryWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Try to access beyond allocated memory (64KB per page)
        XCTAssertThrowsError(try runner.readMemory(from: instance, offset: 64 * 1024, length: 4)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .outOfBoundsMemoryAccess)
        }
    }
    
    /// Test memory growth
    func testMemoryGrowth() throws {
        let data = Data(WASMRunnerTests.memoryHogWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Grow by 1 page (64KB)
        try runner.call(instance, function: "grow", args: [1])
        
        // Should now be able to access higher addresses
        // Verify by checking memory size increased
        let size = try runner.getMemorySize(instance)
        XCTAssertEqual(size, 2)  // 2 pages (1 original + 1 grown)
    }
    
    // MARK: - Test Cases: Host Function Exposure
    
    /// Test exposing Swift function to WASM
    func testExposeSwiftFunction() throws {
        let data = Data(WASMRunnerTests.hostFunctionWASM)
        let module = try runner.loadModule(from: data)
        
        var capturedValue: Int32?
        let hostLog: WASMHostFunction = { args in
            guard case .i32(let value) = args.first else {
                return .void
            }
            capturedValue = value
            return .void
        }
        
        let imports = WASMImports()
        imports.addFunction(module: "env", name: "host_log", signature: "(i32)", implementation: hostLog)
        
        let instance = try runner.instantiate(module, with: imports)
        
        // Call WASM function which calls host function
        try runner.call(instance, function: "call_log", args: [42])
        
        XCTAssertEqual(capturedValue, 42)
    }
    
    /// Test host function with return value
    func testHostFunctionWithReturn() throws {
        let doubleHost: WASMHostFunction = { args in
            guard case .i32(let value) = args.first else {
                return .i32(0)
            }
            return .i32(value * 2)
        }
        
        let imports = WASMImports()
        imports.addFunction(module: "env", name: "double", signature: "(i32) -> (i32)", implementation: doubleHost)
        
        // Create a simple WASM that imports and uses double
        let simpleWASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x08, 0x02,
            0x60, 0x01, 0x7F, 0x01, 0x7F,  // (i32) -> i32
            0x60, 0x00, 0x01, 0x7F,        // () -> i32
            0x02, 0x0C, 0x01,
            0x03, 0x65, 0x6E, 0x76,  // "env"
            0x06, 0x64, 0x6F, 0x75, 0x62, 0x6C, 0x65,  // "double"
            0x00, 0x00,
            0x07, 0x07, 0x01, 0x04, 0x74, 0x65, 0x73, 0x74, 0x00, 0x01,
            0x0A, 0x06, 0x01, 0x04, 0x00, 0x41, 0x15, 0x10, 0x00, 0x0B  // call with 21
        ]
        
        let data = Data(simpleWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module, with: imports)
        
        let result = try runner.call(instance, function: "test", args: [])
        XCTAssertEqual(result, .i32(42))  // 21 * 2
    }
    
    /// Test host function error handling
    func testHostFunctionErrorHandling() throws {
        let failingHost: WASMHostFunction = { _ in
            throw WASMError.hostFunctionFailed("Intentional error")
        }
        
        let imports = WASMImports()
        imports.addFunction(module: "env", name: "fail", signature: "()", implementation: failingHost)
        
        // Create WASM that calls failing host function
        let simpleWASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x04, 0x01, 0x60, 0x00, 0x00,
            0x02, 0x09, 0x01,
            0x03, 0x65, 0x6E, 0x76, 0x04, 0x66, 0x61, 0x69, 0x6C, 0x00, 0x00,
            0x03, 0x02, 0x01, 0x00,
            0x07, 0x07, 0x01, 0x04, 0x63, 0x61, 0x6C, 0x6C, 0x00, 0x01,
            0x0A, 0x05, 0x01, 0x03, 0x00, 0x10, 0x00, 0x0B
        ]
        
        let data = Data(simpleWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module, with: imports)
        
        XCTAssertThrowsError(try runner.call(instance, function: "call", args: [])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .hostFunctionFailed("Intentional error"))
        }
    }
    
    // MARK: - Test Cases: Resource Limits
    
    /// Test memory limit enforcement
    func testMemoryLimitEnforcement() throws {
        let data = Data(WASMRunnerTests.memoryHogWASM)
        let module = try runner.loadModule(from: data)
        
        // Configure with 2 page limit
        let config = WASMConfig(maxMemoryPages: 2)
        let instance = try runner.instantiate(module, config: config)
        
        // First grow should succeed (1 -> 2 pages)
        try runner.call(instance, function: "grow", args: [1])
        
        // Second grow should fail (would exceed 2 page limit)
        XCTAssertThrowsError(try runner.call(instance, function: "grow", args: [1])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .memoryLimitExceeded)
        }
    }
    
    /// Test execution timeout
    func testExecutionTimeout() throws {
        let data = Data(WASMRunnerTests.infiniteLoopWASM)
        let module = try runner.loadModule(from: data)
        
        let config = WASMConfig(maxExecutionTime: 0.1)  // 100ms timeout
        let instance = try runner.instantiate(module, config: config)
        
        let expectation = self.expectation(description: "Timeout")
        
        DispatchQueue.global().async {
            do {
                _ = try self.runner.call(instance, function: "loop", args: [])
                XCTFail("Should have timed out")
            } catch let error as WASMError {
                XCTAssertEqual(error, .executionTimeout)
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    /// Test call stack depth limit
    func testStackDepthLimit() throws {
        // Create recursive WASM
        let recursiveWASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x06, 0x01, 0x60, 0x01, 0x7F, 0x01, 0x7F,
            0x03, 0x02, 0x01, 0x00,
            0x07, 0x0B, 0x01, 0x08, 0x72, 0x65, 0x63, 0x75, 0x72, 0x73, 0x65, 0x00, 0x00,
            0x0A, 0x14, 0x01, 0x12, 0x00,
            0x20, 0x00,  // local.get 0
            0x41, 0x01,  // i32.const 1
            0x46,        // i32.eq
            0x04, 0x40,  // if
            0x20, 0x00,  // then: return local.get 0
            0x0B,        // end
            0x20, 0x00,  // local.get 0
            0x41, 0x01,  // i32.const 1
            0x6B,        // i32.sub
            0x10, 0x00,  // call 0 (recursive)
            0x0B         // end
        ]
        
        let data = Data(recursiveWASM)
        let module = try runner.loadModule(from: data)
        
        let config = WASMConfig(maxCallStackDepth: 100)
        let instance = try runner.instantiate(module, config: config)
        
        // This should work (depth 50 < 100)
        let result1 = try runner.call(instance, function: "recurse", args: [50])
        XCTAssertEqual(result1, .i32(1))
        
        // This should fail (depth 200 > 100)
        XCTAssertThrowsError(try runner.call(instance, function: "recurse", args: [200])) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .callStackExhausted)
        }
    }
    
    // MARK: - Test Cases: WASI (if implemented)
    
    #if ENABLE_WASI
    /// Test WASI file operations (if WASI is implemented)
    func testWASIFileOperations() throws {
        // This test only runs if WASI is enabled
        let wasiWASM: [UInt8] = [
            // WASI-enabled WASM that opens and reads a file
            // This is a placeholder - real WASI test would need actual WASI module
        ]
        
        let data = Data(wasiWASM)
        let module = try runner.loadModule(from: data)
        let wasi = WASIContext()
            .withPreopen("/tmp", mappedTo: FileManager.default.temporaryDirectory)
            .withStdoutPipe()
        
        let instance = try runner.instantiate(module, wasi: wasi)
        
        // Run the module
        try runner.start(instance)
        
        // Check stdout
        let output = wasi.getStdout()
        XCTAssertFalse(output.isEmpty)
    }
    
    /// Test WASI environment variables
    func testWASIEnvironmentVariables() throws {
        let env = ["TEST_VAR": "test_value"]
        let wasi = WASIContext()
            .withEnvironment(env)
        
        // Load and run WASI module that reads env vars
        // Verify it can access TEST_VAR
    }
    
    /// Test WASI arguments
    func testWASIArguments() throws {
        let args = ["prog", "arg1", "arg2"]
        let wasi = WASIContext()
            .withArguments(args)
        
        // Load and run WASI module that accesses args
        // Verify it receives correct arguments
    }
    #endif
    
    // MARK: - Test Cases: Edge Cases & Error Handling
    
    /// Test reusing module for multiple instances
    func testModuleReuse() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        
        // Create multiple independent instances
        let instance1 = try runner.instantiate(module)
        let instance2 = try runner.instantiate(module)
        
        // Each should work independently
        let result1 = try runner.call(instance1, function: "add", args: [1, 2])
        let result2 = try runner.call(instance2, function: "add", args: [3, 4])
        
        XCTAssertEqual(result1, .i32(3))
        XCTAssertEqual(result2, .i32(7))
    }
    
    /// Test instance isolation (memory should be separate)
    func testInstanceIsolation() throws {
        let data = Data(WASMRunnerTests.memoryWASM)
        let module = try runner.loadModule(from: data)
        
        let instance1 = try runner.instantiate(module)
        let instance2 = try runner.instantiate(module)
        
        // Store different values in each instance
        try runner.call(instance1, function: "store", args: [0, 100])
        try runner.call(instance2, function: "store", args: [0, 200])
        
        // Verify isolation
        let result1 = try runner.call(instance1, function: "load", args: [0])
        let result2 = try runner.call(instance2, function: "load", args: [0])
        
        XCTAssertEqual(result1, .i32(100))
        XCTAssertEqual(result2, .i32(200))
    }
    
    /// Test concurrent execution (if supported)
    func testConcurrentExecution() throws {
        let data = Data(WASMRunnerTests.simpleAddWASM)
        let module = try runner.loadModule(from: data)
        
        let iterations = 100
        let expectation = self.expectation(description: "Concurrent execution")
        expectation.expectedFulfillmentCount = iterations
        
        for i in 0..<iterations {
            DispatchQueue.global().async {
                do {
                    let instance = try self.runner.instantiate(module)
                    let result = try self.runner.call(instance, function: "add", args: [i, i])
                    XCTAssertEqual(result, .i32(i * 2))
                    expectation.fulfill()
                } catch {
                    XCTFail("Concurrent execution failed: \(error)")
                }
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    /// Test i64 values (if supported)
    func testI64Operations() throws {
        // WASM with i64 operations
        let i64WASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x07, 0x01, 0x60, 0x02, 0x7E, 0x7E, 0x01, 0x7E,  // (i64, i64) -> i64
            0x03, 0x02, 0x01, 0x00,
            0x07, 0x06, 0x01, 0x03, 0x61, 0x64, 0x64, 0x00, 0x00,
            0x0A, 0x0A, 0x01, 0x08, 0x00,
            0x20, 0x00,
            0x20, 0x01,
            0x7C,  // i64.add
            0x0B
        ]
        
        let data = Data(i64WASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        let result = try runner.call(instance, function: "add", args: [Int64.max / 2, 1])
        XCTAssertEqual(result, .i64(Int64.max / 2 + 1))
    }
    
    /// Test f32 and f64 floating point operations
    func testFloatOperations() throws {
        // WASM with floating point
        let floatWASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x09, 0x02,
            0x60, 0x02, 0x7D, 0x7D, 0x01, 0x7D,  // (f32, f32) -> f32
            0x60, 0x02, 0x7C, 0x7C, 0x01, 0x7C,  // (f64, f64) -> f64
            0x03, 0x03, 0x02, 0x00, 0x01,
            0x07, 0x11, 0x02,
            0x08, 0x61, 0x64, 0x64, 0x46, 0x33, 0x32, 0x00, 0x00,  // "addF32"
            0x08, 0x61, 0x64, 0x64, 0x46, 0x36, 0x34, 0x00, 0x01,  // "addF64"
            0x0A, 0x13, 0x02,
            0x08, 0x00, 0x20, 0x00, 0x20, 0x01, 0x92, 0x0B,  // f32.add
            0x08, 0x00, 0x20, 0x00, 0x20, 0x01, 0xA0, 0x0B   // f64.add
        ]
        
        let data = Data(floatWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        let f32Result = try runner.call(instance, function: "addF32", args: [1.5, 2.5])
        XCTAssertEqual(f32Result, .f32(4.0))
        
        let f64Result = try runner.call(instance, function: "addF64", args: [1.1, 2.2])
        XCTAssertEqual(f64Result, .f64(3.3))
    }
    
    /// Test handling of invalid UTF-8 in strings
    func testInvalidUTF8Handling() throws {
        let data = Data(WASMRunnerTests.memoryWASM)
        let module = try runner.loadModule(from: data)
        let instance = try runner.instantiate(module)
        
        // Write invalid UTF-8 bytes
        var invalidBytes = Data([0x80, 0x81, 0x82, 0x83])
        try runner.writeMemory(to: instance, offset: 0, data: invalidBytes)
        
        // Reading as string should fail gracefully
        XCTAssertThrowsError(try runner.readString(from: instance, offset: 0, length: 4)) { error in
            guard let wasmError = error as? WASMError else {
                XCTFail("Expected WASMError")
                return
            }
            XCTAssertEqual(wasmError, .invalidUTF8)
        }
    }
    
    /// Test multiple export types (functions, memory, globals, tables)
    func testMultipleExportTypes() throws {
        // WASM with multiple export types
        let multiExportWASM: [UInt8] = [
            0x00, 0x61, 0x73, 0x6D, 0x01, 0x00, 0x00, 0x00,
            0x01, 0x04, 0x01, 0x60, 0x00, 0x00,
            0x03, 0x02, 0x01, 0x00,
            0x04, 0x04, 0x01, 0x70, 0x00, 0x01,  // table
            0x05, 0x03, 0x01, 0x00, 0x01,        // memory
            0x06, 0x06, 0x01, 0x7F, 0x00, 0x41, 0x2A, 0x0B,  // global i32 = 42
            0x07, 0x19, 0x04,  // export section
            0x04, 0x66, 0x75, 0x6E, 0x63, 0x00, 0x00,  // "func"
            0x03, 0x6D, 0x65, 0x6D, 0x02, 0x00,       // "mem"
            0x05, 0x74, 0x61, 0x62, 0x6C, 0x01, 0x01, 0x00,  // "tab"
            0x06, 0x67, 0x6C, 0x6F, 0x62, 0x03, 0x03, 0x00,  // "glob"
            0x0A, 0x04, 0x01, 0x02, 0x00, 0x0B
        ]
        
        let data = Data(multiExportWASM)
        let module = try runner.loadModule(from: data)
        let exports = try runner.getExports(module)
        
        XCTAssertTrue(exports.contains("func"))
        XCTAssertTrue(exports.contains("mem"))
        XCTAssertTrue(exports.contains("tab"))
        XCTAssertTrue(exports.contains("glob"))
    }
    
    /// Test module validation without instantiation
    func testModuleValidation() throws {
        let validData = Data(WASMRunnerTests.simpleAddWASM)
        XCTAssertTrue(try runner.validateModule(validData))
        
        let invalidData = Data(WASMRunnerTests.invalidWASM)
        XCTAssertFalse(try runner.validateModule(invalidData))
    }
}

// MARK: - Supporting Types (Expected interfaces)

/// WASM value types
enum WASMValue: Equatable {
    case i32(Int32)
    case i64(Int64)
    case f32(Float)
    case f64(Double)
    case void
}

/// WASM errors
enum WASMError: Error, Equatable {
    case invalidMagic
    case truncatedModule
    case emptyModule
    case moduleTooLarge
    case invalidSection
    case functionNotFound(String)
    case invalidArgumentCount(expected: Int, got: Int)
    case typeMismatch
    case outOfBoundsMemoryAccess
    case memoryLimitExceeded
    case executionTimeout
    case callStackExhausted
    case hostFunctionFailed(String)
    case invalidUTF8
    case validationFailed(String)
    case instantiationFailed(String)
}

/// Protocol for WASM host functions
typealias WASMHostFunction = ([WASMValue]) throws -> WASMValue

/// WASM imports configuration
class WASMImports {
    private var functions: [(module: String, name: String, signature: String, implementation: WASMHostFunction)] = []
    
    func addFunction(module: String, name: String, signature: String, implementation: @escaping WASMHostFunction) {
        functions.append((module, name, signature, implementation))
    }
    
    func getFunctions() -> [(module: String, name: String, signature: String, implementation: WASMHostFunction)] {
        return functions
    }
}

/// WASM configuration
struct WASMConfig {
    let maxMemoryPages: UInt32
    let maxExecutionTime: TimeInterval
    let maxCallStackDepth: Int
    
    init(maxMemoryPages: UInt32 = 65536, maxExecutionTime: TimeInterval = 30.0, maxCallStackDepth: Int = 10000) {
        self.maxMemoryPages = maxMemoryPages
        self.maxExecutionTime = maxExecutionTime
        self.maxCallStackDepth = maxCallStackDepth
    }
}

#if ENABLE_WASI
/// WASI context for file operations and system interfaces
class WASIContext {
    private var preopens: [(guest: String, host: URL)] = []
    private var environment: [String: String] = [:]
    private var arguments: [String] = []
    private var stdoutBuffer: Data = Data()
    
    func withPreopen(_ guest: String, mappedTo host: URL) -> Self {
        preopens.append((guest, host))
        return self
    }
    
    func withEnvironment(_ env: [String: String]) -> Self {
        environment = env
        return self
    }
    
    func withArguments(_ args: [String]) -> Self {
        arguments = args
        return self
    }
    
    func withStdoutPipe() -> Self {
        return self
    }
    
    func getStdout() -> String {
        return String(data: stdoutBuffer, encoding: .utf8) ?? ""
    }
}
#endif

/// Protocol definition for WASMRunner (tests assume this interface)
protocol WASMRunnerProtocol {
    func loadModule(from data: Data) throws -> WASMModule
    func validateModule(_ data: Data) throws -> Bool
    func instantiate(_ module: WASMModule, with imports: WASMImports) throws -> WASMInstance
    func instantiate(_ module: WASMModule, config: WASMConfig) throws -> WASMInstance
    func instantiate(_ module: WASMModule) throws -> WASMInstance
    func call(_ instance: WASMInstance, function: String, args: [Any]) throws -> WASMValue
    func getExports(_ module: WASMModule) throws -> [String]
    func readString(from instance: WASMInstance, offset: Int, length: Int) throws -> String
    func writeString(to instance: WASMInstance, offset: Int, string: String) throws
    func readMemory(from instance: WASMInstance, offset: Int, length: Int) throws -> Data
    func writeMemory(to instance: WASMInstance, offset: Int, data: Data) throws
    func getMemorySize(_ instance: WASMInstance) throws -> Int
    #if ENABLE_WASI
    func instantiate(_ module: WASMModule, wasi: WASIContext) throws -> WASMInstance
    func start(_ instance: WASMInstance) throws
    #endif
}

/// Placeholder types (actual implementation would have real types)
class WASMModule {}
class WASMInstance {}

/// The actual WASMRunner class (expected to be implemented)
class WASMRunner: WASMRunnerProtocol {
    func loadModule(from data: Data) throws -> WASMModule {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func validateModule(_ data: Data) throws -> Bool {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func instantiate(_ module: WASMModule, with imports: WASMImports) throws -> WASMInstance {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func instantiate(_ module: WASMModule, config: WASMConfig) throws -> WASMInstance {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func instantiate(_ module: WASMModule) throws -> WASMInstance {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func call(_ instance: WASMInstance, function: String, args: [Any]) throws -> WASMValue {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func getExports(_ module: WASMModule) throws -> [String] {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func readString(from instance: WASMInstance, offset: Int, length: Int) throws -> String {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func writeString(to instance: WASMInstance, offset: Int, string: String) throws {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func readMemory(from instance: WASMInstance, offset: Int, length: Int) throws -> Data {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func writeMemory(to instance: WASMInstance, offset: Int, data: Data) throws {
        fatalError("WASMRunner not implemented - this is a test file")
    }
    
    func getMemorySize(_ instance: WASMInstance) throws -> Int {
        fatalError("WASMRunner not implemented - this is a test file")
    }
}