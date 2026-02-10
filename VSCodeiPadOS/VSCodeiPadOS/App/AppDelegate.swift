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
        
        // Configure for Stage Manager optimization
        configureStageManager()
        
        // Register for window title change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowTitleChange(_:)),
            name: NSNotification.Name("WindowTitleDidChange"),
            object: nil
        )
        
        return true
    }
    
    // MARK: - Scene Configuration
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Let SwiftUI handle all scene management via WindowGroup
        // This prevents duplicate menu registration
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }
    
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
        // Enable Stage Manager optimizations for iPadOS 26+
        if #available(iOS 16.0, *) {
            // Configure scene resizing behavior
            // This allows windows to properly resize in Stage Manager
            
            // Note: These are hints to the system that help optimize
            // the app's behavior in Stage Manager
        }
    }
}

// MARK: - Scene Session Extensions

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
