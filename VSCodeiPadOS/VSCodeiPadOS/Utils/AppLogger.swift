import Foundation
import os
import Combine

// MARK: - AppLogger

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

// MARK: - CrashReporter
//
// Simple crash reporting mechanism that catches uncaught exceptions,
// persists crash details to disk, and surfaces them on next launch.
// No third-party SDKs required.
//

final class CrashReporter: ObservableObject, @unchecked Sendable {

    // MARK: - Singleton

    static let shared = CrashReporter()

    // MARK: - Published State

    /// Non-nil when a crash log was detected from the previous launch.
    /// Once read, the crash file is automatically cleared so it only appears once.
    @Published var lastCrashReport: String?

    // MARK: - Private

    private static let crashLogDirectory = "crash_reports"
    private static let crashLogFilename = "last_crash.log"

    // MARK: - Init

    private init() {}

    // MARK: - Setup

    /// Call this early in `didFinishLaunchingWithOptions`.
    /// Installs the uncaught-exception handler and checks for a previous crash.
    func setup() {
        checkForPreviousCrash()
        installUncaughtExceptionHandler()
    }

    // MARK: - Exception Handler

    private func installUncaughtExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.shared.handleUncaughtException(exception)
        }
    }

    private func handleUncaughtException(_ exception: NSException) {
        let report = buildCrashReport(exception: exception)
        persistCrashReport(report)
    }

    // MARK: - Crash Report Construction

    private func buildCrashReport(exception: NSException) -> String {
        var lines: [String] = []

        lines.append("═══════════════════════════════════════")
        lines.append("  CRASH REPORT")
        lines.append("═══════════════════════════════════════")
        lines.append("")

        // Timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        let timestamp = formatter.string(from: Date())
        lines.append("Date:           \(timestamp)")

        // App info
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build   = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        lines.append("App Version:    \(version) (\(build))")
        lines.append("OS Version:     \(ProcessInfo.processInfo.operatingSystemVersionString)")
        lines.append("Device Model:   \(getDeviceModel())")
        lines.append("")

        // Exception details
        lines.append("── Exception ──────────────────────────")
        lines.append("Name:           \(exception.name.rawValue)")
        lines.append("Reason:         \(exception.reason ?? "nil")")
        lines.append("")

        // Call stack
        let callStack = exception.callStackSymbols
        if !callStack.isEmpty {
            lines.append("── Call Stack ─────────────────────────")
            for (index, frame) in callStack.enumerated() {
                lines.append(String(format: "  %03d  %@", index + 1, frame))
            }
            lines.append("")
        }

        // Additional userInfo if present
        if let userInfo = exception.userInfo, !userInfo.isEmpty {
            lines.append("── User Info ──────────────────────────")
            for (key, value) in userInfo {
                lines.append("  \(key): \(value)")
            }
            lines.append("")
        }

        lines.append("═══════════════════════════════════════")

        return lines.joined(separator: "\n")
    }

    // MARK: - Persistence

    private func persistCrashReport(_ report: String) {
        guard let directory = crashLogDirectoryURL else { return }

        // Ensure directory exists
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            AppLogger.general.error("CrashReporter: failed to create crash log directory: \(error)")
            return
        }

        // Write (overwrite) the crash log
        do {
            try report.write(
                to: directory.appendingPathComponent(Self.crashLogFilename),
                atomically: true,
                encoding: .utf8
            )
        } catch {
            AppLogger.general.error("CrashReporter: failed to write crash log: \(error)")
        }
    }

    // MARK: - Previous Crash Detection

    private func checkForPreviousCrash() {
        guard let fileURL = crashLogFileURL,
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            DispatchQueue.main.async { [weak self] in
                self?.lastCrashReport = contents
            }

            AppLogger.general.warning("CrashReporter: previous crash detected")

            // Remove the file so we don't report the same crash twice
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            AppLogger.general.error("CrashReporter: failed to read/remove crash log: \(error)")
        }
    }

    // MARK: - Public API

    /// URL for the crash log file itself.
    var crashLogFileURL: URL? {
        crashLogDirectoryURL?.appendingPathComponent(Self.crashLogFilename)
    }

    /// URL for the directory that holds crash logs.
    var crashLogDirectoryURL: URL? {
        try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(Self.crashLogDirectory)
    }

    /// Clear the displayed crash report (e.g. after the user dismisses the alert).
    func dismissCrashReport() {
        lastCrashReport = nil
    }

    // MARK: - Helpers

    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
        return machine
    }
}
