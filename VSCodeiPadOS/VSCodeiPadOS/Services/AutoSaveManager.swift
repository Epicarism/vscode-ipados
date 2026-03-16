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
    private var autoSaveTask: Task<Void, Never>?
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
        // Cancel any existing scheduled save
        autoSaveTask?.cancel()
        
        let delay = autoSaveDelay
        autoSaveTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            performAutoSave(tabId: tabId)
        }
    }
    
    private func performAutoSave(tabId: UUID) {
        guard let editorCore = editorCore,
              let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }),
              let url = editorCore.tabs[index].url,
              editorCore.tabs[index].isUnsaved else { return }
        
        do {
            if let fileNavigator = editorCore.fileNavigator {
                try fileNavigator.writeFile(at: url, content: editorCore.tabs[index].content)
            } else {
                try editorCore.tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
            }
            
            editorCore.tabs[index].isUnsaved = false
            pendingSaves.remove(tabId)
            
            // Post notification for status bar feedback
            NotificationCenter.default.post(
                name: .autoSaved,
                object: nil,
                userInfo: ["fileName": url.lastPathComponent]
            )
        } catch {
            AppLogger.editor.error("Auto-save error: \(error)")
        }
    }
    
    private func saveAllPending() {
        guard let editorCore = editorCore else { return }
        
        for tabId in pendingSaves {
            if let index = editorCore.tabs.firstIndex(where: { $0.id == tabId }),
               editorCore.tabs[index].isUnsaved,
               editorCore.tabs[index].url != nil {
                performAutoSave(tabId: tabId)
            }
        }
        
        pendingSaves.removeAll()
    }
    
    deinit {
        if let focusObserver = focusObserver {
            NotificationCenter.default.removeObserver(focusObserver)
        }
    }
}

// MARK: - Notifications (defined in Notification+Names.swift)
