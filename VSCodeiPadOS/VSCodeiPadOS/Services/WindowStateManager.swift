//
//  WindowStateManager.swift
//  VSCodeiPadOS
//
//  Manages multi-window state persistence and restoration for iPadOS 26+
//

import SwiftUI
import UIKit

// MARK: - Window State

/// Represents the state of a single window that can be persisted and restored
struct WindowState: Codable, Identifiable {
    let id: UUID
    var workspacePath: String?
    var openFiles: [OpenFileState]
    var activeFileIndex: Int?
    var sidebarVisible: Bool
    var sidebarWidth: CGFloat
    var windowTitle: String?
    var lastModified: Date
    
    init(
        id: UUID = UUID(),
        workspacePath: String? = nil,
        openFiles: [OpenFileState] = [],
        activeFileIndex: Int? = nil,
        sidebarVisible: Bool = true,
        sidebarWidth: CGFloat = 250,
        windowTitle: String? = nil
    ) {
        self.id = id
        self.workspacePath = workspacePath
        self.openFiles = openFiles
        self.activeFileIndex = activeFileIndex
        self.sidebarVisible = sidebarVisible
        self.sidebarWidth = sidebarWidth
        self.windowTitle = windowTitle
        self.lastModified = Date()
    }
}

/// Represents the state of an open file within a window
struct OpenFileState: Codable, Identifiable {
    let id: UUID
    var filePath: String
    var fileName: String
    var cursorLine: Int
    var cursorColumn: Int
    var scrollPosition: Int
    var isUnsaved: Bool
    var unsavedContent: String?
    
    init(
        id: UUID = UUID(),
        filePath: String,
        fileName: String,
        cursorLine: Int = 1,
        cursorColumn: Int = 1,
        scrollPosition: Int = 0,
        isUnsaved: Bool = false,
        unsavedContent: String? = nil
    ) {
        self.id = id
        self.filePath = filePath
        self.fileName = fileName
        self.cursorLine = cursorLine
        self.cursorColumn = cursorColumn
        self.scrollPosition = scrollPosition
        self.isUnsaved = isUnsaved
        self.unsavedContent = unsavedContent
    }
}

// MARK: - Window Activity

/// User activity type for state restoration
struct WindowActivity {
    static let activityType = "com.vscode-ipados.window"
    static let workspacePathKey = "workspacePath"
    static let windowStateKey = "windowState"
    static let fileURLKey = "fileURL"
}

// MARK: - Window State Manager

/// Singleton manager for multi-window state persistence
class WindowStateManager: ObservableObject {
    static let shared = WindowStateManager()
    
    @Published private(set) var windowStates: [UUID: WindowState] = [:]
    @Published private(set) var activeWindowId: UUID?
    
    private let statesKey = "com.vscode-ipados.windowStates"
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadStates()
    }
    
    // MARK: - State Persistence
    
    /// Load all window states from UserDefaults
    private func loadStates() {
        guard let data = userDefaults.data(forKey: statesKey),
              let states = try? JSONDecoder().decode([UUID: WindowState].self, from: data) else {
            return
        }
        windowStates = states
    }
    
    /// Save all window states to UserDefaults
    private func saveStates() {
        guard let data = try? JSONEncoder().encode(windowStates) else { return }
        userDefaults.set(data, forKey: statesKey)
    }
    
    // MARK: - Window Management
    
    /// Register a new window
    func registerWindow(id: UUID, state: WindowState? = nil) {
        if let state = state {
            windowStates[id] = state
        } else if windowStates[id] == nil {
            windowStates[id] = WindowState(id: id)
        }
        saveStates()
    }
    
    /// Update state for a window
    func updateWindowState(id: UUID, updater: (inout WindowState) -> Void) {
        guard var state = windowStates[id] else { return }
        updater(&state)
        state.lastModified = Date()
        windowStates[id] = state
        saveStates()
    }
    
    /// Remove window state
    func removeWindow(id: UUID) {
        windowStates.removeValue(forKey: id)
        saveStates()
    }
    
    /// Get state for a window
    func getWindowState(id: UUID) -> WindowState? {
        return windowStates[id]
    }
    
    /// Set active window
    func setActiveWindow(_ id: UUID?) {
        activeWindowId = id
    }
    
    // MARK: - State Capture from EditorCore
    
    /// Capture current state from an EditorCore instance
    func captureState(from editorCore: EditorCore, windowId: UUID, workspacePath: String? = nil) {
        let openFiles = editorCore.tabs.map { tab in
            OpenFileState(
                id: tab.id,
                filePath: tab.url?.path ?? "",
                fileName: tab.fileName,
                cursorLine: editorCore.cursorPosition.line,
                cursorColumn: editorCore.cursorPosition.column,
                scrollPosition: 0,
                isUnsaved: tab.isUnsaved,
                unsavedContent: tab.isUnsaved ? tab.content : nil
            )
        }
        
        let activeIndex = editorCore.activeTabId.flatMap { activeId in
            editorCore.tabs.firstIndex { $0.id == activeId }
        }
        
        let windowTitle = editorCore.activeTab?.fileName ?? workspacePath?.components(separatedBy: "/").last
        
        updateWindowState(id: windowId) { state in
            state.workspacePath = workspacePath
            state.openFiles = openFiles
            state.activeFileIndex = activeIndex
            state.sidebarVisible = editorCore.showSidebar
            state.sidebarWidth = editorCore.sidebarWidth
            state.windowTitle = windowTitle
        }
    }
    
    // MARK: - State Restoration to EditorCore
    
    /// Restore state to an EditorCore instance
    func restoreState(to editorCore: EditorCore, windowId: UUID) {
        guard let state = windowStates[windowId] else { return }
        
        // Restore sidebar state
        editorCore.showSidebar = state.sidebarVisible
        editorCore.sidebarWidth = state.sidebarWidth
        
        // Restore open files
        for fileState in state.openFiles {
            if !fileState.filePath.isEmpty {
                let url = URL(fileURLWithPath: fileState.filePath)
                if FileManager.default.fileExists(atPath: fileState.filePath) {
                    editorCore.openFile(from: url)
                }
            } else if let content = fileState.unsavedContent {
                // Restore unsaved file
                editorCore.addTab(fileName: fileState.fileName, content: content)
            }
        }
        
        // Restore active tab
        if let activeIndex = state.activeFileIndex, activeIndex < editorCore.tabs.count {
            editorCore.selectTab(id: editorCore.tabs[activeIndex].id)
        }
    }
    
    // MARK: - User Activity
    
    /// Create NSUserActivity for state restoration
    func createUserActivity(for windowId: UUID) -> NSUserActivity {
        let activity = NSUserActivity(activityType: WindowActivity.activityType)
        activity.title = "VS Code Window"
        
        if let state = windowStates[windowId] {
            activity.userInfo = [
                WindowActivity.windowStateKey: windowId.uuidString,
                WindowActivity.workspacePathKey: state.workspacePath ?? ""
            ]
            
            if let title = state.windowTitle {
                activity.title = title
            }
        }
        
        activity.isEligibleForHandoff = true
        activity.isEligibleForPrediction = true
        
        return activity
    }
    
    /// Restore window from NSUserActivity
    func windowId(from activity: NSUserActivity) -> UUID? {
        guard activity.activityType == WindowActivity.activityType,
              let uuidString = activity.userInfo?[WindowActivity.windowStateKey] as? String,
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return uuid
    }
    
    // MARK: - Window Creation Helpers
    
    /// Request a new window with optional file URL
    @MainActor
    func requestNewWindow(with fileURL: URL? = nil, workspacePath: String? = nil) {
        let options = UIScene.ActivationRequestOptions()
        options.requestingScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        // Create user activity for the new window
        let activity = NSUserActivity(activityType: WindowActivity.activityType)
        activity.title = fileURL?.lastPathComponent ?? "New Window"
        
        var userInfo: [String: Any] = [:]
        if let fileURL = fileURL {
            userInfo[WindowActivity.fileURLKey] = fileURL.absoluteString
        }
        if let workspacePath = workspacePath {
            userInfo[WindowActivity.workspacePathKey] = workspacePath
        }
        activity.userInfo = userInfo
        
        UIApplication.shared.requestSceneSessionActivation(
            nil,
            userActivity: activity,
            options: options,
            errorHandler: { error in
                print("Failed to create new window: \(error.localizedDescription)")
            }
        )
    }
    
    /// Close a window scene
    @MainActor
    func closeWindow(_ scene: UIWindowScene) {
        UIApplication.shared.requestSceneSessionDestruction(
            scene.session,
            options: nil,
            errorHandler: { error in
                print("Failed to close window: \(error.localizedDescription)")
            }
        )
    }
}

// MARK: - Scene Identifier Extension

extension UISceneSession {
    /// Get a stable identifier for this scene session
    var windowId: UUID {
        // Use persistentIdentifier to create a stable UUID
        if let uuid = UUID(uuidString: persistentIdentifier) {
            return uuid
        }
        // Fallback: create deterministic UUID from identifier
        let data = Data(persistentIdentifier.utf8)
        return UUID(uuid: (data as NSData).hash.uuid)
    }
}

private extension Int {
    var uuid: uuid_t {
        var value = self
        var bytes = [UInt8](repeating: 0, count: 16)
        withUnsafeBytes(of: &value) { buffer in
            for (index, byte) in buffer.enumerated() where index < 16 {
                bytes[index] = byte
            }
        }
        return (bytes[0], bytes[1], bytes[2], bytes[3],
                bytes[4], bytes[5], bytes[6], bytes[7],
                bytes[8], bytes[9], bytes[10], bytes[11],
                bytes[12], bytes[13], bytes[14], bytes[15])
    }
}
