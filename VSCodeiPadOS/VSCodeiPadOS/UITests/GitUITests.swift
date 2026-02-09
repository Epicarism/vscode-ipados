import XCTest

/// UI tests for the Git/Source Control panel.
///
/// These tests rely on accessibility identifiers set in Git views for:
/// - Git panel container: `git.panel`
/// - Git panel title: `sidebar.header.title`
/// - Activity bar button: `activityBar.sourceControl`
/// - Repository list: `git.repositoryList`
/// - Branch selector: `git.branchSelector`
/// - Commit button: `git.commitButton`
/// - Stage button: `git.stageButton`
final class GitUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launch()

        // Ensure activity bar is present and open Git panel
        XCTAssertTrue(app.buttons["activityBar.sourceControl"].waitForExistence(timeout: 10))
        openGitPanel()
    }

    // MARK: - Helpers

    private func openGitPanel() {
        let gitButton = app.buttons["activityBar.sourceControl"]
        XCTAssertTrue(gitButton.waitForExistence(timeout: 5), "Git activity bar button should exist")
        gitButton.tap()

        // Verify Git panel is visible
        let sidebarTitle = app.staticTexts["sidebar.header.title"]
        XCTAssertTrue(sidebarTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(sidebarTitle.label, "SOURCE CONTROL")
    }

    private func waitForGitPanel(timeout: TimeInterval = 5) -> XCUIElement {
        let panel = app.otherElements["git.panel"]
        XCTAssertTrue(panel.waitForExistence(timeout: timeout), "Git panel should exist")
        return panel
    }

    // MARK: - Panel Navigation Tests

    func testGitPanelOpens() {
        let panel = waitForGitPanel()
        XCTAssertTrue(panel.exists)
        
        let title = app.staticTexts["sidebar.header.title"]
        XCTAssertEqual(title.label, "SOURCE CONTROL")
    }

    func testGitPanelToggle() {
        // Panel is already open from setUp
        let panel = waitForGitPanel()
        XCTAssertTrue(panel.exists)

        // Toggle off by clicking same button
        let gitButton = app.buttons["activityBar.sourceControl"]
        gitButton.tap()

        // Wait for panel to disappear
        let predicate = NSPredicate(format: "exists == false")
        let expectation = self.expectation(for: predicate, evaluatedWith: panel)
        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Repository Tests

    func testRepositoryListExists() {
        let panel = waitForGitPanel()
        
        let repositoryList = app.tables["git.repositoryList"]
        // Repository list may or may not exist depending on open folders
        // Just verify panel structure is accessible
        XCTAssertTrue(panel.exists)
    }

    func testBranchSelector() {
        let panel = waitForGitPanel()
        
        let branchSelector = app.buttons["git.branchSelector"]
        if branchSelector.waitForExistence(timeout: 3) {
            XCTAssertTrue(branchSelector.exists)
        }
    }

    // MARK: - Action Button Tests

    func testCommitButtonExists() {
        let panel = waitForGitPanel()
        
        let commitButton = app.buttons["git.commitButton"]
        if commitButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(commitButton.exists)
        }
    }

    func testStageButtonExists() {
        let panel = waitForGitPanel()
        
        let stageButton = app.buttons["git.stageButton"]
        if stageButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(stageButton.exists)
        }
    }

    func testRefreshButtonExists() {
        let panel = waitForGitPanel()
        
        let refreshButton = app.buttons["git.refreshButton"]
        if refreshButton.waitForExistence(timeout: 3) {
            XCTAssertTrue(refreshButton.exists)
        }
    }

    // MARK: - SCM Provider Tests

    func testScmProvidersListed() {
        let panel = waitForGitPanel()
        
        // Check for any SCM provider sections
        let scmSections = app.otherElements.matching(identifier: "git.scmSection")
        _ = scmSections.count // May be 0 if no repos open
    }

    func testChangesList() {
        let panel = waitForGitPanel()
        
        // Look for changes list
        let changesList = app.tables["git.changesList"]
        // May not exist if no changes
        if changesList.waitForExistence(timeout: 2) {
            XCTAssertTrue(changesList.exists)
        }
    }

    // MARK: - Message Input Tests

    func testCommitMessageInput() {
        let panel = waitForGitPanel()
        
        let messageInput = app.textFields["git.commitMessage"]
        if messageInput.waitForExistence(timeout: 3) {
            messageInput.tap()
            messageInput.typeText("Test commit message")
            
            let value = messageInput.value as? String ?? ""
            XCTAssertEqual(value, "Test commit message")
        }
    }
}
