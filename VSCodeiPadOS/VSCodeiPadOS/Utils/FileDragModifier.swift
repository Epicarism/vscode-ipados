//
//  FileDragModifier.swift
//  VSCodeiPadOS
//
//  Enables dragging files to create new windows
//

import SwiftUI

/// A view modifier that adds drag-and-drop functionality for creating new windows
struct FileDragModifier: ViewModifier {
    let fileURL: URL
    let fileName: String
    
    func body(content: Content) -> some View {
        if UIApplication.shared.supportsMultipleScenes {
            content
                .onDrag {
                    // Create item provider for drag
                    let itemProvider = NSItemProvider()
                    
                    // Register the file URL
                    itemProvider.registerObject(fileURL as NSSecureCoding?, visibility: .all)
                    
                    // Create user activity for new window
                    let activity = NSUserActivity(activityType: WindowActivity.activityType)
                    activity.userInfo = [
                        WindowActivity.fileURLKey: fileURL.absoluteString,
                        WindowActivity.workspacePathKey: ""
                    ]
                    activity.title = fileName
                    
                    itemProvider.registerObject(activity, visibility: .all)
                    
                    return NSItemProvider(object: activity as NSSecureCoding & NSItemProviderWriting)
                }
        } else {
            content
        }
    }
}

extension View {
    /// Adds drag-to-new-window functionality to a view
    /// - Parameters:
    ///   - fileURL: The URL of the file to drag
    ///   - fileName: The display name of the file
    /// - Returns: A view with drag-to-new-window support
    func draggableToNewWindow(fileURL: URL, fileName: String) -> some View {
        self.modifier(FileDragModifier(fileURL: fileURL, fileName: fileName))
    }
}

// MARK: - NSUserActivity Conformance

extension NSUserActivity: NSItemProviderWriting {
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [WindowActivity.activityType]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        // Return activity data
        if let data = try? JSONEncoder().encode(userInfo) {
            completionHandler(data, nil)
        } else {
            completionHandler(nil, NSError(domain: "VSCodeiPadOS", code: -1, userInfo: nil))
        }
        return nil
    }
}

// MARK: - NSSecureCoding Conformance for URL

extension URL: NSSecureCoding {
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.absoluteString, forKey: "url")
    }
    
    public init?(coder: NSCoder) {
        guard let urlString = coder.decodeObject(of: NSString.self, forKey: "url") as String?,
              let url = URL(string: urlString) else {
            return nil
        }
        self = url
    }
}
