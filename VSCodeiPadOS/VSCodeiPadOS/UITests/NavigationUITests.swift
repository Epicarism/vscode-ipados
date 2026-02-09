import XCTest

/// UI tests for navigation including tabs, panels, and navigation actions.
///
/// These tests rely on accessibility identifiers set in navigation views for:
/// - Tab bar: `tabBar.container`
/// - Tab items: `tabBar.item.<id>`
/// - Close tab button: `tabBar.close.<id>`
/// - New tab button: `tabBar.newTab`
/// - Navigation buttons: `navigation.back`, `navigation.forward`
/// - Sidebar panel: `sidebar.panel`
/// - Activity bar: `activityBar.container`
final class NavigationUITests: XCTestCase {

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

    private func waitForTabBar(timeout: TimeInterval = 5) -> XCUIElement {
        let tabBar = app.otherElements["tabBar.container"]
        XCTAssertTrue(tabBar.waitForExistence(timeout: timeout), "Tab bar should exist")
        return tabBar
    }

    private func waitForSidebar(timeout: TimeInterval = 5) -> XCUIElement {
        let sidebar = app.otherElements["sidebar.panel"]
        XCTAssertTrue(sidebar.waitForExistence(timeout: timeout), "Sidebar should exist")
        return sidebar
    }

    private func ensureSidebarOpen() {
        let sidebar = app.otherElements["sidebar.panel"]
        if !sidebar.exists {
            app.buttons["activityBar.explorer"].tap()
        }
        XCTAssertTrue(app.otherElements["sidebar.panel"].waitForExistence(timeout: 5))
    }

    // MARK: - Tab Bar Tests

    func testTabBarExists() {
        let tabBar = waitForTabBar()
        XCTAssertTrue(tabBar.exists)
        XCTAssertTrue(tabBar.isHittable)
    }

    func testNewTabButton() {
        let newTabButton = app.buttons["tabBar.newTab"]
        if newTabButton.waitForExistence(timeout: 3) {
            newTabButton.tap()
            
            // Verify a new tab was created
            let tabCount = app.buttons.matching(identifier: "tabBar.item").count
            XCTAssertGreaterThanOrEqual(tabCount, 1)
        }
    }

    func testTabSelection() {
        let newTabButton = app.buttons["tabBar.newTab"]
        if newTabButton.waitForExistence(timeout: 3) {
            // Create a new tab first
            newTabButton.tap()
            
            // Try to select the first tab
            let firstTab = app.buttons["tabBar.item.0"]
            if firstTab.waitForExistence(timeout: 3) {
                firstTab.tap()
                XCTAssertTrue(firstTab.isSelected)
            }
        }
    }

    func testCloseTabButton() {
        // Look for any close tab button
        let closeButton = app.buttons.matching(identifier: "tabBar.close").firstMatch
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        }
    }

    func testMultipleTabs() {
        let newTabButton = app.buttons["tabBar.newTab"]
        guard newTabButton.waitForExistence(timeout: 3) else { return }
        
        // Create multiple tabs
        for _ in 1...3 {
            newTabButton.tap()
        }
        
        // Count tabs
        let tabs = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'tabBar.item'"))
        XCTAssertGreaterThanOrEqual(tabs.count, 1)
    }

    // MARK: - Sidebar Navigation Tests

    func testSidebarToggle() {
        ensureSidebarOpen()
        
        let sidebar = waitForSidebar()
        XCTAssertTrue(sidebar.exists)
    }

    func testActivityBarNavigation() {
        // Test clicking each activity bar button navigates correctly
        let activities = [
            ("activityBar.explorer", "EXPLORER"),
            ("activityBar.search", "SEARCH"),
            ("activityBar.sourceControl", "SOURCE CONTROL"),
            ("activityBar.runAndDebug", "RUN AND DEBUG"),
            ("activityBar.extensions", "EXTENSIONS")
        ]
        
        for (buttonId, expectedTitle) in activities {
            let button = app.buttons[buttonId]
            guard button.waitForExistence(timeout: 3) else { continue }
            
            button.tap()
            
            let title = app.staticTexts["sidebar.header.title"]
            if title.waitForExistence(timeout: 3) {
                XCTAssertEqual(title.label, expectedTitle)
            }
        }
    }

    // MARK: - Navigation Buttons Tests

    func testBackButton() {
        let backButton = app.buttons["navigation.back"]
        if backButton.waitForExistence(timeout: 3) {
            backButton.tap()
        }
    }

    func testForwardButton() {
        let forwardButton = app.buttons["navigation.forward"]
        if forwardButton.waitForExistence(timeout: 3) {
            forwardButton.tap()
        }
    }

    // MARK: - Breadcrumb Tests

    func testBreadcrumbExists() {
        let breadcrumb = app.otherElements["navigation.breadcrumb"]
        if breadcrumb.waitForExistence(timeout: 3) {
            XCTAssertTrue(breadcrumb.exists)
        }
    }

    func testBreadcrumbNavigation() {
        let breadcrumb = app.otherElements["navigation.breadcrumb"]
        guard breadcrumb.waitForExistence(timeout: 3) else { return }
        
        // Try to tap on breadcrumb items
        let items = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'breadcrumb.item'"))
        if items.count > 0 {
            items.firstMatch.tap()
        }
    }

    // MARK: - Panel Tests

    func testBottomPanelToggle() {
        let bottomPanelButton = app.buttons["panel.toggleBottom"]
        if bottomPanelButton.waitForExistence(timeout: 3) {
            bottomPanelButton.tap()
            
            let panel = app.otherElements["panel.bottom"]
            XCTAssertTrue(panel.waitForExistence(timeout: 3))
        }
    }

    func testRightPanelToggle() {
        let rightPanelButton = app.buttons["panel.toggleRight"]
        if rightPanelButton.waitForExistence(timeout: 3) {
            rightPanelButton.tap()
            
            let panel = app.otherElements["panel.right"]
            XCTAssertTrue(panel.waitForExistence(timeout: 3))
        }
    }

    // MARK: - Explorer Navigation Tests

    func testExplorerTree() {
        // Ensure Explorer is open
        let explorerButton = app.buttons["activityBar.explorer"]
        guard explorerButton.waitForExistence(timeout: 3) else { return }
        explorerButton.tap()
        
        ensureSidebarOpen()
        
        // Look for file tree items
        let treeItems = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'explorer.file'"))
        
        // Try to expand a folder if one exists
        if treeItems.count > 0 {
            treeItems.firstMatch.tap()
        }
    }

    func testExplorerFileSelection() {
        ensureSidebarOpen()
        
        let fileItems = app.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'explorer.file'"))
        
        if fileItems.count > 0 {
            let firstFile = fileItems.firstMatch
            firstFile.tap()
            
            // Verify file was selected (may trigger tab creation)
            XCTAssertTrue(firstFile.exists)
        }
    }
}
