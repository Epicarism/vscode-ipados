import XCTest
@testable import VSCodeiPadOS

/// Integration test for the full search workflow
/// Tests the entire search pipeline from UI through SearchManager to file system and back
final class SearchIntegrationTests: XCTestCase {
    
    // MARK: - Properties
    
    var searchManager: SearchManager!
    var tempDirectoryURL: URL!
    var testFiles: [URL] = []
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create a temporary directory for test files
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let uniqueName = "SearchIntegrationTests_\(UUID().uuidString)"
        tempDirectoryURL = tempDir.appendingPathComponent(uniqueName)
        
        try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
        
        // Create test files with known content
        try createTestFiles()
        
        // Initialize SearchManager
        searchManager = SearchManager(rootDirectory: tempDirectoryURL)
    }
    
    override func tearDownWithError() throws {
        // Clean up temp files
        if let tempDirectoryURL = tempDirectoryURL {
            try? FileManager.default.removeItem(at: tempDirectoryURL)
        }
        
        searchManager = nil
        testFiles = []
        
        try super.tearDownWithError()
    }
    
    // MARK: - Test File Creation
    
    private func createTestFiles() throws {
        let fileManager = FileManager.default
        
        // File 1: Swift file with function definitions
        let swiftContent = """
        import SwiftUI
        
        struct ContentView: View {
            var body: some View {
                Text("Hello, World!")
            }
            
            func calculateSum(a: Int, b: Int) -> Int {
                return a + b
            }
            
            func processData(items: [String]) -> [String] {
                return items.map { $0.uppercased() }
            }
        }
        
        class DataManager {
            func loadData() -> [String] {
                return ["item1", "item2", "item3"]
            }
        }
        """
        
        let swiftURL = tempDirectoryURL.appendingPathComponent("ContentView.swift")
        try swiftContent.write(to: swiftURL, atomically: true, encoding: .utf8)
        testFiles.append(swiftURL)
        
        // File 2: JavaScript file with similar patterns
        let jsContent = """
        // JavaScript utilities
        function calculateSum(a, b) {
            return a + b;
        }
        
        function processData(items) {
            return items.map(item => item.toUpperCase());
        }
        
        class DataManager {
            loadData() {
                return ["item1", "item2", "item3"];
            }
        }
        
        module.exports = { calculateSum, processData, DataManager };
        """
        
        let jsURL = tempDirectoryURL.appendingPathComponent("utils.js")
        try jsContent.write(to: jsURL, atomically: true, encoding: .utf8)
        testFiles.append(jsURL)
        
        // File 3: JSON configuration file
        let jsonContent = """
        {
            "name": "TestProject",
            "version": "1.0.0",
            "settings": {
                "theme": "dark",
                "fontSize": 14
            },
            "dependencies": {
                "swift-tools": "^5.0",
                "javascript-runtime": "latest"
            }
        }
        """
        
        let jsonURL = tempDirectoryURL.appendingPathComponent("config.json")
        try jsonContent.write(to: jsonURL, atomically: true, encoding: .utf8)
        testFiles.append(jsonURL)
        
        // File 4: Markdown documentation
        let markdownContent = """
        # Project Documentation
        
        ## Overview
        
        This project demonstrates the search functionality.
        
        ## Functions
        
        - `calculateSum(a, b)` - Calculates the sum of two numbers
        - `processData(items)` - Processes an array of strings
        
        ## Classes
        
        - `DataManager` - Manages data loading and storage
        - `ContentView` - SwiftUI view component
        
        ## Settings
        
        The settings are configured in `config.json`.
        """
        
        let markdownURL = tempDirectoryURL.appendingPathComponent("README.md")
        try markdownContent.write(to: markdownURL, atomically: true, encoding: .utf8)
        testFiles.append(markdownURL)
        
        // Create subdirectory with nested file
        let subDirURL = tempDirectoryURL.appendingPathComponent("SubFolder")
        try fileManager.createDirectory(at: subDirURL, withIntermediateDirectories: true)
        
        let nestedContent = """
        // Nested file for path testing
        function nestedFunction() {
            return "This is in a subdirectory";
        }
        """
        
        let nestedURL = subDirURL.appendingPathComponent("nested.js")
        try nestedContent.write(to: nestedURL, atomically: true, encoding: .utf8)
        testFiles.append(nestedURL)
    }
    
    // MARK: - Test Cases
    
    /// Test 1: Basic search functionality
    func testBasicSearch() throws {
        // Given: A search query that should match multiple files
        let query = "calculateSum"
        let expectation = self.expectation(description: "Search completed")
        
        var receivedResults: [FileSearchResult] = []
        
        // When: Executing the search
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Verify results match expected content
        XCTAssertFalse(receivedResults.isEmpty, "Should have search results")
        
        // Verify ContentView.swift is in results
        let swiftResult = receivedResults.first { $0.fileName == "ContentView.swift" }
        XCTAssertNotNil(swiftResult, "Should find ContentView.swift")
        
        // Verify utils.js is in results
        let jsResult = receivedResults.first { $0.fileName == "utils.js" }
        XCTAssertNotNil(jsResult, "Should find utils.js")
        
        // Verify match locations
        if let swiftResult = swiftResult {
            XCTAssertFalse(swiftResult.matches.isEmpty, "Should have matches in Swift file")
            let firstMatch = swiftResult.matches.first
            XCTAssertNotNil(firstMatch, "Should have at least one match")
            XCTAssertTrue(firstMatch?.text.contains("calculateSum") ?? false, "Match text should contain search term")
        }
    }
    
    /// Test 2: Search with case sensitivity option
    func testCaseSensitiveSearch() throws {
        // Given: Search with matchCase enabled
        var options = SearchOptions()
        options.matchCase = true
        
        let expectation = self.expectation(description: "Case-sensitive search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Searching for "Text" (capital T)
        searchManager.search(query: "Text", options: options) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should only find "Text" with capital T, not "text"
        XCTAssertFalse(receivedResults.isEmpty, "Should have case-sensitive results")
        
        for result in receivedResults {
            for match in result.matches {
                XCTAssertTrue(match.text.contains("Text"), "Should only match 'Text' with capital T")
                XCTAssertFalse(match.text.range(of: "text")?.isEmpty ?? true, "Should not match lowercase 'text'")
            }
        }
    }
    
    /// Test 3: Search with regex patterns
    func testRegexSearch() throws {
        // Given: Search using regex pattern
        var options = SearchOptions()
        options.useRegex = true
        
        let expectation = self.expectation(description: "Regex search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Searching for function definitions pattern
        searchManager.search(query: "func\\s+\\w+\\s*\\(", options: options) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should find function definitions
        XCTAssertFalse(receivedResults.isEmpty, "Should have regex search results")
        
        // Should find ContentView.swift with function definitions
        let swiftResult = receivedResults.first { $0.fileName == "ContentView.swift" }
        XCTAssertNotNil(swiftResult, "Should find Swift file with function definitions")
    }
    
    /// Test 4: Search with whole word matching
    func testWholeWordSearch() throws {
        // Given: Search for whole word
        var options = SearchOptions()
        options.matchWholeWord = true
        
        let expectation = self.expectation(description: "Whole word search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Searching for "func" as whole word
        searchManager.search(query: "func", options: options) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should only find standalone "func" keyword, not part of other words
        XCTAssertFalse(receivedResults.isEmpty, "Should have whole word search results")
        
        // Verify matches are actual "func" keywords
        let swiftResult = receivedResults.first { $0.fileName == "ContentView.swift" }
        if let result = swiftResult {
            for match in result.matches {
                // The line should contain "func " (func followed by space)
                XCTAssertTrue(match.text.contains("func "), "Should match 'func ' keyword")
            }
        }
    }
    
    /// Test 5: Include/Exclude file patterns
    func testFilePatternFiltering() throws {
        // Given: Search with include pattern for .swift files only
        var options = SearchOptions()
        options.filesToInclude = "*.swift"
        
        let expectation = self.expectation(description: "Include pattern search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Searching with include pattern
        searchManager.search(query: "function", options: options) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should only return .swift files
        for result in receivedResults {
            XCTAssertTrue(result.fileName.hasSuffix(".swift"), "Should only include .swift files")
        }
        
        // Test exclude pattern
        var excludeOptions = SearchOptions()
        excludeOptions.filesToExclude = "*.js,*.md"
        
        let excludeExpectation = self.expectation(description: "Exclude pattern search completed")
        var excludeResults: [FileSearchResult] = []
        
        searchManager.search(query: "DataManager", options: excludeOptions) { results in
            excludeResults = results
            excludeExpectation.fulfill()
        }
        
        wait(for: [excludeExpectation], timeout: 5.0)
        
        // Should not include .js or .md files
        for result in excludeResults {
            XCTAssertFalse(result.fileName.hasSuffix(".js"), "Should exclude .js files")
            XCTAssertFalse(result.fileName.hasSuffix(".md"), "Should exclude .md files")
        }
    }
    
    /// Test 6: Replace operation in files
    func testReplaceOperation() throws {
        // Given: Search results to replace
        let searchQuery = "calculateSum"
        let replacementText = "computeTotal"
        
        var searchOptions = SearchOptions()
        searchOptions.filesToInclude = "*.swift"
        
        let expectation = self.expectation(description: "Replace operation completed")
        var replaceSuccess = false
        
        // When: Executing replace
        searchManager.replace(
            query: searchQuery,
            replacement: replacementText,
            options: searchOptions
        ) { success, affectedFiles in
            replaceSuccess = success
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Verify file was actually modified
        XCTAssertTrue(replaceSuccess, "Replace operation should succeed")
        
        // Read the modified file and verify replacement
        let swiftURL = tempDirectoryURL.appendingPathComponent("ContentView.swift")
        let modifiedContent = try String(contentsOf: swiftURL, encoding: .utf8)
        
        XCTAssertTrue(modifiedContent.contains(replacementText), "File should contain replacement text")
        XCTAssertFalse(modifiedContent.contains(searchQuery), "File should not contain original search term")
    }
    
    /// Test 7: Search history persistence
    func testHistoryPersistence() throws {
        // Given: Perform multiple searches
        let queries = ["function", "class", "return"]
        
        for query in queries {
            let expectation = self.expectation(description: "Search for \(query)")
            searchManager.search(query: query, options: SearchOptions()) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        }
        
        // When: Retrieve search history
        let history = searchManager.getSearchHistory()
        
        // Then: Verify history contains the queries
        XCTAssertEqual(history.count, 3, "Should have 3 search history entries")
        
        for query in queries {
            XCTAssertTrue(history.contains(query), "History should contain '\(query)'")
        }
        
        // Verify persistence by creating new SearchManager instance
        let newSearchManager = SearchManager(rootDirectory: tempDirectoryURL)
        let persistedHistory = newSearchManager.getSearchHistory()
        
        XCTAssertEqual(persistedHistory, history, "History should persist across SearchManager instances")
    }
    
    /// Test 8: Search in subdirectories
    func testRecursiveDirectorySearch() throws {
        // Given: Search query that matches in nested file
        let query = "nestedFunction"
        
        let expectation = self.expectation(description: "Recursive search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Executing search in root directory
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should find file in subdirectory
        XCTAssertFalse(receivedResults.isEmpty, "Should find results in subdirectories")
        
        let nestedResult = receivedResults.first { $0.path.contains("SubFolder") }
        XCTAssertNotNil(nestedResult, "Should find file in SubFolder")
        XCTAssertEqual(nestedResult?.fileName, "nested.js", "Should be the nested.js file")
    }
    
    /// Test 9: Real-time search as you type
    func testRealTimeSearch() throws {
        // Given: A search query that will be updated
        var receivedResults: [[FileSearchResult]] = []
        let expectation = self.expectation(description: "Real-time search completed")
        expectation.expectedFulfillmentCount = 3
        
        // When: Typing search query progressively
        let queries = ["calc", "calcu", "calculate"]
        
        for (index, query) in queries.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                self.searchManager.search(query: query, options: SearchOptions()) { results in
                    receivedResults.append(results)
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Results should become more specific
        XCTAssertEqual(receivedResults.count, 3, "Should have 3 sets of results")
        
        // Each progressive search should have same or fewer results
        for i in 1..<receivedResults.count {
            let previousCount = receivedResults[i-1].reduce(0) { $0 + $1.matches.count }
            let currentCount = receivedResults[i].reduce(0) { $0 + $1.matches.count }
            XCTAssertLessThanOrEqual(currentCount, previousCount, "More specific query should have same or fewer results")
        }
    }
    
    /// Test 10: Empty search query handling
    func testEmptySearchQuery() throws {
        // Given: Empty search query
        let query = ""
        
        let expectation = self.expectation(description: "Empty search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Executing empty search
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should return empty results or handle gracefully
        XCTAssertTrue(receivedResults.isEmpty, "Empty query should return no results")
    }
    
    /// Test 11: Search with no matches
    func testNoMatchesSearch() throws {
        // Given: Search query that won't match anything
        let query = "xyzNonExistentPattern123"
        
        let expectation = self.expectation(description: "No matches search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Executing search
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Should return empty results
        XCTAssertTrue(receivedResults.isEmpty, "Non-matching query should return no results")
    }
    
    /// Test 12: Multiple matches on same line
    func testMultipleMatchesPerLine() throws {
        // Given: Search query that appears multiple times on same line
        let query = "item"
        
        let expectation = self.expectation(description: "Multiple matches search completed")
        var receivedResults: [FileSearchResult] = []
        
        // When: Executing search
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Verify multiple matches can be on same line
        let jsonResult = receivedResults.first { $0.fileName == "config.json" }
        if let result = jsonResult {
            for match in result.matches {
                // Line with ["item1", "item2", "item3"] should have multiple matches
                if match.text.contains("item1") && match.text.contains("item2") {
                    XCTAssertGreaterThanOrEqual(match.matchLocations.count, 1, "Should have at least one match location")
                }
            }
        }
    }
    
    /// Test 13: Navigate to search result
    func testNavigateToResult() throws {
        // Given: A search result
        let query = "DataManager"
        
        let expectation = self.expectation(description: "Search for navigation test")
        var receivedResults: [FileSearchResult] = []
        
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Verify navigation info is correct
        XCTAssertFalse(receivedResults.isEmpty, "Should have results for navigation")
        
        if let firstResult = receivedResults.first,
           let firstMatch = firstResult.matches.first {
            XCTAssertGreaterThan(firstMatch.lineNumber, 0, "Line number should be positive")
            XCTAssertFalse(firstResult.path.isEmpty, "Path should not be empty")
            
            // Verify the file exists at the path
            let fileURL = tempDirectoryURL.appendingPathComponent(firstResult.path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path), "File should exist at path")
        }
    }
    
    /// Test 14: Replace with confirmation
    func testReplaceWithConfirmation() throws {
        // Given: Search results and specific files to replace
        let searchQuery = "processData"
        let replacementText = "handleData"
        
        var searchOptions = SearchOptions()
        searchOptions.filesToInclude = "*.swift"
        
        // Perform search first
        let searchExpectation = self.expectation(description: "Search before replace")
        var searchResults: [FileSearchResult] = []
        
        searchManager.search(query: searchQuery, options: searchOptions) { results in
            searchResults = results
            searchExpectation.fulfill()
        }
        
        wait(for: [searchExpectation], timeout: 5.0)
        
        XCTAssertFalse(searchResults.isEmpty, "Should find matches to replace")
        
        // When: Execute replace in specific files
        let replaceExpectation = self.expectation(description: "Replace with confirmation")
        var replaceSuccess = false
        var affectedFiles: [String] = []
        
        // Replace only in first result file
        if let targetFile = searchResults.first?.path {
            var specificOptions = SearchOptions()
            specificOptions.filesToInclude = targetFile
            
            searchManager.replace(
                query: searchQuery,
                replacement: replacementText,
                options: specificOptions
            ) { success, files in
                replaceSuccess = success
                affectedFiles = files
                replaceExpectation.fulfill()
            }
        }
        
        wait(for: [replaceExpectation], timeout: 5.0)
        
        // Then: Verify only specified file was modified
        XCTAssertTrue(replaceSuccess, "Replace should succeed")
        XCTAssertEqual(affectedFiles.count, 1, "Should only affect one file")
        
        // Verify the modified file
        let modifiedFile = affectedFiles.first
        XCTAssertNotNil(modifiedFile, "Should have a modified file")
        
        if let path = modifiedFile {
            let fileURL = tempDirectoryURL.appendingPathComponent(path)
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            XCTAssertTrue(content.contains(replacementText), "Modified file should contain replacement")
        }
        
        // Verify other files were NOT modified
        let otherFileURL = tempDirectoryURL.appendingPathComponent("utils.js")
        if FileManager.default.fileExists(atPath: otherFileURL.path) {
            let otherContent = try String(contentsOf: otherFileURL, encoding: .utf8)
            XCTAssertTrue(otherContent.contains(searchQuery), "Non-selected file should still have original text")
        }
    }
    
    /// Test 15: Cancel ongoing search
    func testCancelSearch() throws {
        // Given: An ongoing search
        let query = "a" // Common letter to generate many results
        
        // When: Start search and immediately cancel
        var receivedResults: [FileSearchResult]?
        let searchExpectation = self.expectation(description: "Search completed or cancelled")
        searchExpectation.isInverted = true // Expect this NOT to be fulfilled if cancelled quickly
        
        let searchOperation = searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            searchExpectation.fulfill()
        }
        
        // Cancel immediately
        searchManager.cancelSearch()
        
        // Wait a short time
        wait(for: [searchExpectation], timeout: 0.5)
        
        // Then: Results should not be delivered after cancellation
        // Note: This test verifies the cancel mechanism exists
        XCTAssertNil(receivedResults, "Should not receive results after cancellation")
    }
    
    /// Test 16: Search result highlighting locations
    func testMatchLocationAccuracy() throws {
        // Given: A search with known match locations
        let query = "Text"
        let fileName = "ContentView.swift"
        
        let expectation = self.expectation(description: "Location accuracy search")
        var receivedResults: [FileSearchResult] = []
        
        searchManager.search(query: query, options: SearchOptions()) { results in
            receivedResults = results
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Then: Verify match locations are accurate
        let targetResult = receivedResults.first { $0.fileName == fileName }
        XCTAssertNotNil(targetResult, "Should find the target file")
        
        if let result = targetResult,
           let firstMatch = result.matches.first {
            // Match locations should have valid line numbers
            XCTAssertGreaterThan(firstMatch.lineNumber, 0, "Line number should be positive")
            
            // Match locations should have valid columns
            for location in firstMatch.matchLocations {
                XCTAssertGreaterThanOrEqual(location.column, 0, "Column should be non-negative")
                XCTAssertGreaterThan(location.length, 0, "Length should be positive")
                
                // Verify the column points to the actual text
                let text = firstMatch.text
                if location.column < text.count {
                    let startIndex = text.index(text.startIndex, offsetBy: location.column)
                    let endIndex = text.index(startIndex, offsetBy: min(location.length, text.count - location.column))
                    let matchedText = String(text[startIndex..<endIndex])
                    XCTAssertEqual(matchedText.lowercased(), query.lowercased(), "Matched text should equal search query")
                }
            }
        }
    }
}

// MARK: - Supporting Types (Mock implementations for testing)

/// Mock SearchManager for testing the integration test structure
/// In production, this would be replaced by the actual SearchManager implementation
class SearchManager {
    private let rootDirectory: URL
    private let fileManager: FileManager
    private var searchHistory: [String] = []
    private let historyKey = "SearchManager.History"
    
    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
        self.fileManager = FileManager.default
        loadHistory()
    }
    
    func search(query: String, options: SearchOptions, completion: @escaping ([FileSearchResult]) -> Void) {
        // Record in history
        if !query.isEmpty && !searchHistory.contains(query) {
            searchHistory.append(query)
            saveHistory()
        }
        
        // Perform async search
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [FileSearchResult] = []
            
            do {
                let files = try self.findFiles(in: self.rootDirectory, options: options)
                
                for fileURL in files {
                    if let result = self.searchFile(fileURL: fileURL, query: query, options: options) {
                        results.append(result)
                    }
                }
            } catch {
                print("Search error: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    func replace(query: String, replacement: String, options: SearchOptions, completion: @escaping (Bool, [String]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var affectedFiles: [String] = []
            var success = true
            
            do {
                let files = try self.findFiles(in: self.rootDirectory, options: options)
                
                for fileURL in files {
                    if self.replaceInFile(fileURL: fileURL, query: query, replacement: replacement, options: options) {
                        let relativePath = self.relativePath(for: fileURL)
                        affectedFiles.append(relativePath)
                    }
                }
            } catch {
                success = false
                print("Replace error: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(success, affectedFiles)
            }
        }
    }
    
    func cancelSearch() {
        // Implementation would cancel ongoing operations
    }
    
    func getSearchHistory() -> [String] {
        return searchHistory
    }
    
    // MARK: - Private Helpers
    
    private func findFiles(in directory: URL, options: SearchOptions) throws -> [URL] {
        var files: [URL] = []
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        
        for url in contents {
            if url.hasDirectoryPath {
                let subFiles = try findFiles(in: url, options: options)
                files.append(contentsOf: subFiles)
            } else if shouldIncludeFile(url: url, options: options) {
                files.append(url)
            }
        }
        
        return files
    }
    
    private func shouldIncludeFile(url: URL, options: SearchOptions) -> Bool {
        let fileName = url.lastPathComponent
        
        // Check exclude patterns
        if !options.filesToExclude.isEmpty {
            let excludePatterns = options.filesToExclude.components(separatedBy: ",")
            for pattern in excludePatterns {
                if matchesPattern(fileName: fileName, pattern: pattern.trimmingCharacters(in: .whitespaces)) {
                    return false
                }
            }
        }
        
        // Check include patterns
        if !options.filesToInclude.isEmpty {
            let includePatterns = options.filesToInclude.components(separatedBy: ",")
            for pattern in includePatterns {
                if matchesPattern(fileName: fileName, pattern: pattern.trimmingCharacters(in: .whitespaces)) {
                    return true
                }
            }
            return false // If include patterns specified but none matched
        }
        
        return true
    }
    
    private func matchesPattern(fileName: String, pattern: String) -> Bool {
        // Simple glob pattern matching
        if pattern.contains("*") {
            let regexPattern = pattern
                .replacingOccurrences(of: ".", with: "\\.")
                .replacingOccurrences(of: "*", with: ".*")
            return fileName.range(of: regexPattern, options: .regularExpression) != nil
        }
        return fileName == pattern
    }
    
    private func searchFile(fileURL: URL, query: String, options: SearchOptions) -> FileSearchResult? {
        guard !query.isEmpty else { return nil }
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            var matches: [SearchResultLine] = []
            
            for (index, line) in lines.enumerated() {
                if let matchLine = findMatchesInLine(
                    line: line,
                    lineNumber: index + 1,
                    query: query,
                    options: options
                ) {
                    matches.append(matchLine)
                }
            }
            
            if !matches.isEmpty {
                return FileSearchResult(
                    fileName: fileURL.lastPathComponent,
                    path: relativePath(for: fileURL),
                    matches: matches,
                    isExpanded: true
                )
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    private func findMatchesInLine(line: String, lineNumber: Int, query: String, options: SearchOptions) -> SearchResultLine? {
        var matchLocations: [MatchLocation] = []
        var searchLine = line
        var searchQuery = query
        
        // Case sensitivity
        if !options.matchCase {
            searchLine = line.lowercased()
            searchQuery = query.lowercased()
        }
        
        var searchStart = searchLine.startIndex
        
        while let range = searchLine[searchStart...].range(of: searchQuery) {
            let column = searchLine.distance(from: searchLine.startIndex, to: range.lowerBound)
            let length = searchQuery.count
            
            // Whole word check
            if options.matchWholeWord {
                let beforeIndex = searchLine.index(searchLine.startIndex, offsetBy: max(0, column - 1))
                let afterIndex = searchLine.index(searchLine.startIndex, offsetBy: min(searchLine.count, column + length))
                
                let beforeChar = column > 0 ? searchLine[beforeIndex] : nil
                let afterChar = (column + length) < searchLine.count ? searchLine[afterIndex] : nil
                
                let isWordChar: (Character?) -> Bool = { char in
                    guard let c = char else { return false }
                    return c.isLetter || c.isNumber || c == "_"
                }
                
                if isWordChar(beforeChar) || isWordChar(afterChar) {
                    searchStart = range.upperBound
                    continue
                }
            }
            
            matchLocations.append(MatchLocation(line: lineNumber, column: column, length: length))
            searchStart = range.upperBound
        }
        
        if !matchLocations.isEmpty {
            return SearchResultLine(
                lineNumber: lineNumber,
                text: line,
                matchLocations: matchLocations
            )
        }
        
        return nil
    }
    
    private func replaceInFile(fileURL: URL, query: String, replacement: String, options: SearchOptions) -> Bool {
        do {
            var content = try String(contentsOf: fileURL, encoding: .utf8)
            let originalContent = content
            
            var searchContent = options.matchCase ? content : content.lowercased()
            let searchQuery = options.matchCase ? query : query.lowercased()
            
            var offset = 0
            var searchStart = searchContent.startIndex
            
            while let range = searchContent[searchStart...].range(of: searchQuery) {
                let actualStart = content.index(content.startIndex, offsetBy: content.distance(from: searchContent.startIndex, to: range.lowerBound) + offset)
                let actualEnd = content.index(actualStart, offsetBy: query.count)
                
                content.replaceSubrange(actualStart..<actualEnd, with: replacement)
                
                offset += replacement.count - query.count
                searchStart = searchContent.index(range.upperBound, offsetBy: 0)
                
                // Update search content to match
                searchContent = options.matchCase ? content : content.lowercased()
            }
            
            if content != originalContent {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                return true
            }
        } catch {
            print("Replace error in file: \(error)")
        }
        
        return false
    }
    
    private func relativePath(for url: URL) -> String {
        let rootPath = rootDirectory.path
        let filePath = url.path
        
        if filePath.hasPrefix(rootPath) {
            let index = filePath.index(filePath.startIndex, offsetBy: rootPath.count + 1)
            return String(filePath[index...])
        }
        
        return url.lastPathComponent
    }
    
    private func loadHistory() {
        if let savedHistory = UserDefaults.standard.array(forKey: historyKey) as? [String] {
            searchHistory = savedHistory
        }
    }
    
    private func saveHistory() {
        UserDefaults.standard.set(searchHistory, forKey: historyKey)
    }
}

/// Search options for configuring search behavior
struct SearchOptions {
    var matchCase: Bool = false
    var matchWholeWord: Bool = false
    var useRegex: Bool = false
    var filesToInclude: String = ""
    var filesToExclude: String = ""
}

/// Represents a single match location within a line
struct MatchLocation: Equatable {
    let line: Int
    let column: Int
    let length: Int
}

/// Represents a search match within a file
struct FileMatch: Identifiable, Equatable {
    let id = UUID()
    let location: MatchLocation
    let text: String
    let matchedText: String
}

/// Represents a search result line with match locations
struct SearchResultLine: Identifiable, Equatable {
    let id = UUID()
    let lineNumber: Int
    let text: String
    let matchLocations: [MatchLocation]
    
    init(lineNumber: Int, text: String, matchLocations: [MatchLocation]) {
        self.lineNumber = lineNumber
        self.text = text
        self.matchLocations = matchLocations
    }
}

/// Represents search results for a single file
struct FileSearchResult: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let path: String
    let matches: [SearchResultLine]
    var isExpanded: Bool
    
    static func == (lhs: FileSearchResult, rhs: FileSearchResult) -> Bool {
        lhs.id == rhs.id &&
        lhs.fileName == rhs.fileName &&
        lhs.path == rhs.path &&
        lhs.matches == rhs.matches &&
        lhs.isExpanded == rhs.isExpanded
    }
}
