import Foundation

// MARK: - Types

/// Supported programming languages
public enum Language: String, CaseIterable, Sendable {
    case javascript = "javascript"
    case python = "python"
    case swift = "swift"
    case typescript = "typescript"
    case unknown = "unknown"
    
    /// Detect language from file extension or code content
    public static func detect(from filename: String, code: String? = nil) -> Language {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "js": return .javascript
        case "ts": return .typescript
        case "py": return .python
        case "swift": return .swift
        default:
            // Try to detect from code heuristics
            if let code = code {
                return detectFromCode(code)
            }
            return .unknown
        }
    }
    
    private static func detectFromCode(_ code: String) -> Language {
        if code.contains("func ") && code.contains("{") && code.contains("var ") || code.contains("let ") {
            return .swift
        }
        if code.contains("def ") && code.contains(":") {
            return .python
        }
        if code.contains("function ") || code.contains("const ") || code.contains("let ") {
            if code.contains(": ") && code.contains("interface ") {
                return .typescript
            }
            return .javascript
        }
        return .unknown
    }
}

/// Complexity score with detailed metrics
public struct ComplexityScore: Sendable {
    public let score: Int // 0-100
    public let cyclomaticComplexity: Int
    public let linesOfCode: Int
    public let nestingDepth: Int
    public let functionCount: Int
    public let cognitiveComplexity: Int
    
    public var isSimple: Bool { score < 30 }
    public var isModerate: Bool { score >= 30 && score < 60 }
    public var isComplex: Bool { score >= 60 }
    
    public init(
        score: Int,
        cyclomaticComplexity: Int,
        linesOfCode: Int,
        nestingDepth: Int,
        functionCount: Int,
        cognitiveComplexity: Int
    ) {
        self.score = min(100, max(0, score))
        self.cyclomaticComplexity = cyclomaticComplexity
        self.linesOfCode = linesOfCode
        self.nestingDepth = nestingDepth
        self.functionCount = functionCount
        self.cognitiveComplexity = cognitiveComplexity
    }
}

/// Security warning with severity
public struct SecurityWarning: Sendable, Identifiable {
    public let id = UUID()
    public let severity: Severity
    public let category: Category
    public let pattern: String
    public let line: Int?
    public let message: String
    public let suggestion: String?
    
    public enum Severity: String, Sendable {
        case critical = "critical"
        case high = "high"
        case medium = "medium"
        case low = "low"
        case info = "info"
        
        public var priority: Int {
            switch self {
            case .critical: return 4
            case .high: return 3
            case .medium: return 2
            case .low: return 1
            case .info: return 0
            }
        }
    }
    
    public enum Category: String, Sendable {
        case injection = "injection"
        case network = "network"
        case fileSystem = "file_system"
        case crypto = "crypto"
        case eval = "eval"
        case unsafeCode = "unsafe_code"
        case resourceExhaustion = "resource_exhaustion"
        case privacy = "privacy"
    }
}

/// Risk assessment result
public struct RiskAssessment: Sendable {
    public let score: Int // 0-100 (0=safe, 100=dangerous)
    public let warnings: [SecurityWarning]
    public let canRunOnDevice: Bool
    public let requiresSandbox: Bool
    public let requiresNetwork: Bool
    public let requiresFileSystem: Bool
    
    public var riskLevel: RiskLevel {
        switch score {
        case 0..<20: return .minimal
        case 20..<40: return .low
        case 40..<60: return .moderate
        case 60..<80: return .high
        default: return .critical
        }
    }
    
    public enum RiskLevel: String, Sendable {
        case minimal = "minimal"
        case low = "low"
        case moderate = "moderate"
        case high = "high"
        case critical = "critical"
        
        public var description: String {
            switch self {
            case .minimal: return "Safe to run without restrictions"
            case .low: return "Low risk, minimal precautions needed"
            case .moderate: return "Moderate risk, sandbox recommended"
            case .high: return "High risk, strict sandboxing required"
            case .critical: return "Critical risk, review before execution"
            }
        }
    }
}

/// Optimization suggestion
public struct OptimizationSuggestion: Sendable {
    public let type: SuggestionType
    public let message: String
    public let alternative: String?
    public let estimatedImpact: Impact
    
    public enum SuggestionType: String, Sendable {
        case useOnDevice = "use_on_device"
        case useRemote = "use_remote"
        case replaceFeature = "replace_feature"
        case optimizeLoop = "optimize_loop"
        case reduceComplexity = "reduce_complexity"
        case addCaching = "add_caching"
    }
    
    public enum Impact: String, Sendable {
        case high = "high"
        case medium = "medium"
        case low = "low"
    }
}

/// Complete analysis result
public struct CodeAnalysisResult: Sendable {
    public let language: Language
    public let imports: [String]
    public let usesNetwork: Bool
    public let usesFileSystem: Bool
    public let complexity: ComplexityScore
    public let warnings: [SecurityWarning]
    public let riskAssessment: RiskAssessment
    public let suggestions: [OptimizationSuggestion]
    public let executionRecommendation: ExecutionRecommendation
    public let analysisDuration: TimeInterval
    
    public enum ExecutionRecommendation: String, Sendable {
        case safeOnDevice = "safe_on_device"
        case sandboxedOnDevice = "sandboxed_on_device"
        case remoteOnly = "remote_only"
        case requiresReview = "requires_review"
        case blocked = "blocked"
    }
}

/// Cached analysis entry
private struct CachedAnalysis: Sendable {
    let result: CodeAnalysisResult
    let timestamp: Date
    let codeHash: String
}

// MARK: - CodeAnalyzer

/// Static code analyzer for pre-execution safety and capability checks
public actor CodeAnalyzer {
    
    // MARK: - Singleton
    
    public static let shared = CodeAnalyzer()
    
    // MARK: - Properties
    
    private var cache: [String: CachedAnalysis] = [:]
    private let cacheQueue = DispatchQueue(label: "com.codeanalyzer.cache", qos: .utility)
    private let maxCacheSize = 100
    private let cacheExpiration: TimeInterval = 3600 // 1 hour
    
    // Regex patterns cache for performance
    private var patterns: [Language: LanguagePatterns] = [:]
    
    // MARK: - Initialization
    
    private init() {
        initializePatterns()
    }
    
    // MARK: - Public API
    
    /// Analyze code and return comprehensive results
    public func analyze(code: String, language: Language? = nil, filename: String? = nil) -> CodeAnalysisResult {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Detect language if not provided
        let detectedLanguage = language ?? Language.detect(
            from: filename ?? "unknown",
            code: code
        )
        
        // Check cache
        let codeHash = hashCode(code)
        if let cached = getCachedAnalysis(hash: codeHash) {
            return cached
        }
        
        // Perform analysis
        let imports = detectImports(code: code, language: detectedLanguage)
        let usesNetwork = detectNetworkUsage(code: code)
        let usesFileSystem = detectFileSystemUsage(code: code)
        let complexity = estimateComplexity(code: code, language: detectedLanguage)
        let warnings = findUnsafePatterns(code: code, language: detectedLanguage)
        
        // Calculate risk
        let riskAssessment = calculateRisk(
            warnings: warnings,
            usesNetwork: usesNetwork,
            usesFileSystem: usesFileSystem,
            complexity: complexity,
            imports: imports
        )
        
        // Generate suggestions
        let suggestions = generateSuggestions(
            language: detectedLanguage,
            warnings: warnings,
            usesNetwork: usesNetwork,
            usesFileSystem: usesFileSystem,
            complexity: complexity,
            imports: imports
        )
        
        // Determine execution recommendation
        let recommendation = determineExecutionRecommendation(
            riskAssessment: riskAssessment,
            warnings: warnings,
            complexity: complexity
        )
        
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        
        let result = CodeAnalysisResult(
            language: detectedLanguage,
            imports: imports,
            usesNetwork: usesNetwork,
            usesFileSystem: usesFileSystem,
            complexity: complexity,
            warnings: warnings,
            riskAssessment: riskAssessment,
            suggestions: suggestions,
            executionRecommendation: recommendation,
            analysisDuration: duration
        )
        
        // Cache result
        cacheAnalysis(hash: codeHash, result: result)
        
        return result
    }
    
    /// Quick pre-flight check
    public func canExecuteSafely(code: String, language: Language? = nil) -> Bool {
        let result = analyze(code: code, language: language)
        return result.executionRecommendation != .blocked && 
               result.riskAssessment.score < 80
    }
    
    /// Clear analysis cache
    public func clearCache() {
        cacheQueue.sync {
            cache.removeAll()
        }
    }
    
    // MARK: - Analysis Methods
    
    /// Detect imports/requires/includes in code
    public func detectImports(code: String, language: Language) -> [String] {
        let patterns = getPatterns(for: language)
        var imports: [String] = []
        
        for pattern in patterns.importPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    if let importRange = Range(match.range(at: 1), in: code) {
                        let importName = String(code[importRange])
                        imports.append(importName)
                    }
                }
            }
        }
        
        return Array(Set(imports)).sorted()
    }
    
    /// Detect network usage patterns
    public func detectNetworkUsage(code: String) -> Bool {
        let networkPatterns = [
            // JavaScript/TypeScript
            "fetch\\s*\\(",
            "XMLHttpRequest",
            "axios", "request", "http\\.", "https\\.",
            "WebSocket", "Socket\\.IO", "socket",
            "navigator\\.sendBeacon",
            "new\\s+Request\\s*\\(",
            
            // Python
            "requests\\.", "urllib", "http\\.client",
            "socket\\.socket", "asyncio\\.open_connection",
            "aiohttp", "httpx",
            
            // Swift
            "URLSession", "URLRequest", "Alamofire",
            "NSURLConnection", "CFNetwork",
            
            // General
            "ws://", "wss://", "http://", "https://",
            "@\\w+\\.com", // Email patterns
            "api\\.", "apiKey", "API_KEY"
        ]
        
        return containsAnyPattern(code: code, patterns: networkPatterns)
    }
    
    /// Detect file system usage patterns
    public func detectFileSystemUsage(code: String) -> Bool {
        let fsPatterns = [
            // JavaScript/TypeScript
            "fs\\.", "require\\s*\\(\\s*['\"]fs", "fs/promises",
            "path\\.", "require\\s*\\(\\s*['\"]path",
            "os\\.", "process\\.cwd",
            
            // Python
            "open\\s*\\(", "with\\s+open\\s*\\(",
            "os\\.path", "pathlib", "shutil", "fileinput",
            "os\\.mkdir", "os\\.makedirs", "os\\.remove",
            
            // Swift
            "FileManager", "FileHandle",
            "URL\\s*\\(.*fileURLWithPath",
            "NSFileManager", "NSFileHandle",
            
            // General
            "\\.readFile", "\\.writeFile",
            "createReadStream", "createWriteStream",
            "readdir", "readdirSync", "read_dir"
        ]
        
        return containsAnyPattern(code: code, patterns: fsPatterns)
    }
    
    /// Estimate code complexity
    public func estimateComplexity(code: String, language: Language? = nil) -> ComplexityScore {
        let lines = code.components(separatedBy: .newlines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let linesOfCode = nonEmptyLines.count
        
        // Count functions
        let functionPattern = getFunctionPattern(for: language)
        let functionCount = countMatches(code: code, pattern: functionPattern)
        
        // Calculate cyclomatic complexity (branches + 1)
        let branchKeywords = ["if", "while", "for", "switch", "case", "catch", "&&", "||", "?"]
        var cyclomaticComplexity = 1
        for keyword in branchKeywords {
            cyclomaticComplexity += countOccurrences(code: code, of: keyword)
        }
        
        // Calculate nesting depth
        let nestingDepth = calculateNestingDepth(code: code)
        
        // Cognitive complexity (simplified)
        let cognitiveComplexity = calculateCognitiveComplexity(
            cyclomaticComplexity: cyclomaticComplexity,
            nestingDepth: nestingDepth,
            functionCount: functionCount
        )
        
        // Overall score (0-100)
        let score = calculateOverallComplexityScore(
            linesOfCode: linesOfCode,
            cyclomaticComplexity: cyclomaticComplexity,
            nestingDepth: nestingDepth,
            functionCount: functionCount
        )
        
        return ComplexityScore(
            score: score,
            cyclomaticComplexity: cyclomaticComplexity,
            linesOfCode: linesOfCode,
            nestingDepth: nestingDepth,
            functionCount: functionCount,
            cognitiveComplexity: cognitiveComplexity
        )
    }
    
    /// Find unsafe patterns in code
    public func findUnsafePatterns(code: String, language: Language? = nil) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        let lines = code.components(separatedBy: .newlines)
        
        // Critical patterns
        warnings.append(contentsOf: findEvalPatterns(code: code, lines: lines))
        warnings.append(contentsOf: findInjectionPatterns(code: code, lines: lines))
        warnings.append(contentsOf: findUnsafeCodePatterns(code: code, lines: lines, language: language))
        
        // High severity
        warnings.append(contentsOf: findCryptoIssues(code: code, lines: lines))
        warnings.append(contentsOf: findResourceExhaustion(code: code, lines: lines))
        
        // Medium severity
        warnings.append(contentsOf: findPrivacyIssues(code: code, lines: lines))
        
        // Sort by severity
        return warnings.sorted { $0.severity.priority > $1.severity.priority }
    }
    
    // MARK: - Private Helpers
    
    private func initializePatterns() {
        // JavaScript/TypeScript patterns
        patterns[.javascript] = LanguagePatterns(
            importPatterns: [
                "(?:import|require)\\s*\\(?(?:['\"])([^'\"]+)(?:['\"])",
                "import\\s+.*?\\s+from\\s+['\"]([^'\"]+)['\"]",
                "import\\s+['\"]([^'\"]+)['\"]"
            ],
            functionPattern: "(?:function|const|let|var)\\s+(\\w+)\\s*[=:]\\s*(?:async\\s*)?(?:function\\s*\\(|\\([^)]*\\)\\s*=>)",
            unsafePatterns: [
                "eval\\s*\\(": .critical,
                "Function\\s*\\(": .high,
                "setTimeout\\s*\\([^,]+,": .medium,
                "setInterval\\s*\\([^,]+,": .medium
            ]
        )
        
        // TypeScript uses same patterns as JavaScript
        patterns[.typescript] = patterns[.javascript]
        
        // Python patterns
        patterns[.python] = LanguagePatterns(
            importPatterns: [
                "(?:import|from)\\s+([\\w.]+)",
                "__import__\\s*\\(\\s*['\"]([^'\"]+)['\"]"
            ],
            functionPattern: "(?:def|lambda)\\s+(\\w+)",
            unsafePatterns: [
                "eval\\s*\\(": .critical,
                "exec\\s*\\(": .critical,
                "compile\\s*\\(": .high,
                "__import__\\s*\\(": .medium,
                "subprocess\\.": .high,
                "os\\.system": .critical,
                "pickle\\.loads": .high
            ]
        )
        
        // Swift patterns
        patterns[.swift] = LanguagePatterns(
            importPatterns: [
                "import\\s+([\\w.]+)"
            ],
            functionPattern: "(?:func)\\s+(\\w+)",
            unsafePatterns: [
                "NSClassFromString": .medium,
                "unsafe": .high,
                "UnsafePointer": .high,
                "UnsafeMutablePointer": .high,
                "UnsafeRawPointer": .high,
                "UnsafeMutableRawPointer": .high,
                "UnsafeBufferPointer": .high,
                "dlopen": .critical,
                "dlsym": .critical,
                "NSBundle\\.main\\.executablePath": .medium
            ]
        )
    }
    
    private func getPatterns(for language: Language) -> LanguagePatterns {
        return patterns[language] ?? patterns[.javascript]!
    }
    
    private func getFunctionPattern(for language: Language?) -> String {
        guard let lang = language else {
            return "(?:function|def|func)\\s+(\\w+)"
        }
        return getPatterns(for: lang).functionPattern
    }
    
    private func containsAnyPattern(code: String, patterns: [String]) -> Bool {
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(code.startIndex..., in: code)
                if regex.firstMatch(in: code, options: [], range: range) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    private func countMatches(code: String, pattern: String) -> Int {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return 0
        }
        let range = NSRange(code.startIndex..., in: code)
        return regex.matches(in: code, options: [], range: range).count
    }
    
    private func countOccurrences(code: String, of substring: String) -> Int {
        var count = 0
        var searchRange = code.startIndex..<code.endIndex
        
        while let range = code.range(of: substring, options: [], range: searchRange) {
            count += 1
            searchRange = range.upperBound..<code.endIndex
        }
        
        return count
    }
    
    private func calculateNestingDepth(code: String) -> Int {
        let lines = code.components(separatedBy: .newlines)
        var maxDepth = 0
        var currentDepth = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Count opening braces/brackets
            let openCount = trimmed.filter { "{[(".contains($0) }.count
            let closeCount = trimmed.filter { "}])".contains($0) }.count
            
            // Check for control structures that increase depth
            let controlPatterns = ["if\\s*\\(", "for\\s*\\(", "while\\s*\\(", "switch\\s*"]
            var hasControl = false
            for pattern in controlPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    if regex.firstMatch(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed)) != nil {
                        hasControl = true
                        break
                    }
                }
            }
            
            if hasControl && openCount == 0 {
                currentDepth += 1
            }
            
            currentDepth += openCount - closeCount
            maxDepth = max(maxDepth, currentDepth)
        }
        
        return maxDepth
    }
    
    private func calculateCognitiveComplexity(
        cyclomaticComplexity: Int,
        nestingDepth: Int,
        functionCount: Int
    ) -> Int {
        return cyclomaticComplexity + (nestingDepth * 2) + (functionCount / 2)
    }
    
    private func calculateOverallComplexityScore(
        linesOfCode: Int,
        cyclomaticComplexity: Int,
        nestingDepth: Int,
        functionCount: Int
    ) -> Int {
        var score = 0
        
        // Lines of code factor (max 20 points)
        score += min(20, linesOfCode / 50)
        
        // Cyclomatic complexity factor (max 30 points)
        score += min(30, cyclomaticComplexity * 2)
        
        // Nesting depth factor (max 25 points)
        score += min(25, nestingDepth * 5)
        
        // Function count factor (max 25 points)
        score += min(25, functionCount * 2)
        
        return min(100, score)
    }
    
    // MARK: - Security Pattern Detection
    
    private func findEvalPatterns(code: String, lines: [String]) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        let evalPatterns = [
            ("eval\\s*\\(", SecurityWarning.Severity.critical, "eval() execution"),
            ("new\\s+Function\\s*\\(", SecurityWarning.Severity.critical, "Function constructor"),
            ("setTimeout\\s*\\(['\"]", SecurityWarning.Severity.high, "setTimeout with string"),
            ("setInterval\\s*\\(['\"]", SecurityWarning.Severity.high, "setInterval with string")
        ]
        
        for (pattern, severity, description) in evalPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: .eval,
                        pattern: pattern,
                        line: line,
                        message: "\(description) detected - arbitrary code execution risk",
                        suggestion: "Replace with direct function calls or safe alternatives"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    private func findInjectionPatterns(code: String, lines: [String]) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        let injectionPatterns = [
            ("innerHTML\\s*[=:]", SecurityWarning.Severity.high, "innerHTML assignment"),
            ("outerHTML\\s*[=:]", SecurityWarning.Severity.high, "outerHTML assignment"),
            ("document\\.write\\s*\\(", SecurityWarning.Severity.high, "document.write"),
            ("\\.html\\s*\\(", SecurityWarning.Severity.medium, "jQuery .html()"),
            ("sql|SELECT|INSERT|UPDATE|DELETE.*\\+", SecurityWarning.Severity.critical, "SQL concatenation"),
            ("process\\.env", SecurityWarning.Severity.medium, "Environment variable access")
        ]
        
        for (pattern, severity, description) in injectionPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: .injection,
                        pattern: pattern,
                        line: line,
                        message: "\(description) - injection risk",
                        suggestion: "Use parameterized queries, textContent, or safe sanitization"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    private func findUnsafeCodePatterns(
        code: String,
        lines: [String],
        language: Language?
    ) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        guard let lang = language else { return warnings }
        let patterns = getPatterns(for: lang)
        
        for (pattern, severity) in patterns.unsafePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    let message = "Unsafe pattern '\(pattern)' detected"
                    
                    let category: SecurityWarning.Category
                    if pattern.contains("unsafe") || pattern.contains("Pointer") {
                        category = .unsafeCode
                    } else {
                        category = .unsafeCode
                    }
                    
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: category,
                        pattern: pattern,
                        line: line,
                        message: message,
                        suggestion: "Review and use safe alternatives"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    private func findCryptoIssues(code: String, lines: [String]) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        let cryptoPatterns = [
            ("Math\\.random\\s*\\(\\s*\\)", SecurityWarning.Severity.high, "Weak random number generator"),
            ("MD5|SHA1[^2-9]", SecurityWarning.Severity.medium, "Weak hash algorithm"),
            ("crypto\\.createHash\\s*\\(\\s*['\"](md5|sha1)['\"]", SecurityWarning.Severity.medium, "Weak hash algorithm")
        ]
        
        for (pattern, severity, description) in cryptoPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: .crypto,
                        pattern: pattern,
                        line: line,
                        message: description,
                        suggestion: "Use crypto.getRandomValues or Web Crypto API"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    private func findResourceExhaustion(code: String, lines: [String]) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        let resourcePatterns = [
            ("while\\s*\\(\\s*true\\s*\\)", SecurityWarning.Severity.high, "Infinite loop risk"),
            ("for\\s*\\(\\s*;;\\s*\\)", SecurityWarning.Severity.high, "Infinite loop risk"),
            ("Array\\s*\\(\\s*[0-9]{7,}\\s*\\)", SecurityWarning.Severity.medium, "Large array allocation"),
            ("new\\s+Array\\s*\\(\\s*[0-9]{7,}\\s*\\)", SecurityWarning.Severity.medium, "Large array allocation"),
            ("setInterval\\s*\\(", SecurityWarning.Severity.medium, "Unbounded interval")
        ]
        
        for (pattern, severity, description) in resourcePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: .resourceExhaustion,
                        pattern: pattern,
                        line: line,
                        message: description,
                        suggestion: "Add termination conditions and resource limits"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    private func findPrivacyIssues(code: String, lines: [String]) -> [SecurityWarning] {
        var warnings: [SecurityWarning] = []
        
        let privacyPatterns = [
            ("localStorage", SecurityWarning.Severity.low, "localStorage access"),
            ("sessionStorage", SecurityWarning.Severity.low, "sessionStorage access"),
            ("document\\.cookie", SecurityWarning.Severity.medium, "Cookie access"),
            ("navigator\\.geolocation", SecurityWarning.Severity.medium, "Geolocation access"),
            ("Notification\\.requestPermission", SecurityWarning.Severity.low, "Notification permission"),
            ("getUserMedia|getDisplayMedia", SecurityWarning.Severity.medium, "Media device access")
        ]
        
        for (pattern, severity, description) in privacyPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(code.startIndex..., in: code)
                let matches = regex.matches(in: code, options: [], range: range)
                
                for match in matches {
                    let line = findLineNumber(for: match.range, in: lines)
                    warnings.append(SecurityWarning(
                        severity: severity,
                        category: .privacy,
                        pattern: pattern,
                        line: line,
                        message: description,
                        suggestion: "Ensure user consent and data protection compliance"
                    ))
                }
            }
        }
        
        return warnings
    }
    
    // MARK: - Risk Assessment
    
    private func calculateRisk(
        warnings: [SecurityWarning],
        usesNetwork: Bool,
        usesFileSystem: Bool,
        complexity: ComplexityScore,
        imports: [String]
    ) -> RiskAssessment {
        var score = 0
        
        // Critical warnings add 30 points each
        let criticalCount = warnings.filter { $0.severity == .critical }.count
        score += criticalCount * 30
        
        // High severity warnings add 15 points each
        let highCount = warnings.filter { $0.severity == .high }.count
        score += highCount * 15
        
        // Medium severity warnings add 5 points each
        let mediumCount = warnings.filter { $0.severity == .medium }.count
        score += mediumCount * 5
        
        // Low severity warnings add 1 point each
        let lowCount = warnings.filter { $0.severity == .low }.count
        score += lowCount * 1
        
        // Network access adds 10 points
        if usesNetwork {
            score += 10
        }
        
        // File system access adds 20 points (more dangerous on device)
        if usesFileSystem {
            score += 20
        }
        
        // High complexity adds up to 15 points
        score += min(15, complexity.score / 5)
        
        // External imports add 5 points each (max 25)
        score += min(25, imports.count * 5)
        
        let finalScore = min(100, score)
        
        return RiskAssessment(
            score: finalScore,
            warnings: warnings,
            canRunOnDevice: finalScore < 80,
            requiresSandbox: finalScore >= 40 || usesFileSystem || usesNetwork,
            requiresNetwork: usesNetwork,
            requiresFileSystem: usesFileSystem
        )
    }
    
    // MARK: - Suggestions
    
    private func generateSuggestions(
        language: Language,
        warnings: [SecurityWarning],
        usesNetwork: Bool,
        usesFileSystem: Bool,
        complexity: ComplexityScore,
        imports: [String]
    ) -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []
        
        // Execution location recommendation
        if usesNetwork && !usesFileSystem && complexity.isSimple {
            suggestions.append(OptimizationSuggestion(
                type: .useRemote,
                message: "Network-only operations can run remotely for better isolation",
                alternative: "Consider executing on remote server",
                estimatedImpact: .medium
            ))
        } else if !usesNetwork && !usesFileSystem && complexity.isSimple {
            suggestions.append(OptimizationSuggestion(
                type: .useOnDevice,
                message: "Simple computation with no I/O - ideal for on-device execution",
                alternative: nil,
                estimatedImpact: .high
            ))
        }
        
        // Complexity reduction
        if complexity.isComplex {
            suggestions.append(OptimizationSuggestion(
                type: .reduceComplexity,
                message: "Code complexity is high (\\(complexity.score)/100)",
                alternative: "Consider breaking into smaller functions",
                estimatedImpact: .medium
            ))
        }
        
        // Caching for network operations
        if usesNetwork {
            suggestions.append(OptimizationSuggestion(
                type: .addCaching,
                message: "Network operations detected - consider response caching",
                alternative: "Implement cache layer for API responses",
                estimatedImpact: .high
            ))
        }
        
        // Replace unsafe patterns
        for warning in warnings where warning.severity == .critical || warning.severity == .high {
            suggestions.append(OptimizationSuggestion(
                type: .replaceFeature,
                message: "Replace unsafe pattern: \\(warning.pattern)",
                alternative: warning.suggestion,
                estimatedImpact: .high
            ))
        }
        
        return suggestions
    }
    
    private func determineExecutionRecommendation(
        riskAssessment: RiskAssessment,
        warnings: [SecurityWarning],
        complexity: ComplexityScore
    ) -> CodeAnalysisResult.ExecutionRecommendation {
        let hasCritical = warnings.contains { $0.severity == .critical }
        let hasHigh = warnings.contains { $0.severity == .high }
        
        if hasCritical {
            return .blocked
        }
        
        if riskAssessment.score >= 80 {
            return .requiresReview
        }
        
        if hasHigh || riskAssessment.score >= 60 {
            return .remoteOnly
        }
        
        if riskAssessment.requiresSandbox || riskAssessment.score >= 40 {
            return .sandboxedOnDevice
        }
        
        return .safeOnDevice
    }
    
    // MARK: - Cache Management
    
    private func hashCode(_ code: String) -> String {
        let data = Data(code.utf8)
        var hash = data.reduce(0) { $0 &+ Int($1) }
        hash = hash &+ code.count * 31
        return String(format: "%08X", hash)
    }
    
    private func getCachedAnalysis(hash: String) -> CodeAnalysisResult? {
        return cacheQueue.sync {
            guard let cached = cache[hash],
                  Date().timeIntervalSince(cached.timestamp) < cacheExpiration else {
                return nil
            }
            return cached.result
        }
    }
    
    private func cacheAnalysis(hash: String, result: CodeAnalysisResult) {
        cacheQueue.sync {
            // Evict oldest if at capacity
            if cache.count >= maxCacheSize {
                let oldest = cache.min { $0.value.timestamp < $1.value.timestamp }
                if let key = oldest?.key {
                    cache.removeValue(forKey: key)
                }
            }
            
            cache[hash] = CachedAnalysis(
                result: result,
                timestamp: Date(),
                codeHash: hash
            )
        }
    }
    
    private func findLineNumber(for range: NSRange, in lines: [String]) -> Int? {
        var currentIndex = 0
        for (index, line) in lines.enumerated() {
            let lineRange = NSRange(location: currentIndex, length: line.count)
            if range.location >= lineRange.location && 
               range.location < lineRange.location + lineRange.length + 1 {
                return index + 1 // 1-based line numbers
            }
            currentIndex += line.count + 1 // +1 for newline
        }
        return nil
    }
}

// MARK: - Supporting Types

private struct LanguagePatterns {
    let importPatterns: [String]
    let functionPattern: String
    let unsafePatterns: [String: SecurityWarning.Severity]
}

// MARK: - Convenience Extensions

public extension CodeAnalyzer {
    /// Analyze JavaScript code
    func analyzeJavaScript(_ code: String) -> CodeAnalysisResult {
        return analyze(code: code, language: .javascript)
    }
    
    /// Analyze Python code
    func analyzePython(_ code: String) -> CodeAnalysisResult {
        return analyze(code: code, language: .python)
    }
    
    /// Analyze Swift code
    func analyzeSwift(_ code: String) -> CodeAnalysisResult {
        return analyze(code: code, language: .swift)
    }
    
    /// Analyze TypeScript code
    func analyzeTypeScript(_ code: String) -> CodeAnalysisResult {
        return analyze(code: code, language: .typescript)
    }
}

// MARK: - Preview / Testing Helpers

#if DEBUG
public extension CodeAnalyzer {
    /// Test helper to inspect cache
    func testGetCacheSize() -> Int {
        return cache.count
    }
    
    /// Test helper to pre-populate cache
    func testPopulateCache(hash: String, result: CodeAnalysisResult) {
        cache[hash] = CachedAnalysis(
            result: result,
            timestamp: Date(),
            codeHash: hash
        )
    }
}
#endif