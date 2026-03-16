//
//  NotificationToastView.swift
//  VSCodeiPadOS
//
//  VS Code-style toast notifications (bottom-right) and
//  notification center dropdown.
//

import SwiftUI

// MARK: - Toast Overlay (add to main ContentView as overlay)

struct NotificationToastOverlay: View {
    @ObservedObject var manager: NotificationManager
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Spacer()
            
            ForEach(manager.activeNotifications) { notification in
                NotificationToast(notification: notification, manager: manager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .allowsHitTesting(!manager.activeNotifications.isEmpty)
    }
}

// MARK: - Single Toast

struct NotificationToast: View {
    let notification: IDENotification
    @ObservedObject var manager: NotificationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: notification.type.icon)
                    .font(.system(size: 14))
                    .foregroundColor(notification.type.color)
                    .accessibilityHidden(true)
                
                Text(notification.message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: { manager.dismiss(notification) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss notification")
                .accessibilityHint("Dismiss this notification")
            }
            
            // Detail text
            if let detail = notification.detail {
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Progress indicator
            if notification.type == .progress {
                ProgressView()
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
            }
            
            // Action buttons
            if !notification.actions.isEmpty {
                HStack(spacing: 8) {
                    Spacer()
                    ForEach(notification.actions) { action in
                        Button(action: {
                            action.handler()
                            manager.dismiss(notification)
                        }) {
                            Text(action.title)
                                .font(.system(size: 12, weight: action.isPrimary ? .semibold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(action.isPrimary ? Color.accentColor : Color(UIColor.systemFill))
                                .foregroundColor(action.isPrimary ? .white : .primary)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notification.type.rawValue) notification: \(notification.message)")
        .padding(12)
        .frame(width: 360)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(notification.type.color.opacity(0.3), lineWidth: 1)
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width > 50 {
                        manager.dismiss(notification)
                    }
                }
        )
    }
}

// MARK: - Notification Center (dropdown from bell icon)

struct NotificationCenterView: View {
    @ObservedObject var manager: NotificationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("NOTIFICATIONS")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .accessibilityAddTraits(.isHeader)
                
                Spacer()
                
                if !manager.allNotifications.isEmpty {
                    Button(action: { manager.markAllRead() }) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Mark all read")
                    .help("Mark All Read")
                    
                    Button(action: { manager.clearHistory() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear all notifications")
                    .help("Clear All")
                    
                    Button(action: { manager.dismissAll() }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Dismiss all active notifications")
                    .help("Dismiss All Active")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
            
            if manager.allNotifications.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "bell.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                        .accessibilityHidden(true)
                    Text("No Notifications")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .accessibilityLabel("No notifications")
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(manager.allNotifications) { notification in
                            NotificationHistoryRow(notification: notification)
                            Divider().padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .frame(width: 380, height: 400)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 4)
    }
}

struct NotificationHistoryRow: View {
    let notification: IDENotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Unread dot
            Circle()
                .fill(notification.isRead ? Color.clear : Color.accentColor)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            // Icon
            Image(systemName: notification.type.icon)
                .font(.system(size: 14))
                .foregroundColor(notification.type.color)
                .frame(width: 20)
                .padding(.top, 2)
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(notification.message)
                    .font(.system(size: 12, weight: notification.isRead ? .regular : .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let detail = notification.detail {
                    Text(detail)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(timeAgo(notification.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(notification.isRead ? Color.clear : Color.accentColor.opacity(0.03))
    }
    
    private func timeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}
