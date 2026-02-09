import Foundation

// MARK: - Python Execution Architecture Decision
//
// This file documents the extensive research and rationale for why direct
// Python execution via PythonKit is NOT feasible on iOS/iPadOS for App Store
// distribution.
//
// =============================================================================
// RESEARCH FINDINGS
// =============================================================================
//
// 1. PythonKit Architecture
//    - Original PythonKit (pvieito/PythonKit) uses dlopen()/dlsym() to
//      dynamically load libpython at runtime
//    - Fork kewlbear/PythonKitIOS attempts iOS support but still relies on
//      dynamic library loading mechanisms
//
// 2. iOS Sandbox Restrictions
//    - iOS does NOT allow dlopen() of arbitrary dynamic libraries in App Store apps
//    - Dynamic library loading is considered a security risk (code injection)
//    - Only system frameworks and bundled frameworks can be loaded
//    - The iOS kernel enforces these restrictions at the system level
//
// 3. Embedded Python Challenges
//    - Python-Apple-support (beeware/kewlbear) can build static Python libraries
//    - However, this requires:
//      * Custom Xcode build phases
//      * 50+ MB additional binary size
//      * Complex patch management for Python versions
//      * Recompilation for every Python version update
//
// 4. Scientific Library Limitations
//    - numpy, pandas, scipy require compiled C extensions
//    - These extensions use:
//      * Platform-specific assembly (SIMD instructions)
//      * BLAS/LAPACK libraries (not available on iOS)
//      * Memory mapping features restricted by iOS sandbox
//    - Cross-compiling these for iOS ARM64 is extremely complex
//
// 5. JIT Compilation Restrictions
//    - Python's eval()/exec() create executable code at runtime
//    - iOS requires com.apple.security.cs.allow-jit entitlement
//    - This entitlement is ONLY available to:
//      * Web browsers (WKWebView JIT)
//      * Apps with special justification (not general Python execution)
//
// =============================================================================
// ALTERNATIVES CONSIDERED
// =============================================================================
//
// Option 1: Pyodide via WASM (RECOMMENDED)
//    - Pyodide = Python compiled to WebAssembly
//    - Runs in WKWebView JavaScript context
//    - Pros: No native code restrictions, full numpy/pandas support via WASM
//    - Cons: 10-50x slower than native, large initial download (~20MB)
//    - Status: Best option for in-browser Python execution
//
// Option 2: Remote Execution
//    - Execute Python on server, stream results
//    - Pros: Full Python environment, zero iOS restrictions
//    - Cons: Requires internet, latency, privacy concerns
//    - Status: Good for production apps with server infrastructure
//
// Option 3: Restricted Static Python
//    - Use Python-Apple-support for basic stdlib only
//    - Pros: Truly offline, native performance
//    - Cons: No scientific libraries, complex build process, large app size
//    - Status: Viable for simple scripts only
//
// Option 4: transpilation
//    - Convert Python to Swift/JavaScript
//    - Pros: Native execution, no runtime overhead
//    - Cons: Limited language compatibility, complex implementation
//    - Status: Research phase only
//
// =============================================================================

// MARK: - Error Types

enum PythonRunnerError: Error, LocalizedError {
    case pythonExecutionNotSupported
    case numpyPandasNotAvailable
    case networkRequired
    case timeout
    case memoryLimitExceeded
    case wasmNotInitialized
    case remoteServerUnavailable
    
    var errorDescription: String? {
        switch self {
        case .pythonExecutionNotSupported:
            return "Native Python execution is not supported on iOS/iPadOS. " +
                   "Use executeWebAssembly(code:) or executeRemote(code:) instead."
        case .numpyPandasNotAvailable:
            return "numpy and pandas require WebAssembly or remote execution. " +
                   "Native iOS execution does not support compiled C extensions."
        case .networkRequired:
            return "This operation requires an internet connection."
        case .timeout:
            return "Python execution timed out."
        case .memoryLimitExceeded:
            return "Python execution exceeded memory limits."
        case .wasmNotInitialized:
            return "WebAssembly runtime not initialized. Call initializeWASM() first."
        case .remoteServerUnavailable:
            return "Remote Python server is unavailable."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .pythonExecutionNotSupported:
            return "Use WebAssembly execution for client-side Python or remote " +
                   "execution for full environment support."
        case .numpyPandasNotAvailable:
            return "Use WebAssembly execution which supports numpy/pandas via WASM."
        case .networkRequired:
            return "Connect to Wi-Fi or cellular network and try again."
        case .timeout:
            return "Simplify your code or increase the timeout threshold."
        case .memoryLimitExceeded:
            return "Reduce data size or use streaming/chunked processing."
        case .wasmNotInitialized:
            return "Initialize the WASM runtime before executing code."
        case .remoteServerUnavailable:
            return "Check server status or use WebAssembly fallback."
        }
    }
}

// MARK: - PythonRunner

/// A service that provides Python execution capabilities on iOS/iPadOS.
///
/// ⚠️ IMPORTANT: This is a STUB implementation documenting why native Python
/// execution is not feasible on iOS/iPadOS. See the extensive comments above
/// for technical details.
///
/// Use this class to:
/// 1. Detect if user code requires numpy/pandas
/// 2. Route execution to appropriate backend (WASM, Remote, or reject)
/// 3. Provide clear error messages about limitations
///
/// Example usage:
/// ```swift
/// let runner = PythonRunner()
/// runner.setOutputHandler { print("Output: \($0)") }
///
/// // For WebAssembly execution (recommended for client-side):
/// let result = try await runner.executeWebAssembly(code: pythonCode)
///
/// // For remote execution (requires server):
/// let result = try await runner.executeRemote(code: pythonCode, endpoint: serverURL)
/// ```
actor PythonRunner {
    
    // MARK: - Properties
    
    private var outputHandler: ((String) -> Void)?
    private var wasmInitialized: Bool = false
    private var defaultTimeout: TimeInterval = 30.0
    private var memoryLimitMB: Int = 512
    
    // Patterns to detect libraries that require WASM/remote execution
    private let heavyLibraryPatterns: [String] = [
        "import numpy",
        "import pandas",
        "import scipy",
        "import matplotlib",
        "import sklearn",
        "import tensorflow",
        "import torch",
        "import cv2",
        "import PIL",
        "from numpy",
        "from pandas",
        "from scipy",
        "np\\.",
        "pd\\.",
    ]
    
    // MARK: - Initialization
    
    init() {
        // No native Python initialization possible on iOS
        // Log the architecture decision
        print("PythonRunner initialized (STUB - native execution unavailable)")
    }
    
    // MARK: - Configuration
    
    /// Sets a handler for capturing Python print() output.
    /// Note: Only works with WebAssembly or remote execution.
    func setOutputHandler(_ handler: @escaping (String) -> Void) {
        self.outputHandler = handler
    }
    
    /// Sets the execution timeout.
    /// - Parameter seconds: Maximum execution time (default: 30s)
    func setTimeout(_ seconds: TimeInterval) {
        self.defaultTimeout = seconds
    }
    
    /// Sets the memory limit for Python execution.
    /// - Parameter megabytes: Maximum memory in MB (default: 512)
    func setMemoryLimit(megabytes: Int) {
        self.memoryLimitMB = megabytes
    }
    
    /// Initializes the WebAssembly Python runtime.
    /// This is required before using executeWebAssembly().
    func initializeWASM() async throws {
        // TODO: Implement Pyodide loading
        // This would:
        // 1. Load pyodide.js in WKWebView
        // 2. Download Python WASM packages (~20MB)
        // 3. Set up output capture bridge
        self.wasmInitialized = true
        print("WASM initialization not yet implemented")
    }
    
    // MARK: - Code Analysis
    
    /// Analyzes Python code to determine execution requirements.
    /// - Returns: Detection result with recommendations
    func analyze(code: String) -> CodeAnalysisResult {
        let requiresHeavyLibraries = heavyLibraryPatterns.contains { pattern in
            code.range(of: pattern, options: .regularExpression) != nil
        }
        
        let detectedLibraries = heavyLibraryPatterns.compactMap { pattern -> String? in
            let cleanPattern = pattern
                .replacingOccurrences(of: "import ", with: "")
                .replacingOccurrences(of: "from ", with: "")
                .replacingOccurrences(of: "\\.", with: "")
                .replacingOccurrences(of: "\\", with: "")
            if code.range(of: pattern, options: .regularExpression) != nil {
                return cleanPattern
            }
            return nil
        }
        
        let estimatedComplexity = estimateComplexity(code)
        
        return CodeAnalysisResult(
            requiresNativeExecution: false,  // Never possible on iOS
            requiresWASMExecution: requiresHeavyLibraries,
            requiresRemoteExecution: requiresHeavyLibraries || estimatedComplexity > .high,
            detectedLibraries: Array(Set(detectedLibraries)),
            complexity: estimatedComplexity,
            recommendedBackend: requiresHeavyLibraries ? .webAssembly : .webAssembly,
            warnings: generateWarnings(code: code, requiresHeavyLibraries: requiresHeavyLibraries)
        )
    }
    
    private func estimateComplexity(_ code: String) -> CodeComplexity {
        let lines = code.components(separatedBy: .newlines).count
        let hasLoops = code.contains("for ") || code.contains("while ")
        let hasRecursion = code.contains("func ") && code.contains(code.components(separatedBy: "func ").first ?? "")
        
        if lines > 500 || (hasLoops && hasRecursion) {
            return .veryHigh
        } else if lines > 100 || hasRecursion {
            return .high
        } else if lines > 50 || hasLoops {
            return .medium
        } else {
            return .low
        }
    }
    
    private func generateWarnings(code: String, requiresHeavyLibraries: Bool) -> [String] {
        var warnings: [String] = []
        
        if requiresHeavyLibraries {
            warnings.append(
                "Detected scientific Python libraries (numpy, pandas, etc.). " +
                "These require WebAssembly or remote execution due to iOS sandbox restrictions."
            )
        }
        
        if code.contains("import os") || code.contains("import sys") {
            warnings.append(
                "System-level operations may behave differently in sandboxed environments."
            )
        }
        
        if code.contains("open(") || code.contains("with open") {
            warnings.append(
                "File I/O is restricted. Use in-memory data or WebAssembly virtual filesystem."
            )
        }
        
        if code.contains("import requests") || code.contains("import urllib") {
            warnings.append(
                "Network operations may fail in WebAssembly. Consider remote execution."
            )
        }
        
        return warnings
    }
    
    // MARK: - Execution Methods (Stubs)
    
    /// ⚠️ NOT IMPLEMENTED: Native Python execution is NOT POSSIBLE on iOS/iPadOS.
    ///
    /// This method always throws PythonRunnerError.pythonExecutionNotSupported.
    ///
    /// For alternatives, use:
    /// - executeWebAssembly(code:) for client-side execution
    /// - executeRemote(code:endpoint:) for server-side execution
    func execute(code: String) async throws -> String {
        throw PythonRunnerError.pythonExecutionNotSupported
    }
    
    /// Executes Python code using Pyodide WebAssembly runtime.
    ///
    /// This is the recommended approach for client-side Python execution.
    /// Supports numpy, pandas, and other scientific libraries compiled to WASM.
    ///
    /// Requirements:
    /// - Call initializeWASM() before first use
    /// - ~20MB initial download for Python WASM packages
    /// - 10-50x slower than native execution
    ///
    /// - Parameters:
    ///   - code: Python code to execute
    ///   - timeout: Maximum execution time (uses default if nil)
    /// - Returns: Execution output as string
    func executeWebAssembly(code: String, timeout: TimeInterval? = nil) async throws -> String {
        guard wasmInitialized else {
            throw PythonRunnerError.wasmNotInitialized
        }
        
        // TODO: Implement Pyodide execution via WKWebView
        // 1. Inject code into JavaScript context
        // 2. Set up output capture
        // 3. Apply timeout using Task.withTimeout
        // 4. Return results
        
        throw PythonRunnerError.pythonExecutionNotSupported
    }
    
    /// Executes Python code on a remote server.
    ///
    /// This provides full Python environment support but requires network access.
    ///
    /// - Parameters:
    ///   - code: Python code to execute
    ///   - endpoint: URL of Python execution server
    ///   - timeout: Maximum execution time (uses default if nil)
    /// - Returns: Execution output as string
    func executeRemote(
        code: String,
        endpoint: URL,
        timeout: TimeInterval? = nil
    ) async throws -> String {
        // TODO: Implement remote execution
        // 1. Send code to server endpoint
        // 2. Stream output if supported
        // 3. Apply timeout
        // 4. Handle network errors gracefully
        
        throw PythonRunnerError.pythonExecutionNotSupported
    }
    
    // MARK: - Utility Methods
    
    /// Returns documentation about iOS Python limitations.
    func getLimitationsDocumentation() -> String {
        return """
        iOS/iPadOS Python Execution Limitations
        =======================================
        
        1. NO Native Execution
           - dlopen() is restricted on iOS
           - JIT compilation requires special entitlements
           - App Store policies prohibit arbitrary code execution
        
        2. WebAssembly Alternative
           - Pyodide provides Python in WASM
           - Supports numpy, pandas, matplotlib
           - 10-50x slower than native
           - ~20MB download size
        
        3. Remote Execution
           - Full Python environment on server
           - Requires network connection
           - Privacy considerations for sensitive data
        
        4. Build Requirements for Static Python
           - Python-Apple-support: 50+ MB binary
           - No numpy/pandas (C extensions don't compile)
           - Complex Xcode build phases
           - Manual patch management
        
        For implementation details, see:
        - Pyodide: https://pyodide.org
        - Python-Apple-support: https://github.com/beeware/Python-Apple-support
        - PythonKit: https://github.com/pvieito/PythonKit
        """
    }
    
    /// Returns the appropriate execution backend for given code.
    func recommendBackend(for code: String) -> ExecutionBackend {
        let analysis = analyze(code: code)
        return analysis.recommendedBackend
    }
}

// MARK: - Supporting Types

struct CodeAnalysisResult {
    let requiresNativeExecution: Bool
    let requiresWASMExecution: Bool
    let requiresRemoteExecution: Bool
    let detectedLibraries: [String]
    let complexity: CodeComplexity
    let recommendedBackend: ExecutionBackend
    let warnings: [String]
}

enum CodeComplexity: String, Comparable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
    
    static func < (lhs: CodeComplexity, rhs: CodeComplexity) -> Bool {
        let order: [CodeComplexity] = [.low, .medium, .high, .veryHigh]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

enum ExecutionBackend: String {
    case native = "Native (Not Available)"
    case webAssembly = "WebAssembly (Recommended)"
    case remote = "Remote Server"
    case none = "None (Not Supported)"
}

// MARK: - Convenience Extensions

extension PythonRunner {
    /// Quick check if code can run locally (WASM).
    func canExecuteLocally(_ code: String) -> Bool {
        let analysis = analyze(code: code)
        return !analysis.requiresRemoteExecution
    }
    
    /// Check if code uses scientific libraries.
    func usesScientificLibraries(_ code: String) -> Bool {
        let analysis = analyze(code: code)
        return analysis.detectedLibraries.contains { lib in
            ["numpy", "pandas", "scipy", "matplotlib", "sklearn"].contains(lib)
        }
    }
}

// MARK: - Usage Example (Documentation)

/*
 Example implementation pattern:
 
 class PythonExecutionController: ObservableObject {
     private let runner = PythonRunner()
     
     func executePython(_ code: String) async {
         let analysis = await runner.analyze(code: code)
         
         // Show warnings
         for warning in analysis.warnings {
             print("⚠️ \(warning)")
         }
         
         // Route to appropriate backend
         switch analysis.recommendedBackend {
         case .webAssembly:
             do {
                 try await runner.initializeWASM()
                 let result = try await runner.executeWebAssembly(code: code)
                 print(result)
             } catch {
                 print("WASM Error: \(error.localizedDescription)")
             }
             
         case .remote:
             let serverURL = URL(string: "https://api.example.com/python")!
             do {
                 let result = try await runner.executeRemote(
                     code: code,
                     endpoint: serverURL
                 )
                 print(result)
             } catch {
                 print("Remote Error: \(error.localizedDescription)")
             }
             
         default:
             print("Execution not supported for this code")
         }
     }
 }
*/
