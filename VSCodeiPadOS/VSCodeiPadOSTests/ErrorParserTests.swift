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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 3, "Should extract 3 stack frames from Python traceback")
        
        // First frame
        XCTAssertEqual(errors[0].file, "app.py")
        XCTAssertEqual(errors[0].line, 42)
        XCTAssertEqual(errors[0].column, 0)
        XCTAssertTrue(errors[0].message.contains("main"))
        
        // Second frame
        XCTAssertEqual(errors[1].file, "app.py")
        XCTAssertEqual(errors[1].line, 38)
        XCTAssertEqual(errors[1].column, 0)
        XCTAssertTrue(errors[1].message.contains("calculate"))
        
        // Third frame - actual error location
        XCTAssertEqual(errors[2].file, "utils.py")
        XCTAssertEqual(errors[2].line, 15)
        XCTAssertEqual(errors[2].column, 0)
        XCTAssertTrue(errors[2].message.contains("x / y") || errors[2].message.contains("ZeroDivisionError"))
    }
    
    func testPythonTracebackWithSyntaxError() throws {
        let errorOutput = """
          File "script.py", line 10
            if x > 5
                    ^
        SyntaxError: expected ':'
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "script.py")
        XCTAssertEqual(errors[0].line, 10)
        XCTAssertTrue(errors[0].message.contains("SyntaxError") || errors[0].message.contains("expected"))
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0].file, "/home/user/project/src/main.py")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[1].file, "/home/user/project/src/data_loader.py")
        XCTAssertEqual(errors[1].line, 50)
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        
        // Should extract all frames including system files
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        let userError = errors.first { $0.file.contains("app.py") }
        XCTAssertNotNil(userError)
        XCTAssertEqual(userError?.line, 5)
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .nodeJS)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/app.js")
        XCTAssertEqual(errors[0].line, 15)
        XCTAssertEqual(errors[0].column, 21)
        XCTAssertTrue(errors[0].message.contains("ReferenceError") || errors[0].message.contains("undefinedVariable"))
    }
    
    func testNodeJSNestedStackTrace() throws {
        let errorOutput = """
        Error: Database connection failed
            at connectDB (/home/user/project/src/db.js:45:11)
            at processTicksAndRejections (internal/process/task_queues.js:97:5)
            at async init (/home/user/project/src/app.js:23:5)
            at async main (/home/user/project/src/index.js:10:3)
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .nodeJS)
        
        XCTAssertGreaterThanOrEqual(errors.count, 2)
        
        // Check first frame
        XCTAssertEqual(errors[0].file, "/home/user/project/src/db.js")
        XCTAssertEqual(errors[0].line, 45)
        XCTAssertEqual(errors[0].column, 11)
        
        // Check async frames exist
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .nodeJS)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        let tsError = errors.first { $0.file.contains("UserService.ts") }
        if let tsError = tsError {
            XCTAssertEqual(tsError.line, 78)
            XCTAssertEqual(tsError.column, 15)
        }
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .nodeJS)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertEqual(errors[0].severity, .error)
        
        // Should include note as additional entry
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        
        XCTAssertTrue(errors.contains { $0.file.hasSuffix("Package.swift") })
    }
    
    // MARK: - Go Build Error Tests
    
    func testGoBuildSimpleError() throws {
        let errorOutput = """
        # github.com/user/project
./main.go:25:10: undefined: someFunction
./main.go:30:5: invalid operation: mismatched types int and string
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 2)
        
        XCTAssertEqual(errors[0].file, "./main.go")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertEqual(errors[0].column, 10)
        XCTAssertTrue(errors[0].message.contains("undefined: someFunction"))
        XCTAssertEqual(errors[0].severity, .error)
        
        XCTAssertEqual(errors[1].file, "./main.go")
        XCTAssertEqual(errors[1].line, 30)
        XCTAssertEqual(errors[1].column, 5)
        XCTAssertTrue(errors[1].message.contains("mismatched types"))
    }
    
    func testGoVetWarning() throws {
        let errorOutput = """
        # github.com/user/project
./utils.go:45:12: possible formatting directive in Println call
./utils.go:50:3: the cancel function is not used on all paths (possible context leak)
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .go)
        
        XCTAssertEqual(errors.count, 2)
        XCTAssertEqual(errors[0].line, 45)
        XCTAssertEqual(errors[0].column, 12)
        XCTAssertTrue(errors[0].message.contains("Println"))
    }
    
    func testGoCompilerFullPath() throws {
        let errorOutput = """
        /home/user/go/src/github.com/user/project/handlers/api.go:120:25: cannot use data (type []byte) as type string in argument to processString
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .go)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .go)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .go)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .ruby)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/app.rb")
        XCTAssertEqual(errors[0].line, 25)
        XCTAssertTrue(errors[0].message.contains("undefined method") || errors[0].message.contains("NoMethodError"))
    }
    
    func testRubyBacktrace() throws {
        let errorOutput = """
        /home/user/project/lib/processor.rb:42:in `block in process': Invalid data format (RuntimeError)
            from /home/user/project/lib/processor.rb:38:in `each'
            from /home/user/project/lib/processor.rb:38:in `process'
            from /home/user/project/app.rb:15:in `<main>'
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .ruby)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        
        // First frame (actual error)
        XCTAssertEqual(errors[0].file, "/home/user/project/lib/processor.rb")
        XCTAssertEqual(errors[0].line, 42)
        
        // Check for stack frames
        if errors.count >= 4 {
            XCTAssertEqual(errors[1].line, 38)
            XCTAssertEqual(errors[2].line, 38)
            XCTAssertEqual(errors[3].file, "/home/user/project/app.rb")
            XCTAssertEqual(errors[3].line, 15)
        }
    }
    
    func testRubySyntaxError() throws {
        let errorOutput = """
        /home/user/project/script.rb:10: syntax error, unexpected end-of-input, expecting keyword_end
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .ruby)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, "/home/user/project/script.rb")
        XCTAssertEqual(errors[0].line, 10)
        XCTAssertTrue(errors[0].message.contains("syntax error") || errors[0].message.contains("unexpected end-of-input"))
    }
    
    func testRubyGemLoadError() throws {
        let errorOutput = """
        /var/lib/gems/2.7.0/gems/bundler-2.2.3/lib/bundler/spec_set.rb:86:in `block in materialize': Could not find nokogiri-1.11.0 in any of the sources (Bundler::GemNotFound)
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .ruby)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertTrue(errors[0].message.contains("Could not find nokogiri") || errors[0].message.contains("GemNotFound"))
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .ruby)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        let specError = errors.first { $0.file.contains("calculator_spec.rb") }
        XCTAssertNotNil(specError)
    }
    
    // MARK: - Generic Compiler Error Tests (C/C++)
    
    func testGenericCError() throws {
        let errorOutput = """
        main.c:15:5: error: expected ';' before 'return'
            return 0;
            ^~~~~~
        main.c:20:10: warning: unused variable 'x' [-Wunused-variable]
            int x = 5;
                ^
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .gcc)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .gcc)
        
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .unknown)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        
        // Java errors use generic parsing, check for basic extraction
        let errorEntry = errors.first { $0.file.contains("Main.java") }
        XCTAssertNotNil(errorEntry)
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
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .rust)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        
        let error = errors.first { $0.file.contains("main.rs") }
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.line, 15)
        XCTAssertEqual(error?.column, 13)
        XCTAssertTrue(error?.message.contains("cannot find value") ?? false)
    }
    
    func testGenericMakeError() throws {
        let errorOutput = """
        gcc -c -o main.o main.c
        main.c:5:10: error: missing_header.h: No such file or directory
            5 | #include <missing_header.h>
              |          ^~~~~~~~~~~~~~~~~~
        compilation terminated.
        make: *** [Makefile:15: main.o] Error 1
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .gcc)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        XCTAssertTrue(errors[0].message.contains("No such file or directory") || errors[0].message.contains("missing_header"))
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
        
        let parser = ErrorParser()
        // When language is not specified, should try to detect
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: nil)
        
        // Should detect and parse both formats
        XCTAssertGreaterThanOrEqual(errors.count, 1)
    }
    
    func testEmptyOutput() throws {
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: "", language: .python)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testNoErrorsFound() throws {
        let errorOutput = """
        Build successful!
        All tests passed.
        Coverage: 95%
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        XCTAssertEqual(errors.count, 0)
    }
    
    func testMalformedErrorOutput() throws {
        let errorOutput = """
        Some random text without proper format
        File: something
        Line: twenty-five
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        // Should handle gracefully without crashing
        XCTAssertEqual(errors.count, 0)
    }
    
    func testWindowsPathStyle() throws {
        let errorOutput = """
        C:\\Users\\Dev\\Project\\app.py:42: error: something went wrong
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: nil)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        if let error = errors.first {
            XCTAssertTrue(error.file.contains("app.py"))
            XCTAssertEqual(error.line, 42)
        }
    }
    
    func testVeryLongPath() throws {
        let longPath = "/very/long/path/to/the/project/that/has/many/nested/directories/src/components/utils/helpers/file.swift"
        let errorOutput = "\(longPath):100:50: error: some error"
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .swift)
        
        XCTAssertEqual(errors.count, 1)
        XCTAssertEqual(errors[0].file, longPath)
        XCTAssertEqual(errors[0].line, 100)
        XCTAssertEqual(errors[0].column, 50)
    }
    
    func testUnicodeInPathAndMessage() throws {
        let errorOutput = """
        /项目/源码/文件.py:15: error: 发生错误
        """
        
        let parser = ErrorParser()
        let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: .python)
        
        XCTAssertGreaterThanOrEqual(errors.count, 1)
        if let error = errors.first {
            XCTAssertTrue(error.file.contains("文件.py"))
            XCTAssertTrue(error.message.contains("发生错误") || error.message.contains("error"))
        }
    }
    
    func testLineAndColumnExtraction() throws {
        // Test various line/column formats with generic parsing
        let formats = [
            ("file.py:10", 10),
            ("file.py:10:5", 10),
        ]
        
        let parser = ErrorParser()
        for (format, expectedLine) in formats {
            let errorOutput = "\(format): error: test"
            let errors = parser.parseErrorsToParsedErrors(from: errorOutput, language: nil)
            
            if let error = errors.first {
                XCTAssertEqual(error.line, expectedLine, "Failed for format: \(format)")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testLargeOutputPerformance() throws {
        var largeOutput = ""
        for i in 0..<1000 {
            largeOutput += "/path/to/file\(i).swift:\(i*10):\(i): error: Error number \(i)\n"
        }
        
        let parser = ErrorParser()
        measure {
            let errors = parser.parseErrorsToParsedErrors(from: largeOutput, language: .swift)
            XCTAssertEqual(errors.count, 1000)
        }
    }
}
