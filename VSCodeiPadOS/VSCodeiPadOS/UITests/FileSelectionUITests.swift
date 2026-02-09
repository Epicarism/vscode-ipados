import XCTest

// MARK: - File Selection UI Tests
/// Tests file selection behavior in the file tree and editor integration
/// Verifies that clicking files opens them in the editor and creates tabs
class FileSelectionUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to fully load
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test Helpers
    
    /// Finds the file tree view in the sidebar
    private var fileTreeView: XCUIElement {
        // File tree is in a scroll view with file rows
        return app.scrollViews.firstMatch
    }
    
    /// Finds a file row by name in the file tree
    /// - Parameter name: The display name of the file
    /// - Returns: The file row element
    private func fileRow(named name: String) -> XCUIElement {
        // File rows contain text with the file name and a doc icon
        return app.staticTexts[name].firstMatch
    }
    
    /// Finds the editor area
    private var editorArea: XCUIElement {
        return app.otherElements["EditorArea"].firstMatch
    }
    
    /// Finds the tab bar
    private var tabBar: XCUIElement {
        return app.otherElements["TabBar"].firstMatch
    }
    
    /// Finds a tab by file name
    /// - Parameter name: The file name shown in the tab
    /// - Returns: The tab element
    private func tab(named name: String) -> XCUIElement {
        return app.buttons[name].firstMatch
    }
    
    /// Expands a directory in the file tree to show its children
    /// - Parameter directoryName: The name of the directory to expand
    private func expandDirectory(named directoryName: String) {
        let directoryRow = app.buttons.matching(identifier: "Expand\(directoryName)").firstMatch
        if directoryRow.exists && directoryRow.isHittable {
            directoryRow.tap()
        }
    }
    
    // MARK: - Tests
    
    /// Tests that clicking a file in the file tree opens it in the editor
    /// Reference: FileTreeView.swift line 86-93 - onTapGesture calls editorCore.openFile(from:)
    func testFileClickOpensEditor() throws {
        // Given: App is launched with file tree visible
        let fileTree = fileTreeView
        XCTAssertTrue(fileTree.waitForExistence(timeout: 3), "File tree should be visible")
        
        // When: User taps on a file (not directory) in the tree
        // Look for a file with a doc icon (not folder)
        let fileElement = app.images["doc"].firstMatch
        XCTAssertTrue(fileElement.waitForExistence(timeout: 2), "A file should exist in the tree")
        
        // Get the parent row containing the file icon
        let fileRow = fileElement.parentElement()
        XCTAssertTrue(fileRow.exists, "File row should exist")
        
        // Tap on the file row
        fileRow.tap()
        
        // Then: Editor area should become active with content
        let editor = editorArea
        XCTAssertTrue(editor.waitForExistence(timeout: 2), "Editor area should appear after file selection")
        
        // Verify editor shows content placeholder or actual content
        let editorContent = app.textViews.firstMatch
        XCTAssertTrue(editorContent.exists || app.otherElements["EditorContent"].exists, 
                      "Editor should show content area")
    }
    
    /// Tests that clicking a file creates a new tab in the tab bar
    /// Reference: EditorCore.openFile(from:) should create a new tab
    func testFileCreatesTab() throws {
        // Given: Initial state with no tabs or single welcome tab
        let initialTabCount = app.buttons.count
        
        // When: User clicks on a file in the tree
        let fileTree = fileTreeView
        XCTAssertTrue(fileTree.waitForExistence(timeout: 3))
        
        // Find and tap a file
        let fileIcon = app.images["doc"].firstMatch
        XCTAssertTrue(fileIcon.waitForExistence(timeout: 2))
        
        let fileRow = fileIcon.parentElement()
        fileRow.tap()
        
        // Then: A new tab should be created
        let tabBar = self.tabBar
        XCTAssertTrue(tabBar.waitForExistence(timeout: 2), "Tab bar should exist")
        
        // Verify at least one tab exists with file content
        let tabs = app.buttons.allElementsBoundByIndex.filter { button in
            // Tabs typically have close buttons or specific identifiers
            button.identifier.contains("Tab") || 
            button.label.contains(".") // File extension indicator
        }
        
        XCTAssertGreaterThan(tabs.count, 0, "At least one tab should exist after opening a file")
        
        // Verify the tab shows file name
        let hasFileTab = app.buttons.allElementsBoundByIndex.contains { button in
            // Check if any button represents an open file
            let label = button.label.lowercased()
            return label.hasSuffix(".swift") || 
                   label.hasSuffix(".js") || 
                   label.hasSuffix(".ts") ||
                   label.hasSuffix(".json") ||
                   label.hasSuffix(".md")
        }
        XCTAssertTrue(hasFileTab, "A tab with a file name should exist")
    }
    
    /// Tests selecting multiple files creates multiple tabs
    /// Verifies that each file click opens a separate tab
    func testMultipleFileSelection() throws {
        // Given: File tree with multiple files
        let fileTree = fileTreeView
        XCTAssertTrue(fileTree.waitForExistence(timeout: 3))
        
        // Find all file icons (doc images) in the tree
        let fileIcons = app.images.matching(identifier: "doc")
        XCTAssertGreaterThanOrEqual(fileIcons.count, 2, "Should have at least 2 files to test")
        
        // When: Click first file
        let firstFile = fileIcons.element(boundBy: 0)
        XCTAssertTrue(firstFile.exists)
        let firstRow = firstFile.parentElement()
        firstRow.tap()
        
        // Wait for first tab to appear
        sleep(1)
        
        // Then: First tab should exist
        let tabCountAfterFirst = countFileTabs()
        XCTAssertGreaterThanOrEqual(tabCountAfterFirst, 1, "Should have at least 1 tab after first click")
        
        // When: Click second file
        let secondFile = fileIcons.element(boundBy: 1)
        XCTAssertTrue(secondFile.exists)
        let secondRow = secondFile.parentElement()
        secondRow.tap()
        
        // Wait for second tab
        sleep(1)
        
        // Then: Should have 2 tabs now
        let tabCountAfterSecond = countFileTabs()
        XCTAssertEqual(tabCountAfterSecond, 2, "Should have 2 tabs after opening 2 files")
        
        // Verify both tabs are still accessible
        let tabs = getAllFileTabs()
        XCTAssertEqual(tabs.count, 2, "Should be able to access both tabs")
        
        // Verify switching between tabs works
        if tabs.count >= 2 {
            tabs[0].tap()
            sleep(0.5)
            tabs[1].tap()
            sleep(0.5)
            // If we can tap both without crash, switching works
        }
    }
    
    // MARK: - Private Helpers
    
    /// Counts the number of file tabs currently open
    private func countFileTabs() -> Int {
        // Tabs are buttons with file-like identifiers or containing file extensions
        let tabBar = self.tabBar
        guard tabBar.exists else { return 0 }
        
        // Count buttons that look like tabs (have file extension patterns)
        return app.buttons.allElementsBoundByIndex.filter { button in
            let label = button.label.lowercased()
            return label.contains(".") && !label.isEmpty
        }.count
    }
    
    /// Gets all file tab elements
    private func getAllFileTabs() -> [XCUIElement] {
        return app.buttons.allElementsBoundByIndex.filter { button in
            let label = button.label.lowercased()
            return label.contains(".") && !label.isEmpty
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Returns the parent element of this element
    func parentElement() -> XCUIElement {
        // Navigate up to parent using query
        return self.parents(matching: .any).firstMatch
    }
    
    /// Checks if element has a specific descendant
    func hasDescendant(matching type: XCUIElement.ElementType, identifier: String) -> Bool {
        return self.descendants(matching: type).matching(identifier: identifier).firstMatch.exists
    }
}
