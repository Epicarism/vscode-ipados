import XCTest

final class SidebarToggleUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        // Ensure the app has focus so Cmd+B is delivered.
        app.tap()
    }

    // MARK: - Elements

    private var sidebarPanel: XCUIElement {
        app.otherElements["sidebar.panel"]
    }

    private var explorerActivityBarButton: XCUIElement {
        app.buttons["activityBar.explorer"]
    }

    // MARK: - Helpers

    private func waitForSidebar(exists: Bool, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "exists == %@", NSNumber(value: exists))
        expectation(for: predicate, evaluatedWith: sidebarPanel)
        waitForExpectations(timeout: timeout)
    }

    private func ensureSidebarVisible(timeout: TimeInterval = 5) {
        if sidebarPanel.exists { return }

        XCTAssertTrue(explorerActivityBarButton.waitForExistence(timeout: timeout), "Explorer activity bar button must exist")
        explorerActivityBarButton.tap()
        waitForSidebar(exists: true, timeout: timeout)
    }

    private func toggleSidebarWithKeyboard() {
        // Cmd+B
        app.typeKey("b", modifierFlags: .command)
    }

    private func currentSidebarWidthOrZero() -> CGFloat {
        sidebarPanel.exists ? sidebarPanel.frame.size.width : 0
    }

    // MARK: - Tests

    func testToggleSidebarWithKeyboard() throws {
        ensureSidebarVisible()

        let visibleWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(visibleWidth, 1, "Expected sidebar to be visible with non-zero width")

        toggleSidebarWithKeyboard()
        waitForSidebar(exists: false)

        let hiddenWidth = currentSidebarWidthOrZero()
        XCTAssertEqual(hiddenWidth, 0, "Expected sidebar width to be 0 when hidden")
        XCTAssertNotEqual(hiddenWidth, visibleWidth, "Expected sidebar width to change after toggle")

        toggleSidebarWithKeyboard()
        waitForSidebar(exists: true)

        let restoredWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(restoredWidth, 1, "Expected sidebar to be visible after toggling back on")
    }

    func testToggleSidebarWithButton() throws {
        ensureSidebarVisible()

        let visibleWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(visibleWidth, 1)

        XCTAssertTrue(explorerActivityBarButton.waitForExistence(timeout: 5), "Explorer activity bar button must exist")

        // If Explorer is already selected, one tap hides.
        // If not selected, first tap selects Explorer (sidebar remains visible), second tap hides.
        explorerActivityBarButton.tap()
        if sidebarPanel.exists {
            explorerActivityBarButton.tap()
        }
        waitForSidebar(exists: false)

        let hiddenWidth = currentSidebarWidthOrZero()
        XCTAssertEqual(hiddenWidth, 0)

        // Show again.
        explorerActivityBarButton.tap()
        waitForSidebar(exists: true)

        let restoredWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(restoredWidth, 1)
    }

    func testSidebarVisibilityState() throws {
        ensureSidebarVisible()

        let initialWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(initialWidth, 1)

        toggleSidebarWithKeyboard()
        waitForSidebar(exists: false)

        toggleSidebarWithKeyboard()
        waitForSidebar(exists: true)

        let restoredWidth = currentSidebarWidthOrZero()
        XCTAssertGreaterThan(restoredWidth, 1)

        // editorCore.sidebarWidth should be preserved across show/hide.
        XCTAssertEqual(restoredWidth, initialWidth, accuracy: 2.0)
    }
}
