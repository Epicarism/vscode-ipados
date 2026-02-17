// Feature flags for VSCodeiPadOS

import Foundation

struct FeatureFlags {
    // Core feature flags
    static let enableSSH = false
    static let enableiCloudSync = false
    static let enableRemoteExecution = false
    static let enableDebugger = false
    
    /// Use Runestone editor instead of legacy regex-based highlighting
    /// Set to false to rollback if issues occur
    static let useRunestoneEditor = true  // ENABLED - Runestone provides O(log n) text storage
    
    /// Enable verbose logging for editor performance debugging
    static let editorPerformanceLogging = false
}
