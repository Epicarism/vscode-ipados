import UIKit
import SwiftUI

/// UIViewController that registers hardware keyboard shortcuts via UIKeyCommand.
/// These shortcuts post centralized Notification.Name constants (from Notification+Names.swift)
/// so that ContentView and other subscribers can respond.
class KeyCommandController: UIViewController {
    
    override var canBecomeFirstResponder: Bool { true }
    
    // When no child (e.g. editor text view) is first responder, this controller
    // must claim first responder so that UIKeyCommand shortcuts (Cmd+Shift+P, etc.)
    // work globally from any state — not just when the editor has focus.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Listen for app foregrounding so we can reclaim first responder
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // Reclaim first responder when keyboard hides (text view resigned first responder).
        // This covers dismissing overlays like Command Palette, Quick Open, Find, etc.
        // where the search TextField resigns and the keyboard disappears.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scheduleFirstResponderReclaim),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        // Reclaim when any text view ends editing (covers UIKit text view dismissals)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scheduleFirstResponderReclaim),
            name: UITextView.textDidEndEditingNotification,
            object: nil
        )
        // Reclaim when any text field ends editing (covers SwiftUI TextField dismissals)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scheduleFirstResponderReclaim),
            name: UITextField.textDidEndEditingNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reclaimFirstResponderIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Reclaim on layout changes — covers cases where SwiftUI restructuring
        // (overlay dismissals, tab switches, panel toggles) leaves no first responder.
        reclaimFirstResponderIfNeeded()
    }
    
    /// Called when the app returns to foreground. Reclaim first responder
    /// if no child view has taken it, so global shortcuts work immediately.
    @objc private func appDidBecomeActive() {
        reclaimFirstResponderIfNeeded()
    }
    
    /// Called when keyboard hides or text editing ends. Delayed to let the
    /// resign operation complete before we attempt to reclaim.
    @objc private func scheduleFirstResponderReclaim() {
        DispatchQueue.main.async { [weak self] in
            self?.reclaimFirstResponderIfNeeded()
        }
    }
    
    /// Attempt to become first responder only if no descendant view is
    /// already first responder. The editor text view naturally takes first
    /// responder when tapped; when it resigns, we reclaim.
    private func reclaimFirstResponderIfNeeded() {
        guard !isFirstResponder else { return }
        // Only claim if no descendant view currently holds first responder.
        // Walk the view hierarchy (not just immediate subviews) since the editor
        // text view may be nested several levels deep inside UIHostingController.
        let childIsFirstResponder = containsFirstResponder(in: view)
        if !childIsFirstResponder {
            becomeFirstResponder()
        }
    }
    
    /// Recursively check if any subview in the hierarchy is first responder.
    private func containsFirstResponder(in view: UIView) -> Bool {
        if view.isFirstResponder { return true }
        for subview in view.subviews {
            if containsFirstResponder(in: subview) { return true }
        }
        return false
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let defs: [(String, String, UIKeyModifierFlags, Selector)] = [
            // MARK: - General
            ("Command Palette", "p", [.command, .shift], #selector(cmdPalette)),
            ("AI Assistant", "a", [.command, .shift], #selector(cmdAIAssistant)),
            ("Quick Open", "p", [.command], #selector(cmdQuickOpen)),
            ("New File", "n", [.command], #selector(cmdNewFile)),
            ("Save", "s", [.command], #selector(cmdSave)),
            ("Save All", "s", [.command, .alternate], #selector(cmdSaveAll)),
            ("Close Tab", "w", [.command], #selector(cmdCloseTab)),
            
            // MARK: - View
            ("Toggle Sidebar", "b", [.command], #selector(cmdToggleSidebar)),
            ("Toggle Terminal", "j", [.command], #selector(cmdToggleTerminal)),
            ("Zoom In", "=", [.command], #selector(cmdZoomIn)),
            ("Zoom Out", "-", [.command], #selector(cmdZoomOut)),
            
            // MARK: - Search
            ("Find", "f", [.command], #selector(cmdFind)),
            ("Replace", "f", [.command, .alternate], #selector(cmdShowReplace)),
            ("Close Find Bar", UIKeyCommand.inputEscape, [], #selector(cmdHideSearch)),
            
            // MARK: - Navigation
            ("Go to Line", "g", [.control], #selector(cmdGoToLine)),
            ("Go to Symbol", "o", [.command, .shift], #selector(cmdGoToSymbol)),
            ("Go to Definition", ".", [.command], #selector(cmdGoToDefinition)),
            ("Go Back", "[", [.control], #selector(cmdGoBack)),
            ("Go Forward", "]", [.control], #selector(cmdGoForward)),
            
            // MARK: - Multi-Cursor
            ("Add Cursor Above", UIKeyCommand.inputUpArrow, [.command, .alternate], #selector(cmdAddCursorAbove)),
            ("Add Cursor Below", UIKeyCommand.inputDownArrow, [.command, .alternate], #selector(cmdAddCursorBelow)),
            
            // MARK: - Selection
            ("Add Next Occurrence", "d", [.command], #selector(cmdAddNextOccurrence)),
            ("Select All Occurrences", "l", [.command, .shift], #selector(cmdSelectAllOccurrences)),
            
            // MARK: - Editing
            ("Toggle Comment", "/", [.command], #selector(cmdToggleComment)),
            ("Delete Line", "k", [.command, .shift], #selector(cmdDeleteLine)),
            ("Move Line Up", UIKeyCommand.inputUpArrow, [.alternate], #selector(cmdMoveLineUp)),
            ("Move Line Down", UIKeyCommand.inputDownArrow, [.alternate], #selector(cmdMoveLineDown)),
            ("Duplicate Line Up", UIKeyCommand.inputUpArrow, [.shift, .alternate], #selector(cmdDuplicateLineUp)),
            ("Duplicate Line Down", UIKeyCommand.inputDownArrow, [.shift, .alternate], #selector(cmdDuplicateLineDown)),
            ("Format Document", "f", [.shift, .alternate], #selector(cmdFormatDocument)),
            // Undo/Redo (as fallback - UIKit handles these natively, but add explicit ones)
            ("Undo", "z", [.command], #selector(cmdUndo)),
            ("Redo", "z", [.command, .shift], #selector(cmdRedo)),
            // Select Line
            ("Select Line", "l", [.command], #selector(cmdSelectLine)),
            // Expand/Shrink Selection
            ("Expand Selection", UIKeyCommand.inputRightArrow, [.shift, .alternate], #selector(cmdExpandSelection)),
            ("Shrink Selection", UIKeyCommand.inputLeftArrow, [.shift, .alternate], #selector(cmdShrinkSelection)),
            // Indent/Outdent
            ("Indent Line", "]", [.command], #selector(cmdIndentLines)),
            ("Outdent Line", "[", [.command], #selector(cmdOutdentLines)),
            // Join Lines
            ("Join Lines", "j", [.control], #selector(cmdJoinLines)),
            // Fold/Unfold All
            ("Fold All", "0", [.command, .shift], #selector(cmdFoldAll)),
            ("Unfold All", "9", [.command, .shift], #selector(cmdUnfoldAll)),
            // Insert Line Below/Above
            ("Insert Line Below", "\r", [.command], #selector(cmdInsertLineBelow)),
            ("Insert Line Above", "\r", [.command, .shift], #selector(cmdInsertLineAbove)),
            // Trigger Suggestions
            ("Trigger Suggestion", " ", [.control], #selector(cmdTriggerSuggestion)),
            // Show Problems
            ("Show Problems", "m", [.command, .shift], #selector(cmdShowProblems)),
            
            // MARK: - Panels
            ("Search in Files", "f", [.command, .shift], #selector(cmdSearchInFiles)),
            ("Settings", ",", [.command], #selector(cmdSettings)),
        ]
        return defs.map { (title, input, mods, action) in
            let cmd = UIKeyCommand(title: title, action: action, input: input, modifierFlags: mods)
            cmd.wantsPriorityOverSystemBehavior = true
            return cmd
        }
    }
    
    // MARK: - General
    
    @objc func cmdPalette() {
        NotificationCenter.default.post(name: .showCommandPalette, object: nil)
    }
    @objc func cmdAIAssistant() {
        NotificationCenter.default.post(name: .showAIAssistant, object: nil)
    }
    @objc func cmdQuickOpen() {
        NotificationCenter.default.post(name: .showQuickOpen, object: nil)
    }
    @objc func cmdNewFile() {
        NotificationCenter.default.post(name: .newFile, object: nil)
    }
    @objc func cmdSave() {
        NotificationCenter.default.post(name: .saveFile, object: nil)
    }
    @objc func cmdSaveAll() {
        NotificationCenter.default.post(name: .saveAllFiles, object: nil)
    }
    @objc func cmdCloseTab() {
        NotificationCenter.default.post(name: .closeTab, object: nil)
    }
    
    // MARK: - View
    
    @objc func cmdToggleSidebar() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }
    @objc func cmdToggleTerminal() {
        NotificationCenter.default.post(name: .toggleTerminal, object: nil)
    }
    @objc func cmdZoomIn() {
        NotificationCenter.default.post(name: .zoomIn, object: nil)
    }
    @objc func cmdZoomOut() {
        NotificationCenter.default.post(name: .zoomOut, object: nil)
    }
    
    // MARK: - Search
    
    @objc func cmdFind() {
        NotificationCenter.default.post(name: .showFind, object: nil)
    }
    @objc func cmdShowReplace() {
        NotificationCenter.default.post(name: .showReplace, object: nil)
    }
    @objc func cmdHideSearch() {
        NotificationCenter.default.post(name: .hideSearch, object: nil)
    }
    
    // MARK: - Navigation
    
    @objc func cmdGoToLine() {
        NotificationCenter.default.post(name: .showGoToLine, object: nil)
    }
    @objc func cmdGoToSymbol() {
        NotificationCenter.default.post(name: .showGoToSymbol, object: nil)
    }
    @objc func cmdGoToDefinition() {
        NotificationCenter.default.post(name: .goToDefinition, object: nil)
    }
    @objc func cmdGoBack() {
        NotificationCenter.default.post(name: .goBack, object: nil)
    }
    @objc func cmdGoForward() {
        NotificationCenter.default.post(name: .goForward, object: nil)
    }
    
    // MARK: - Multi-Cursor
    
    @objc func cmdAddCursorAbove() {
        NotificationCenter.default.post(name: .addCursorAbove, object: nil)
    }
    @objc func cmdAddCursorBelow() {
        NotificationCenter.default.post(name: .addCursorBelow, object: nil)
    }
    
    // MARK: - Selection
    
    @objc func cmdAddNextOccurrence() {
        NotificationCenter.default.post(name: .addNextOccurrence, object: nil)
    }
    @objc func cmdSelectAllOccurrences() {
        NotificationCenter.default.post(name: .selectAllOccurrences, object: nil)
    }
    
    // MARK: - Editing
    
    @objc func cmdToggleComment() {
        NotificationCenter.default.post(name: .toggleComment, object: nil)
    }
    @objc func cmdDeleteLine() {
        NotificationCenter.default.post(name: .deleteLine, object: nil)
    }
    @objc func cmdMoveLineUp() {
        NotificationCenter.default.post(name: .moveLineUp, object: nil)
    }
    @objc func cmdMoveLineDown() {
        NotificationCenter.default.post(name: .moveLineDown, object: nil)
    }
    @objc func cmdDuplicateLineUp() {
        NotificationCenter.default.post(name: .duplicateLineUp, object: nil)
    }
    @objc func cmdDuplicateLineDown() {
        NotificationCenter.default.post(name: .duplicateLineDown, object: nil)
    }
    @objc func cmdFormatDocument() {
        NotificationCenter.default.post(name: .formatDocument, object: nil)
    }
    @objc func cmdUndo() { NotificationCenter.default.post(name: .performUndo, object: nil) }
    @objc func cmdRedo() { NotificationCenter.default.post(name: .performRedo, object: nil) }
    @objc func cmdSelectLine() { NotificationCenter.default.post(name: .selectLine, object: nil) }
    @objc func cmdExpandSelection() { NotificationCenter.default.post(name: .expandSelection, object: nil) }
    @objc func cmdShrinkSelection() { NotificationCenter.default.post(name: .shrinkSelection, object: nil) }
    @objc func cmdIndentLines() { NotificationCenter.default.post(name: .indentLines, object: nil) }
    @objc func cmdOutdentLines() { NotificationCenter.default.post(name: .outdentLines, object: nil) }
    @objc func cmdJoinLines() { NotificationCenter.default.post(name: .joinLines, object: nil) }
    @objc func cmdFoldAll() { NotificationCenter.default.post(name: .collapseAllFolds, object: nil) }
    @objc func cmdUnfoldAll() { NotificationCenter.default.post(name: .expandAllFolds, object: nil) }
    @objc func cmdInsertLineBelow() { NotificationCenter.default.post(name: .insertLineBelow, object: nil) }
    @objc func cmdInsertLineAbove() { NotificationCenter.default.post(name: .insertLineAbove, object: nil) }
    @objc func cmdTriggerSuggestion() { NotificationCenter.default.post(name: .triggerSuggestion, object: nil) }
    @objc func cmdShowProblems() { NotificationCenter.default.post(name: .showProblems, object: nil) }
    

    // MARK: - Panels
    
    @objc func cmdSearchInFiles() {
        NotificationCenter.default.post(name: .showGlobalSearch, object: nil)
    }
    @objc func cmdSettings() {
        NotificationCenter.default.post(name: .showSettings, object: nil)
    }
}

// MARK: - SwiftUI Bridge

/// Wraps the entire SwiftUI view hierarchy inside a KeyCommandController
/// so that UIKeyCommand shortcuts are available app-wide.
struct KeyCommandBridge<Content: View>: UIViewControllerRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> KeyCommandController {
        let controller = KeyCommandController()
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        controller.addChild(host)
        controller.view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
        ])
        host.didMove(toParent: controller)
        // Become first responder immediately so global key commands work from launch
        DispatchQueue.main.async {
            controller.becomeFirstResponder()
        }
        return controller
    }
    
    func updateUIViewController(_ vc: KeyCommandController, context: Context) {
        if let host = vc.children.first as? UIHostingController<Content> {
            host.rootView = content
        }
    }
}
