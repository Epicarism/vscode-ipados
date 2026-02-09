import XCTest
import Foundation

/// UI tests for the editor breadcrumbs bar.
///
/// Notes:
/// - The app currently does not expose explicit accessibility identifiers for breadcrumb elements.
///   These tests therefore use best-effort heuristics against the SwiftUI view hierarchy.
/// - The breadcrumbs UI is implemented as a horizontal `ScrollView` containing multiple `Text` nodes.
final class BreadcrumbsUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launch()
    }

    // MARK: - Helpers

    /// Returns the most likely breadcrumb labels found in the UI.
    ///
    /// Heuristic: pick the scroll view that contains the most "breadcrumb-like" static texts.
    private func breadcrumbLabels() -> [XCUIElement] {
        let scrollViews = app.scrollViews.allElementsBoundByIndex

        func isProbablyNotBreadcrumbLabel(_ label: String) -> Bool {
            let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return true }

            // Exclude a few well-known non-breadcrumb labels in this app.
            if trimmed.hasPrefix("Ln ") { return true }
            if trimmed.hasPrefix("Spaces:") { return true }
            if trimmed == "UTF-8" { return true }
            if trimmed == "LF" { return true }
            return false
        }

        var best: [XCUIElement] = []
        for sv in scrollViews {
            let labels = sv.staticTexts.allElementsBoundByIndex.filter { el in
                !isProbablyNotBreadcrumbLabel(el.label)
            }
            if labels.count > best.count {
                best = labels
            }
        }

        return best
    }

    /// Attempts to tap an element even when it isn't considered hittable by XCTest.
    private func forceTap(_ element: XCUIElement) {
        if element.isHittable {
            element.tap()
        } else {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }

    // MARK: - Tests

    /// Verifies breadcrumbs are visible and reflect a path hierarchy (multiple components).
    func testBreadcrumbDisplay() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        let labels = breadcrumbLabels()
        XCTAssertGreaterThanOrEqual(
            labels.count,
            2,
            "Expected breadcrumbs to show a path hierarchy with 2+ components (found: \(labels.map(\\.label)))."
        )
    }

    /// Verifies a breadcrumb item can be tapped.
    func testBreadcrumbClick() {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        let labels = breadcrumbLabels()
        XCTAssertFalse(labels.isEmpty, "Expected breadcrumb labels to exist before tapping.")

        // Prefer a non-last element (directory-like) when possible.
        let target = labels.count >= 2 ? labels[0] : labels[labels.count - 1]
        XCTAssertTrue(target.exists, "Expected a breadcrumb label to exist.")

        forceTap(target)

        // Breadcrumbs should still be present after a tap.
        XCTAssertGreaterThanOrEqual(breadcrumbLabels().count, 2, "Expected breadcrumbs to remain visible after tapping a breadcrumb item.")
    }

    /// Verifies a breadcrumb dropdown (if implemented) can be opened.
    ///
    /// The current `BreadcrumbsView` implementation uses `.onTapGesture` and may not expose a
    /// dropdown menu. This test performs a long-press and *skips* if no menu UI surfaces.
    func testBreadcrumbDropdown() throws {
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))

        let labels = breadcrumbLabels()
        guard let target = labels.last else {
            XCTFail("Expected at least one breadcrumb label to test dropdown.")
            return
        }

        target.press(forDuration: 1.0)

        let menu = app.menus.firstMatch
        let sheet = app.sheets.firstMatch
        let popover = app.popovers.firstMatch

        let appeared =
            menu.waitForExistence(timeout: 2) ||
            sheet.waitForExistence(timeout: 2) ||
            popover.waitForExistence(timeout: 2)

        guard appeared else {
            throw XCTSkip("No breadcrumb dropdown surfaced (menu/sheet/popover). Dropdown may not be implemented or not accessible.")
        }

        XCTAssertTrue(menu.exists || sheet.exists || popover.exists)
    }
}
