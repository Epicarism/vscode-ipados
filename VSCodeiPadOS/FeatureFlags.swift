import Foundation

/// Feature flags for gradual rollout of new features
struct FeatureFlags {
    /// Use Runestone editor instead of legacy regex-based highlighting
    /// Set to false to rollback if issues occur
    static let useRunestoneEditor = true
    
    /// Enable verbose logging for editor performance debugging
    static let editorPerformanceLogging = false
}
