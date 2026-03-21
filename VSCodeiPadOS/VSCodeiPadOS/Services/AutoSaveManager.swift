//
//  AutoSaveManager.swift
//  VSCodeiPadOS
//
//  Implements VS Code-style auto-save with multiple modes:
//  - off: No auto-save
//  - afterDelay: Save after a configurable delay (default 1 second)
//  - onFocusChange: Save when editor loses focus
//  - onWindowChange: Save when window loses focus
//

import Foundation
import SwiftUI
import Combine

/// Manages automatic file saving with VS Code-compatible modes
@MainActor
final class AutoSaveManager: ObservableObject {
    static let shared = AutoSaveManager()
    
    // MARK: - Properties
    
    private weak var editorCore: EditorCore?
    private var autoSaveTasks: [UUID: Task<Void, Never>] = [:]
    nonisolated(unsafe) private var focusObserver: NSObjectProtocol?
    
    /// Tracks pending saves per tab ID to avoid duplicate saves
    private var pendingSaves: Set<UUID> = []
    
    // MARK: - Configuration
    
    /// Configurable delay for afterDelay mode (default 1 second)
    @AppStorage("autoSaveDelay") var autoSaveDelayMs: Int = 1000
    
    var autoSaveDelay: TimeInterval {
        Double(autoSaveDelayMs) / 1000.0
    }
    
    // MARK: - Init
    
    private init() {
        setupObservers()
    }
    
    // MARK: - Public API
    
    /// Connect to EditorCore for save operations
    func connect(to editorCore: EditorCore) {
        self.editorCore = editorCore
    }
    
    /// Call when text content changes in a tab
    nonisolated func contentDidChange(tabId: UUID) {
        Task { @MainActor in
            self.handleContentChange(tabId: tabId)
        }
    }
    
    private func handleContentChange(tabId: UUID) {
        guard let editorCore = editorCore,
              let tab = editorCore.tabs.first(where: { $0.id == tabId }),
              tab.url != nil, // Only auto-save files with URLs
              tab.isUnsaved else { return }
        
        let autoSaveMode = SettingsManager.shared.autoSaveMode
        
        switch autoSaveMode {
        case .off:
            break // Do nothing
        case .afterDelay:
            scheduleAutoSave(tabId: tabId)
        case .onFocusChange, .onWindowChange:
            // Mark for save on next focus/window change
            pendingSaves.insert(tabId)
        }
    }
    
    /// Call when the app enters background or loses focus
    func appDidResignActive() {
        guard SettingsManager.shared.autoSaveMode == .onWindowChange else { return }
        saveAllPending()
    }
    
    /// Call when the editor loses focus (switching tabs, views, etc.)
    func editorDidLoseFocus() {
        let mode = SettingsManager.shared.autoSaveMode
        guard mode == .onFocusChange || mode == .onWindowChange else { return }
        saveAllPending()
    }
    
    /// Call when switching tabs
    nonisolated func willSwitchTab(from oldTabId: UUID?) {
        Task { @MainActor in
            self.handleTabSwitch(from: oldTabId)
        }
    }
    
    private func handleTabSwitch(from oldTabId: UUID?) {
        guard let oldTabId = oldTabId else { return }
        
        // For onFocusChange mode, save when leaving a tab
        if SettingsManager.shared.autoSaveMode == .onFocusChange {
            pendingSaves.insert(oldTabId)
            saveAllPending()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe app going to background
        focusObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.appDidResignActive()
            }
        }
    }
    
    private func scheduleAutoSave(tabId: UUID) {
        // Cancel any existing scheduled save for this specific tab
        autoSaveTasks[tabId]?.cancel()
        
        let delay = autoSaveDelay
        autoSaveTasks[tabId] = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            autoSaveTasks.removeValue(forKey: tabId)
            performAutoSave(tabId: tabId)
        }
    }
    
    @discardableResult
    private func performAutoSave(tabId: UUID) -> Bool {
        guard let editorCore = editorCore,
              let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }),
              let url = editorCore.tabs[index].url,
              editorCore.tabs[index].isUnsaved else { return false }
        
        do {
            var contentToSave = editorCore.tabs[index].content
            
            // Apply format-on-save if enabled (uses local formatter for fast,
            // synchronous formatting — auto-save should not wait on LSP round-trips).
            if UserDefaults.standard.bool(forKey: "formatOnSave") {
                let formatter = CodeFormatter.shared
                contentToSave = formatter.format(
                    code: contentToSave,
                    filename: editorCore.tabs[index].fileName
                )
            }
            
            if let fileNavigator = editorCore.fileNavigator {
                try fileNavigator.writeFile(at: url, content: contentToSave)
            } else {
                try contentToSave.write(to: url, atomically: true, encoding: .utf8)
            }
            
            editorCore.tabs[index].isUnsaved = false
            // Return true before posting notification
            pendingSaves.remove(tabId)
            
            // Post notification for status bar feedback
            NotificationCenter.default.post(
                name: .autoSaved,
                object: nil,
                userInfo: ["fileName": url.lastPathComponent]
            )
            return true
        } catch {
            AppLogger.editor.error("Auto-save error: \(error)")
            return false
        }
    }
    
    private func saveAllPending() {
        guard let editorCore = editorCore else { return }
        
        // Clean up stale entries for tabs that no longer exist
        let existingTabIds = Set(editorCore.tabs.map { $0.id })
        pendingSaves = pendingSaves.intersection(existingTabIds)
        for staleId in autoSaveTasks.keys where !existingTabIds.contains(staleId) {
            autoSaveTasks[staleId]?.cancel()
            autoSaveTasks.removeValue(forKey: staleId)
        }
        
        var succeeded: Set<UUID> = []
        for tabId in pendingSaves {
            if let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }),
               editorCore.tabs[index].isUnsaved,
               editorCore.tabs[index].url != nil {
                if performAutoSave(tabId: tabId) {
                    succeeded.insert(tabId)
                }
            }
        }
        
        pendingSaves.subtract(succeeded)
    }
    
    deinit {
        if let focusObserver = focusObserver {
            NotificationCenter.default.removeObserver(focusObserver)
        }
    }
}

// MARK: - Notifications (defined in Notification+Names.swift)
