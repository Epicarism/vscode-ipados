import XCTest
@testable import VSCodeiPadOS

/// Unit tests for ErrorParser
/// Tests parsing of various error formats from different programming languages
@MainActor
final class ErrorParserTests: XCTestCase {
    
    var parser: ErrorParser!
    
    override func setUp() {
        super.setUp()
        parser = ErrorParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Python Traceback Tests
    
    func testPythonSimpleTraceback() throws {
        let errorOutput = """
        Traceback (most recent call last):
          File "app.py\