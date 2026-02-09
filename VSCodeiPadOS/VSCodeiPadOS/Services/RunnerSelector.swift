import Foundation
import JavaScriptCore

// MARK: - Supporting Types

/// Supported programming languages for execution
public enum Language: String, CaseIterable, Sendable {
    case javascript = "javascript"
    case python = "python"
    case swift = "swift"
    case typescript = "typescript"
    case bash = "bash"
    case ruby = "ruby"
    case php = "php"
    case go = "go"
    case rust = "rust"
    case lua = "lua"
    case wasm = "wasm"
    
    /// Returns true if the language can potentially run on-device
    public var supportsOnDeviceExecution: Bool {
        switch self {
        case .javascript, .lua:
            return true // JavaScriptCore available
        case .python:
            return false // Requires embedded Python or Pyodide
        case .swift:
            return true // Can run in limited sandbox
        case .typescript:
            return true // Transpiles to JS
        case .wasm:
            return true // WebAssembly via WKWebView
        case .bash, .ruby, .php, .go, .rust:
            return false // Requires interpreter/compiler not on iOS
        }
    }
    
    /// File extensions for this language
    public var fileExtensions: [String] {
        switch self {
        case .javascript: return ["js", "mjs"]
        case .python: return ["py", "pyw"]
        case .swift: return ["swift"]
        case .typescript: return ["ts", "tsx"]
        case .bash: return ["sh", "bash"]
        case .ruby: return ["rb"]
        case .php: return ["php"]
        case .go: return ["go"]
        case .rust: return ["rs"]
        case .lua: return ["lua"]
        case .wasm: return ["wasm"]
        }
    }
}

/// Execution strategy determined by the selector
public enum ExecutionStrategy: Equatable, Sendable {
    /// Run entirely on-device
    case onDevice
    
    /// Run on remote server
    case remote(reason: String)
    
    /// Hybrid: analyze on-device, run on remote
    case hybrid(analysisOnDevice: Bool, executionRemote: Bool)
    
    public var description: String {
        switch self {
        case .onDevice:
            return "Execute entirely on-device"
        case .remote(let reason):
            return "Execute remotely: \(reason)"
        case .hybrid(let analysis, let execution):
            return "Hybrid (analysis: \(analysis ? "on-device" : "remote"), execution: \(execution ? "remote" : "on-device"))"
        }
    }
}

/// Resource usage estimate for code execution
public struct ResourceEstimate: Sendable {
    public let estimatedTimeSeconds: Double
    public let estimatedMemoryMB: Double
    public let estimatedCPUUsage: Double // 0.0 to 1.0
    public let hasExternalDependencies: Bool
    public let requiresNetwork: Bool
    public let requiresFileSystem: Bool
    
    public init(
        estimatedTimeSeconds: Double = 1.0,
        estimatedMemoryMB: Double = 50.0,
        estimatedCPUUsage: Double = 0.5,
        hasExternalDependencies: Bool = false,
        requiresNetwork: Bool = false,
        requiresFileSystem: Bool = false
    ) {
        self.estimatedTimeSeconds = estimatedTimeSeconds
        self.estimatedMemoryMB = estimatedMemoryMB
        self.estimatedCPUUsage = estimatedCPUUsage
        self.hasExternalDependencies = hasExternalDependencies
        self.requiresNetwork = requiresNetwork
        self.requiresFileSystem = requiresFileSystem
    }
    
    /// Check if estimate exceeds typical iOS limits
    public var exceedsOnDeviceLimits: Bool {
        return estimatedTimeSeconds > 30.0 || // 30 second limit
               estimatedMemoryMB > 512.0 || // 512MB memory limit
               estimatedCPUUsage > 0.8 || // High CPU usage
               requiresNetwork || // Network required
               hasExternalDependencies // External packages needed
    }
}

/// Result of on-device capability analysis
public struct DeviceExecutionResult: Sendable {
    public let canRunOnDevice: Bool
    public let recommendedStrategy: ExecutionStrategy
    public let factors: [ExecutionFactor]
    public let resourceEstimate: ResourceEstimate
    
    public init(
        canRunOnDevice: Bool,
        recommendedStrategy: ExecutionStrategy,
        factors: [ExecutionFactor],
        resourceEstimate: ResourceEstimate
    ) {
        self.canRunOnDevice = canRunOnDevice
        self.recommendedStrategy = recommendedStrategy
        self.factors = factors
        self.resourceEstimate = resourceEstimate
    }
}

/// Individual factor affecting execution decision
public struct ExecutionFactor: Sendable {
    public let name: String
    public let status: FactorStatus
    public let description: String
    
    public init(name: String, status: FactorStatus, description: String) {
        self.name = name
        self.status = status
        self.description = description
    }
}

public enum FactorStatus: String, Sendable {
    case pass = "✅"
    case warning = "⚠️"
    case fail = "❌"
}

/// User preferences for execution
public struct ExecutionPreferences: Sendable {
    public var preferOnDevice: Bool
    public var preferRemote: Bool
    public var warnBeforeRemote: Bool
    public var maxOnDeviceTimeSeconds: Double
    public var maxOnDeviceMemoryMB: Double
    
    public init(
        preferOnDevice: Bool = true,
        preferRemote: Bool = false,
        warnBeforeRemote: Bool = true,
        maxOnDeviceTimeSeconds: Double = 30.0,
        maxOnDeviceMemoryMB: Double = 256.0
    ) {
        self.preferOnDevice = preferOnDevice
        self.preferRemote = preferRemote
        self.warnBeforeRemote = warnBeforeRemote
        self.maxOnDeviceTimeSeconds = maxOnDeviceTimeSeconds
        self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
    }
}

/// Configuration for the RunnerSelector
public struct RunnerConfiguration: Sendable {
    public var maxOnDeviceExecutionTime: TimeInterval
    public var maxOnDeviceMemoryMB: Double
    public var maxCPUUsageBeforeThrottle: Double
    public var allowNetworkAccess: Bool
    public var allowFileSystemAccess: Bool
    
    public static let `default` = RunnerConfiguration(
        maxOnDeviceExecutionTime: 30.0,
        maxOnDeviceMemoryMB: 256.0,
        maxCPUUsageBeforeThrottle: 0.8,
        allowNetworkAccess: false,
        allowFileSystemAccess: true
    )
    
    public init(
        maxOnDeviceExecutionTime: TimeInterval = 30.0,
        maxOnDeviceMemoryMB: Double = 256.0,
        maxCPUUsageBeforeThrottle: Double = 0.8,
        allowNetworkAccess: Bool = false,
        allowFileSystemAccess: Bool = true
    ) {
        self.maxOnDeviceExecutionTime = maxOnDeviceExecutionTime
        self.maxOnDeviceMemoryMB = maxOnDeviceMemoryMB
        self.maxCPUUsageBeforeThrottle = maxCPUUsageBeforeThrottle
        self.allowNetworkAccess = allowNetworkAccess
        self.allowFileSystemAccess = allowFileSystemAccess
    }
}

// MARK: - RunnerSelector

/// Intelligent runner selection that decides on-device vs remote execution
@MainActor
public final class RunnerSelector: Sendable {
    
    // MARK: - Properties
    
    public var userPreferences: ExecutionPreferences
    public var configuration: RunnerConfiguration
    public var delegate: RunnerSelectorDelegate?
    
    // MARK: - Initialization
    
    public init(
        preferences: ExecutionPreferences = ExecutionPreferences(),
        configuration: RunnerConfiguration = .default
    ) {
        self.userPreferences = preferences
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    
    /// Analyzes code and determines the best execution strategy
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language
    /// - Returns: Recommended execution strategy
    public func analyze(code: String, language: Language) -> ExecutionStrategy {
        // Step 1: Check user preference overrides
        if userPreferences.preferRemote {
            return .remote(reason: "User preference for remote execution")
        }
        
        // Step 2: Check if language supports on-device execution at all
        if !language.supportsOnDeviceExecution {
            return .remote(reason: "\(language.rawValue) requires remote interpreter")
        }
        
        // Step 3: Estimate resource usage
        let resourceEstimate = estimateResourceUsage(code: code, language: language)
        
        // Step 4: Check for file system requirements
        let requiresFileSystem = detectFileSystemAccess(code: code, language: language)
        if requiresFileSystem && !configuration.allowFileSystemAccess {
            return .remote(reason: "File system access required but not allowed on-device")
        }
        
        // Step 5: Check for network requirements
        let requiresNetwork = detectNetworkAccess(code: code, language: language)
        if requiresNetwork && !configuration.allowNetworkAccess {
            return .remote(reason: "Network access required but not allowed on-device")
        }
        
        // Step 6: Check resource limits
        if resourceEstimate.exceedsOnDeviceLimits {
            let reason = buildLimitExceededReason(estimate: resourceEstimate)
            return .remote(reason: reason)
        }
        
        // Step 7: Check execution time against user preference
        if resourceEstimate.estimatedTimeSeconds > userPreferences.maxOnDeviceTimeSeconds {
            return .remote(reason: "Estimated execution time (\(Int(resourceEstimate.estimatedTimeSeconds))s) exceeds user limit")
        }
        
        // Step 8: Check code complexity
        let complexity = calculateComplexityScore(code: code, language: language)
        if complexity > 100 {
            return .hybrid(analysisOnDevice: true, executionRemote: true)
        }
        
        // All checks passed - can run on-device
        return .onDevice
    }
    
    /// Determines if code can run on-device and provides detailed analysis
    /// - Parameters:
    ///   - code: The source code to analyze
    ///   - language: The programming language
    /// - Returns: Detailed execution result with factors
    public func canRunOnDevice(code: String, language: Language) -> DeviceExecutionResult {
        var factors: [ExecutionFactor] = []
        
        // Language support check
        if language.supportsOnDeviceExecution {
            factors.append(ExecutionFactor(
                name: "Language Support",
                status: .pass,
                description: "\(language.rawValue) supports on-device execution"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "Language Support",
                status: .fail,
                description: "\(language.rawValue) requires remote execution"
            ))
        }
        
        // Resource estimation
        let resources = estimateResourceUsage(code: code, language: language)
        if resources.exceedsOnDeviceLimits {
            factors.append(ExecutionFactor(
                name: "Resource Usage",
                status: .fail,
                description: "Exceeds on-device limits (time: \(Int(resources.estimatedTimeSeconds))s, memory: \(Int(resources.estimatedMemoryMB))MB)"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "Resource Usage",
                status: .pass,
                description: "Within on-device limits"
            ))
        }
        
        // Dependencies check
        let dependencies = analyzeDependencies(code: code, language: language)
        if dependencies.isEmpty {
            factors.append(ExecutionFactor(
                name: "Dependencies",
                status: .pass,
                description: "No external dependencies detected"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "Dependencies",
                status: .warning,
                description: "Detected dependencies: \(dependencies.joined(separator: ", "))"
            ))
        }
        
        // Network check
        let network = detectNetworkAccess(code: code, language: language)
        if network {
            factors.append(ExecutionFactor(
                name: "Network Access",
                status: configuration.allowNetworkAccess ? .warning : .fail,
                description: configuration.allowNetworkAccess ? "Network access detected" : "Network access not allowed on-device"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "Network Access",
                status: .pass,
                description: "No network access required"
            ))
        }
        
        // File system check
        let fileSystem = detectFileSystemAccess(code: code, language: language)
        if fileSystem {
            factors.append(ExecutionFactor(
                name: "File System",
                status: configuration.allowFileSystemAccess ? .warning : .fail,
                description: configuration.allowFileSystemAccess ? "File system access detected" : "File system access restricted"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "File System",
                status: .pass,
                description: "No file system access required"
            ))
        }
        
        // Complexity check
        let complexity = calculateComplexityScore(code: code, language: language)
        if complexity > 100 {
            factors.append(ExecutionFactor(
                name: "Code Complexity",
                status: .warning,
                description: "High complexity score: \(complexity)"
            ))
        } else {
            factors.append(ExecutionFactor(
                name: "Code Complexity",
                status: .pass,
                description: "Complexity score: \(complexity)"
            ))
        }
        
        let strategy = analyze(code: code, language: language)
        let canRun = strategy == .onDevice || (strategy == .hybrid && factors.allSatisfy { $0.status != .fail })
        
        return DeviceExecutionResult(
            canRunOnDevice: canRun,
            recommendedStrategy: strategy,
            factors: factors,
            resourceEstimate: resources
        )
    }
    
    /// Estimates resource usage for the given code
    /// - Parameters:
    ///   - code: The source code
    ///   - language: The programming language
    /// - Returns: Resource estimate
    public func estimateResourceUsage(code: String, language: Language) -> ResourceEstimate {
        let lines = code.components(separatedBy: .newlines).count
        let characters = code.count
        
        // Base estimates
        var timeEstimate = Double(lines) * 0.01 // 10ms per line baseline
        var memoryEstimate = Double(characters) * 0.001 // 1KB per 1000 chars
        var cpuEstimate = 0.3
        var hasExternalDeps = false
        var requiresNetwork = false
        var requiresFileSystem = false
        
        // Language-specific adjustments
        switch language {
        case .javascript:
            // Check for complex operations
            if code.contains("while(true)") || code.contains("for(;;)") {
                timeEstimate *= 10
                cpuEstimate = 1.0
            }
            // Check for large data structures
            if code.contains("new Array(1000000)") || code.contains("Array(1000000)") {
                memoryEstimate += 8.0 // ~8MB for million element array
            }
            
        case .python:
            // Python typically needs more memory
            memoryEstimate *= 1.5
            if code.contains("import numpy") || code.contains("import pandas") {
                memoryEstimate += 100.0
                hasExternalDeps = true
            }
            
        case .swift:
            // Swift compilation time
            timeEstimate += 2.0
            memoryEstimate *= 1.2
            
        default:
            break
        }
        
        // Check for network operations
        requiresNetwork = detectNetworkAccess(code: code, language: language)
        
        // Check for file operations
        requiresFileSystem = detectFileSystemAccess(code: code, language: language)
        
        // Check for external dependencies
        let deps = analyzeDependencies(code: code, language: language)
        hasExternalDeps = !deps.isEmpty
        
        return ResourceEstimate(
            estimatedTimeSeconds: min(timeEstimate, 300.0), // Cap at 5 minutes
            estimatedMemoryMB: min(memoryEstimate, 2048.0), // Cap at 2GB
            estimatedCPUUsage: min(cpuEstimate, 1.0),
            hasExternalDependencies: hasExternalDeps,
            requiresNetwork: requiresNetwork,
            requiresFileSystem: requiresFileSystem
        )
    }
    
    // MARK: - Private Methods
    
    /// Calculate complexity score based on code analysis
    private func calculateComplexityScore(code: String, language: Language) -> Int {
        var score = 0
        
        // Lines of code
        let lines = code.components(separatedBy: .newlines).count
        score += lines / 10 // 1 point per 10 lines
        
        // Control flow complexity
        let controlFlowPatterns = [
            "if", "else", "switch", "case", "for", "while", "do",
            "try", "catch", "finally", "guard", "defer"
        ]
        for pattern in controlFlowPatterns {
            score += code.components(separatedBy: pattern).count - 1
        }
        
        // Nesting depth (approximate)
        let braceCount = code.filter { $0 == "{" }.count
        score += braceCount / 3
        
        // Function/method count
        switch language {
        case .javascript, .typescript:
            score += code.components(separatedBy: "function ").count - 1
            score += code.components(separatedBy: "=> ").count - 1
        case .python:
            score += code.components(separatedBy: "def ").count - 1
        case .swift:
            score += code.components(separatedBy: "func ").count - 1
        default:
            break
        }
        
        // API calls (external complexity)
        let apiPatterns = ["fetch(", "XMLHttpRequest", "URLSession", "AF.request", "Alamofire"]
        for pattern in apiPatterns {
            score += code.components(separatedBy: pattern).count - 1
        }
        
        return score
    }
    
    /// Detect imports/requires to find external dependencies
    private func analyzeDependencies(code: String, language: Language) -> [String] {
        var dependencies: [String] = []
        
        switch language {
        case .javascript, .typescript:
            // ES6 imports
            let importRegex = try? NSRegularExpression(pattern: #"import\s+(?:{[^}]+}|\*?\s+as\s+\w+|\w+)\s+from\s+['"]([^'"]+)['"]"#, options: [])
            let importMatches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
            for match in importMatches {
                if let range = Range(match.range(at: 1), in: code) {
                    dependencies.append(String(code[range]))
                }
            }
            
            // CommonJS requires
            let requireRegex = try? NSRegularExpression(pattern: #"require\s*\(\s*['"]([^'"]+)['"]\s*\)"#, options: [])
            let requireMatches = requireRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
            for match in requireMatches {
                if let range = Range(match.range(at: 1), in: code) {
                    dependencies.append(String(code[range]))
                }
            }
            
        case .python:
            // Python imports
            let importRegex = try? NSRegularExpression(pattern: #"^\s*(?:import|from)\s+(\w+)"#, options: [.anchorsMatchLines])
            let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
            for match in matches {
                if let range = Range(match.range(at: 1), in: code) {
                    let module = String(code[range])
                    // Filter out standard library
                    let stdLib = ["os", "sys", "json", "math", "random", "datetime", "collections", "itertools", "functools"]
                    if !stdLib.contains(module) {
                        dependencies.append(module)
                    }
                }
            }
            
        case .swift:
            // Swift imports
            let importRegex = try? NSRegularExpression(pattern: #"^\s*import\s+(\w+)"#, options: [.anchorsMatchLines])
            let matches = importRegex?.matches(in: code, options: [], range: NSRange(code.startIndex..., in: code)) ?? []
            for match in matches {
                if let range = Range(match.range(at: 1), in: code) {
                    let module = String(code[range])
                    // Filter out standard library
                    let stdLib = ["Foundation", "Swift", "Dispatch"]
                    if !stdLib.contains(module) {
                        dependencies.append(module)
                    }
                }
            }
            
        default:
            break
        }
        
        return dependencies
    }
    
    /// Detect file system access patterns
    private func detectFileSystemAccess(code: String, language: Language) -> Bool {
        switch language {
        case .javascript, .typescript:
            let patterns = ["fs.readFile", "fs.writeFile", "require('fs')", "import.*fs", "FileReader"]
            return patterns.contains { code.contains($0) }
            
        case .python:
            let patterns = ["open(", "os.path", "pathlib", "shutil", "with open"]
            return patterns.contains { code.contains($0) }
            
        case .swift:
            let patterns = ["FileManager", "NSData(contentsOfFile:", "String(contentsOfFile:", "FileHandle"]
            return patterns.contains { code.contains($0) }
            
        case .bash:
            return true // Bash almost always uses file system
            
        default:
            return false
        }
    }
    
    /// Detect network access patterns
    private func detectNetworkAccess(code: String, language: Language) -> Bool {
        switch language {
        case .javascript, .typescript:
            let patterns = [
                "fetch(", "XMLHttpRequest", "axios", "$.ajax", "$.get", "$.post",
                "request(", "require('http')", "require('https')", "new WebSocket",
                "navigator.sendBeacon", "EventSource"
            ]
            return patterns.contains { code.contains($0) }
            
        case .python:
            let patterns = ["import requests", "import urllib", "import http", "socket.socket", "urlopen"]
            return patterns.contains { code.contains($0) }
            
        case .swift:
            let patterns = ["URLSession", "URLRequest", "Alamofire", "AF.request"]
            return patterns.contains { code.contains($0) }
            
        case .bash:
            let patterns = ["curl", "wget", "ssh", "scp", "ftp"]
            return patterns.contains { code.contains($0) }
            
        default:
            return false
        }
    }
    
    /// Build a descriptive reason for why limits were exceeded
    private func buildLimitExceededReason(estimate: ResourceEstimate) -> String {
        var reasons: [String] = []
        
        if estimate.estimatedTimeSeconds > 30 {
            reasons.append("long execution time (\(Int(estimate.estimatedTimeSeconds))s)")
        }
        if estimate.estimatedMemoryMB > 256 {
            reasons.append("high memory usage (\(Int(estimate.estimatedMemoryMB))MB)")
        }
        if estimate.hasExternalDependencies {
            reasons.append("external dependencies required")
        }
        if estimate.requiresNetwork {
            reasons.append("network access required")
        }
        
        return reasons.isEmpty ? "Resource limits exceeded" : reasons.joined(separator: ", ")
    }
}

// MARK: - Delegate Protocol

/// Protocol for receiving runner selection events
public protocol RunnerSelectorDelegate: AnyObject {
    /// Called when remote execution is required
    func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String)
    
    /// Called when on-device execution is selected
    func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String)
    
    /// Called when execution strategy is determined
    func runnerSelector(_ selector: RunnerSelector, selectedStrategy: ExecutionStrategy, for code: String)
}

// MARK: - Convenience Extensions

public extension RunnerSelector {
    /// Quick check if code should run remotely
    func shouldRunRemotely(code: String, language: Language) -> Bool {
        let strategy = analyze(code: code, language: language)
        if case .remote = strategy {
            return true
        }
        return false
    }
    
    /// Get execution strategy with formatted explanation
    func analyzeWithExplanation(code: String, language: Language) -> (strategy: ExecutionStrategy, explanation: String) {
        let result = canRunOnDevice(code: code, language: language)
        
        var explanation = "Execution Analysis:\n"
        explanation += "Strategy: \(result.recommendedStrategy.description)\n"
        explanation += "Can run on-device: \(result.canRunOnDevice ? "Yes" : "No")\n\n"
        explanation += "Factors:\n"
        for factor in result.factors {
            explanation += "  \(factor.status.rawValue) \(factor.name): \(factor.description)\n"
        }
        explanation += "\nResource Estimate:\n"
        explanation += "  Time: \(Int(result.resourceEstimate.estimatedTimeSeconds))s\n"
        explanation += "  Memory: \(Int(result.resourceEstimate.estimatedMemoryMB))MB\n"
        explanation += "  CPU: \(Int(result.resourceEstimate.estimatedCPUUsage * 100))%\n"
        
        return (result.recommendedStrategy, explanation)
    }
}

// MARK: - Usage Examples

/*
 // Example 1: Basic usage
 let selector = RunnerSelector()
 let strategy = selector.analyze(code: "console.log('Hello')", language: .javascript)
 // Returns: .onDevice
 
 // Example 2: Network access requires remote
 let strategy = selector.analyze(
     code: "fetch('https://api.example.com')",
     language: .javascript
 )
 // Returns: .remote(reason: "Network access required but not allowed on-device")
 
 // Example 3: Detailed analysis
 let result = selector.canRunOnDevice(
     code: "import numpy; print('test')",
     language: .python
 )
 // result.canRunOnDevice = false
 // result.factors contains warnings about Python not being available
 
 // Example 4: With user preferences
 let preferences = ExecutionPreferences(
     preferOnDevice: true,
     warnBeforeRemote: true,
     maxOnDeviceTimeSeconds: 5.0
 )
 let selector = RunnerSelector(preferences: preferences)
 
 // Example 5: Using delegate
 class ExecutionCoordinator: RunnerSelectorDelegate {
     func runnerSelector(_ selector: RunnerSelector, requiresRemoteExecution reason: String, for code: String) {
         showRemoteExecutionWarning(reason: reason)
     }
     
     func runnerSelector(_ selector: RunnerSelector, willExecuteOnDevice code: String) {
         showLoadingIndicator()
     }
 }
 
 let selector = RunnerSelector()
 selector.delegate = coordinator
 
 // Example 6: Resource estimation
 let estimate = selector.estimateResourceUsage(
     code: largeScript,
     language: .javascript
 )
 print("Estimated: \(estimate.estimatedTimeSeconds)s, \(estimate.estimatedMemoryMB)MB")
 
 // Example 7: With formatted explanation
 let (strategy, explanation) = selector.analyzeWithExplanation(
     code: code,
     language: .swift
 )
 print(explanation) // Human-readable analysis
 */
