//
//  AppDelegate.swift
//  VSCodeiPadOS
//
//  Application delegate handling scene configuration for multiple windows
//  and Stage Manager optimization for iPadOS 26+
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Lifecycle
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Migrate API keys from UserDefaults to Keychain (one-time)
        KeychainHelper.migrateFromUserDefaults()
        
        // Configure for Stage Manager optimization
        configureStageManager()
        
        // Register for window title change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowTitleChange(_:)),
            name: .windowTitleDidChange,
            object: nil
        )
        
        return true
    }
    
    // MARK: - Scene Configuration
    
    // NOTE: Removed configurationForConnecting - let SwiftUI handle scenes entirely
    // Returning a custom UISceneConfiguration was causing "Info.plist contained no 
    // UIScene configuration dictionary" errors and duplicate menu registration
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Clean up state for discarded scenes
        for session in sceneSessions {
            let windowId = session.windowId
            WindowStateManager.shared.removeWindow(id: windowId)
        }
    }
    
    // MARK: - Window Title Management
    
    @objc private func handleWindowTitleChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let title = userInfo["title"] as? String else {
            return
        }
        
        updateWindowSceneTitle(title)
    }
    
    private func updateWindowSceneTitle(_ title: String) {
        // Update all connected window scenes with the new title
        UIApplication.shared.connectedScenes.forEach { scene in
            if let windowScene = scene as? UIWindowScene {
                windowScene.title = title
            }
        }
    }
    
    // MARK: - Stage Manager Optimization
    
    private func configureStageManager() {
        guard UIApplication.shared.supportsMultipleScenes else { return }
        
        if #available(iOS 16.0, *) {
            // Configure preferred scene sizes for Stage Manager
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                
                let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(
                    interfaceOrientations: .all
                )
                windowScene.requestGeometryUpdate(geometryPreferences) { error in
                    AppLogger.editor.error("Stage Manager geometry update failed: \(error)")
                }
                
                // Set minimum size for Stage Manager windows
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 768, height: 600)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 2732, height: 2048)
            }
        }
    }
}
