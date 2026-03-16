// Feature flags for VSCodeiPadOS

import Foundation

struct FeatureFlags {
    // Core feature flags
    static let enableSSH = true
    static let enableiCloudSync = false  // Not yet implemented
    static let enableRemoteExecution = true
    static let enableDebugger = true
    
    /// Use Runestone editor instead of legacy regex-based highlighting
    /// Set to false to rollback if issues occur
    static let useRunestoneEditor = true  // ENABLED - Runestone provides O(log n) text storage
    
    /// Enable verbose logging for editor performance debugging
    static let editorPerformanceLogging = false
    
    // Remote features
    static let enableRemoteFileSystem = true
    static let enableIntegratedTerminal = true
    static let enableGitOverSSH = true
    
    // Panel features
    static let enableOutputPanel = true
    static let enableProblemsPanel = true
    static let enableDebugConsole = true
    
    // Polish features
    static let enableNotificationToasts = true
    static let enableBreadcrumbs = true
    static let enableMinimap = true
}
