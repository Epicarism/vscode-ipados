import UniformTypeIdentifiers

// This file defines the custom UTType for FileItem drag and drop support
// In a production app, you would also declare this in your app's Info.plist

extension UTType {
    static let fileItem: UTType = {
        if let registered = UTType("com.vscodeipad.fileitem") {
            return registered
        }
        // If not registered, create a dynamic type
        return UTType(exportedAs: "com.vscodeipad.fileitem")
    }()
}
