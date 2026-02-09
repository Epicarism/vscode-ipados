import XCTest

class CommandPaletteUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to fully load
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.windows.firstMatch
        )
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "App failed to launch")
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Test Cases
    
    /// Test: Cmd+Shift+P opens the command palette
    func testOpenWithKeyboard() throws {
        // Send Cmd+Shift+P keyboard shortcut to open command palette
        app.keys["command"].press(forDuration: 0.1, thenTap: app.keys["shift"])
        app.keys["p"].tap()
        
        // Alternative approach: use key press combination
        // Use menu or keyboard shortcut simulation
        let commandPaletteNavBar = app.navigationBars["Command Palette"]
        
        // Wait for command palette to appear
        XCTAssertTrue(commandPaletteNavBar.waitForExistence(timeout: 2.0), 
                      "Command Palette should appear after Cmd+Shift+P")
        
        // Verify the search field exists
        let searchField = app.searchFields["Search commands..."]
        XCTAssertTrue(searchField.exists, "Search field should be present in Command Palette")
        
        // Clean up: close the palette
        closeCommandPalette()
    }
    
    /// Test: Search filters commands correctly
    func testSearchFiltering() throws {
        // Open command palette first
        openCommandPalette()
        
        let searchField = app.searchFields["Search commands..."]
        XCTAssertTrue(searchField.exists, "Search field should exist")
        
        // Tap search field and enter search term
        searchField.tap()
        searchField.typeText("collapse")
        
        // Wait for filtering to apply
        sleep(1)
        
        // Verify "Collapse All" command is visible
        let collapseAllButton = app.buttons["Collapse All"]
        XCTAssertTrue(collapseAllButton.exists, "'Collapse All' command should appear when searching 'collapse'")
        
        // Verify other commands are filtered out (e.g., "Zoom In" should not be visible)
        let zoomInButton = app.buttons["Zoom In"]
        XCTAssertFalse(zoomInButton.exists, "'Zoom In' should be filtered out when searching 'collapse'")
        
        // Clear search and verify all commands return
        searchField.tap()
        searchField.clearAndEnterText(text: "")
        sleep(1)
        
        // After clearing, multiple categories should be visible
        let editorSection = app.staticTexts["Editor"]
        let viewSection = app.staticTexts["View"]
        XCTAssertTrue(editorSection.exists, "Editor section should reappear after clearing search")
        
        closeCommandPalette()
    }
    
    /// Test: Selecting a command executes its action
    func testCommandExecution() throws {
        // Open command palette
        openCommandPalette()
        
        // Search for a specific command
        let searchField = app.searchFields["Search commands..."]
        searchField.tap()
        searchField.typeText("toggle sidebar")
        
        sleep(1)
        
        // Find and tap the "Toggle Sidebar" command
        let toggleSidebarButton = app.buttons["Toggle Sidebar"]
        XCTAssertTrue(toggleSidebarButton.waitForExistence(timeout: 2.0), 
                      "Toggle Sidebar command should be found")
        
        // Tap the command to execute it
        toggleSidebarButton.tap()
        
        // Verify command palette is dismissed after execution
        let commandPaletteNavBar = app.navigationBars["Command Palette"]
        XCTAssertFalse(commandPaletteNavBar.waitForExistence(timeout: 2.0),
                       "Command Palette should dismiss after command execution")
    }
    
    /// Test: Escape key closes the command palette
    func testCloseOnEscape() throws {
        // Open command palette
        openCommandPalette()
        
        let commandPaletteNavBar = app.navigationBars["Command Palette"]
        XCTAssertTrue(commandPaletteNavBar.exists, "Command Palette should be open")
        
        // Press Escape key to close
        app.keys["escape"].tap()
        
        // Verify palette is closed
        XCTAssertFalse(commandPaletteNavBar.waitForExistence(timeout: 2.0),
                       "Command Palette should close on Escape key")
    }
    
    // MARK: - Helper Methods
    
    private func openCommandPalette() {
        // Try to open via keyboard shortcut
        // Note: On iPad with keyboard, Cmd+Shift+P should trigger
        
        // Alternative: Use accessibility to find a trigger if available
        // For testing, we can also use the app's menu or button if exposed
        
        // Simulate keyboard shortcut
        let keyP = app.keys["p"]
        let keyShift = app.keys["shift"]
        let keyCommand = app.keys["command"]
        
        // Press Cmd+Shift+P
        keyCommand.press(forDuration: 0.1, thenTap: keyShift)
        keyP.tap()
        
        // Wait for palette to appear
        let commandPaletteNavBar = app.navigationBars["Command Palette"]
        let appeared = commandPaletteNavBar.waitForExistence(timeout: 3.0)
        
        // If keyboard shortcut didn't work, try alternative method
        if !appeared {
            // Look for a command palette button in the UI if available
            let paletteButton = app.buttons["Command Palette"]
            if paletteButton.exists {
                paletteButton.tap()
            }
        }
        
        XCTAssertTrue(commandPaletteNavBar.waitForExistence(timeout: 2.0),
                      "Failed to open Command Palette")
    }
    
    private func closeCommandPalette() {
        // Try Escape key first
        app.keys["escape"].tap()
        
        let commandPaletteNavBar = app.navigationBars["Command Palette"]
        
        // If still exists, try Close button
        if commandPaletteNavBar.exists {
            let closeButton = app.buttons["Close"]
            if closeButton.exists {
                closeButton.tap()
            }
        }
        
        // Wait for dismissal
        _ = commandPaletteNavBar.waitForNonExistence(timeout: 2.0)
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Failed to get string value from element")
            return
        }
        
        // Clear existing text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        
        // Enter new text
        self.typeText(text)
    }
    
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
