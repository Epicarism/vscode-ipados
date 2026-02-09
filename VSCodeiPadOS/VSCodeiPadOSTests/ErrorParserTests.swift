import XCTest
@testable import VSCodeiPadOS

/// Unit tests for ErrorParser
/// Tests parsing of various error formats from different programming languages
@MainActor
final class ErrorParserTests: XCTestCase {
    
    // MARK: - Python Traceback Tests
    
    func testPythonSimpleTraceback() throws {
        let errorOutput = """
        Traceback (most recent call last):
          File "app.py", line 42, in <module>
            main()
          File "app.py", line 38, in main
            result = calculate()
          File "utils.py", line 15, in calculate
            return x / y
        ZeroDivisionError: division by zero
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 3, "Should extract 3 stack frames from Python traceback")
        
        // First frame
        XCTAssertEqual(errors[0].file, "app.py")
        XCTAssertEqual(errors[0].line, 42)
        XCTAssertNil(errors[0].column)
        XCTAssertEqual(errors[0].message, "main()")
        
        // Second frame
        XCTAssertEqual(errors[1].file, "app.py")
        XCTAssertEqual(errors[1].line, 38)
        XCTAssertNil(errors[1].column)
        XCTAssertEqual(errors[1].message, "result = calculate()")
        
        // Third frame - actual error location
        XCTAssertEqual(errors[2].file, "utils.py")
        XCTAssertEqual(errors[2].line, 15)
        XCTAssertNil(errors[2].column)
        XCTAssertEqual(errors[2].message, "return x / y")
        XCTAssertEqual(errors[2].errorType, "ZeroDivisionError")
        XCTAssertEqual(errors[2].errorDescription, "division by zero")
    }
    
    func testPythonTracebackWithSyntaxError() throws {
        let errorOutput = """
          File "script.py", line 10
            if x > 5
                    ^
        SyntaxError: expected ':'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "script.py")
        XCTAssertEqual(errors[0].line, 10)
        XCTAssertEqual(errors[0].column, 9)
        XCTAssertEqual(errors[0].errorType, "SyntaxError")
        XCTAssertEqual(errors[0].errorDescription, "expected ':'")
    }
    
    func testPythonTracebackWithFullPath() throws {
        let errorOutput = """
        Traceback (most recent call last):
          File "/home/user/project/src/main.py", line 25, in process_data
            data = load_data()
          File "/home/user/project/src/data_loader.py", line 50, in load_data
            with open(filename, 'r') as f:
        FileNotFoundError: [Errno 2] No such file or directory: 'data.csv'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0].file, "/home/user/project/src/main.py")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[1].file, "/home/user/project/src/data_loader.py")
        XCTAssertEqual(errors[1].line, 50)
        XCTAssertEqual(errors[1].errorType, "FileNotFoundError")
    }
    
    func testPythonTracebackWithModuleInfo() throws {
        let errorOutput = """
        Traceback (most recent call last):
          File "/usr/lib/python3.9/runpy.py", line 197, in _run_module_as_main
            return _run_code(code=mod_globals, init_globals=None,
          File "/usr/lib/python3.9/runpy.py", line 87, in _run_code
            exec(code, run_globals)
          File "/home/user/app.py", line 5, in <module>
            import nonexistent_module
        ModuleNotFoundError: No module named 'nonexistent_module'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        
        // Should filter out system files and focus on user code
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        let userError = errors.first { $0.file.contains("app.py") }
        XCTAssertNotNil(userError)
        XCTAssertEqual(userError?.line, 5)
        XCTAssertEqual(userError?.errorType, "ModuleNotFoundError")
    }
    
    // MARK: - Node.js Stack Trace Tests
    
    func testNodeJSSimpleStackTrace() throws {
        let errorOutput = """
        /home/user/project/app.js:15
            console.log(undefinedVariable);
                        ^
        
        ReferenceError: undefinedVariable is not defined
            at Object.<anonymous> (/home/user/project/app.js:15:21)
            at Module._compile (internal/modules/cjs/loader.js:1068:30)
            at Object.Module._extensions..js (internal/modules/cjs/loader.js:1097:10)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .javascript)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/app.js")
        XCTAssertEqual(errors[0].line, 15)
        XCTAssertEqual(errors[0].column, 21)
        XCTAssertEqual(errors[0].errorType, "ReferenceError")
        XCTAssertEqual(errors[0].errorDescription, "undefinedVariable is not defined")
    }
    
    func testNodeJSNestedStackTrace() throws {
        let errorOutput = """
        Error: Database connection failed
            at connectDB (/home/user/project/src/db.js:45:11)
            at processTicksAndRejections (internal/process/task_queues.js:97:5)
            at async init (/home/user/project/src/app.js:23:5)
            at async main (/home/user/project/src/index.js:10:3)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .javascript)
        
        XCTAssertGreaterThanOrEqual(errors.count, 3)
        
        // Check first frame
        XCTAssertEqual(errors[0].file, "/home/user/project/src/db.js")
        XCTAssertEqual(errors[0].line, 45)
        XCTAssertEqual(errors[0].column, 11)
        XCTAssertEqual(errors[0].function, "connectDB")
        
        // Check async frames
        XCTAssertTrue(errors.contains { $0.file == "/home/user/project/src/app.js" && $0.line == 23 })
        XCTAssertTrue(errors.contains { $0.file == "/home/user/project/src/index.js" && $0.line == 10 })
    }
    
    func testNodeJSTypeScriptStackTrace() throws {
        let errorOutput = """
        src/services/UserService.ts:78:15 - error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.
        
        78         processData(userId);
                       ~~~~~~
        
            at createTSError (/node_modules/ts-node/src/index.ts:513:12)
            at reportTSError (/node_modules/ts-node/src/index.ts:517:19)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .typescript)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "src/services/UserService.ts")
        XCTAssertEqual(errors[0].line, 78)
        XCTAssertEqual(errors[0].column, 15)
        XCTAssertEqual(errors[0].errorType, "TS2345")
        XCTAssertTrue(errors[0].errorDescription?.contains("not assignable") ?? false)
    }
    
    func testNodeJSErrorWithRelativePath() throws {
        let errorOutput = """
        ./src/utils/helpers.js:30
        throw new Error('Invalid input');
        ^
        
        Error: Invalid input
            at validateInput (./src/utils/helpers.js:30:9)
            at processData (./src/components/Processor.js:15:5)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .javascript)
        
        XCTAssertTrue(errors.contains { $0.file.contains("helpers.js") && $0.line == 30 })
        XCTAssertTrue(errors.contains { $0.file.contains("Processor.js") && $0.line == 15 })
    }
    
    // MARK: - Swift Compiler Error Tests
    
    func testSwiftCompilerSimpleError() throws {
        let errorOutput = """
        /Users/dev/project/Sources/Main.swift:42:15: error: cannot find 'undeclaredVar' in scope
            let x = undeclaredVar
                      ^~~~~~~~~~~~~
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/Users/dev/project/Sources/Main.swift")
        XCTAssertEqual(errors[0].line, 42)
        XCTAssertEqual(errors[0].column, 15)
        XCTAssertEqual(errors[0].severity, .error)
        XCTAssertTrue(errors[0].message.contains("cannot find"))
    }
    
    func testSwiftCompilerMultipleErrors() throws {
        let errorOutput = """
        /Users/dev/project/Sources/ViewModel.swift:25:5: error: value of type 'String' has no member 'toInt'
            return value.toInt()
            ^
        /Users/dev/project/Sources/ViewModel.swift:30:10: warning: variable 'unused' was never used
            let unused = calculate()
                ^
        /Users/dev/project/Sources/ViewModel.swift:35:20: error: missing return in instance method expected to return 'Int'
        }
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        
        XCTAssertEqual(errors.count, 3)
        
        // First error
        XCTAssertEqual(errors[0].file, "/Users/dev/project/Sources/ViewModel.swift")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[0].column, 5)
        XCTAssertEqual(errors[0].severity, .error)
        
        // Warning
        XCTAssertEqual(errors[1].file, "/Users/dev/project/Sources/ViewModel.swift")
        XCTAssertEqual(errors[1].line, 30)
        XCTAssertEqual(errors[1].column, 10)
        XCTAssertEqual(errors[1].severity, .warning)
        XCTAssertTrue(errors[1].message.contains("never used"))
        
        // Third error
        XCTAssertEqual(errors[2].line, 35)
        XCTAssertEqual(errors[2].column, 20)
        XCTAssertEqual(errors[2].severity, .error)
    }
    
    func testSwiftCompilerNoteWithFixIt() throws {
        let errorOutput = """
        /Users/dev/project/Sources/NetworkManager.swift:50:24: error: cannot convert value of type 'String' to expected argument type 'URL'
            let request = URLRequest(url: endpoint)
                                       ^~~~~~~~
        /Users/dev/project/Sources/NetworkManager.swift:50:24: note: overloads for 'URLRequest' exist with these partially matching parameter lists: (url: URL), (url: URL, cachePolicy: URLRequest.CachePolicy, timeoutInterval: TimeInterval)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].severity, .error)
        
        // Should include note as additional context or separate entry
        let note = errors.first { $0.message.contains("overloads for") }
        XCTAssertNotNil(note)
    }
    
    func testSwiftPackageBuildError() throws {
        let errorOutput = """
        /Users/dev/project/Package.swift:12:15: error: type 'Package.Dependency' has no member 'package'
                    .package(url: "https://github.com/example/repo", from: "1.0.0"),
                     ^
        error: fatalError
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        
        XCTAssertTrue(errors.contains { $0.file.hasSuffix("Package.swift") })
    }
    
    // MARK: - Go Build Error Tests
    
    func testGoBuildSimpleError() throws {
        let errorOutput = """
        # github.com/user/project
./main.go:25:10: undefined: someFunction
./main.go:30:5: invalid operation: mismatched types int and string
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 2)
        
        XCTAssertEqual(errors[0].file, "./main.go")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[0].column, 10)
        XCTAssertEqual(errors[0].message, "undefined: someFunction")
        XCTAssertEqual(errors[0].severity, .error)
        
        XCTAssertEqual(errors[1].file, "./main.go")
        XCTAssertEqual(errors[1].line, 30)
        XCTAssertEqual(errors[1].column, 5)
        XCTAssertEqual(errors[1].message, "invalid operation: mismatched types int and string")
    }
    
    func testGoVetWarning() throws {
        let errorOutput = """
        # github.com/user/project
./utils.go:45:12: possible formatting directive in Println call
./utils.go:50:3: the cancel function is not used on all paths (possible context leak)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0].line, 45)
        XCTAssertEqual(errors[0].column, 12)
        XCTAssertEqual(errors[0].severity, .warning)
        XCTAssertTrue(errors[0].message.contains("Println"))
    }
    
    func testGoCompilerFullPath() throws {
        let errorOutput = """
        /home/user/go/src/github.com/user/project/handlers/api.go:120:25: cannot use data (type []byte) as type string in argument to processString
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/go/src/github.com/user/project/handlers/api.go")
        XCTAssertEqual(errors[0].line, 120)
        XCTAssertEqual(errors[0].column, 25)
    }
    
    func testGoTestFailure() throws {
        let errorOutput = """
        --- FAIL: TestCalculate (0.00s)
            calculator_test.go:15: expected 4, got 5
            calculator_test.go:16: test failed at line 16
        FAIL
        FAIL\tgithub.com/user/project\t0.123s
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .go)
        
        XCTAssertGreaterThanOrEqual(errors.count, 2)
        
        let testErrors = errors.filter { $0.file.contains("_test.go") }
        XCTAssertEqual(testErrors.count, 2)
        XCTAssertEqual(testErrors[0].line, 15)
        XCTAssertTrue(testErrors[0].message.contains("expected 4"))
    }
    
    func testGoMultipleFilesError() throws {
        let errorOutput = """
        # github.com/user/project
./main.go:10:5: imported and not used: "fmt"
./models/user.go:25:2: field 'Id' is unused
./services/auth.go:45:20: undefined: ValidateToken
./controllers/home.go:15:1: syntax error: unexpected newline, expecting comma or )
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 4)
        
        let files = errors.map { $0.file }
        XCTAssertTrue(files.contains("./main.go"))
        XCTAssertTrue(files.contains("./models/user.go"))
        XCTAssertTrue(files.contains("./services/auth.go"))
        XCTAssertTrue(files.contains("./controllers/home.go"))
    }
    
    // MARK: - Ruby Error Tests
    
    func testRubySimpleError() throws {
        let errorOutput = """
        /home/user/project/app.rb:25:in `process_data': undefined method `to_int' for nil:NilClass (NoMethodError)
        
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .ruby)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/app.rb")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[0].function, "process_data")
        XCTAssertEqual(errors[0].errorType, "NoMethodError")
        XCTAssertTrue(errors[0].message.contains("undefined method"))
    }
    
    func testRubyBacktrace() throws {
        let errorOutput = """
        /home/user/project/lib/processor.rb:42:in `block in process': Invalid data format (RuntimeError)
            from /home/user/project/lib/processor.rb:38:in `each'
            from /home/user/project/lib/processor.rb:38:in `process'
            from /home/user/project/app.rb:15:in `<main>'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .ruby)
        
        XCTAssertEqual(errors.count, 4)
        
        // First frame (actual error)
        XCTAssertEqual(errors[0].file, "/home/user/project/lib/processor.rb")
        XCTAssertEqual(errors[0].line, 42)
        XCTAssertTrue(errors[0].function?.contains("block in process") ?? false)
        XCTAssertEqual(errors[0].errorType, "RuntimeError")
        
        // Rest of stack
        XCTAssertEqual(errors[1].line, 38)
        XCTAssertEqual(errors[2].line, 38)
        XCTAssertEqual(errors[3].file, "/home/user/project/app.rb")
        XCTAssertEqual(errors[3].line, 15)
    }
    
    func testRubySyntaxError() throws {
        let errorOutput = """
        /home/user/project/script.rb:10: syntax error, unexpected end-of-input, expecting keyword_end
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .ruby)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/script.rb")
        XCTAssertEqual(errors[0].line, 10)
        XCTAssertEqual(errors[0].errorType, "syntax error")
        XCTAssertTrue(errors[0].message.contains("unexpected end-of-input"))
    }
    
    func testRubyGemLoadError() throws {
        let errorOutput = """
        /var/lib/gems/2.7.0/gems/bundler-2.2.3/lib/bundler/spec_set.rb:86:in `block in materialize': Could not find nokogiri-1.11.0 in any of the sources (Bundler::GemNotFound)
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .ruby)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].errorType, "Bundler::GemNotFound")
        XCTAssertTrue(errors[0].message.contains("Could not find nokogiri"))
    }
    
    func testRubyRSpecFailure() throws {
        let errorOutput = """
        Failures:
        
          1) Calculator#add returns the sum of two numbers
             Failure/Error: expect(calculator.add(2, 2)).to eq(5)
             
               expected: 5
                    got: 4
               
               (compared using ==)
             # ./spec/calculator_spec.rb:12:in `block (3 levels) in <top (required)>'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .ruby)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertTrue(errors.contains { $0.file.contains("calculator_spec.rb") })
        XCTAssertTrue(errors[0].message.contains("expected: 5") || errors[0].message.contains("Failure/Error"))
    }
    
    // MARK: - Generic Compiler Error Tests
    
    func testGenericCError() throws {
        let errorOutput = """
        main.c:15:5: error: expected ';' before 'return'
            return 0;
            ^~~~~~
        main.c:20:10: warning: unused variable 'x' [-Wunused-variable]
            int x = 5;
                ^
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .c)
        
        XCTAssertEqual(errors.count, 2)
        
        XCTAssertEqual(errors[0].file, "main.c")
        XCTAssertEqual(errors[0].line, 15)
        XCTAssertEqual(errors[0].column, 5)
        XCTAssertEqual(errors[0].severity, .error)
        
        XCTAssertEqual(errors[1].severity, .warning)
        XCTAssertEqual(errors[1].line, 20)
        XCTAssertEqual(errors[1].column, 10)
    }
    
    func testGenericCPlusPlusTemplateError() throws {
        let errorOutput = """
        template<typename T>
        ^
        test.cpp:25:5: note: candidate template ignored: couldn't infer template argument 'T'
            process<T>(value);
            ^
        test.cpp:25:13: error: no matching function for call to 'process'
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .cpp)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        let errorEntry = errors.first { $0.severity == .error }
        XCTAssertNotNil(errorEntry)
        XCTAssertEqual(errorEntry?.line, 25)
        XCTAssertEqual(errorEntry?.column, 13)
    }
    
    func testGenericJavaError() throws {
        let errorOutput = """
        Main.java:12: error: cannot find symbol
            System.out.println(undefinedVariable);
                             ^
          symbol:   variable undefinedVariable
          location: class Main
        Main.java:15: warning: [unchecked] unchecked conversion
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .java)
        
        XCTAssertGreaterThanOrEqual(errors.count, 2)
        
        let error = errors.first { $0.severity == .error }
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.file, "Main.java")
        XCTAssertEqual(error?.line, 12)
    }
    
    func testGenericRustError() throws {
        let errorOutput = """
        error[E0425]: cannot find value `x` in this scope
         --> src/main.rs:15:13
          |
        15 |     let y = x + 1;
          |             ^ help: a local variable with a similar name exists: `y`
          |
        error: aborting due to previous error
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .rust)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        
        let error = errors.first { $0.errorType == "E0425" }
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.file, "src/main.rs")
        XCTAssertEqual(error?.line, 15)
        XCTAssertEqual(error?.column, 13)
        XCTAssertTrue(error?.message.contains("cannot find value") ?? false)
    }
    
    func testGenericMakeError() throws {
        let errorOutput = """
        gcc -c -o main.o main.c
        main.c:5:10: fatal error: missing_header.h: No such file or directory
            5 | #include <missing_header.h>
              |          ^~~~~~~~~~~~~~~~~~
        compilation terminated.
        make: *** [Makefile:15: main.o] Error 1
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .generic)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertTrue(errors.contains { $0.severity == .fatal })
        XCTAssertTrue(errors[0].message.contains("No such file or directory"))
    }
    
    // MARK: - Edge Cases and Special Formats
    
    func testMultipleLanguagesInOutput() throws {
        let errorOutput = """
        Python error:
          File "script.py", line 10, in <module>
            main()
        
        Node.js error:
        /project/app.js:25
        throw new Error('test');
        ^
        """
        
        // When language is not specified or is generic, should try to detect
        let errors = ErrorParser.parse(errorOutput, language: .generic)
        
        // Should detect and parse both formats
        XCTAssertGreaterThanOrEqual(errors.count, 2)
    }
    
    func testEmptyOutput() throws {
        let errors = ErrorParser.parse("", language: .python)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testNoErrorsFound() throws {
        let errorOutput = """
        Build successful!
        All tests passed.
        Coverage: 95%
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testMalformedErrorOutput() throws {
        let errorOutput = """
        Some random text without proper format
        File: something
        Line: twenty-five
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        // Should handle gracefully without crashing
        XCTAssertEqual(errors.count, 0)
    }
    
    func testWindowsPathStyle() throws {
        let errorOutput = """
        C:\\Users\\Dev\\Project\\app.py:42: error: something went wrong
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .generic)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "C:\\Users\\Dev\\Project\\app.py")
        XCTAssertEqual(errors[0].line, 42)
    }
    
    func testVeryLongPath() throws {
        let longPath = "/very/long/path/to/the/project/that/has/many/nested/directories/src/components/utils/helpers/file.swift"
        let errorOutput = "\(longPath):100:50: error: some error"
        
        let errors = ErrorParser.parse(errorOutput, language: .swift)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, longPath)
        XCTAssertEqual(errors[0].line, 100)
        XCTAssertEqual(errors[0].column, 50)
    }
    
    func testUnicodeInPathAndMessage() throws {
        let errorOutput = """
        /项目/源码/文件.py:15: error: 发生错误
        """
        
        let errors = ErrorParser.parse(errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/项目/源码/文件.py")
        XCTAssertTrue(errors[0].message.contains("发生错误"))
    }
    
    func testLineAndColumnExtraction() throws {
        // Test various line/column formats
        let formats = [
            ("file.py:10", 10, nil as Int?),
            ("file.py:10:5", 10, 5),
            ("file.py(10)", 10, nil),
            ("file.py(10,5)", 10, 5),
            ("file.py:10:5:10:15", 10, 5), // Range format
            ("[file.py:10]", 10, nil),
            ("file.py: 10 : 5", 10, 5),
        ]
        
        for (format, expectedLine, expectedColumn) in formats {
            let errorOutput = "\(format): error: test"
            let errors = ErrorParser.parse(errorOutput, language: .generic)
            
            XCTAssertEqual(errors.first?.line, expectedLine, "Failed for format: \(format)")
            XCTAssertEqual(errors.first?.column, expectedColumn, "Failed for format: \(format)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testLargeOutputPerformance() throws {
        var largeOutput = ""
        for i in 0..<1000 {
            largeOutput += "/path/to/file\(i).swift:\(i*10):\(i): error: Error number \(i)\n"
        }
        
        measure {
            let errors = ErrorParser.parse(largeOutput, language: .swift)
            XCTAssertEqual(errors.count, 1000)
        }
    }
    
    // MARK: - Helper Tests
    
    func testLanguageDetection() throws {
        // Python patterns
        XCTAssertEqual(ErrorParser.detectLanguage("Traceback (most recent call last):"), .python)
        XCTAssertEqual(ErrorParser.detectLanguage("  File \"test.py\", line 10"), .python)
        
        // Node.js patterns
        XCTAssertEqual(ErrorParser.detectLanguage("/path/file.js:10"), .javascript)
        XCTAssertEqual(ErrorParser.detectLanguage("ReferenceError:"), .javascript)
        
        // Swift patterns
        XCTAssertEqual(ErrorParser.detectLanguage("file.swift:10:5: error:"), .swift)
        
        // Go patterns
        XCTAssertEqual(ErrorParser.detectLanguage("./main.go:10:5:"), .go)
        XCTAssertEqual(ErrorParser.detectLanguage("# command-line-arguments"), .go)
        
        // Ruby patterns
        XCTAssertEqual(ErrorParser.detectLanguage("file.rb:10:in `"), .ruby)
        XCTAssertEqual(ErrorParser.detectLanguage("SyntaxError:"), .ruby)
        
        // Generic fallback
        XCTAssertEqual(ErrorParser.detectLanguage("random text"), nil)
    }
}

// MARK: - Test Helpers

extension ErrorParser.ParsedError: Equatable {
    public static func == (lhs: ErrorParser.ParsedError, rhs: ErrorParser.ParsedError) -> Bool {
        lhs.file == rhs.file &&
        lhs.line == rhs.line &&
        lhs.column == rhs.column &&
        lhs.message == rhs.message &&
        lhs.severity == rhs.severity &&
        lhs.errorType == rhs.errorType &&
        lhs.function == rhs.function
    }
}
