//
//  SceneDelegate.swift
//  VSCodeiPadOS
//
//  Manages multiple window scenes for iPadOS 26+
//  Handles state restoration, drag & drop, and window lifecycle
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var editorCore: EditorCore?
    private var windowId: UUID?
    
    // MARK: - Scene Lifecycle
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Generate or retrieve window ID
        windowId = session.windowId
        
        // Create a new EditorCore instance for this window
        let core = EditorCore()
        editorCore = core
        
        // Create the root view
        let contentView = ContentView()
            .environmentObject(core)
            .focusedSceneValue(\.menuEditorCore, core)
            .onAppear {
                self.restoreWindowState(session: session, connectionOptions: connectionOptions)
            }
        
        // Set up the window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
        self.window = window
        
        // Handle URL contexts if opening a file directly
        if let urlContext = connectionOptions.urlContexts.first {
            handleFileURL(urlContext.url)
        }
        
        // Handle user activities (e.g., from handoff or spotlight)
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity)
        }
        
        // Set window title
        updateWindowTitle()
        
        // Register this window with the state manager
        WindowStateManager.shared.registerWindow(id: windowId!)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Save state before disconnecting
        saveWindowState()
        
        // Remove window from state manager
        if let windowId = windowId {
            WindowStateManager.shared.removeWindow(id: windowId)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Set as active window
        if let windowId = windowId {
            WindowStateManager.shared.setActiveWindow(windowId)
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Save state when resigning active
        saveWindowState()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Restore state when entering foreground
        restoreWindowState(session: (scene as? UIWindowScene)?.session)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save state when entering background
        saveWindowState()
    }
    
    // MARK: - State Restoration
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        // Return user activity for state restoration
        guard let windowId = windowId else { return nil }
        
        let activity = WindowStateManager.shared.createUserActivity(for: windowId)
        
        // Update activity with current state
        if let editorCore = editorCore {
            WindowStateManager.shared.captureState(
                from: editorCore,
                windowId: windowId,
                workspacePath: editorCore.fileNavigator?.rootPath
            )
        }
        
        return activity
    }
    
    // MARK: - Window Title
    
    private func updateWindowTitle() {
        guard let scene = window?.windowScene else { return }
        
        var title = "VS Code"
        
        if let editorCore = editorCore,
           let activeTab = editorCore.activeTab {
            title = activeTab.fileName
            
            // Add unsaved indicator
            if activeTab.isUnsaved {
                title += " •"
            }
        } else if let editorCore = editorCore,
                  let workspacePath = editorCore.fileNavigator?.rootPath {
            title = URL(fileURLWithPath: workspacePath).lastPathComponent
        }
        
        scene.title = title
    }
    
    // MARK: - File Handling
    
    private func handleFileURL(_ url: URL) {
        guard let editorCore = editorCore else { return }
        
        // Start accessing security-scoped resource if needed
        let _ = url.startAccessingSecurityScopedResource()
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Open the file
        editorCore.openFile(from: url)
        updateWindowTitle()
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let editorCore = editorCore else { return }
        
        // Check if this is a window activity
        if userActivity.activityType == WindowActivity.activityType {
            if let fileURLString = userActivity.userInfo?[WindowActivity.fileURLKey] as? String,
               let fileURL = URL(string: fileURLString) {
                editorCore.openFile(from: fileURL)
            }
            
            if let workspacePath = userActivity.userInfo?[WindowActivity.workspacePathKey] as? String {
                // TODO: Open workspace at path
                print("Opening workspace: \(workspacePath)")
            }
        }
        
        updateWindowTitle()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let urlContext = URLContexts.first else { return }
        handleFileURL(urlContext.url)
    }
    
    // MARK: - Window State Persistence
    
    private func saveWindowState() {
        guard let windowId = windowId,
              let editorCore = editorCore else { return }
        
        WindowStateManager.shared.captureState(
            from: editorCore,
            windowId: windowId,
            workspacePath: editorCore.fileNavigator?.rootPath
        )
    }
    
    private func restoreWindowState(
        session: UISceneSession?,
        connectionOptions: UIScene.ConnectionOptions? = nil
    ) {
        guard let windowId = windowId,
              let editorCore = editorCore else { return }
        
        // Try to restore from session state restoration activity
        var shouldRestore = false
        
        if let session = session,
           let activity = session.stateRestorationActivity {
            shouldRestore = true
        }
        
        // Or check connection options for user activity
        if !shouldRestore,
           let options = connectionOptions,
           let activity = options.userActivities.first {
            shouldRestore = true
        }
        
        if shouldRestore {
            WindowStateManager.shared.restoreState(to: editorCore, windowId: windowId)
        }
    }
}

// MARK: - FocusedSceneKey

struct MenuEditorCoreKey: FocusedSceneValueKey {
    typealias Value = EditorCore
}

extension FocusedSceneValues {
    var menuEditorCore: EditorCore? {
        get { self[MenuEditorCoreKey.self] }
        set { self[MenuEditorCoreKey.self] = newValue }
    }
}
