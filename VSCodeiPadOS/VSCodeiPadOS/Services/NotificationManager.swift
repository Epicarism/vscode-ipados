//
//  NotificationManager.swift
//  VSCodeiPadOS
//
//  VS Code-style notification/toast system.
//  Shows transient notifications in bottom-right corner.
//  Supports info, warning, error, and progress types.
//

import Foundation
import SwiftUI

// MARK: - Notification Model

struct IDENotification: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let detail: String?
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    let actions: [NotificationAction]
    let autoDismissSeconds: Double?
    
    init(
        message: String,
        detail: String? = nil,
        type: NotificationType = .info,
        actions: [NotificationAction] = [],
        autoDismiss: Double? = 5.0
    ) {
        self.message = message
        self.detail = detail
        self.type = type
        self.timestamp = Date()
        self.isRead = false
        self.actions = actions
        self.autoDismissSeconds = autoDismiss
    }
    
    static func == (lhs: IDENotification, rhs: IDENotification) -> Bool {
        lhs.id == rhs.id
    }
}

enum NotificationType {
    case info
    case warning
    case error
    case progress
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        case .progress: return "arrow.clockwise"
        }
    }
    
    var color: Color {
        switch self {
        case .info: return .accentColor
        case .warning: return .orange
        case .error: return .red
        case .progress: return .secondary
        }
    }
}

struct NotificationAction: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let isPrimary: Bool
    let handler: () -> Void
    
    init(title: String, isPrimary: Bool = false, handler: @escaping () -> Void) {
        self.title = title
        self.isPrimary = isPrimary
        self.handler = handler
    }
    
    static func == (lhs: NotificationAction, rhs: NotificationAction) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Notification Manager

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    /// Currently visible toast notifications (max 3 shown)
    @Published var activeNotifications: [IDENotification] = []
    
    /// All notification history
    @Published var allNotifications: [IDENotification] = []
    
    /// Show the notification center panel
    @Published var showNotificationCenter: Bool = false
    
    /// Unread count for badge
    var unreadCount: Int {
        allNotifications.filter { !$0.isRead }.count
    }
    
    private var dismissTimers: [UUID: Task<Void, Never>] = [:]
    nonisolated(unsafe) private var extensionObservers: [NSObjectProtocol] = []
    
    init() {
        setupObservers()
    }

    deinit {
        for observer in extensionObservers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Public API
    
    func notify(_ message: String, type: NotificationType = .info, detail: String? = nil, autoDismiss: Double? = 5.0) {
        let notification = IDENotification(
            message: message,
            detail: detail,
            type: type,
            autoDismiss: autoDismiss
        )
        show(notification)
    }
    
    func notifyWithActions(_ message: String, type: NotificationType = .info, detail: String? = nil, actions: [NotificationAction]) {
        let notification = IDENotification(
            message: message,
            detail: detail,
            type: type,
            actions: actions,
            autoDismiss: nil // Don't auto-dismiss if has actions
        )
        show(notification)
    }
    
    func info(_ message: String, detail: String? = nil) {
        notify(message, type: .info, detail: detail)
    }
    
    func warning(_ message: String, detail: String? = nil) {
        notify(message, type: .warning, detail: detail, autoDismiss: 8.0)
    }
    
    func error(_ message: String, detail: String? = nil) {
        notify(message, type: .error, detail: detail, autoDismiss: nil)
    }
    
    func progress(_ message: String, detail: String? = nil) {
        notify(message, type: .progress, detail: detail, autoDismiss: nil)
    }
    
    // MARK: - Dismiss
    
    func dismiss(_ notification: IDENotification) {
        withAnimation(.easeOut(duration: 0.25)) {
            activeNotifications.removeAll { $0.id == notification.id }
        }
        dismissTimers[notification.id]?.cancel()
        dismissTimers.removeValue(forKey: notification.id)
    }
    
    func dismissAll() {
        withAnimation(.easeOut(duration: 0.25)) {
            activeNotifications.removeAll()
        }
        for (_, task) in dismissTimers {
            task.cancel()
        }
        dismissTimers.removeAll()
    }
    
    func markAllRead() {
        for i in allNotifications.indices {
            allNotifications[i].isRead = true
        }
    }
    
    func clearHistory() {
        allNotifications.removeAll()
    }
    
    // MARK: - Internal
    
    private func show(_ notification: IDENotification) {
        // Add to history
        allNotifications.insert(notification, at: 0)
        
        // Cap history at 100
        if allNotifications.count > 100 {
            allNotifications = Array(allNotifications.prefix(100))
        }
        
        // Show as toast (max 3 visible)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            activeNotifications.append(notification)
            if activeNotifications.count > 3 {
                activeNotifications.removeFirst()
            }
        }
        
        // Schedule auto-dismiss
        if let seconds = notification.autoDismissSeconds {
            let id = notification.id
            dismissTimers[id] = Task {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                if !Task.isCancelled {
                    dismiss(notification)
                }
            }
        }
    }
    
    // MARK: - System Event Observers
    
    private func setupObservers() {
        // Extension events
        extensionObservers.append(
            NotificationCenter.default.addObserver(
                forName: .extensionInstalled, object: nil, queue: .main
            ) { [weak self] notif in
                if let name = notif.userInfo?["extension"] as? String {
                    Task { @MainActor in
                        self?.info("Extension '\(name)' installed successfully")
                    }
                }
            }
        )

        extensionObservers.append(
            NotificationCenter.default.addObserver(
                forName: .extensionUninstalled, object: nil, queue: .main
            ) { [weak self] notif in
                if let name = notif.userInfo?["extension"] as? String {
                    Task { @MainActor in
                        self?.info("Extension '\(name)' uninstalled")
                    }
                }
            }
        )
    }
}
