import XCTest

final class QuickOpenUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        // Enables deterministic Quick Open content via ProcessInfo argument handling in QuickOpenView.
        app.launchArguments += ["-uiTesting"]
        app.launch()
    }

    // MARK: - Helpers

    @discardableResult
    private func openQuickOpen() -> XCUIElement {
        app.typeKey("p", modifierFlags: [.command])
        let quickOpen = app.otherElements["QuickOpen.Root"]
        XCTAssertTrue(quickOpen.waitForExistence(timeout: 5), "Quick Open overlay did not appear")
        return quickOpen
    }

    @discardableResult
    private func waitForNonExistence(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let exp = expectation(for: predicate, evaluatedWith: element)
        return XCTWaiter.wait(for: [exp], timeout: timeout) == .completed
    }

    // MARK: - Tests

    func testOpenWithKeyboard() {
        _ = openQuickOpen()

        let searchField = app.textFields["QuickOpen.SearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
    }

    func testFileSearch() {
        _ = openQuickOpen()

        let searchField = app.textFields["QuickOpen.SearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("UITest-B")

        XCTAssertTrue(app.otherElements["QuickOpen.Row.UITest-B.txt"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["QuickOpen.Row.UITest-A.txt"].exists)
    }

    func testKeyboardNavigation() {
        _ = openQuickOpen()

        let searchField = app.textFields["QuickOpen.SearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()

        let rowA = app.otherElements["QuickOpen.Row.UITest-A.txt"]
        let rowB = app.otherElements["QuickOpen.Row.UITest-B.txt"]

        XCTAssertTrue(rowA.waitForExistence(timeout: 2))
        XCTAssertTrue(rowB.waitForExistence(timeout: 2))

        // Default selection should be first row.
        XCTAssertEqual(rowA.value as? String, "selected")
        XCTAssertEqual(rowB.value as? String, "unselected")

        searchField.typeKey(.downArrow, modifierFlags: [])

        XCTAssertEqual(rowA.value as? String, "unselected")
        XCTAssertEqual(rowB.value as? String, "selected")

        searchField.typeKey(.upArrow, modifierFlags: [])

        XCTAssertEqual(rowA.value as? String, "selected")
        XCTAssertEqual(rowB.value as? String, "unselected")
    }

    func testFileOpen() {
        let quickOpen = openQuickOpen()

        let searchField = app.textFields["QuickOpen.SearchField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("UITest-B")

        XCTAssertTrue(app.otherElements["QuickOpen.Row.UITest-B.txt"].waitForExistence(timeout: 2))

        // Enter should open the selected file and dismiss Quick Open.
        searchField.typeKey(.return, modifierFlags: [])

        XCTAssertTrue(waitForNonExistence(quickOpen, timeout: 5), "Quick Open did not dismiss after pressing Enter")
    }
}
