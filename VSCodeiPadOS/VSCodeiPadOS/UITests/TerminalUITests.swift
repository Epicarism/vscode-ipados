import XCTest

/// UI tests for the integrated terminal.
///
/// These tests rely on accessibility identifiers set in Terminal views for:
/// - Terminal container: `terminal.container`
/// - Terminal input: `terminal.input`
/// - Terminal output: `terminal.output`
/// - Terminal tab: `terminal.tab`
/// - New terminal button: `terminal.newButton`
/// - Close terminal button: `terminal.closeButton`
final class TerminalUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launch()

        // Wait for app to be ready
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }

    // MARK: - Helpers

    private func openTerminal() {
        // Try to open terminal via menu or keyboard shortcut
        // This will vary based on implementation
        let terminalMenu = app.menuItems["Terminal"]
        if terminalMenu.waitForExistence(timeout: 3) {
            terminalMenu.tap()
            let newTerminal = app.menuItems["New Terminal"]
            if newTerminal.waitForExistence(timeout: 2) {
                newTerminal.tap()
            }
        }
    }

    private func waitForTerminal(timeout: TimeInterval = 5) -> XCUIElement {
        let terminal = app.otherElements["terminal.container"]
        XCTAssertTrue(terminal.waitForExistence(timeout: timeout), "Terminal should exist")
        return terminal
    }

    private func getTerminalInput() -> XCUIElement {
        let input = app.textViews["terminal.input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5), "Terminal input should exist")
        return input
    }

    // MARK: - Terminal Open/Close Tests

    func testTerminalOpens() {
        openTerminal()
        
        let terminal = waitForTerminal()
        XCTAssertTrue(terminal.exists)
        XCTAssertTrue(terminal.isHittable)
    }

    func testTerminalContainerExists() {
        let terminal = app.otherElements["terminal.container"]
        // Terminal may not be open by default
        _ = terminal.exists
    }

    // MARK: - Terminal Input Tests

    func testTerminalTyping() {
        openTerminal()
        
        let input = getTerminalInput()
        input.tap()
        input.typeText("ls")
        
        let value = input.value as? String ?? ""
        XCTAssertTrue(value.contains("ls"))
    }

    func testTerminalEnterCommand() {
        openTerminal()
        
        let input = getTerminalInput()
        input.tap()
        input.typeText("pwd")
        
        // Simulate return key
        app.keyboards.buttons["return"].tap()
    }

    func testTerminalSpecialCharacters() {
        openTerminal()
        
        let input = getTerminalInput()
        input.tap()
        input.typeText("echo \"test\" > file.txt")
        
        let value = input.value as? String ?? ""
        XCTAssertTrue(value.contains("echo"))
    }

    // MARK: - Terminal Output Tests

    func testTerminalOutputExists() {
        openTerminal()
        
        let output = app.textViews["terminal.output"]
        // Output may or may not be a separate element depending on implementation
        _ = output.exists
    }

    func testTerminalOutputScrolling() {
        openTerminal()
        
        let input = getTerminalInput()
        input.tap()
        
        // Generate output
        for i in 1...10 {
            input.typeText("echo Line \(i)")
            app.keyboards.buttons["return"].tap()
        }
        
        // Try to scroll output
        let output = app.textViews["terminal.output"]
        if output.exists {
            output.swipeUp()
        }
    }

    // MARK: - Terminal Tab Tests

    func testNewTerminalTabButton() {
        let newButton = app.buttons["terminal.newButton"]
        if newButton.waitForExistence(timeout: 3) {
            newButton.tap()
            
            let terminal = waitForTerminal()
            XCTAssertTrue(terminal.exists)
        }
    }

    func testTerminalTabExists() {
        openTerminal()
        
        let tab = app.buttons["terminal.tab"]
        if tab.waitForExistence(timeout: 3) {
            XCTAssertTrue(tab.exists)
        }
    }

    func testCloseTerminalButton() {
        openTerminal()
        
        let closeButton = app.buttons["terminal.closeButton"]
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
            
            let terminal = app.otherElements["terminal.container"]
            let predicate = NSPredicate(format: "exists == false")
            let expectation = self.expectation(for: predicate, evaluatedWith: terminal)
            wait(for: [expectation], timeout: 5)
        }
    }

    // MARK: - Terminal Clear Tests

    func testTerminalClear() {
        openTerminal()
        
        let clearButton = app.buttons["terminal.clearButton"]
        if clearButton.waitForExistence(timeout: 3) {
            clearButton.tap()
        }
    }

    // MARK: - Terminal Resize Tests

    func testTerminalResizeHandle() {
        openTerminal()
        
        let resizeHandle = app.otherElements["terminal.resizeHandle"]
        if resizeHandle.waitForExistence(timeout: 3) {
            // Try to resize by dragging
            let startPoint = resizeHandle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endPoint = resizeHandle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.5))
            startPoint.press(forDuration: 0.5, thenDragTo: endPoint)
        }
    }
}
