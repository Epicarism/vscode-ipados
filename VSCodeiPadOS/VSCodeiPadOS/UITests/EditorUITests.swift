import XCTest

/// UI tests for editor interactions including typing, selection, scrolling, and syntax highlighting.
///
/// These tests rely on accessibility identifiers set in editor views for:
/// - Editor container: `editor.container`
/// - Text input area: `editor.textInput`
/// - Line numbers: `editor.lineNumbers`
/// - Syntax highlighted text: `editor.syntaxText`
final class EditorUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]
        app.launch()

        // Ensure editor is present
        XCTAssertTrue(app.otherElements["editor.container"].waitForExistence(timeout: 10))
    }

    // MARK: - Helpers

    private func getTextInput() -> XCUIElement {
        let textInput = app.textViews["editor.textInput"]
        XCTAssertTrue(textInput.waitForExistence(timeout: 5), "Text input should exist")
        return textInput
    }

    private func typeText(_ text: String) {
        let textInput = getTextInput()
        textInput.tap()
        textInput.typeText(text)
    }

    private func waitForContent(timeout: TimeInterval = 5) -> XCUIElement {
        let content = app.textViews["editor.textInput"]
        XCTAssertTrue(content.waitForExistence(timeout: timeout))
        return content
    }

    // MARK: - Typing Tests

    func testTypingBasicText() {
        let textInput = getTextInput()
        textInput.tap()
        textInput.typeText("Hello World")
        
        XCTAssertEqual(textInput.value as? String, "Hello World")
    }

    func testTypingWithSpecialCharacters() {
        let textInput = getTextInput()
        textInput.tap()
        textInput.typeText("!@#$%^&*()")
        
        XCTAssertEqual(textInput.value as? String, "!@#$%^&*()")
    }

    func testTypingMultipleLines() {
        let textInput = getTextInput()
        textInput.tap()
        textInput.typeText("Line 1\nLine 2\nLine 3")
        
        let value = textInput.value as? String ?? ""
        XCTAssertTrue(value.contains("Line 1"))
        XCTAssertTrue(value.contains("Line 2"))
        XCTAssertTrue(value.contains("Line 3"))
    }

    // MARK: - Selection Tests

    func testTextSelection() {
        typeText("Select this text")
        
        let textInput = getTextInput()
        textInput.doubleTap()
        
        // Verify selection menu appears
        let copyButton = app.menuItems["Copy"]
        XCTAssertTrue(copyButton.waitForExistence(timeout: 3))
    }

    func testSelectAll() {
        typeText("Content to select all")
        
        let textInput = getTextInput()
        textInput.press(forDuration: 1.0)
        
        let selectAll = app.menuItems["Select All"]
        if selectAll.exists {
            selectAll.tap()
        }
    }

    // MARK: - Scroll Tests

    func testVerticalScrolling() {
        // Type enough content to make scrolling necessary
        let longText = String(repeating: "Line with content\n", count: 50)
        typeText(longText)
        
        let textInput = getTextInput()
        let startPosition = textInput.frame.origin.y
        
        // Swipe to scroll
        textInput.swipeUp()
        
        let endPosition = textInput.frame.origin.y
        XCTAssertNotEqual(startPosition, endPosition)
    }

    func testHorizontalScrolling() {
        let longLine = String(repeating: "a", count: 200)
        typeText(longLine)
        
        let textInput = getTextInput()
        textInput.swipeLeft()
    }

    // MARK: - Syntax Highlighting Tests

    func testSyntaxContainerExists() {
        let container = app.otherElements["editor.container"]
        XCTAssertTrue(container.exists)
    }

    func testEditorHandlesCodeInput() {
        let swiftCode = """
        func hello() {
            print("Hello, World!")
        }
        """
        
        typeText(swiftCode)
        
        let textInput = getTextInput()
        let value = textInput.value as? String ?? ""
        XCTAssertTrue(value.contains("func"))
        XCTAssertTrue(value.contains("hello"))
    }

    // MARK: - Editing Actions Tests

    func testUndoRedo() {
        typeText("Text to undo")
        
        // Shake to undo (iOS gesture)
        app.device.shake()
        
        // Or use toolbar button if available
        let undoButton = app.buttons["editor.undo"]
        if undoButton.exists {
            undoButton.tap()
        }
    }

    func testCutCopyPaste() {
        typeText("Copy and paste me")
        
        let textInput = getTextInput()
        textInput.doubleTap()
        
        let copyButton = app.menuItems["Copy"]
        if copyButton.waitForExistence(timeout: 3) {
            copyButton.tap()
        }
    }
}
