import Foundation
import os

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.vscodeipad"

    static let editor = os.Logger(subsystem: subsystem, category: "editor")
    static let git = os.Logger(subsystem: subsystem, category: "git")
    static let ai = os.Logger(subsystem: subsystem, category: "ai")
    static let network = os.Logger(subsystem: subsystem, category: "network")
    static let fileSystem = os.Logger(subsystem: subsystem, category: "fileSystem")
    static let ui = os.Logger(subsystem: subsystem, category: "ui")
    static let general = os.Logger(subsystem: subsystem, category: "general")
}
