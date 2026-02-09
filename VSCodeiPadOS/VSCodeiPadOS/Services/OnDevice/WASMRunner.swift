import Foundation
import WebKit
import JavaScriptCore

// MARK: - Errors

/// Errors that can occur during WASM execution
public enum WASMError: Error, LocalizedError {
    case initializationFailed(reason: String)
    case moduleCompilationFailed(reason: String)
    case moduleLoadFailed(reason: String)
    case functionNotFound(name: String)
    case executionFailed(reason: String)
    case invalidArguments
    case memoryLimitExceeded(limit: UInt64)
    case executionTimeout(seconds: TimeInterval)
    case hostFunctionRegistrationFailed(name: String)
    case wasiNotSupported
    case invalidReturnType
    
    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let reason):
            return "WASM initialization failed: \(reason)"
        case .moduleCompilationFailed(let reason):
            return "Module compilation failed: \(reason)"
        case .moduleLoadFailed(let reason):
            return "Module load failed: \(reason)"
        case .functionNotFound(let name):
            return "Function '\(name)' not found in WASM module"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        case .invalidArguments:
            return "Invalid arguments provided to WASM function"
        case .memoryLimitExceeded(let limit):
            return "Memory limit exceeded: \(limit) bytes"
        case .executionTimeout(let seconds):
            return "Execution timed out after \(seconds) seconds"
        case .hostFunctionRegistrationFailed(let name):
            return "Failed to register host function '\(name)'"
        case .wasiNotSupported:
            return "WASI is not fully supported on iOS. Use WASI polyfills or server-side execution."
        case .invalidReturnType:
            return "Invalid return type from WASM function"
        }
    }
}

// MARK: - Configuration

/// Configuration for WASM execution environment
public struct WASMConfiguration {
    /// Memory limit in bytes (default: 128 MB)
    public var memoryLimit: UInt64
    
    /// Execution timeout in seconds (default: 30)
    public var executionTimeout: TimeInterval
    
    /// Enable debug logging
    public var enableDebugLogging: Bool
    
    /// WASI support mode
    public var wasiMode: WASIMode
    
    /// JavaScript runtime to use
    public var runtime: JavaScriptRuntime
    
    public enum WASIMode {
        case disabled
        case polyfill  // Limited support via polyfills
        case stub      // Stub implementations that log warnings
    }
    
    public enum JavaScriptRuntime {
        case wkWebView   // Full WebAssembly support via Safari engine
        case javaScriptCore  // No WebAssembly support (fallback only)
    }
    
    public init(
        memoryLimit: UInt64 = 128 * 1024 * 1024,
        executionTimeout: TimeInterval = 30.0,
        enableDebugLogging: Bool = false,
        wasiMode: WASIMode = .stub,
        runtime: JavaScriptRuntime = .wkWebView
    ) {
        self.memoryLimit = memoryLimit
        self.executionTimeout = executionTimeout
        self.enableDebugLogging = enableDebugLogging
        self.wasiMode = wasiMode
        self.runtime = runtime
    }
    
    /// Default configuration with conservative limits
    public static let `default` = WASMConfiguration()
    
    /// Configuration optimized for Pyodide
    public static let pyodide = WASMConfiguration(
        memoryLimit: 256 * 1024 * 1024,
        executionTimeout: 60.0,
        enableDebugLogging: true,
        wasiMode: .disabled
    )
    
    /// Configuration optimized for Rust WASM
    public static let rust = WASMConfiguration(
        memoryLimit: 64 * 1024 * 1024,
        executionTimeout: 10.0,
        enableDebugLogging: false,
        wasiMode: .stub
    )
}

// MARK: - WASMRunner

/// WebAssembly runner for iOS using WKWebView
/// 
/// **IMPORTANT LIMITATIONS:**
/// - WKWebView runs in separate process - all calls are async
/// - JavaScriptCore does NOT support WebAssembly
/// - WASI filesystem operations are limited/stubbed
/// - Memory limits are approximate (WebKit manages memory)
/// - Large WASM modules (>50MB) may cause memory pressure
/// - Pyodide requires ~200MB+ memory and network access
/// 
/// **Architecture:**
/// Uses WKWebView with a hidden web view to execute WASM in Safari's JavaScriptCore engine.
/// Communication happens via WKUserContentController message handlers.
public actor WASMRunner: NSObject {
    
    // MARK: - Properties
    
    private var webView: WKWebView?
    private let configuration: WASMConfiguration
    private var hostFunctions: [String: ([Any]) -> Any] = [:]
    private var continuation: CheckedContinuation<Any, Error>?
    private var executionTask: Task<Void, Never>?
    private var isInitialized = false
    private var moduleLoaded = false
    private var currentModuleName: String?
    
    // Message handler identifier
    private let messageHandlerName = "wasmRunner"
    
    // MARK: - Initialization
    
    /// Creates a new WASM runner with the specified configuration
    /// - Parameter configuration: Execution configuration (defaults to .default)
    /// - Throws: WASMError.initializationFailed if WKWebView setup fails
    public init(configuration: WASMConfiguration = .default) throws {
        self.configuration = configuration
        super.init()
        
        guard configuration.runtime == .wkWebView else {
            throw WASMError.initializationFailed(
                reason: "JavaScriptCore does not support WebAssembly. Use WKWebView runtime."
            )
        }
        
        try setupWebView()
    }
    
    private func setupWebView() throws {
        let webConfiguration = WKWebViewConfiguration()
        
        // Set up message handler for communication
        let userContentController = WKUserContentController()
        userContentController.add(self, name: messageHandlerName)
        webConfiguration.userContentController = userContentController
        
        // Enable WASM support
        webConfiguration.preferences.javaScriptEnabled = true
        if #available(iOS 15.0, *) {
            webConfiguration.preferences.isTextInteractionEnabled = true
        }
        
        // Create hidden web view
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isHidden = true
        
        // Inject WASM runtime helper
        let wasmHelperScript = WKUserScript(
            source: WASMRuntimeHelper.javascript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(wasmHelperScript)
        
        self.webView = webView
        
        // Load blank page to initialize
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
        
        if configuration.enableDebugLogging {
            print("[WASMRunner] WebView initialized")
        }
    }
    
    // MARK: - Module Loading
    
    /// Loads a WebAssembly module from Data
    /// - Parameter wasmData: The WASM binary data
    /// - Throws: WASMError.moduleLoadFailed if loading fails
    public func load(wasmData: Data) async throws {
        guard let webView = webView else {
            throw WASMError.initializationFailed(reason: "WebView not available")
        }
        
        // Convert to base64 for JavaScript transfer
        let base64String = wasmData.base64EncodedString()
        let moduleName = "wasm_module_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        
        // Build load command
        let loadScript = """
        (async function() {
            try {
                const binaryString = atob('\(base64String)');
                const bytes = new Uint8Array(binaryString.length);
                for (let i = 0; i < binaryString.length; i++) {
                    bytes[i] = binaryString.charCodeAt(i);
                }
                
                // Compile the module
                const module = await WebAssembly.compile(bytes);
                
                // Store in window.wasmModules
                if (!window.wasmModules) window.wasmModules = {};
                window.wasmModules['\(moduleName)'] = module;
                
                // Check memory requirements
                const memoryPages = module.imports.find(i => i.module === 'env' && i.name === 'memory');
                if (memoryPages) {
                    // Memory is imported, will be checked at instantiation
                }
                
                return { success: true, moduleName: '\(moduleName)' };
            } catch (error) {
                return { success: false, error: error.toString() };
            }
        })()
        """
        
        let result = try await executeJavaScript(loadScript, in: webView)
        
        guard let dict = result as? [String: Any],
              let success = dict["success"] as? Bool else {
            throw WASMError.moduleLoadFailed(reason: "Invalid response from WebView")
        }
        
        if success {
            self.currentModuleName = moduleName
            self.moduleLoaded = true
            
            if configuration.enableDebugLogging {
                print("[WASMRunner] Module '\(moduleName)' loaded successfully")
            }
        } else {
            let errorMessage = dict["error"] as? String ?? "Unknown error"
            throw WASMError.moduleLoadFailed(reason: errorMessage)
        }
    }
    
    /// Loads a WebAssembly module from a file URL
    /// - Parameter url: File URL to the .wasm file
    /// - Throws: WASMError.moduleLoadFailed if loading fails
    public func load(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        try await load(wasmData: data)
    }
    
    // MARK: - Function Execution
    
    /// Executes a function from the loaded WASM module
    /// - Parameters:
    ///   - function: Name of the exported function
    ///   - args: Arguments to pass (must be JSON-serializable)
    /// - Returns: The function result (converted from JavaScript)
    /// - Throws: WASMError if execution fails
    public func execute(function: String, args: [Any] = []) async throws -> Any {
        guard moduleLoaded, let moduleName = currentModuleName else {
            throw WASMError.moduleLoadFailed(reason: "No module loaded")
        }
        
        // Serialize arguments
        let argsJSON = try serializeArguments(args)
        
        // Build execution script with timeout
        let executionScript = """
        (async function() {
            const timeout = \(Int(configuration.executionTimeout * 1000));
            const startTime = Date.now();
            
            const timeoutPromise = new Promise((_, reject) => {
                setTimeout(() => reject(new Error('Execution timeout')), timeout);
            });
            
            const executionPromise = (async () => {
                try {
                    const module = window.wasmModules['\(moduleName)'];
                    if (!module) throw new Error('Module not found');
                    
                    // Create import object with host functions
                    const importObject = window.createImportObject ? window.createImportObject() : {};
                    
                    // Instantiate the module
                    const instance = await WebAssembly.instantiate(module, importObject);
                    
                    // Get the exported function
                    const fn = instance.exports['\(function)'];
                    if (typeof fn !== 'function') {
                        throw new Error('Function \'\(function)\' not found or not a function');
                    }
                    
                    // Parse arguments
                    const args = \(argsJSON);
                    
                    // Call the function
                    const result = fn.apply(null, args);
                    
                    return { 
                        success: true, 
                        result: result,
                        executionTime: Date.now() - startTime
                    };
                } catch (error) {
                    return { 
                        success: false, 
                        error: error.toString(),
                        executionTime: Date.now() - startTime
                    };
                }
            })();
            
            return Promise.race([executionPromise, timeoutPromise]);
        })()
        """
        
        guard let webView = webView else {
            throw WASMError.executionFailed(reason: "WebView not available")
        }
        
        let result = try await executeJavaScript(executionScript, in: webView)
        
        guard let dict = result as? [String: Any] else {
            throw WASMError.executionFailed(reason: "Invalid response format")
        }
        
        if let success = dict["success"] as? Bool, success {
            return dict["result"] ?? NSNull()
        } else {
            let errorMessage = dict["error"] as? String ?? "Unknown error"
            if errorMessage.contains("timeout") {
                throw WASMError.executionTimeout(seconds: configuration.executionTimeout)
            }
            throw WASMError.executionFailed(reason: errorMessage)
        }
    }
    
    // MARK: - Host Functions
    
    /// Exposes a native Swift function to the WASM module
    /// 
    /// **Limitation:** Host functions are called asynchronously via message handlers.
    /// Synchronous host function calls from WASM are not supported.
    /// 
    /// - Parameters:
    ///   - name: Name of the function in the import namespace
    ///   - handler: Closure that receives arguments and returns a result
    /// - Throws: WASMError.hostFunctionRegistrationFailed if registration fails
    public func exposeHostFunction(name: String, handler: @escaping ([Any]) -> Any) async throws {
        hostFunctions[name] = handler
        
        guard let webView = webView else {
            throw WASMError.hostFunctionRegistrationFailed(name: name)
        }
        
        // Register with JavaScript runtime
        let registerScript = """
        (function() {
            if (!window.hostFunctions) window.hostFunctions = {};
            window.hostFunctions['\(name)'] = function(...args) {
                // Send message to native for async execution
                window.webkit.messageHandlers.\(messageHandlerName).postMessage({
                    type: 'hostFunction',
                    name: '\(name)',
                    args: args
                });
                // Return a placeholder (actual result comes async)
                return 0;
            };
            return { success: true };
        })()
        """
        
        _ = try await executeJavaScript(registerScript, in: webView)
        
        if configuration.enableDebugLogging {
            print("[WASMRunner] Host function '\(name)' registered")
        }
    }
    
    // MARK: - WASI Support
    
    /// Configures WASI support (limited on iOS)
    /// 
    /// **IMPORTANT:** Full WASI support requires a server-side component or
    /// WASI polyfill. On iOS, this is stubbed to prevent security issues.
    /// 
    /// - Throws: WASMError.wasiNotSupported if WASI mode is .disabled
    public func configureWASI() async throws {
        switch configuration.wasiMode {
        case .disabled:
            throw WASMError.wasiNotSupported
            
        case .stub:
            // Install stub WASI implementations that log warnings
            guard let webView = webView else {
                throw WASMError.initializationFailed(reason: "WebView not available")
            }
            
            let wasiStubScript = """
            (function() {
                const wasiStub = {
                    fd_write: function() { 
                        console.warn('WASI fd_write stub called'); return 0; 
                    },
                    fd_read: function() { 
                        console.warn('WASI fd_read stub called'); return 0; 
                    },
                    fd_close: function() { 
                        console.warn('WASI fd_close stub called'); return 0; 
                    },
                    fd_seek: function() { 
                        console.warn('WASI fd_seek stub called'); return 0; 
                    },
                    path_open: function() { 
                        console.warn('WASI path_open stub called'); return -1; 
                    },
                    path_unlink_file: function() { 
                        console.warn('WASI path_unlink_file stub called'); return -1; 
                    },
                    environ_get: function() { return 0; },
                    environ_sizes_get: function() { return 0; },
                    args_get: function() { return 0; },
                    args_sizes_get: function() { return 0; },
                    proc_exit: function(code) { 
                        console.log('WASI proc_exit called with code:', code); 
                    },
                    clock_time_get: function() { return 0; }
                };
                
                if (!window.wasiSnapshotPreview1) {
                    window.wasiSnapshotPreview1 = wasiStub;
                }
                
                return { success: true };
            })()
            """
            
            _ = try await executeJavaScript(wasiStubScript, in: webView)
            
            if configuration.enableDebugLogging {
                print("[WASMRunner] WASI stub configured")
            }
            
        case .polyfill:
            // Would require loading external polyfill library
            if configuration.enableDebugLogging {
                print("[WASMRunner] WASI polyfill mode - external polyfill required")
            }
        }
    }
    
    // MARK: - Cleanup
    
    /// Unloads the current WASM module and cleans up resources
    public func unload() async {
        guard let webView = webView, let moduleName = currentModuleName else { return }
        
        let cleanupScript = """
        (function() {
            if (window.wasmModules && window.wasmModules['\(moduleName)']) {
                delete window.wasmModules['\(moduleName)'];
            }
            return { success: true };
        })()
        """
        
        _ = try? await executeJavaScript(cleanupScript, in: webView)
        
        currentModuleName = nil
        moduleLoaded = false
        
        if configuration.enableDebugLogging {
            print("[WASMRunner] Module unloaded")
        }
    }
    
    /// Destroys the runner and releases all resources
    public func destroy() {
        executionTask?.cancel()
        webView?.stopLoading()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
        webView = nil
        hostFunctions.removeAll()
        
        if configuration.enableDebugLogging {
            print("[WASMRunner] Destroyed")
        }
    }
    
    deinit {
        Task { @MainActor in
            destroy()
        }
    }
    
    // MARK: - Private Helpers
    
    private func executeJavaScript(_ script: String, in webView: WKWebView) async throws -> Any {
        return try await withCheckedThrowingContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    continuation.resume(throwing: WASMError.executionFailed(reason: error.localizedDescription))
                } else {
                    continuation.resume(returning: result ?? NSNull())
                }
            }
        }
    }
    
    private func serializeArguments(_ args: [Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: args, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw WASMError.invalidArguments
        }
        return string
    }
}

// MARK: - WKScriptMessageHandler

extension WASMRunner: WKScriptMessageHandler {
    nonisolated public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String else { return }
        
        Task {
            await handleMessage(type: type, body: body)
        }
    }
    
    private func handleMessage(type: String, body: [String: Any]) async {
        switch type {
        case "hostFunction":
            if let name = body["name"] as? String,
               let args = body["args"] as? [Any],
               let handler = hostFunctions[name] {
                _ = handler(args)
            }
        default:
            if configuration.enableDebugLogging {
                print("[WASMRunner] Unknown message type: \(type)")
            }
        }
    }
}

// MARK: - JavaScript Runtime Helper

private enum WASMRuntimeHelper {
    static let javascript = """
    (function() {
        'use strict';
        
        // WASM Module storage
        window.wasmModules = window.wasmModules || {};
        window.hostFunctions = window.hostFunctions || {};
        
        // Create import object with WASI and host functions
        window.createImportObject = function(env) {
            env = env || {};
            
            // Add WASI if available
            if (window.wasiSnapshotPreview1) {
                env.wasi_snapshot_preview1 = window.wasiSnapshotPreview1;
            }
            
            // Add host functions
            if (window.hostFunctions) {
                env.env = env.env || {};
                for (const [name, fn] of Object.entries(window.hostFunctions)) {
                    env.env[name] = fn;
                }
            }
            
            return env;
        };
        
        // Helper to convert JS values for WASM
        window.toWASM = {
            string: function(ptr, len, memory) {
                const bytes = new Uint8Array(memory.buffer, ptr, len);
                return new TextDecoder('utf8').decode(bytes);
            },
            bytes: function(ptr, len, memory) {
                return new Uint8Array(memory.buffer, ptr, len);
            }
        };
        
        // Helper to write to WASM memory
        window.fromWASM = {
            string: function(str, memory) {
                const encoder = new TextEncoder();
                const bytes = encoder.encode(str);
                // Note: Actual memory allocation must be done in WASM
                return bytes;
            }
        };
        
        console.log('[WASMRuntime] Helper loaded');
    })();
    """
}

// MARK: - Example Usage

/*
Example 1: Running a simple Rust-compiled WASM module

```swift
// Load a Rust-compiled WASM module
let runner = try WASMRunner(configuration: .rust)

// Load the module
let wasmData = try Data(contentsOf: Bundle.main.url(forResource: "calculator", withExtension: "wasm")!)
try await runner.load(wasmData: wasmData)

// Call an exported function
let result = try await runner.execute(function: "add", args: [5, 3])
print("Result: \(result)") // Prints: 8

// Clean up
await runner.unload()
```

Example 2: Running Pyodide (requires network access and large memory)

```swift
// Pyodide requires significant memory
let runner = try WASMRunner(configuration: .pyodide)

// Load Pyodide (this is a large download ~20MB)
let pyodideURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js")!
let pyodideWasmURL = URL(string: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.asm.wasm")!

// First load the JavaScript bootstrap
try await runner.load(from: pyodideWasmURL)

// Pyodide requires special initialization - see Pyodide documentation
// This is a simplified example

// Clean up
await runner.unload()
```

Example 3: Exposing host functions

```swift
let runner = try WASMRunner()

// Expose a native function to WASM
try await runner.exposeHostFunction(name: "log") { args in
    print("WASM Log: \(args)")
    return 0
}

// WASM module can now import and call this function
// (import "env" "log" (func $log (param i32)))
```

Example 4: Error handling

```swift
do {
    let runner = try WASMRunner()
    try await runner.load(wasmData: invalidData)
    let result = try await runner.execute(function: "main", args: [])
} catch let error as WASMError {
    switch error {
    case .moduleCompilationFailed(let reason):
        print("Compilation failed: \(reason)")
    case .executionTimeout(let seconds):
        print("Timeout after \(seconds) seconds")
    default:
        print("WASM Error: \(error.localizedDescription)")
    }
}
```
*/

// MARK: - Advanced Features (Future)

/*
Potential future enhancements:

1. **Streaming Compilation**: Use WebAssembly.compileStreaming() for larger modules
2. **SharedArrayBuffer**: Enable for multi-threaded WASM (requires COOP/COEP headers)
3. **WASI Polyfill Integration**: Full WASI support via wasmtime or wasmer
4. **Debugging Support**: DWARF debugging info integration
5. **Hot Reloading**: Module replacement without full reinitialization
6. **Performance Profiling**: Integration with Safari DevTools

Current limitations that may be addressed:
- Host function calls are async-only (no sync interop)
- WASI filesystem is stubbed (no real file access)
- Memory limits are WebKit-managed, not strictly enforced
- No direct memory access from Swift (must go through JS bridge)
*/
