import SwiftUI
import Foundation

struct TestView: View {
    @State private var testSuites: [TestSuite] = []
    @State private var isScanning: Bool = false
    @State private var scanMessage: String = "Scanning workspace for tests…"
    @State private var hasScanned: Bool = false
    @State private var statusFilter: TestStatus? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TESTING")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { scanWorkspaceForTests() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .help("Rescan Workspace")
                .accessibilityLabel("Rescan Workspace")
                .accessibilityHint("Double tap to scan workspace for test functions")
                .buttonStyle(PlainButtonStyle())

                Menu {
                    Button(action: {
                        testSuites = testSuites.sorted { $0.name < $1.name }
                    }) {
                        Label("Sort by Name", systemImage: "textformat.abc")
                    }
                    Button(action: {
                        statusFilter = (statusFilter == .success) ? nil : .success
                    }) {
                        Label(statusFilter == .success ? "Show All Tests" : "Show Passed", systemImage: "checkmark.circle")
                    }
                    Button(action: {
                        statusFilter = (statusFilter == .failure) ? nil : .failure
                    }) {
                        Label(statusFilter == .failure ? "Show All Tests" : "Show Failed", systemImage: "xmark.circle")
                    }
                    Divider()
                    Button(action: {
                        for i in testSuites.indices {
                            testSuites[i].isExpanded = false
                        }
                    }) {
                        Label("Collapse All", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.leading, 4)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))

            ScrollView {
                VStack {
                    // Banner: test execution requires language-specific runners
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 11))
                            .foregroundColor(.orange)
                        Text("Test execution requires language-specific test runners (e.g., XCTest for Swift, Jest for JavaScript, pytest for Python).")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.8))
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemOrange).opacity(0.08))
                    .cornerRadius(6)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    .padding(.bottom, 4)

                    if isScanning {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text(scanMessage)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else if testSuites.isEmpty && hasScanned {
                        VStack(alignment: .center, spacing: 12) {
                            Image(systemName: "testtube.2")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("Test discovery not available")
                                .accessibilityLabel("Test discovery not available")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("Test execution is not implemented on device. Run tests via Xcode or a CI pipeline.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 300)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach($testSuites) { $suite in
                            TestSuiteRow(suite: $suite, statusFilter: $statusFilter)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            if !hasScanned {
                scanWorkspaceForTests()
            }
        }
    }

    // MARK: - Workspace Test Scanning

    /// Scans the workspace for Swift files containing test functions.
    /// Test functions are identified as `func test...` declarations in files
    /// whose names end with "Tests.swift" or that contain `import XCTest`.
    func scanWorkspaceForTests() {
        isScanning = true
        scanMessage = "Scanning workspace for tests…"

        DispatchQueue.global(qos: .userInitiated).async {
            let discoveredSuites = Self.discoverTestFunctions()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                testSuites = discoveredSuites
                isScanning = false
                hasScanned = true
            }
        }
    }

    /// Scans the app's documents directory and bundle for Swift test files.
    static func discoverTestFunctions() -> [TestSuite] {
        var suites: [String: [String]] = [:]

        // Scan the app's documents directory (workspace files)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let docsURL = documentsURL {
            scanDirectoryRecursively(docsURL, into: &suites)
        }

        // Also scan the main bundle for test files included in the app
        if let bundleTests = Bundle.main.urls(forResourcesWithExtension: "swift", subdirectory: nil) {
            for url in bundleTests {
                let filename = url.lastPathComponent
                if filename.hasSuffix("Tests.swift") || filename.hasSuffix("Test.swift") {
                    scanSwiftFile(at: url, into: &suites)
                }
            }
        }

        // Convert dictionary to TestSuite array
        return suites.map { name, tests in
            TestSuite(
                name: name,
                tests: tests.sorted().map { TestCase(name: $0, status: .none) }
            )
        }.sorted(by: { $0.name < $1.name })
    }

    /// Recursively scans a directory for Swift test files.
    private static func scanDirectoryRecursively(_ url: URL, into suites: inout [String: [String]]) {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        for case let fileURL as URL in enumerator {
            let filename = fileURL.lastPathComponent
            // Only look at Swift files that appear to be test files
            guard filename.hasSuffix(".swift") else { continue }
            let isTestFile = filename.hasSuffix("Tests.swift") || filename.hasSuffix("Test.swift")
            if !isTestFile {
                // Also check file content for XCTest import
                guard let content = try? String(contentsOf: fileURL, encoding: .utf8),
                      content.contains("import XCTest") else {
                    continue
                }
            }
            scanSwiftFile(at: fileURL, into: &suites)
        }
    }

    /// Parses a single Swift file for test function declarations.
    /// Looks for patterns like `func testName(` that start with "test".
    private static func scanSwiftFile(at url: URL, into suites: inout [String: [String]]) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }

        // Check for XCTest import (confirm this is a test file)
        let hasXCTestImport = content.contains("import XCTest")
        let filename = url.deletingPathExtension().lastPathComponent

        // Extract test function names: lines matching "func test..."
        let lines = content.components(separatedBy: .newlines)
        var foundTests: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Match "func testName(" or "func testName _("
            guard trimmed.hasPrefix("func test") else { continue }
            // Extract the function name between "func " and the "("
            if let parenRange = trimmed.range(of: "(") {
                let funcDecl = trimmed[trimmed.startIndex..<parenRange.lowerBound]
                // Remove "func " prefix and any generic parameters
                var name = String(funcDecl)
                if name.hasPrefix("func ") {
                    name = String(name.dropFirst(5))
                }
                // Remove generic parameters like "<T>"
                if let genericStart = name.firstIndex(of: "<") {
                    name = String(name[name.startIndex..<genericStart])
                }
                // Clean up whitespace
                name = name.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty && name.hasPrefix("test") {
                    // Skip private/internal access modifiers that got mixed in
                    foundTests.append(String(name))
                }
            }
        }

        if !foundTests.isEmpty || hasXCTestImport {
            if suites[filename] == nil {
                suites[filename] = []
            }
            suites[filename]?.append(contentsOf: foundTests)
        }
    }
}

// MARK: - Test Suite Row

struct TestSuiteRow: View {
    @Binding var suite: TestSuite
    @Binding var statusFilter: TestStatus?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { suite.isExpanded.toggle() } }) {
                    Image(systemName: suite.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 16, height: 16)
                        .contentShape(Rectangle())
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())

                Image(systemName: "testtube.2")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(suite.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                let visibleCount = filteredTests.count
                Text("\(visibleCount)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            if suite.isExpanded {
                if filteredTests.isEmpty {
                    Text("No test functions found in this file")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.leading, 24)
                        .padding(.vertical, 4)
                } else {
                    ForEach(filteredTests.indices, id: \.self) { index in
                        TestCaseRow(test: $suite.tests[indexForFiltered(index)])
                            .padding(.leading, 24)
                    }
                }

                // Unavailability notice
                unavailableNotice
                    .padding(.leading, 24)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
            }
        }
    }

    private var filteredTests: [TestCase] {
        guard let filter = statusFilter else {
            return suite.tests
        }
        return suite.tests.filter { $0.status == filter }
    }

    /// Maps a filtered index back to the original tests array index.
    private func indexForFiltered(_ filteredIndex: Int) -> Int {
        guard let filter = statusFilter else {
            return filteredIndex
        }
        var count = -1
        for (originalIndex, test) in suite.tests.enumerated() {
            if test.status == filter {
                count += 1
                if count == filteredIndex {
                    return originalIndex
                }
            }
        }
        return filteredIndex
    }

    private var unavailableNotice: some View {
        HStack(spacing: 6) {
            Image(systemName: "info.circle")
                .font(.system(size: 10))
                .foregroundColor(.orange)
            Text("Test execution is not available on device. Run tests via Xcode or a CI pipeline.")
                .font(.system(size: 10))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Test Case Row

struct TestCaseRow: View {
    @Binding var test: TestCase

    var body: some View {
        HStack(spacing: 6) {
            StatusIcon(status: test.status)

            Text(test.name)
                .font(.system(size: 12))
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 2)
        .padding(.trailing, 8)
    }
}

// MARK: - Status Icon

struct StatusIcon: View {
    let status: TestStatus

    var body: some View {
        ZStack {
            switch status {
            case .none:
                Circle()
                    .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                    .frame(width: 10, height: 10)
            case .skipped:
                Image(systemName: "minus.circle")
                    .foregroundColor(.orange)
                    .font(.system(size: 10))
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 10))
            case .failure:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 10))
            }
        }
        .frame(width: 16, height: 16)
    }
}

// MARK: - Models

struct TestSuite: Identifiable {
    let id = UUID()
    let name: String
    var tests: [TestCase]
    var isExpanded: Bool = true
}

struct TestCase: Identifiable {
    let id = UUID()
    let name: String
    var status: TestStatus
}

enum TestStatus {
    /// Not yet run / discovered but idle
    case none
    /// Cannot be run on device (replaces fake random results)
    case skipped
    /// Test passed
    case success
    /// Test failed
    case failure
}
