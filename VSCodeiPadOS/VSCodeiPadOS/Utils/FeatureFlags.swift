import Foundation

/// Feature flags for gradual rollout of new features
struct FeatureFlags {
    /// Use Runestone editor instead of legacy regex-based highlighting
    /// Set to false to rollback if issues occur
    static let useRunestoneEditor = false  // DISABLED until Runestone package is properly linked
    
    /// Enable verbose logging for editor performance debugging
    static let editorPerformanceLogging = false
}
