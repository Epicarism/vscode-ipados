# On-Device Code Execution Testing Documentation

> **Version:** 1.0  
> **Last Updated:** February 2025  
> **Scope:** Testing strategy for JavaScriptCore, WebAssembly, and Python execution on iPadOS

---

## Table of Contents

1. [Overview](#overview)
2. [Test Suite Structure](#test-suite-structure)
3. [Unit Tests](#unit-tests)
4. [Integration Tests](#integration-tests)
5. [Manual Testing](#manual-testing)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)
8. [Debugging Guide](#debugging-guide)
9. [CI/CD Integration](#cicd-integration)

---

## Overview

This document provides comprehensive testing guidance for the on-device code execution system in VS Code for iPad. The testing strategy covers unit tests, integration tests, manual testing procedures, performance benchmarks, and security validation.

### Testing Philosophy

- **Isolation**: Each test runs in a clean environment
- **Determinism**: Tests produce consistent results
- **Speed**: Unit tests complete in < 100ms each
- **Coverage**: Aim for > 80% code coverage
- **Realism**: Integration tests use real iOS APIs

---

## Test Suite Structure

```
Services/OnDevice/
├── JSRunner.swift              ← Implementation
├── JSRunnerTests.swift         ← Unit tests
├── PythonRunner.swift          ← Implementation (stub)
├── PythonRunnerTests.swift     ← Unit tests
├── WASMRunner.swift            ← Implementation
├── WASMRunnerTests.swift       ← Unit tests
├── RunnerSelector.swift        ← Decision engine
├── RunnerSelectorTests.swift   ← Unit tests
├── IntegrationTests.swift      ← End-to-end tests
├── MockRunners.swift           ← Test mocks
└── CodeAnalyzer.swift          ← Static analysis

Tests/
├── ServicesTests/
│   └── OnDevice/
│       ├── RunnerSelectorTests.swift
│       └── IntegrationTests.swift
└── UITests/
    └── RunnerWarningViewTests.swift
```

### File Naming Conventions

- `*Tests.swift` - Unit tests (XCTestCase)
- `*IntegrationTests.swift` - Integration tests
- `Mock*.swift` - Test doubles
- `*PerformanceTests.swift` - Performance benchmarks

---

## Unit Tests

### JavaScript Runner Tests

**File:** `Services/OnDevice/JSRunnerTests.swift`

#### Basic Execution Tests

```swift
func testSimpleArithmetic() async throws {
    let runner = JSRunner()
    let result = try await runner.execute("2 + 2")
    XCTAssertEqual(result.toInt32(), 4)
}

func testStringManipulation() async throws {
    let runner = JSRunner()
    let result = try await runner.execute("'hello'.toUpperCase()")
    XCTAssertEqual(result.toString(), "HELLO")
}

func testArrayOperations() async throws {
    let runner = JSRunner()
    let result = try await runner.execute("[1, 2, 3].map(x => x * 2)")
    // Verify array result
}
```

#### Error Handling Tests

```swift
func testSyntaxError() async throws {
    let runner = JSRunner()
    do {
        _ = try await runner.execute("function {")
        XCTFail("Should throw syntax error")
    } catch let error as JSRunnerError {
        XCTAssertTrue(error.isSyntaxError)
    }
}

func testRuntimeError() async throws {
    let runner = JSRunner()
    do {
        _ = try await runner.execute("undefinedFunction()")
        XCTFail("Should throw runtime error")
    } catch let error as JSRunnerError {
        XCTAssertTrue(error.isRuntimeError)
    }
}

func testTimeout() async throws {
    let runner = JSRunner(timeout: 1.0)
    do {
        _ = try await runner.execute("while(true) {}")
        XCTFail("Should timeout")
    } catch JSRunnerError.executionTimeout {
        // ✅ Expected
    }
}
```

#### Console Capture Tests

```swift
func testConsoleLogCapture() async throws {
    let runner = JSRunner()
    var logs: [String] = []
    
    runner.setConsoleHandler { message in
        logs.append(message)
    }
    
    _ = try await runner.execute("console.log('test'); console.log('test2')")
    
    XCTAssertEqual(logs.count, 2)
    XCTAssertTrue(logs[0].contains("test"))
}
```

#### Native Function Tests

```swift
func testExposeNativeFunction() async throws {
    let runner = JSRunner()
    
    runner.exposeNativeFunction(name: "nativeAdd") { args in
        guard args.count >= 2,
              let a = args[0].toInt32(),
              let b = args[1].toInt32() else {
            return JSValue(int32: 0, in: runner.context)
        }
        return JSValue(int32: a + b, in: runner.context)
    }
    
    let result = try await runner.execute("nativeAdd(5, 3)")
    XCTAssertEqual(result.toInt32(), 8)
}
```

### Runner Selector Tests

**File:** `Services/OnDevice/RunnerSelectorTests.swift`

#### Language Detection Tests

```swift
func testJavaScriptDetection() {
    let selector = RunnerSelector()
    let strategy = selector.analyze(code: "function test() {}", language: .javascript)
    XCTAssertEqual(strategy, .onDevice)
}

func testPythonDetection() {
    let selector = RunnerSelector()
    let strategy = selector.analyze(code: "import numpy", language: .python)
    if case .remote = strategy {
        // ✅ Python with numpy requires remote
    } else {
        XCTFail("Should require remote execution")
    }
}

func testNetworkAccessDetection() {
    let selector = RunnerSelector()
    let strategy = selector.analyze(code: "fetch('https://api.com')", language: .javascript)
    if case .remote = strategy {
        // ✅ Network access requires remote
    } else {
        XCTFail("Should require remote for network access")
    }
}
```

#### Resource Estimation Tests

```swift
func testResourceEstimation() {
    let selector = RunnerSelector()
    let estimate = selector.estimateResourceUsage(
        code: String(repeating: "x", count: 10000),
        language: .javascript
    )
    
    XCTAssertGreaterThan(estimate.estimatedMemoryMB, 0)
    XCTAssertLessThan(estimate.estimatedMemoryMB, 100)
}

func testComplexityScore() {
    let selector = RunnerSelector()
    let simple = "2 + 2"
    let complex = """
        function factorial(n) {
            if (n <= 1) return 1;
            return n * factorial(n - 1);
        }
        for (let i = 0; i < 100; i++) {
            factorial(i);
        }
        """
    
    let simpleEstimate = selector.estimateResourceUsage(code: simple, language: .javascript)
    let complexEstimate = selector.estimateResourceUsage(code: complex, language: .javascript)
    
    XCTAssertLessThan(simpleEstimate.estimatedTimeSeconds, complexEstimate.estimatedTimeSeconds)
}
```

---

## Integration Tests

### End-to-End Workflow Tests

**File:** `Services/OnDevice/IntegrationTests.swift`

```swift
func testFullWorkflow() async throws {
    // Given
    let selector = RunnerSelector()
    let runner = JSRunner()
    let code = "2 + 2"
    
    // When
    let strategy = selector.analyze(code: code, language: .javascript)
    XCTAssertEqual(strategy, .onDevice)
    
    let result = try await runner.execute(code)
    
    // Then
    XCTAssertEqual(result.toInt32(), 4)
}

func testJSEndToEnd() async throws {
    let runner = JSRunner()
    var consoleOutput: [String] = []
    
    runner.setConsoleHandler { output in
        consoleOutput.append(output)
    }
    
    let code = """
        function fibonacci(n) {
            if (n <= 1) return n;
            return fibonacci(n - 1) + fibonacci(n - 2);
        }
        const result = fibonacci(10);
        console.log('Result: ' + result);
        result;
        """
    
    let result = try await runner.execute(code)
    
    XCTAssertEqual(result.toInt32(), 55)
    XCTAssertTrue(consoleOutput.contains { $0.contains("55") })
}

func testFallbackToRemote() async throws {
    let selector = RunnerSelector()
    let complexCode = """
        import numpy as np
        data = np.random.rand(1000000)
        print(data.mean())
        """
    
    let result = selector.canRunOnDevice(code: complexCode, language: .python)
    
    XCTAssertFalse(result.canRunOnDevice)
    XCTAssertTrue(result.factors.contains { $0.name == "Dependencies" })
}
```

### Concurrent Execution Tests

```swift
func testConcurrentExecution() async throws {
    let runner = JSRunner()
    let codes = (0..<5).map { "\($0) + \($0)" }
    
    let results = try await withThrowingTaskGroup(of: Int32.self) { group in
        for code in codes {
            group.addTask {
                let result = try await runner.execute(code)
                return result.toInt32()
            }
        }
        
        var results: [Int32] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
    
    XCTAssertEqual(results.sorted(), [0, 2, 4, 6, 8])
}
```

---

## Manual Testing

### Device Preparation

#### Required Devices

| Device | OS Version | Purpose |
|--------|-----------|---------|
| iPad (base) | iOS 17.x | Memory limit testing |
| iPad Air M1/M2 | iPadOS 17.x | Performance baseline |
| iPad Pro M2/M4 | iPadOS 17.x | High-end performance |
| iPad mini | iPadOS 17.x | Compact form factor |

#### Test Setup

```bash
# Install app on device
xcodebuild -scheme VSCodeiPadOS -destination 'platform=iOS,name=iPad' install

# Enable developer settings on iPad
# Settings > Privacy & Security > Developer Mode > ON
```

### Test Scripts

#### JavaScript Test Suite

```javascript
// test-basic.js
console.log("Basic execution test");
const result = 2 + 2;
console.log("Result:", result);
assert(result === 4, "Basic math failed");

// test-console.js
console.log("Log test");
console.warn("Warn test");
console.error("Error test");
console.info("Info test");

// test-array.js
const arr = [1, 2, 3, 4, 5];
const doubled = arr.map(x => x * 2);
console.log("Doubled:", doubled);

// test-object.js
const obj = { name: "test", value: 42 };
console.log("Object:", JSON.stringify(obj));

// test-async.js
async function delayed() {
    return new Promise(resolve => {
        setTimeout(() => resolve("delayed result"), 100);
    });
}
delayed().then(result => console.log(result));

// test-error.js
try {
    throw new Error("Test error");
} catch (e) {
    console.log("Caught:", e.message);
}

// test-recursion.js
function factorial(n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}
console.log("Factorial 5:", factorial(5));

// test-memory.js (should fail on low memory)
const bigArray = new Array(1000000);
console.log("Created array of size:", bigArray.length);

// test-infinite.js (should timeout)
// WARNING: This will timeout
// while(true) {}
```

#### Python Test Suite (if enabled)

```python
# test_basic.py
print("Hello from Python")
x = 42
print(f"Value: {x}")

# test_math.py
import math
result = math.sqrt(16)
print(f"Square root: {result}")

# test_numpy.py (requires numpy)
import numpy as np
arr = np.array([1, 2, 3])
print(f"Array: {arr}")
print(f"Mean: {arr.mean()}")
```

### Expected vs Actual Behavior Checklist

| Test | Expected | Actual | Pass/Fail |
|------|----------|--------|-----------|
| Basic arithmetic | Returns correct result | | |
| Console capture | All logs captured | | |
| Syntax error | Clear error message | | |
| Runtime error | Stack trace shown | | |
| Timeout | Execution stops at limit | | |
| Memory limit | Graceful OOM handling | | |
| Large file | Rejected or handled | | |
| Network code | Requires permission | | |
| File access | Sandbox enforced | | |

---

## Performance Testing

### Benchmark Scripts

#### Editor Performance

```swift
// PerformanceTests.swift
func testExecutionTime() async throws {
    let runner = JSRunner()
    let code = String(repeating: "x = x + 1;\n", count: 1000)
    
    measure {
        let start = CFAbsoluteTimeGetCurrent()
        _ = try? await runner.execute(code)
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Execution time: \(diff) seconds")
    }
}

func testMemoryUsage() async throws {
    let runner = JSRunner()
    let initialMemory = getMemoryUsage()
    
    _ = try await runner.execute("const arr = new Array(1000000);")
    
    let finalMemory = getMemoryUsage()
    let delta = finalMemory - initialMemory
    print("Memory delta: \(delta) MB")
    XCTAssertLessThan(delta, 50) // Should use < 50MB
}
```

#### CPU Performance

```swift
func testCPUUsage() async throws {
    let runner = JSRunner()
    let code = """
        let sum = 0;
        for (let i = 0; i < 1000000; i++) {
            sum += i;
        }
        sum;
        """
    
    let startCPU = getCPUUsage()
    let startTime = CFAbsoluteTimeGetCurrent()
    
    _ = try await runner.execute(code)
    
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    let avgCPU = (getCPUUsage() + startCPU) / 2
    
    print("Duration: \(duration)s, Avg CPU: \(avgCPU)%")
}
```

### Performance Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Cold start | < 100ms | > 500ms |
| Simple execution | < 50ms | > 200ms |
| Complex execution | < 1s | > 5s |
| Memory per execution | < 100MB | > 256MB |
| Concurrent executions | 4 | > 8 |

### Measurement Tools

```swift
// Memory measurement
func getMemoryUsage() -> Double {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                     task_flavor_t(MACH_TASK_BASIC_INFO),
                     $0,
                     &count)
        }
    }
    
    guard kerr == KERN_SUCCESS else { return 0 }
    return Double(info.resident_size) / 1024 / 1024 // MB
}

// CPU measurement
func getCPUUsage() -> Double {
    // Use host_statistics or NSProcessInfo
    // Implementation depends on specific needs
    return 0.0
}
```

---

## Security Testing

### Malicious Code Tests

#### Infinite Loop Detection

```javascript
// test-infinite-loop.js - Should timeout
while(true) {
    // Busy loop
}

// test-deep-recursion.js - Should hit stack limit
function recurse(n) {
    return recurse(n + 1);
}
recurse(0);
```

#### Memory Exhaustion Tests

```javascript
// test-memory-exhaustion.js
const arrays = [];
while(true) {
    arrays.push(new Array(1000000));
}

// test-string-bomb.js
let str = "x";
while(true) {
    str = str + str; // Exponential growth
}
```

#### Injection Tests

```javascript
// test-prototype-pollution.js
Object.prototype.polluted = true;

// test-eval-injection.js
eval("console.log('Injected')");

// test-function-constructor.js
const fn = new Function("console.log('Injected')");
fn();
```

#### File System Escape Tests

```javascript
// Requires Node.js compatibility layer
// Should be blocked by sandbox
const fs = require('fs');
fs.readFileSync('../../../etc/passwd');
```

### Sandbox Escape Attempts

| Attack Vector | Test Case | Expected Result |
|-------------|-----------|-----------------|
| Path Traversal | `../../../etc/passwd` | Access denied |
| Symlink Escape | Create symlink to / | Resolved within sandbox |
| Null Byte Injection | `file.txt\x00.jpg` | Rejected |
| Unicode Normalization | Unicode path variants | Normalized to safe path |
| Resource Fork | `file.txt/..namedfork/rsrc` | Access denied |

### Resource Exhaustion Test Data

```swift
// Create test files
let sizes = [1024, 1024*1024, 10*1024*1024] // 1KB, 1MB, 10MB
for size in sizes {
    let data = Data(repeating: 0, count: size)
    let url = URL(fileURLWithPath: "/tmp/test-\(size).dat")
    try? data.write(to: url)
}
```

---

## Debugging Guide

### Common Failures

#### Test Activation Failures

**Symptom:** `XCTestCase` not found or tests don't run  
**Cause:** Missing test target configuration  
**Fix:**
```bash
# Ensure test target is set up
xcodebuild -list
xcodebuild test -scheme VSCodeiPadOS -destination 'platform=iOS Simulator,name=iPad Pro'
```

#### WebView Failures

**Symptom:** `WKWebView` not loading or crashing  
**Cause:** Main thread requirement  
**Fix:**
```swift
// Always use MainActor for WebView
@MainActor
func loadWebView() {
    let webView = WKWebView()
    // ...
}
```

#### File System Failures

**Symptom:** File operations fail with permission denied  
**Cause:** Attempting to access outside app container  
**Fix:**
```swift
// Use correct directory
let documents = FileManager.default.urls(
    for: .documentDirectory, 
    in: .userDomainMask
).first!
```

#### Performance Failures

**Symptom:** Tests timeout or run slowly  
**Cause:** Blocking main thread or excessive memory  
**Fix:**
```swift
// Use async/await
func testPerformance() async throws {
    // Move heavy work off main thread
    try await Task.detached {
        // Heavy work
    }.value
}
```

### Log Analysis

#### Enable Debug Logging

```swift
// In setup
UserDefaults.standard.set(true, forKey: "JSRunnerDebugEnabled")

// In code
if UserDefaults.standard.bool(forKey: "JSRunnerDebugEnabled") {
    print("[JSRunner] \(message)")
}
```

#### View Device Logs

```bash
# View all logs
idevicesyslog

# Filter for app
idevicesyslog | grep VSCodeiPadOS

# Save to file
idevicesyslog > app.log

# Real-time with filter
xcrun simctl spawn booted log stream --predicate 'process == "VSCodeiPadOS"'
```

### Troubleshooting Steps

1. **Check Environment**
   ```bash
   xcrun simctl list devices
   xcodebuild -version
   swift --version
   ```

2. **Clean Build**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   xcodebuild clean
   ```

3. **Reset Simulator**
   ```bash
   xcrun simctl erase all
   ```

4. **Check Entitlements**
   ```bash
   codesign -d --entitlements :- /path/to/app.app
   ```

### Emergency Recovery

If tests leave system in bad state:

```bash
# Kill all related processes
killall -9 "Simulator"
killall -9 "Xcode"

# Reset device
xcrun simctl shutdown all
xcrun simctl erase all

# Clear caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode/
rm -rf ~/Library/Developer/CoreSimulator/
```

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/tests.yml
name: On-Device Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
      - name: Run Unit Tests
        run: |
          xcodebuild test \
            -scheme VSCodeiPadOS \
            -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
            -only-testing:VSCodeiPadOSTests/JSRunnerTests \
            -only-testing:VSCodeiPadOSTests/RunnerSelectorTests
      
      - name: Upload Results
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: test-results
          path: build/reports/

  integration-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Integration Tests
        run: |
          xcodebuild test \
            -scheme VSCodeiPadOS \
            -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
            -only-testing:VSCodeiPadOSTests/IntegrationTests

  security-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Security Tests
        run: |
          xcodebuild test \
            -scheme VSCodeiPadOS \
            -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
            -only-testing:VSCodeiPadOSTests/SecurityTests

  performance-tests:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Performance Tests
        run: |
          xcodebuild test \
            -scheme VSCodeiPadOS \
            -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
            -only-testing:VSCodeiPadOSTests/PerformanceTests
```

### Test Reporting

```swift
// XCTestCase extension for better reporting
extension XCTestCase {
    func reportMemoryUsage() {
        let usage = getMemoryUsage()
        add(XCTAttachment(string: "Memory Usage: \(usage) MB"))
    }
    
    func reportExecutionTime(_ block: () async throws -> Void) async rethrows {
        let start = CFAbsoluteTimeGetCurrent()
        try await block()
        let time = CFAbsoluteTimeGetCurrent() - start
        add(XCTAttachment(string: "Execution Time: \(time) seconds"))
    }
}
```

### Pre-Release Checklist

- [ ] All unit tests passing (> 80% coverage)
- [ ] All integration tests passing
- [ ] Security tests passing
- [ ] Performance tests meeting targets
- [ ] Manual testing on physical device
- [ ] Memory leak check (Instruments)
- [ ] UI tests passing
- [ ] Accessibility tests passing

---

## Environment Variables

```bash
# Debug mode
export JSRUNNER_DEBUG=1

# Extended timeout (for slow devices)
export JSRUNNER_TIMEOUT=60

# Disable memory limits (testing only)
export JSRUNNER_NO_MEMORY_LIMIT=1

# Verbose logging
export JSRUNNER_VERBOSE=1

# Test specific runner
export TEST_RUNNER=JSRunner
```

## Scripts

### Run All Tests

```bash
#!/bin/bash
# run-all-tests.sh

set -e

echo "Running unit tests..."
xcodebuild test -scheme VSCodeiPadOS \
    -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
    -only-testing:VSCodeiPadOSTests

echo "Running performance tests..."
xcodebuild test -scheme VSCodeiPadOS \
    -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
    -only-testing:VSCodeiPadOSTests/PerformanceTests

echo "All tests passed!"
```

### Performance Benchmark

```bash
#!/bin/bash
# benchmark.sh

for i in {1..10}; do
    echo "Run $i:"
    xcodebuild test -scheme VSCodeiPadOS \
        -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (6th generation)' \
        -only-testing:VSCodeiPadOSTests/PerformanceTests \
        2>&1 | grep "Execution Time"
done
```

---

## References

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [iOS Testing Guide](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)
- [Performance Testing](https://developer.apple.com/documentation/xctest/performance_tests)
- [UI Testing](https://developer.apple.com/documentation/xctest/user_interface_tests)
