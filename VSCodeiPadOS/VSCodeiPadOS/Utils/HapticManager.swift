//
//  HapticManager.swift
//  VSCodeiPadOS
//
//  Centralised haptic feedback utility.
//  Call these from any view / action handler – they are cheap no-ops
//  on devices that don't support haptics (e.g. iPad without Taptic Engine).
//

import UIKit

// MARK: - Haptic Manager

@MainActor
enum HapticManager {

    /// Short physical impact — use for low-weight confirmations (save, sidebar toggle).
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    /// Success / warning / error notification pattern.
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    /// Subtle tick — use for list / tab selection changes.
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
