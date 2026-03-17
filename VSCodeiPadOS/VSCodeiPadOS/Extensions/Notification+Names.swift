//
//  Notification+Names.swift
//  VSCodeiPadOS
//
//  Centralized notification name constants.
//  Replaces all hardcoded NSNotification.Name("...") strings.
//

import Foundation

extension Notification.Name {

    // MARK: - File Operations

    /// Create a new file.
    static let newFile = Notification.Name("NewFile")
    /// Open a file picker / file.
    static let openFile = Notification.Name("OpenFile")
    /// Save the current file.
    static let saveFile = Notification.Name("SaveFile")
    /// Save all open files.
    static let saveAllFiles = Notification.Name("SaveAllFiles")
    /// Close the currently selected tab.
    static let closeTab = Notification.Name("CloseTab")

    // MARK: - Editor

    /// Force the editor to sync its text content immediately (used before save).
    static let forceEditorSync = Notification.Name("ForceEditorSync")

    /// Show the Find bar.
    static let showFind = Notification.Name("ShowFind")
    /// Show the Replace bar.
    static let showReplace = Notification.Name("ShowReplace")
    /// Add a cursor on the line above.
    static let addCursorAbove = Notification.Name("AddCursorAbove")
    /// Add a cursor on the line below.
    static let addCursorBelow = Notification.Name("AddCursorBelow")
    /// Navigate to the definition of the symbol under the cursor.
    static let goToDefinition = Notification.Name("GoToDefinition")

    // MARK: - View

    /// Toggle the sidebar visibility.
    static let toggleSidebar = Notification.Name("ToggleSidebar")
    /// Show the Command Palette.
    static let showCommandPalette = Notification.Name("ShowCommandPalette")
    /// Show the Quick Open dialog.
    static let showQuickOpen = Notification.Name("ShowQuickOpen")
    /// Zoom in (increase editor font size).
    static let zoomIn = Notification.Name("ZoomIn")
    /// Zoom out (decrease editor font size).
    static let zoomOut = Notification.Name("ZoomOut")

    // MARK: - Navigation

    /// Show the Go to Symbol dialog.
    static let showGoToSymbol = Notification.Name("ShowGoToSymbol")
    /// Show the Go to Line dialog.
    static let showGoToLine = Notification.Name("ShowGoToLine")
    /// Navigate back in editor history.
    static let goBack = Notification.Name("GoBack")
    /// Navigate forward in editor history.
    static let goForward = Notification.Name("GoForward")
    /// Navigate to a specific file and line (from Problems panel, etc.)
    static let navigateToFile = Notification.Name("navigateToFile")

    // MARK: - Terminal

    /// Toggle the integrated terminal visibility.
    static let toggleTerminal = Notification.Name("ToggleTerminal")
    /// Create a new terminal session.
    static let newTerminal = Notification.Name("NewTerminal")
    /// Clear the terminal buffer.
    static let clearTerminal = Notification.Name("ClearTerminal")

    // MARK: - Debug

    /// Start a debugging session.
    static let startDebugging = Notification.Name("StartDebugging")
    /// Run the project without attaching a debugger.
    static let runWithoutDebugging = Notification.Name("RunWithoutDebugging")
    /// Toggle a breakpoint at the current line.
    static let toggleBreakpoint = Notification.Name("ToggleBreakpoint")

    // MARK: - Run

    /// Run the sample WASM project.
    static let runSampleWASM = Notification.Name("RunSampleWASM")
    /// Run the current file as JavaScript.
    static let runJavaScript = Notification.Name("RunJavaScript")

    // MARK: - AI

    /// Show the AI Assistant panel.
    static let showAIAssistant = Notification.Name("ShowAIAssistant")

    // MARK: - Window

    /// The main window title has changed.
    static let windowTitleDidChange = Notification.Name("WindowTitleDidChange")

    // MARK: - Panels

    /// Switch to the output panel in the terminal area.
    static let switchToOutputPanel = Notification.Name("SwitchToOutputPanel")
    /// Switch to the debug console panel.
    static let switchToDebugConsole = Notification.Name("SwitchToDebugConsole")
    /// Switch to the terminal panel.
    static let switchToTerminalPanel = Notification.Name("SwitchToTerminalPanel")
    /// Switch to the problems panel.
    static let switchToProblemsPanel = Notification.Name("SwitchToProblemsPanel")
    /// Switch to the ports panel.
    static let switchToPortsPanel = Notification.Name("SwitchToPortsPanel")
    /// Switch to the timeline panel.
    static let switchToTimelinePanel = Notification.Name("SwitchToTimelinePanel")
    /// Switch to the source control panel.
    static let switchToSourceControlPanel = Notification.Name("SwitchToSourceControlPanel")
    /// Show the settings view.
    static let showSettings = Notification.Name("ShowSettings")
    /// Show the keyboard shortcuts view.
    static let showKeyboardShortcuts = Notification.Name("ShowKeyboardShortcuts")
    /// Show the About panel.
    static let showAbout = Notification.Name("ShowAbout")

    // MARK: - Search

    /// Collapse all search results in the search panel.
    static let collapseAllSearchResults = Notification.Name("collapseAllSearchResults")
    /// Expand all search results in the search panel.
    static let expandAllSearchResults = Notification.Name("expandAllSearchResults")

    // MARK: - Edit

    /// Undo the last action.
    static let undo = Notification.Name("Undo")
    /// Perform an undo operation (triggered from Command Palette).
    static let performUndo = Notification.Name("PerformUndo")
    /// Redo the last undone action.
    static let redo = Notification.Name("Redo")
    /// Perform a redo operation (triggered from Command Palette).
    static let performRedo = Notification.Name("PerformRedo")
    /// Select all content in the active editor.
    static let selectAll = Notification.Name("SelectAll")

    // MARK: - Code

    /// AI-generated code was inserted into the editor.
    static let codeInserted = Notification.Name("CodeInserted")
    /// Append text to the output panel.
    static let appendOutput = Notification.Name("AppendOutput")
    /// Cancel remote execution in progress.
    static let cancelRemoteExecution = Notification.Name("CancelRemoteExecution")

    // MARK: - Code Folding

    /// Collapse all code folds.
    static let collapseAllFolds = Notification.Name("collapseAllFolds")
    /// Expand all code folds.
    static let expandAllFolds = Notification.Name("expandAllFolds")
    /// Code folding regions changed.
    static let codeFoldingDidChange = Notification.Name("codeFoldingDidChange")

    // MARK: - Extensions

    /// An extension was installed.
    static let extensionInstalled = Notification.Name("extensionInstalled")
    /// An extension was uninstalled.
    static let extensionUninstalled = Notification.Name("extensionUninstalled")

    // MARK: - Inline Suggestions

    /// Partially accept an inline suggestion.
    static let inlineSuggestionPartialAccept = Notification.Name("inlineSuggestionPartialAccept")

    // MARK: - Auth

    /// GitHub authentication state changed.
    static let gitHubAuthDidChange = Notification.Name("GitHubAuthDidChange")

    // MARK: - Auto Save

    /// A file was auto-saved.
    static let autoSaved = Notification.Name("AutoSaved")

    // MARK: - Ports

    /// A port was forwarded.
    static let portForwarded = Notification.Name("PortForwarded")
    /// A port was stopped.
    static let portStopped = Notification.Name("PortStopped")
    
    // MARK: - SSH
    
    /// SSH connection was established.
    static let sshDidConnect = Notification.Name("SSHDidConnect")
    /// SSH connection was disconnected.
    static let sshDidDisconnect = Notification.Name("SSHDidDisconnect")

    // MARK: - Workspace Actions

    /// Clone a repository.
    static let cloneRepository = Notification.Name("CloneRepository")

    // MARK: - Debug

    /// Edit a breakpoint condition (object: breakpoint ID string)
    static let editBreakpointCondition = Notification.Name("EditBreakpointCondition")

    // MARK: - System

    /// App received a memory warning — views should release caches.
    static let didReceiveMemoryWarning = Notification.Name("AppDidReceiveMemoryWarning")
}
