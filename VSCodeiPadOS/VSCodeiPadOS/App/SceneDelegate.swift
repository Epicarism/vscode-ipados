//
//  SceneDelegate.swift
//  VSCodeiPadOS
//
//  Scene delegate for multi-window support
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Handle user activity if present
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity, in: windowScene)
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let windowScene = scene as? UIWindowScene else { return }
        handleUserActivity(userActivity, in: windowScene)
    }
    
    private func handleUserActivity(_ activity: NSUserActivity, in windowScene: UIWindowScene) {
        // Handle file or workspace opening via user activity
        if activity.activityType == WindowActivity.activityType {
            if let fileURLString = activity.userInfo?[WindowActivity.fileURLKey] as? String {
                windowScene.title = URL(string: fileURLString)?.lastPathComponent ?? "File"
            } else if let workspacePath = activity.userInfo?[WindowActivity.workspacePathKey] as? String {
                windowScene.title = URL(fileURLWithPath: workspacePath).lastPathComponent
            }
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Scene became active
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Scene will resign active
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Save state when entering background
    }
}

// MARK: - Window Activity Constants

enum WindowActivity {
    static let activityType = "com.vscode.ipados.window"
    static let fileURLKey = "fileURL"
    static let workspacePathKey = "workspacePath"
}

// MARK: - Window State Manager

class WindowStateManager {
    static let shared = WindowStateManager()
    
    private var windowStates: [UUID: WindowState] = [:]
    
    struct WindowState {
        var id: UUID
        var title: String
        var workspacePath: String?
        var openFiles: [String]
    }
    
    func saveWindow(id: UUID, state: WindowState) {
        windowStates[id] = state
    }
    
    func getWindow(id: UUID) -> WindowState? {
        windowStates[id]
    }
    
    func removeWindow(id: UUID) {
        windowStates.removeValue(forKey: id)
    }
}
