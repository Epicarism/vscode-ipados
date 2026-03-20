import os
import SwiftUI

// MARK: - Navigation Location
struct NavigationLocation {
    let tabId: UUID
    let line: Int
    let column: Int
}


// MARK: - Debug Breakpoint
struct DebugBreakpoint: Identifiable, Equatable {
    let id: UUID
    var file: String
    var line: Int
    var isEnabled: Bool
    var condition: String?
    
    init(id: UUID = UUID(), file: String, line: Int, isEnabled: Bool = true, condition: String? = nil) {
        self.id = id
        self.file = file
        self.line = line
        self.isEnabled = isEnabled
        self.condition = condition
    }
}

// MARK: - Peek Definition State
struct PeekState: Equatable {
    let file: String
    let line: Int
    let content: String
    let sourceLine: Int // The line where peek was triggered
}

// MARK: - Diagnostics Service

@MainActor
class DiagnosticsService: ObservableObject {
    static let shared = DiagnosticsService()
    
    /// Per-file diagnostics storage
    private var diagnosticsByFile: [String: [DiagnosticItem]] = [:]
    
    /// All diagnostics across all files (flattened, published for UI)
    @Published var diagnostics: [DiagnosticItem] = []
    
    /// Rebuild the flat diagnostics array from per-file storage
    private func rebuildDiagnostics() {
        diagnostics = diagnosticsByFile.values.flatMap { $0 }.sorted {
            if $0.file != $1.file { return $0.file < $1.file }
            return $0.line < $1.line
        }
    }
    
    /// Clear diagnostics for a specific file
    func clearFile(_ filename: String) {
        diagnosticsByFile.removeValue(forKey: filename)
        rebuildDiagnostics()
        NotificationCenter.default.post(name: .diagnosticsUpdated, object: nil, userInfo: ["clear": true])
    }
    
    /// Clear all diagnostics
    func clearAll() {
        diagnosticsByFile.removeAll()
        rebuildDiagnostics()
        NotificationCenter.default.post(name: .diagnosticsUpdated, object: nil, userInfo: ["clear": true])
    }
    
    func analyzeFile(content: String, filename: String, filePath: String) {
        var items: [DiagnosticItem] = []
        let lines = content.components(separatedBy: "\n")
        let ext = (filename as NSString).pathExtension.lowercased()
        
        for (index, line) in lines.enumerated() {
            let lineNum = index + 1
            
            // Universal checks
            if line.count > 120 {
                items.append(DiagnosticItem(message: "Line exceeds 120 characters (\(line.count))", file: filename, line: lineNum, column: 121, severity: .info))
            }
            if line.hasSuffix(" ") || line.hasSuffix("\t") {
                items.append(DiagnosticItem(message: "Trailing whitespace", file: filename, line: lineNum, column: line.count, severity: .info))
            }
            
            // TODO/FIXME/HACK
            if line.contains("TODO:") {
                items.append(DiagnosticItem(message: String(line.trimmingCharacters(in: .whitespaces)), file: filename, line: lineNum, column: 1, severity: .info))
            }
            if line.contains("FIXME:") {
                items.append(DiagnosticItem(message: String(line.trimmingCharacters(in: .whitespaces)), file: filename, line: lineNum, column: 1, severity: .warning))
            }
            if line.contains("HACK:") || line.contains("XXX:") {
                items.append(DiagnosticItem(message: String(line.trimmingCharacters(in: .whitespaces)), file: filename, line: lineNum, column: 1, severity: .warning))
            }
            
            // Swift-specific
            if ext == "swift" {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.hasPrefix("//") && !trimmed.hasPrefix("*") {
                    if line.contains("!") && !line.contains("!=") && !line.contains("\"!") {
                        let pattern = try? NSRegularExpression(pattern: "\\w+!(?:\\.|\\s|$|\\))")
                        if let pattern = pattern, pattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil {
                            items.append(DiagnosticItem(message: "Force unwrap detected - consider using optional binding", file: filename, line: lineNum, column: 1, severity: .warning))
                        }
                    }
                    if trimmed.hasPrefix("print(") || trimmed.contains(" print(") {
                        items.append(DiagnosticItem(message: "print() statement - consider using a logger", file: filename, line: lineNum, column: 1, severity: .info))
                    }
                    if line.contains("try!") {
                        items.append(DiagnosticItem(message: "Force try detected - consider using do/catch", file: filename, line: lineNum, column: 1, severity: .warning))
                    }
                }
            }
            
            // JS/TS specific
            if ["js", "jsx", "ts", "tsx", "mjs"].contains(ext) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.hasPrefix("//") && !trimmed.hasPrefix("*") {
                    if trimmed.hasPrefix("var ") {
                        items.append(DiagnosticItem(message: "Use 'let' or 'const' instead of 'var'", file: filename, line: lineNum, column: 1, severity: .warning))
                    }
                    if trimmed.contains("console.log(") {
                        items.append(DiagnosticItem(message: "console.log() statement", file: filename, line: lineNum, column: 1, severity: .info))
                    }
                    // Check for == that should be === (but not !==, ===, or inside strings/comments)
                    if let range = line.range(of: #"(?<![!=])={2}(?!=)"#, options: .regularExpression) {
                        // Verify it's not inside a string literal (basic check)
                        let prefix = String(line[line.startIndex..<range.lowerBound])
                        let singleQuotes = prefix.filter { $0 == "'" }.count
                        let doubleQuotes = prefix.filter { $0 == "\"" }.count
                        if singleQuotes % 2 == 0 && doubleQuotes % 2 == 0 {
                            items.append(DiagnosticItem(message: "Use === instead of ==", file: filename, line: lineNum, column: 1, severity: .warning))
                        }
                    }
                    if trimmed.contains("eval(") {
                        items.append(DiagnosticItem(message: "eval() is dangerous - avoid using it", file: filename, line: lineNum, column: 1, severity: .error))
                    }
                }
            }
            
            // Python specific
            if ext == "py" {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.hasPrefix("#") {
                    if trimmed.contains("import *") {
                        items.append(DiagnosticItem(message: "Wildcard import - import specific names", file: filename, line: lineNum, column: 1, severity: .warning))
                    }
                    if trimmed.hasPrefix("except:") && !trimmed.contains("except ") {
                        items.append(DiagnosticItem(message: "Bare except - catch specific exceptions", file: filename, line: lineNum, column: 1, severity: .warning))
                    }
                }
            }
        }
        
        // Store per-file and rebuild combined list
        diagnosticsByFile[filename] = items
        rebuildDiagnostics()
        
        // Post notification for ProblemsView — convert to [[String: Any]] format
        let allItems = diagnostics
        let itemsDicts: [[String: Any]] = allItems.map { item in
            [
                "id": item.id,
                "message": item.message,
                "file": item.file,
                "line": item.line,
                "column": item.column,
                "severity": item.severity.rawValue
            ]
        }
        NotificationCenter.default.post(name: .diagnosticsUpdated, object: nil, userInfo: ["diagnostics": itemsDicts])
    }
}

// MARK: - Editor Core (Central State Manager)
@MainActor
class EditorCore: ObservableObject {
    @Published var peekState: PeekState?
    @Published var tabs: [Tab] = []
    @Published var activeTabId: UUID?
    @Published var showSidebar = true
    @Published var sidebarWidth: CGFloat = 250
    @Published var showFilePicker = false
    @Published var showSearch = false
    @Published var showReplace = false
    @Published var findReferencesQuery: String? = nil
    @Published var showCommandPalette = false
    @Published var showQuickOpen = false
    @Published var showAIAssistant = false
    @Published var showWelcome = false
    @Published var showGoToLine = false
    @Published var showGoToSymbol = false
    @Published var editorFontSize: CGFloat = {
        let stored = UserDefaults.standard.double(forKey: "fontSize")
        return stored > 0 ? CGFloat(stored) : 14.0
    }() {
        didSet {
            UserDefaults.standard.set(editorFontSize, forKey: "fontSize")
        }
    }
    private nonisolated(unsafe) var fontSizeObserver: NSObjectProtocol?
    @Published var isZenMode = false
    @Published var isFocusMode = false

    // MARK: - Large File Performance

    /// Files with more characters than this threshold are considered "large."
    /// Syntax highlighting and other expensive features are limited for large files.
    static let largeFileThreshold = 100_000 // ~100KB in characters
    @Published var isLargeFile = false

    // MARK: - Diagnostics Counts (Frequently Changing - NOT @Published for performance)
    /// Diagnostic counts are updated frequently during editing.
    /// NOT @Published to avoid triggering view updates on every change.
    /// Use updateDiagnosticCounts() to batch updates with a single objectWillChange.
    var diagnosticErrorCount: Int = 0
    var diagnosticWarningCount: Int = 0
    private nonisolated(unsafe) var diagnosticsObserver: NSObjectProtocol?
    private nonisolated(unsafe) var memoryWarningObserver: NSObjectProtocol?
    
    /// Batch update diagnostic counts with a single change notification
    func updateDiagnosticCounts(errorCount: Int, warningCount: Int) {
        let hasChanges = diagnosticErrorCount != errorCount || diagnosticWarningCount != warningCount
        diagnosticErrorCount = errorCount
        diagnosticWarningCount = warningCount
        if hasChanges {
            objectWillChange.send()
        }
    }
    
    /// Increment diagnostic count with optional batching
    func incrementDiagnosticCount(for severity: DiagnosticSeverity) {
        switch severity {
        case .error: diagnosticErrorCount += 1
        case .warning: diagnosticWarningCount += 1
        case .info: break
        }
        // Note: Call objectWillChange.send() explicitly if needed
    }
    
    /// Clear diagnostic counts
    func clearDiagnosticCounts() {
        guard diagnosticErrorCount != 0 || diagnosticWarningCount != 0 else { return }
        diagnosticErrorCount = 0
        diagnosticWarningCount = 0
        objectWillChange.send()
    }

    // Snippet picker support
    @Published var showSnippetPicker = false
    @Published var pendingSnippetInsertion: Snippet?
    @Published var showSaveAsDialog = false
    @Published var saveAsContent: String = ""

    // Pending close tab (for unsaved changes confirmation)
    @Published var pendingCloseTabId: UUID? = nil

    // MARK: - Cursor Tracking (Frequently Changing - Debounced for performance)
    /// Cursor position changes on every keystroke/click.
    /// NOT @Published - uses debounced updates to avoid 60+ view refreshes per second.
    /// Access directly for read, use updateCursorPosition() for debounced write.
    var cursorPosition = CursorPosition()
    
    /// Debounce task for cursor position updates
    private var cursorUpdateTask: Task<Void, Never>?
    
    /// Debounce delay for cursor updates (100ms)
    private let cursorDebounceDelay: UInt64 = 100_000_000 // 100ms in nanoseconds
    
    /// Update cursor position with debouncing to reduce view updates
    func updateCursorPosition(_ newPosition: CursorPosition) {
        cursorPosition = newPosition
        
        // Cancel previous debounce task
        cursorUpdateTask?.cancel()
        
        // Create new debounced update
        cursorUpdateTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: cursorDebounceDelay)
            guard !Task.isCancelled else { return }
            objectWillChange.send()
        }
    }
    
    /// Immediate cursor update (for critical updates that need instant UI refresh)
    func updateCursorPositionImmediate(_ newPosition: CursorPosition) {
        cursorPosition = newPosition
        objectWillChange.send()
    }
    
    // Multi-cursor support (Frequently changing)
    var multiCursorState = MultiCursorState()
    var currentSelection: String = ""
    var currentSelectionRange: NSRange?

    // Selection request for find/replace navigation
    @Published var requestedSelection: NSRange?

    // Go to line request (from GoToLineView)
    @Published var requestedGoToLine: Int?

    // UI Panel state
    @Published var showKeyboardShortcuts = false
    @Published var focusedSidebarTab = 0

    // Error display
    @Published var lastErrorMessage: String?

    // Debug state
    // Reference to file navigator for workspace search
    weak var fileNavigator: FileSystemNavigator?
    
    // Find References Service
    @Published var findReferencesService = FindReferencesService()
    @Published var findReferencesResults: [ReferenceLocation] = []
    @Published var showFindReferencesResults: Bool = false

    // Navigation history
    private var navigationHistory: [NavigationLocation] = []
    private var navigationIndex = -1

    /// Track active security-scoped URL access while files are open in tabs.
    /// This avoids losing access after opening a document (common on iPadOS).
    private var securityScopedAccessCounts: [URL: Int] = [:]

    /// Retained SFTP manager for in-flight remote saves (prevents ARC deallocation before callback)
    private var activeSFTPManager: SFTPManager?

    /// Serializes save dispatches — cancels any pending save when a new one is requested,
    /// preventing concurrent saves from interleaving and corrupting/losing data.
    private var pendingSaveWorkItem: DispatchWorkItem?
    private var pendingIndexWorkItem: DispatchWorkItem?

    var activeTab: Tab? {
        tabs.first { $0.id == activeTabId }
    }

    var activeTabIndex: Int? {
        tabs.firstIndex { $0.id == activeTabId }
    }

    /// Whether the active file is large enough that expensive features (syntax highlighting,
    /// code folding, etc.) should be limited. Consumers such as the syntax highlighter should
    /// check this flag before performing heavy work.
    var shouldLimitExpensiveFeatures: Bool { isLargeFile }

    /// Updates `isLargeFile` based on the active tab's content length.
    /// Also notifies LargeFileHandler for tier-based feature degradation.
    private func updateLargeFileStatus() {
        if let tab = activeTab {
            let wasLarge = isLargeFile
            isLargeFile = tab.content.count > Self.largeFileThreshold
            if isLargeFile, !wasLarge {
                AppLogger.editor.warning("Large file detected: \(tab.fileName) (\(tab.content.count) chars, threshold: \(Self.largeFileThreshold)). Syntax highlighting and other expensive features may be limited.")
            }
            // Wire into LargeFileHandler for tiered performance degradation
            let fileId = tab.url?.absoluteString ?? tab.id.uuidString
            let info = LargeFileHandler.shared.analyzeFile(content: tab.content, fileId: fileId)
            if info.tier >= .large {
                AppLogger.editor.info("LargeFileHandler tier: \(info.tier.description) for \(tab.fileName)")
            }
        } else {
            isLargeFile = false
        }
    }

    // MARK: - Workspace Persistence Keys
    private static let lastWorkspaceBookmarkKey = "lastWorkspaceBookmark"
    private static let lastOpenTabPathsKey = "lastOpenTabPaths"
    private static let lastActiveTabPathKey = "lastActiveTabPath"
    
    /// Whether a saved workspace was restored (skip example tabs)
    private(set) var restoredWorkspace = false
    
    init() {
        // Check for saved workspace - if found, skip example tabs
        if let bookmarkData = UserDefaults.standard.data(forKey: Self.lastWorkspaceBookmarkKey) {
            var isStale = false
            if let _ = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale) {
                // We have a saved workspace - don't create example tabs
                // ContentView will restore the actual folder on appear
                restoredWorkspace = true
            }
        }
        
        if !restoredWorkspace {
            let exampleTabs = Self.createExampleTabs()
            tabs.append(contentsOf: exampleTabs)
            activeTabId = exampleTabs.first?.id ?? UUID()
        }

        // Connect AutoSaveManager
        Task { @MainActor in AutoSaveManager.shared.connect(to: self) }

        // Observe UserDefaults changes from Settings slider
        fontSizeObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            let stored = UserDefaults.standard.double(forKey: "fontSize")
            if stored > 0 {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if CGFloat(stored) != self.editorFontSize {
                        self.editorFontSize = CGFloat(stored)
                    }
                }
            }
        }

        // Observe memory warnings: clear syntax-highlight caches and non-visible tab content
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: .didReceiveMemoryWarning,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                AppLogger.editor.warning("[EditorCore] Memory warning — purging non-visible tab content caches.")
                // Keep the active tab's content intact; drop oversized cached content
                // from background tabs that are file-backed (can reload from disk).
                let activeId = self.activeTabId
                for index in self.tabs.indices where self.tabs[index].id != activeId {
                    if self.tabs[index].url != nil,
                       self.tabs[index].content.count > 10_000 {
                        self.tabs[index].content = ""
                    }
                }
            }
        }

        // Observe diagnostics updates from ProblemsView / ErrorParser
        diagnosticsObserver = NotificationCenter.default.addObserver(
            forName: .diagnosticsUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            // Extract data outside MainActor.assumeIsolated to avoid Sendable issues
            let userInfo = notification.userInfo
            let shouldClear = (userInfo?["clear"] as? Bool) == true
            let errorCount: Int
            let warningCount: Int
            let singleSeverity: DiagnosticSeverity?
            
            if shouldClear {
                errorCount = 0
                warningCount = 0
                singleSeverity = nil
            } else if let items = userInfo?["diagnostics"] as? [[String: Any]] {
                let diagnostics = items.compactMap { DiagnosticItem(userInfo: $0) }
                errorCount = diagnostics.filter { $0.severity == .error }.count
                warningCount = diagnostics.filter { $0.severity == .warning }.count
                singleSeverity = nil
            } else if let item = userInfo as? [String: Any], item["message"] != nil,
                      let severityRaw = item["severity"] as? String {
                errorCount = -1 // sentinel: use increment mode
                warningCount = -1
                singleSeverity = DiagnosticSeverity(rawValue: severityRaw)
            } else {
                return
            }
            
            MainActor.assumeIsolated {
                // Use batched update methods to reduce view refreshes
                if shouldClear {
                    self.clearDiagnosticCounts()
                } else if errorCount >= 0 {
                    self.updateDiagnosticCounts(errorCount: errorCount, warningCount: warningCount)
                } else if let severity = singleSeverity {
                    // For single increments, we still batch via the method
                    self.incrementDiagnosticCount(for: severity)
                    // Trigger single update after increment
                    self.objectWillChange.send()
                }
            }
        }

    }

    deinit {
        // Remove NotificationCenter observers to prevent dangling references
        if let fontObs = fontSizeObserver {
            NotificationCenter.default.removeObserver(fontObs)
        }
        if let diagObs = diagnosticsObserver {
            NotificationCenter.default.removeObserver(diagObs)
        }
        if let memObs = memoryWarningObserver {
            NotificationCenter.default.removeObserver(memObs)
        }
        // Release any remaining security-scoped resources.
        // deinit is nonisolated on @MainActor classes, so we use assumeIsolated
        // to safely access the MainActor-isolated dictionary (requires iOS 17+).
        MainActor.assumeIsolated { releaseAllSecurityScopedAccess() }
    }
    
    /// Creates example tabs demonstrating syntax highlighting for all supported languages
    static func createExampleTabs() -> [Tab] {
        var examples: [Tab] = []
        
        // Swift example
        examples.append(Tab(
            fileName: "Welcome.swift",
            content: """
// Welcome to CodePad! 🎉
//
// Features:
// • Syntax highlighting for Swift, JS, Python, and more
// • Multiple tabs with drag reordering
// • File explorer sidebar
// • Command palette (⌘+Shift+P)
// • Quick open (⌘+P)
// • Find & Replace (⌘+F)
// • AI Assistant
// • Minimap navigation
// • Code folding
// • Go to line (⌘+G)
//
// Start editing or open a file!

import SwiftUI

struct ContentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello, World!")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Button("Count: \\(counter)") {
                counter += 1
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
""",
            language: "swift"
        ))
        
        // JavaScript example
        examples.append(Tab(
            fileName: "example.js",
            content: """
// JavaScript Example - ES6+ Features

import React, { useState, useEffect } from 'react';

const API_URL = 'https://api.example.com';

// Async function with error handling
async function fetchData(endpoint) {
    try {
        const response = await fetch(`${API_URL}/${endpoint}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error('Fetch failed:', error);
        return null;
    }
}

// React Component
function UserProfile({ userId }) {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        fetchData(`users/${userId}`)
            .then(data => {
                setUser(data);
                setLoading(false);
            });
    }, [userId]);
    
    if (loading) return <div>Loading...</div>;
    
    return (
        <div className="profile">
            <h1>{user?.name ?? 'Unknown'}</h1>
            <p>Email: {user?.email}</p>
        </div>
    );
}

// Array methods & destructuring
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const [first, second, ...rest] = doubled;

export { fetchData, UserProfile };
""",
            language: "javascript"
        ))
        
        // Python example
        examples.append(Tab(
            fileName: "example.py",
            content: """
#!/usr/bin/env python3
\"\"\"
Python Example - Modern Python Features
Demonstrates type hints, dataclasses, async, and more.
\"\"\"

import asyncio
from dataclasses import dataclass, field
from typing import Optional, List
from enum import Enum

class Status(Enum):
    PENDING = "pending"
    ACTIVE = "active"
    COMPLETED = "completed"

@dataclass
class Task:
    \"\"\"Represents a task with metadata.\"\"\"
    id: int
    title: str
    status: Status = Status.PENDING
    tags: List[str] = field(default_factory=list)
    description: Optional[str] = None
    
    def mark_complete(self) -> None:
        self.status = Status.COMPLETED
        print(f"Task '{self.title}' completed!")

class TaskManager:
    def __init__(self):
        self._tasks: dict[int, Task] = {}
        self._next_id = 1
    
    def add_task(self, title: str, **kwargs) -> Task:
        task = Task(id=self._next_id, title=title, **kwargs)
        self._tasks[task.id] = task
        self._next_id += 1
        return task
    
    async def process_tasks(self) -> None:
        for task in self._tasks.values():
            await asyncio.sleep(0.1)  # Simulate work
            task.mark_complete()

# Main execution
async def main():
    manager = TaskManager()
    manager.add_task("Learn Python", tags=["programming", "learning"])
    manager.add_task("Build app", description="Create VSCode for iPad")
    
    await manager.process_tasks()

if __name__ == "__main__":
    asyncio.run(main())
""",
            language: "python"
        ))
        
        // JSON example
        examples.append(Tab(
            fileName: "package.json",
            content: """
{
  "name": "vscode-ipados-example",
  "version": "1.0.0",
  "description": "Example package.json for VS Code iPadOS",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "build": "webpack --mode production",
    "test": "jest --coverage",
    "lint": "eslint src/**/*.js"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.4.0"
  },
  "devDependencies": {
    "webpack": "^5.88.0",
    "jest": "^29.5.0",
    "eslint": "^8.44.0",
    "typescript": "^5.1.6"
  },
  "keywords": ["vscode", "ipad", "editor"],
  "author": "VS Code iPadOS Team",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/example/vscode-ipados"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
""",
            language: "json"
        ))
        
        // HTML example
        examples.append(Tab(
            fileName: "index.html",
            content: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodePad</title>
    <link rel="stylesheet" href="styles.css">
    <script src="app.js" defer></script>
</head>
<body>
    <header class="navbar">
        <nav>
            <a href="#" class="logo">VS Code iPadOS</a>
            <ul class="nav-links">
                <li><a href="#features">Features</a></li>
                <li><a href="#download">Download</a></li>
                <li><a href="#docs">Documentation</a></li>
            </ul>
        </nav>
    </header>
    
    <main>
        <section id="hero" class="hero-section">
            <h1>Code Anywhere</h1>
            <p>Professional code editor for your iPad</p>
            <button id="cta-button" class="btn primary">
                Get Started
            </button>
        </section>
        
        <section id="features">
            <h2>Features</h2>
            <div class="feature-grid">
                <article class="feature-card">
                    <h3>Syntax Highlighting</h3>
                    <p>Support for 8+ languages with TreeSitter</p>
                </article>
                <!-- More features -->
            </div>
        </section>
    </main>
    
    <footer>
        <p>&copy; 2024 VS Code iPadOS. All rights reserved.</p>
    </footer>
</body>
</html>
""",
            language: "html"
        ))
        
        // CSS example
        examples.append(Tab(
            fileName: "styles.css",
            content: """
/* VS Code iPadOS - Stylesheet */
/* Modern CSS with variables, grid, and animations */

:root {
    --primary-color: #007acc;
    --secondary-color: #3c3c3c;
    --background-dark: #1e1e1e;
    --text-light: #d4d4d4;
    --accent-green: #4ec9b0;
    --font-mono: 'SF Mono', Menlo, monospace;
    --shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.3);
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    background-color: var(--background-dark);
    color: var(--text-light);
    line-height: 1.6;
}

.navbar {
    position: sticky;
    top: 0;
    background: rgba(30, 30, 30, 0.95);
    backdrop-filter: blur(10px);
    padding: 1rem 2rem;
    z-index: 1000;
}

.hero-section {
    min-height: 100vh;
    display: grid;
    place-items: center;
    text-align: center;
    background: linear-gradient(135deg, var(--background-dark), #2d2d30);
}

.btn.primary {
    background: var(--primary-color);
    color: white;
    padding: 12px 24px;
    border: none;
    border-radius: 6px;
    font-size: 1rem;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
}

.btn.primary:hover {
    transform: translateY(-2px);
    box-shadow: var(--shadow-lg);
}

.feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    padding: 2rem;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

.feature-card {
    animation: fadeIn 0.5s ease-out forwards;
}

@media (max-width: 768px) {
    .nav-links { display: none; }
    .hero-section { padding: 2rem; }
}
""",
            language: "css"
        ))
        
        // Go example
        examples.append(Tab(
            fileName: "main.go",
            content: """
// Go Example - HTTP Server with Goroutines
package main

import (
\t"context"
\t"encoding/json"
\t"fmt"
\t"log"
\t"net/http"
\t"sync"
\t"time"
)

// User represents a user in the system
type User struct {
\tID        int       `json:"id"`
\tName      string    `json:"name"`
\tEmail     string    `json:"email"`
\tCreatedAt time.Time `json:"created_at"`
}

// UserStore handles user data with thread-safe access
type UserStore struct {
\tmu    sync.RWMutex
\tusers map[int]*User
\tnextID int
}

func NewUserStore() *UserStore {
\treturn &UserStore{
\t\tusers:  make(map[int]*User),
\t\tnextID: 1,
\t}
}

func (s *UserStore) Create(name, email string) *User {
\ts.mu.Lock()
\tdefer s.mu.Unlock()
\t
\tuser := &User{
\t\tID:        s.nextID,
\t\tName:      name,
\t\tEmail:     email,
\t\tCreatedAt: time.Now(),
\t}
\ts.users[user.ID] = user
\ts.nextID++
\treturn user
}

func (s *UserStore) Get(id int) (*User, bool) {
\ts.mu.RLock()
\tdefer s.mu.RUnlock()
\tuser, ok := s.users[id]
\treturn user, ok
}

func handleUsers(store *UserStore) http.HandlerFunc {
\treturn func(w http.ResponseWriter, r *http.Request) {
\t\tswitch r.Method {
\t\tcase http.MethodGet:
\t\t\t// Return all users
\t\t\tw.Header().Set("Content-Type", "application/json")
\t\t\tjson.NewEncoder(w).Encode(store.users)
\t\tcase http.MethodPost:
\t\t\t// Create new user
\t\t\tvar req struct {
\t\t\t\tName  string `json:"name"`
\t\t\t\tEmail string `json:"email"`
\t\t\t}
\t\t\tif err := json.NewDecoder(r.Body).Decode(&req); err != nil {
\t\t\t\thttp.Error(w, err.Error(), http.StatusBadRequest)
\t\t\t\treturn
\t\t\t}
\t\t\tuser := store.Create(req.Name, req.Email)
\t\t\tw.WriteHeader(http.StatusCreated)
\t\t\tjson.NewEncoder(w).Encode(user)
\t\tdefault:
\t\t\thttp.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
\t\t}
\t}
}

func main() {
\tstore := NewUserStore()
\t
\t// Seed some data
\tstore.Create("Alice", "alice@example.com")
\tstore.Create("Bob", "bob@example.com")
\t
\tmux := http.NewServeMux()
\tmux.HandleFunc("/api/users", handleUsers(store))
\t
\tserver := &http.Server{
\t\tAddr:         ":8080",
\t\tHandler:      mux,
\t\tReadTimeout:  10 * time.Second,
\t\tWriteTimeout: 10 * time.Second,
\t}
\t
\tfmt.Println("Server starting on :8080")
\tlog.Fatal(server.ListenAndServe())
}
""",
            language: "go"
        ))
        
        // Rust example
        examples.append(Tab(
            fileName: "main.rs",
            content: """
//! Rust Example - Async Web Server
//! Demonstrates ownership, traits, async/await, and error handling

use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;

/// Represents a task in our system
#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct Task {
    pub id: u64,
    pub title: String,
    pub completed: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub description: Option<String>,
}

/// Task store with thread-safe access
pub struct TaskStore {
    tasks: RwLock<HashMap<u64, Task>>,
    next_id: RwLock<u64>,
}

impl TaskStore {
    pub fn new() -> Self {
        Self {
            tasks: RwLock::new(HashMap::new()),
            next_id: RwLock::new(1),
        }
    }
    
    pub async fn create(&self, title: String, description: Option<String>) -> Task {
        let mut next_id = self.next_id.write().await;
        let id = *next_id;
        *next_id += 1;
        
        let task = Task {
            id,
            title,
            completed: false,
            description,
        };
        
        self.tasks.write().await.insert(id, task.clone());
        task
    }
    
    pub async fn get(&self, id: u64) -> Option<Task> {
        self.tasks.read().await.get(&id).cloned()
    }
    
    pub async fn list(&self) -> Vec<Task> {
        self.tasks.read().await.values().cloned().collect()
    }
    
    pub async fn complete(&self, id: u64) -> Result<Task, &'static str> {
        let mut tasks = self.tasks.write().await;
        match tasks.get_mut(&id) {
            Some(task) => {
                task.completed = true;
                Ok(task.clone())
            }
            None => Err("Task not found"),
        }
    }
}

/// Error type for our application
#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("Task not found: {0}")]
    NotFound(u64),
    #[error("Invalid input: {0}")]
    InvalidInput(String),
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let store = Arc::new(TaskStore::new());
    
    // Create some tasks
    let task1 = store.create("Learn Rust".into(), Some("Study ownership".into())).await;
    let task2 = store.create("Build app".into(), None).await;
    
    println!("Created tasks:");
    for task in store.list().await {
        println!("  - {} ({})", task.title, if task.completed { "✓" } else { "○" });
    }
    
    // Complete a task
    store.complete(task1.id).await?;
    println!("\\nCompleted task: {}", task1.title);
    
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_create_task() {
        let store = TaskStore::new();
        let task = store.create("Test".into(), None).await;
        assert_eq!(task.title, "Test");
        assert!(!task.completed);
    }
}
""",
            language: "rust"
        ))
        
        return examples
    }

    // MARK: - Encoding Detection

    /// Attempt to decode file data using multiple encodings in priority order.
    /// Returns the decoded string and the encoding that succeeded.
    private func detectEncodedContent(from data: Data) -> (content: String, encoding: String.Encoding)? {
        // Ordered by likelihood: UTF-8, UTF-16 (little-endian), UTF-16 big-endian,
        // Windows-1252 (superset of ISO Latin 1), ISO Latin 1, ASCII.
        let encodings: [String.Encoding] = [
            .utf8,
            .utf16LittleEndian,
            .utf16BigEndian,
            .windowsCP1252,
            .isoLatin1,
            .ascii
        ]
        for encoding in encodings {
            if let content = String(data: data, encoding: encoding) {
                return (content, encoding)
            }
        }
        return nil
    }

    // MARK: - Tab Management

    func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil, remotePath: String? = nil, remoteHost: String? = nil) {
        // Check if file is already open by URL
        if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
            activeTabId = existingTab.id
            updateLargeFileStatus()
            return
        }
        
        // Check if remote file is already open by remotePath
        if let remotePath = remotePath, let existingTab = tabs.first(where: { $0.remotePath == remotePath }) {
            activeTabId = existingTab.id
            updateLargeFileStatus()
            return
        }
        
        // For tabs without URLs (demo/untitled), check by fileName to avoid duplicates
        if url == nil && remotePath == nil, let existingTab = tabs.first(where: { $0.url == nil && $0.remotePath == nil && $0.fileName == fileName }) {
            activeTabId = existingTab.id
            updateLargeFileStatus()
            return
        }

        let newTab = Tab(fileName: fileName, content: content, url: url, remotePath: remotePath, remoteHost: remoteHost)
        tabs.append(newTab)
        activeTabId = newTab.id
        updateLargeFileStatus()
        // Index symbols for go-to-definition
        indexActiveTab()
    }

    /// Always creates a brand-new untitled tab with a unique name.
    /// Unlike addTab(), this never deduplicates — it always opens a fresh buffer.
    func newUntitledFile() {
        let existingNames = Set(tabs.filter { $0.url == nil }.map { $0.fileName })
        var candidate = "Untitled.swift"
        var counter = 2
        while existingNames.contains(candidate) {
            candidate = "Untitled-\(counter).swift"
            counter += 1
        }
        let tab = Tab(fileName: candidate, content: "", url: nil)
        tabs.append(tab)
        activeTabId = tab.id
        updateLargeFileStatus()
    }

    func closeTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }

        // If the tab has unsaved changes, defer close to confirmation dialog
        if tabs[index].isUnsaved {
            pendingCloseTabId = id
            return
        }

        forceCloseTab(id: id)
    }

    /// Actually removes the tab without confirmation. Call after user confirms.
    func forceCloseTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        pendingCloseTabId = nil

        // Release security-scoped access if this tab was holding it.
        if let url = tabs[index].url {
            releaseSecurityScopedAccess(to: url)
        }

        tabs.remove(at: index)

        // Update active tab if we closed the active one
        if activeTabId == id {
            if tabs.isEmpty {
                activeTabId = nil
                updateLargeFileStatus()
            } else if index >= tabs.count {
                activeTabId = tabs[tabs.count - 1].id
                updateLargeFileStatus()
            } else {
                activeTabId = tabs[index].id
                updateLargeFileStatus()
            }
        }
    }

    func changeLanguage(to language: CodeLanguage) {
        guard let index = activeTabIndex else { return }
        tabs[index].language = language
    }

    func closeAllTabs() {
        // Release security-scoped access held by any open tabs.
        for tab in tabs {
            if let url = tab.url {
                releaseSecurityScopedAccess(to: url)
            }
        }

        tabs.removeAll()
        activeTabId = nil
    }

    func closeOtherTabs(except id: UUID) {
        // If any tab being closed has unsaved changes, defer to confirmation dialog
        if let firstUnsaved = tabs.first(where: { $0.id != id && $0.isUnsaved }) {
            pendingCloseTabId = firstUnsaved.id
            return
        }

        // Release security-scoped access for tabs being closed.
        for tab in tabs where tab.id != id {
            if let url = tab.url {
                releaseSecurityScopedAccess(to: url)
            }
        }

        tabs.removeAll { $0.id != id }
        activeTabId = id
    }

    func closeTabsToTheRight(of id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }

        // If any tab being closed has unsaved changes, defer to confirmation dialog
        if let firstUnsaved = tabs[(index + 1)...].first(where: { $0.isUnsaved }) {
            pendingCloseTabId = firstUnsaved.id
            return
        }

        let tabsToClose = Array(tabs[(index + 1)...])
        for tab in tabsToClose {
            if let url = tab.url {
                releaseSecurityScopedAccess(to: url)
            }
        }
        tabs.removeSubrange((index + 1)...)
        // If active tab was to the right, select the kept tab
        if let activeId = activeTabId, !tabs.contains(where: { $0.id == activeId }) {
            activeTabId = id
        }
    }

    func closeTabsToTheLeft(of id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }

        // If any tab being closed has unsaved changes, defer to confirmation dialog
        if let firstUnsaved = tabs[..<index].first(where: { $0.isUnsaved }) {
            pendingCloseTabId = firstUnsaved.id
            return
        }

        let tabsToClose = Array(tabs[..<index])
        for tab in tabsToClose {
            if let url = tab.url {
                releaseSecurityScopedAccess(to: url)
            }
        }
        tabs.removeSubrange(..<index)
        // If active tab was to the left, select the kept tab
        if let activeId = activeTabId, !tabs.contains(where: { $0.id == activeId }) {
            activeTabId = id
        }
    }

    func selectTab(id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        activeTabId = id
        updateLargeFileStatus()
    }

    func nextTab() {
        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
        let nextIndex = (currentIndex + 1) % tabs.count
        activeTabId = tabs[nextIndex].id
        updateLargeFileStatus()
    }

    func previousTab() {
        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
        let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
        activeTabId = tabs[prevIndex].id
        updateLargeFileStatus()
    }

    func moveTab(from source: IndexSet, to destination: Int) {
        tabs.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: - Content Management

    func updateActiveTabContent(_ content: String) {
        guard let index = activeTabIndex else { return }

        // Avoid marking a tab dirty when we're just syncing state (e.g., initial onAppear assignment).
        guard tabs[index].content != content else { return }

        tabs[index].content = content

        // Mark dirty for both saved and unsaved-new files.
        tabs[index].isUnsaved = true
        updateLargeFileStatus()
        
        // Trigger auto-save if enabled
        let tabId = tabs[index].id
        Task { @MainActor in AutoSaveManager.shared.contentDidChange(tabId: tabId) }
        
        // Debounced symbol indexing for go-to-definition
        pendingIndexWorkItem?.cancel()
        let indexWork = DispatchWorkItem { [weak self] in
            self?.indexActiveTab()
        }
        pendingIndexWorkItem = indexWork
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: indexWork)
    }

    func saveActiveTab() {
        // Capture the active tab identity BEFORE posting the sync notification.
        // This prevents a race where the active tab changes between the sync
        // and the async save dispatch.
        let capturedTabId = activeTabId
        let capturedIndex = activeTabIndex

        // Force the editor view to sync any pending text changes immediately
        NotificationCenter.default.post(name: .forceEditorSync, object: nil)

        // Cancel any previously scheduled save to prevent concurrent/duplicate saves.
        pendingSaveWorkItem?.cancel()

        // Brief delay to allow the sync notification to be processed by the editor view
        // before we read the (now-updated) tab content. 50ms provides enough time for
        // the synchronous notification handler to complete on the main run loop.
        let workItem = DispatchWorkItem { [weak self] in
            self?.pendingSaveWorkItem = nil
            self?._performSave(tabId: capturedTabId, index: capturedIndex)
        }
        pendingSaveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: workItem)
    }

    private func _performSave(tabId: UUID? = nil, index: Int? = nil) {
        // Use the explicitly provided tab identity if available (race-safe),
        // otherwise fall back to reading the current active tab.
        let saveIndex: Int
        if let index {
            saveIndex = index
        } else {
            guard let idx = activeTabIndex else { return }
            saveIndex = idx
        }

        guard tabs.indices.contains(saveIndex) else { return }

        // Apply file cleanup settings to a local copy only — don't mutate tab content
        var contentToSave = tabs[saveIndex].content
        contentToSave = applyFileSaveSettings(to: contentToSave, filename: tabs[saveIndex].fileName)

        // --- Remote file save ---
        if let remotePath = tabs[saveIndex].remotePath {
            let sftpManager = SFTPManager(sshManager: SSHManager.shared)
            self.activeSFTPManager = sftpManager  // Retain until callback completes
            sftpManager.writeTextFile(remotePath: remotePath, content: contentToSave) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.activeSFTPManager = nil  // Release after callback
                    guard self.tabs.indices.contains(saveIndex) else { return }
                    switch result {
                    case .success:
                        self.tabs[saveIndex].isUnsaved = false
                    case .failure(let error):
                        AppLogger.editor.error("Error saving remote file: \(error)")
                        self.lastErrorMessage = "Failed to save remote file: \(error.localizedDescription)"
                    }
                }
            }
            return
        }

        // --- Local file save ---
        guard let url = tabs[saveIndex].url else { return }

        do {
            if let fileNavigator {
                try fileNavigator.writeFile(at: url, content: contentToSave)
            } else {
                // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
                let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
                defer { if didStart { url.stopAccessingSecurityScopedResource() } }
                try contentToSave.write(to: url, atomically: true, encoding: tabs[saveIndex].stringEncoding)
            }

            tabs[saveIndex].isUnsaved = false

            // Run diagnostics on the saved file
            DiagnosticsService.shared.analyzeFile(
                content: contentToSave,
                filename: tabs[saveIndex].fileName,
                filePath: url.path
            )
        } catch {
            AppLogger.editor.error("Error saving file: \(error)")
            lastErrorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
    
    /// Applies trim whitespace, insert final newline, and format-on-save settings
    private func applyFileSaveSettings(to content: String, filename: String = "") -> String {
        // Read settings directly from UserDefaults to avoid MainActor isolation issues
        let trimWhitespace = UserDefaults.standard.bool(forKey: "trimTrailingWhitespace")
        let insertNewline = UserDefaults.standard.bool(forKey: "insertFinalNewline")
        let formatOnSave = UserDefaults.standard.bool(forKey: "formatOnSave")
        
        var result = content
        
        // Format on save (runs first so whitespace trim applies to formatted output)
        if formatOnSave && !filename.isEmpty {
            let formatted = CodeFormatter.shared.format(code: result, filename: filename)
            if formatted != result { result = formatted }
        }
        
        // Trim trailing whitespace from each line
        if trimWhitespace {
            let lines = result.components(separatedBy: "\n")
            let trimmedLines = lines.map { line in
                var trimmed = line
                while trimmed.hasSuffix(" ") || trimmed.hasSuffix("\t") {
                    trimmed.removeLast()
                }
                return trimmed
            }
            result = trimmedLines.joined(separator: "\n")
        }
        
        // Insert final newline if missing
        if insertNewline {
            if !result.isEmpty && !result.hasSuffix("\n") {
                result.append("\n")
            }
        }
        
        return result
    }

    // MARK: - Encoding & EOL
    
    /// Updates the active tab's file encoding (called from StatusBar when user changes encoding)
    func setActiveTabEncoding(_ encoding: String.Encoding) {
        guard let index = activeTabIndex else { return }
        tabs[index].stringEncoding = encoding
        tabs[index].isUnsaved = true
    }
    
    /// Converts the active tab's line endings to the specified EOL sequence
    func convertActiveTabEOL(to eol: String) {
        guard let index = activeTabIndex else { return }
        var content = tabs[index].content
        // Normalize all line endings first (CRLF -> LF, CR -> LF)
        content = content.replacingOccurrences(of: "\r\n", with: "\n")
        content = content.replacingOccurrences(of: "\r", with: "\n")
        // Then convert to target EOL
        if eol != "\n" {
            content = content.replacingOccurrences(of: "\n", with: eol)
        }
        tabs[index].content = content
        tabs[index].isUnsaved = true
    }

    func saveAllTabs() {
        // Force the editor view to sync any pending text changes immediately
        NotificationCenter.default.post(name: .forceEditorSync, object: nil)

        // Small delay to allow sync to complete before reading content
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for index in self.tabs.indices {
                guard self.tabs[index].url != nil, self.tabs[index].isUnsaved else { continue }
                // Call the existing _performSave to avoid code duplication
                self._performSave(tabId: self.tabs[index].id, index: index)
            }
        }
    }

    // MARK: - File Operations

    /// Retain security scoped access for as long as a tab referencing the URL is open.
    /// - Returns: `true` if access was retained (either already retained or started successfully).
    @discardableResult
    func retainSecurityScopedAccess(to url: URL) -> Bool {
        if let count = securityScopedAccessCounts[url] {
            securityScopedAccessCounts[url] = count + 1
            return true
        }

        let started = url.startAccessingSecurityScopedResource()
        if started {
            securityScopedAccessCounts[url] = 1
            return true
        }

        // Not all URLs are security-scoped; startAccessing may legitimately return false.
        return false
    }

    /// Release a previously retained security-scoped access for the given URL.
    /// Decrements the retain count and calls ``stopAccessingSecurityScopedResource()`` when it reaches 0.
    func releaseSecurityScopedAccess(for url: URL) {
        releaseSecurityScopedAccess(to: url)
    }

    /// Release ALL security-scoped resources. Safe to call multiple times.
    /// Intended for app termination cleanup.
    func releaseAllSecurityScopedAccess() {
        for url in securityScopedAccessCounts.keys {
            url.stopAccessingSecurityScopedResource()
        }
        securityScopedAccessCounts.removeAll()
    }

    private func releaseSecurityScopedAccess(to url: URL) {
        guard let count = securityScopedAccessCounts[url] else { return }
        if count <= 1 {
            securityScopedAccessCounts.removeValue(forKey: url)
            url.stopAccessingSecurityScopedResource()
        } else {
            securityScopedAccessCounts[url] = count - 1
        }
    }

    func openFile(from url: URL) {
        // If already open, just activate it (and avoid re-reading / re-requesting access).
        if let existingTab = tabs.first(where: { $0.url == url }) {
            activeTabId = existingTab.id
            return
        }

        // IMPORTANT (BUG-005):
        // Do not early-return if startAccessingSecurityScopedResource() fails.
        // For many URLs (non-security-scoped, or when parent scope is active), this may return false,
        // but the file is still readable. We retain access if available.
        let retained = retainSecurityScopedAccess(to: url)

        do {
            // Guard against loading extremely large files that could cause OOM on iPadOS
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
            if fileSize > 50_000_000 { // 50MB limit
                lastErrorMessage = "File is too large to open (\(fileSize / 1_000_000)MB). Maximum supported size is 50MB."
                if retained { releaseSecurityScopedAccess(to: url) }
                return
            }
            
            let data = try Data(contentsOf: url)
            guard let result = detectEncodedContent(from: data) else {
                AppLogger.editor.error("Error opening file: unable to decode contents of \(url.lastPathComponent)")
                if retained { releaseSecurityScopedAccess(to: url) }
                return
            }
            let content = result.content
            let encoding = result.encoding

            // Create tab with detected encoding stored
            let newTab = Tab(fileName: url.lastPathComponent, content: content, url: url, fileEncoding: encoding.rawValue)
            tabs.append(newTab)
            activeTabId = newTab.id
            updateLargeFileStatus()

            if encoding != .utf8 {
                AppLogger.editor.info("Opened \(url.lastPathComponent) with encoding \(encoding) (fallback from UTF-8)")
            }

            // Track recently opened file
            Task { @MainActor in RecentFileManager.shared.addRecentFile(url) }

            // Index the file in Spotlight for search
            SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
        } catch {
            AppLogger.editor.error("Error opening file: \(error)")
            if retained {
                // We retained access but failed to open; release our retain.
                releaseSecurityScopedAccess(to: url)
            }
        }
    }

    func openFile(_ fileItem: FileItem) {
        guard let url = fileItem.url else {
            // Try path
            if !fileItem.path.isEmpty {
                let fileURL = URL(fileURLWithPath: fileItem.path)
                openFile(from: fileURL)
            }
            return
        }
        openFile(from: url)
    }

    // MARK: - File System Event Handlers

    /// Called when a file or folder is moved/renamed in the file system.
    /// Updates any open tabs that reference the old URL.
    func handleFileSystemItemMoved(from oldURL: URL, to newURL: URL) {
        for index in tabs.indices {
            guard let tabURL = tabs[index].url else { continue }

            // Check if tab URL matches the moved item or is inside it (for folders)
            let oldPath = oldURL.standardizedFileURL.path
            let tabPath = tabURL.standardizedFileURL.path

            if tabPath == oldPath {
                // Direct match - update URL
                tabs[index].url = newURL
                tabs[index].fileName = newURL.lastPathComponent
            } else if tabPath.hasPrefix(oldPath + "/") {
                // Tab is inside a moved folder - update the path prefix
                let relativePath = String(tabPath.dropFirst(oldPath.count))
                let newTabURL = URL(fileURLWithPath: newURL.path + relativePath)
                tabs[index].url = newTabURL
            }
        }
    }

    /// Called when a file or folder is deleted from the file system.
    /// Closes any open tabs that reference the deleted item.
    func handleFileSystemItemDeleted(at url: URL) {
        let deletedPath = url.standardizedFileURL.path

        // Find all tabs that should be closed
        let tabsToClose = tabs.filter { tab in
            guard let tabURL = tab.url else { return false }
            let tabPath = tabURL.standardizedFileURL.path
            // Close if exact match or if tab is inside deleted folder
            return tabPath == deletedPath || tabPath.hasPrefix(deletedPath + "/")
        }

        // Close the tabs (release security access)
        for tab in tabsToClose {
            closeTab(id: tab.id)
        }
    }

    // MARK: - UI Toggles

    func toggleSidebar() {
        withAnimation(.spring(response: 0.3)) {
            showSidebar.toggle()
        }
    }

    func toggleCommandPalette() {
        showCommandPalette.toggle()
    }

    func toggleQuickOpen() {
        showQuickOpen.toggle()
    }

    func toggleSearch() {
        showSearch.toggle()
    }

    func toggleAIAssistant() {
        showAIAssistant.toggle()
    }

    func toggleGoToSymbol() {
        showGoToSymbol.toggle()
    }

    func toggleZenMode() {
        isZenMode.toggle()
    }

    func toggleFocusMode() {
        isFocusMode.toggle()
    }

    func togglePanel() {
        // Panel visibility is managed by ContentView's showTerminal state
        NotificationCenter.default.post(name: .toggleTerminal, object: nil)
    }

    func addSelectionToNextFindMatch() {
        addNextOccurrence()
    }

    func zoomIn() {
        editorFontSize = min(editorFontSize + 2, 32)
    }

    func zoomOut() {
        editorFontSize = max(editorFontSize - 2, 8)
    }

    func resetZoom() {
        editorFontSize = 14.0
    }

    func focusExplorer() {
        focusedSidebarTab = 0
        withAnimation {
            showSidebar = true
        }
    }

    func focusGit() {
        focusedSidebarTab = 1
        withAnimation {
            showSidebar = true
        }
    }

    // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
    // are implemented in an EditorCore extension in Services/NavigationManager.swift.

    // MARK: - Peek Definition

    func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
        peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
    }

    func closePeekDefinition() {
        peekState = nil
    }

    // MARK: - Find References

    /// Performs a find-references search across all source files in the workspace.
    /// Uses FindReferencesService to search .swift, .js, .ts, .py, .go, .rs files.
    /// Shows results in the sidebar search panel.
    func performFindReferences(symbol: String) {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        AppLogger.editor.info("Find References: searching for '\(trimmed)' across workspace")
        
        // Get workspace root URL from file navigator
        guard let rootURL = fileNavigator?.rootURL else {
            // Fallback: search open tabs only
            AppLogger.editor.warning("Find References: No workspace root, falling back to open tabs")
            searchOpenTabs(for: trimmed)
            return
        }
        
        // Use FindReferencesService to search the entire workspace
        findReferencesService.findReferences(symbol: trimmed, in: rootURL)
        
        // Also set the query so SearchView can show it pre-filled
        findReferencesQuery = trimmed
        focusedSidebarTab = 1
        withAnimation {
            showSidebar = true
        }
    }
    
    /// Fallback: search only open tabs (when no workspace is open)
    private func searchOpenTabs(for symbol: String) {
        var results: [(file: String, line: Int, text: String)] = []
        
        for tab in tabs {
            let lines = tab.content.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                let pattern = "\\b" + NSRegularExpression.escapedPattern(for: symbol) + "\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil {
                    let filePath = tab.url?.path ?? tab.fileName
                    results.append((file: filePath, line: index, text: line.trimmingCharacters(in: .whitespaces)))
                }
            }
        }
        
        AppLogger.editor.info("Find References (tabs): found \(results.count) occurrences")
        
        // Convert to ReferenceLocation and store
        findReferencesResults = results.map { result in
            ReferenceLocation(file: result.file, line: result.line + 1, column: 1, lineText: result.text)
        }
        
        // Open the sidebar search panel
        findReferencesQuery = symbol
        focusedSidebarTab = 1
        withAnimation {
            showSidebar = true
        }
    }
    
    /// Cancel any in-flight find references search
    func cancelFindReferences() {
        findReferencesService.cancelSearch()
    }
    
    /// Clear find references results
    func clearFindReferencesResults() {
        findReferencesResults = []
        findReferencesService.clearResults()
    }
    
    /// Get current find references results
    var findReferencesCurrentResults: [ReferenceLocation] {
        findReferencesService.results
    }
    
    /// Check if find references is currently searching
    var isFindReferencesSearching: Bool {
        findReferencesService.isSearching
    }
    
    /// Get find references search progress (0.0 - 1.0)
    var findReferencesProgress: Double {
        findReferencesService.progress
    }
    
    /// Get find references last error
    var findReferencesError: String? {
        findReferencesService.lastError
    }
    
    // MARK: - Find References (Legacy)
    
    /// Legacy method kept for compatibility
    func performFindReferencesLegacy(symbol: String) {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        AppLogger.editor.info("Find References: searching for '\(trimmed)' across \(self.tabs.count) open tabs")
        
        // Collect results from all open tabs that have a valid file URL
        var results: [(file: String, line: Int, text: String)] = []
        
        for tab in tabs {
            let lines = tab.content.components(separatedBy: .newlines)
            for (index, line) in lines.enumerated() {
                // Use regex to match whole-word occurrences
                let pattern = "\\b" + NSRegularExpression.escapedPattern(for: trimmed) + "\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                   regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil {
                    let filePath = tab.url?.path ?? tab.fileName
                    results.append((file: filePath, line: index, text: line.trimmingCharacters(in: .whitespaces)))
                }
            }
        }
        
        AppLogger.editor.info("Find References: found \(results.count) occurrences of '\(trimmed)'")
        
        // Log results for debugging
        for result in results {
            AppLogger.editor.debug("  -> \(result.file):\(result.line + 1): \(result.text)")
        }
        
        // Open the sidebar search panel and set the query
        // focusedSidebarTab = 1 is the Search tab
        findReferencesQuery = trimmed
        focusedSidebarTab = 1
        withAnimation {
            showSidebar = true
        }
    }

    // MARK: - Multi-Cursor Operations

    /// Add cursor at a specific position (Option+Click)
    func addCursorAtPosition(_ position: Int) {
        multiCursorState.addCursor(at: position)
    }

    /// Add cursor on the line above (Cmd+Option+Up)
    func addCursorAbove() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        
        guard let primary = multiCursorState.primaryCursor else { return }
        
        // Find current line and column
        let lines = content.components(separatedBy: "\n")
        var currentLine = 0
        var charCount = 0
        var columnInLine = 0
        
        for (lineIndex, line) in lines.enumerated() {
            let lineLength = line.count + 1 // +1 for newline
            if charCount + lineLength > primary.position {
                currentLine = lineIndex
                columnInLine = primary.position - charCount
                break
            }
            charCount += lineLength
        }
        
        // Can't add cursor above line 0
        guard currentLine > 0 else { return }
        
        // Calculate position on line above
        let targetLine = currentLine - 1
        var targetPosition = 0
        for i in 0..<targetLine {
            targetPosition += lines[i].count + 1
        }
        targetPosition += min(columnInLine, lines[targetLine].count)
        
        multiCursorState.addCursor(at: targetPosition)
    }

    /// Add cursor on the line below (Cmd+Option+Down)
    func addCursorBelow() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        
        guard let primary = multiCursorState.primaryCursor else { return }
        
        // Find current line and column
        let lines = content.components(separatedBy: "\n")
        var currentLine = 0
        var charCount = 0
        var columnInLine = 0
        
        for (lineIndex, line) in lines.enumerated() {
            let lineLength = line.count + 1 // +1 for newline
            if charCount + lineLength > primary.position {
                currentLine = lineIndex
                columnInLine = primary.position - charCount
                break
            }
            charCount += lineLength
        }
        
        // Can't add cursor below last line
        guard currentLine < lines.count - 1 else { return }
        
        // Calculate position on line below
        let targetLine = currentLine + 1
        var targetPosition = 0
        for i in 0..<targetLine {
            targetPosition += lines[i].count + 1
        }
        targetPosition += min(columnInLine, lines[targetLine].count)
        
        multiCursorState.addCursor(at: targetPosition)
    }

    /// Add next occurrence of current selection (Cmd+D)
    func addNextOccurrence() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content

        // Get the word/selection to search for
        let searchText: String
        let startPosition: Int

        if let range = currentSelectionRange, range.length > 0,
           let swiftRange = Range(range, in: content) {
            searchText = String(content[swiftRange])
            startPosition = range.location + range.length
        } else if let primary = multiCursorState.primaryCursor {
            // No selection - select the word under cursor
            let wordRange = findWordAtPosition(primary.position, in: content)
            if let range = wordRange, range.length > 0,
               let swiftRange = Range(range, in: content) {
                searchText = String(content[swiftRange])
                startPosition = range.location + range.length

                // First Cmd+D selects the word under cursor
                multiCursorState.cursors = [Cursor(position: range.location + range.length, anchor: range.location, isPrimary: true)]
                currentSelectionRange = range
                currentSelection = searchText
                return
            } else {
                return
            }
        } else {
            return
        }

        // Find next occurrence
        if let nextRange = content.findNextOccurrence(of: searchText, after: startPosition) {
            // Check if this occurrence is already selected
            let alreadySelected = multiCursorState.cursors.contains { cursor in
                if let selRange = cursor.selectionRange {
                    return selRange.location == nextRange.location
                }
                return false
            }

            if !alreadySelected {
                multiCursorState.addCursorWithSelection(
                    position: nextRange.location + nextRange.length,
                    anchor: nextRange.location
                )
            }
        }
    }

    /// Select all occurrences of current selection (Cmd+Shift+L)
    func selectAllOccurrences() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content

        // Get the word/selection to search for
        let searchText: String

        if let range = currentSelectionRange, range.length > 0,
           let swiftRange = Range(range, in: content) {
            searchText = String(content[swiftRange])
        } else if let primary = multiCursorState.primaryCursor {
            // No selection - use word under cursor
            let wordRange = findWordAtPosition(primary.position, in: content)
            if let range = wordRange, range.length > 0,
               let swiftRange = Range(range, in: content) {
                searchText = String(content[swiftRange])
            } else {
                return
            }
        } else {
            return
        }

        // Find all occurrences
        let allRanges = content.findAllOccurrences(of: searchText)

        guard !allRanges.isEmpty else { return }

        // Create cursors for all occurrences
        multiCursorState.cursors = allRanges.enumerated().map { index, range in
            Cursor(
                position: range.location + range.length,
                anchor: range.location,
                isPrimary: index == 0
            )
        }

        currentSelection = searchText
    }

    /// Reset to single cursor
    func resetToSingleCursor(at position: Int) {
        multiCursorState.reset(to: position)
        currentSelectionRange = nil
        currentSelection = ""
    }

    /// Update selection from text view
    func updateSelection(range: NSRange?, text: String) {
        currentSelectionRange = range
        if let range = range, range.length > 0,
           let index = activeTabIndex {
            let content = tabs[index].content
            if let swiftRange = Range(range, in: content) {
                currentSelection = String(content[swiftRange])
            }
        } else {
            currentSelection = ""
        }
    }

    /// Find word boundaries at a given position
    func findWordAtPosition(_ position: Int, in text: String) -> NSRange? {
        let nsText = text as NSString
        // Use nsText.length (UTF-16) consistently since we work with NSRange
        guard position >= 0, position <= nsText.length else { return nil }

        let wordCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))

        // Find start of word
        var start = position
        while start > 0 {
            let char = nsText.substring(with: NSRange(location: start - 1, length: 1))
            if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
                start -= 1
            } else {
                break
            }
        }

        // Find end of word
        var end = position
        while end < nsText.length {
            let char = nsText.substring(with: NSRange(location: end, length: 1))
            if char.unicodeScalars.allSatisfy({ wordCharacters.contains($0) }) {
                end += 1
            } else {
                break
            }
        }

        guard start < end else { return nil }
        return NSRange(location: start, length: end - start)
    }

    /// Escape multi-cursor mode
    func escapeMultiCursor() {
        if multiCursorState.isMultiCursor {
            if let primary = multiCursorState.primaryCursor {
                resetToSingleCursor(at: primary.position)
            }
        }
    }

    /// Returns (prefix, suffix) for block comment languages, nil for line comments
    private func blockCommentWrappers(for fileName: String) -> (prefix: String, suffix: String)? {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "html", "htm", "xml", "svg":
            return ("<!-- ", " -->")
        case "css", "scss", "less":
            return ("/* ", " */")
        default:
            return nil
        }
    }

    // MARK: - Text Editing Actions

    /// Get comment prefix for a given filename extension
    private func commentPrefix(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        switch ext {
        case "py", "pyw", "rb", "sh", "bash", "zsh", "fish",
             "yaml", "yml", "toml", "r", "pl", "pm",
             "dockerfile", "makefile", "mk":
            return "#"
        case "lua", "sql", "hs":
            return "--"
        case "html", "xml", "svg":
            return "<!--"
        case "css", "scss", "less":
            return "/*"
        case "bat", "cmd":
            return "REM"
        case "vim":
            return "\""
        case "lisp", "clj", "cljs", "el":
            return ";"
        default:
            return "//"
        }
    }

    /// Find line index and line start/end character offsets for a given cursor position
    private func lineInfo(for position: Int, in lines: [String]) -> (lineIndex: Int, lineStart: Int, lineEnd: Int) {
        var charCount = 0
        for (i, line) in lines.enumerated() {
            let lineEnd = charCount + line.count
            if position <= lineEnd || i == lines.count - 1 {
                return (i, charCount, lineEnd)
            }
            charCount += line.count + 1 // +1 for newline
        }
        return (0, 0, 0)
    }

    /// Toggle line comment (Cmd+/)
    func toggleComment() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        let fileName = tabs[index].fileName
        var lines = content.components(separatedBy: "\n")

        // Block comment languages use wrapping instead of line prefix
        if let (blockPrefix, blockSuffix) = blockCommentWrappers(for: fileName) {
            toggleBlockComment(index: index, lines: &lines, prefix: blockPrefix, suffix: blockSuffix)
            return
        }
        
        let prefix = commentPrefix(for: fileName)

        // Determine which lines to toggle
        let startLine: Int
        let endLine: Int

        if let range = currentSelectionRange, range.length > 0 {
            let info1 = lineInfo(for: range.location, in: lines)
            let info2 = lineInfo(for: range.location + range.length, in: lines)
            startLine = info1.lineIndex
            endLine = info2.lineIndex
        } else if let primary = multiCursorState.primaryCursor {
            let info = lineInfo(for: primary.position, in: lines)
            startLine = info.lineIndex
            endLine = info.lineIndex
        } else {
            return
        }

        guard startLine <= endLine, endLine < lines.count else { return }

        // Check if all lines already have the comment prefix
        let allCommented = (startLine...endLine).allSatisfy { i in
            lines[i].trimmingCharacters(in: .whitespaces).hasPrefix(prefix)
        }

        for i in startLine...endLine {
            if allCommented {
                // Remove comment
                let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix(prefix) {
                    if let prefixRange = lines[i].range(of: prefix + " ") {
                        lines[i].removeSubrange(prefixRange)
                    } else if let prefixRange = lines[i].range(of: prefix) {
                        lines[i].removeSubrange(prefixRange)
                    }
                }
            } else {
                // Add comment - find leading whitespace and insert after it
                let leadingWhitespace = String(lines[i].prefix(while: { $0 == " " || $0 == "\t" }))
                let rest = String(lines[i].dropFirst(leadingWhitespace.count))
                lines[i] = leadingWhitespace + prefix + " " + rest
            }
        }

        tabs[index].content = lines.joined(separator: "\n")
    }

    /// Toggle block comment (<!-- --> or /* */) for HTML/CSS/XML files
    private func toggleBlockComment(index: Int, lines: inout [String], prefix: String, suffix: String) {
        guard !lines.isEmpty else { return }
        
        // Determine which lines to toggle
        let startLine: Int
        let endLine: Int

        if let range = currentSelectionRange, range.length > 0 {
            let info1 = lineInfo(for: range.location, in: lines)
            let info2 = lineInfo(for: range.location + range.length, in: lines)
            startLine = info1.lineIndex
            endLine = info2.lineIndex
        } else if let primary = multiCursorState.primaryCursor {
            let info = lineInfo(for: primary.position, in: lines)
            startLine = info.lineIndex
            endLine = info.lineIndex
        } else {
            return
        }

        guard startLine <= endLine, endLine < lines.count else { return }

        // Find first and last non-empty lines in range
        let rangeLines = Array(startLine...endLine)
        guard let firstIdx = rangeLines.first(where: { !lines[$0].trimmingCharacters(in: .whitespaces).isEmpty }),
              let lastIdx = rangeLines.last(where: { !lines[$0].trimmingCharacters(in: .whitespaces).isEmpty }) else { return }

        let firstTrimmed = lines[firstIdx].trimmingCharacters(in: .whitespaces)
        let lastTrimmed = lines[lastIdx].trimmingCharacters(in: .whitespaces)
        let isCommented = firstTrimmed.hasPrefix(prefix) && lastTrimmed.hasSuffix(suffix)

        if isCommented {
            // Uncomment: remove prefix from first non-empty line, suffix from last non-empty line
            if let range = lines[firstIdx].range(of: prefix) {
                lines[firstIdx].removeSubrange(range)
            }
            if lastIdx != firstIdx {
                if let range = lines[lastIdx].range(of: suffix, options: .backwards) {
                    lines[lastIdx].removeSubrange(range)
                }
            }
        } else {
            // Comment: wrap with block comment markers
            let firstWS = String(lines[firstIdx].prefix(while: { $0 == " " || $0 == "\t" }))
            lines[firstIdx] = firstWS + prefix + String(lines[firstIdx].dropFirst(firstWS.count))

            let lastWS = String(lines[lastIdx].prefix(while: { $0 == " " || $0 == "\t" }))
            lines[lastIdx] = lastWS + String(lines[lastIdx].dropFirst(lastWS.count)) + suffix
        }

        tabs[index].content = lines.joined(separator: "\n")
    }

    /// Delete current line (Cmd+Shift+K)
    func deleteLine() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        var lines = content.components(separatedBy: "\n")
        guard !lines.isEmpty else { return }

        let cursorPos = multiCursorState.primaryCursor?.position ?? 0
        let info = lineInfo(for: cursorPos, in: lines)
        let lineIdx = info.lineIndex

        guard lineIdx < lines.count else { return }
        lines.remove(at: lineIdx)

        if lines.isEmpty {
            lines = [""]
        }

        tabs[index].content = lines.joined(separator: "\n")

        // Adjust cursor to stay at same position (clamped)
        let newPos = min(info.lineStart, tabs[index].content.count)
        multiCursorState.reset(to: newPos)
    }

    /// Move current line up (Alt+Up)
    func moveLineUp() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        var lines = content.components(separatedBy: "\n")

        let cursorPos = multiCursorState.primaryCursor?.position ?? 0
        let info = lineInfo(for: cursorPos, in: lines)
        let lineIdx = info.lineIndex

        guard lineIdx > 0, lineIdx < lines.count else { return }

        lines.swapAt(lineIdx, lineIdx - 1)
        tabs[index].content = lines.joined(separator: "\n")

        // Move cursor to the new line position
        let offsetInLine = cursorPos - info.lineStart
        var newLineStart = 0
        for i in 0..<(lineIdx - 1) {
            newLineStart += lines[i].count + 1
        }
        multiCursorState.reset(to: newLineStart + min(offsetInLine, lines[lineIdx - 1].count))
    }

    /// Move current line down (Alt+Down)
    func moveLineDown() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        var lines = content.components(separatedBy: "\n")

        let cursorPos = multiCursorState.primaryCursor?.position ?? 0
        let info = lineInfo(for: cursorPos, in: lines)
        let lineIdx = info.lineIndex

        guard lineIdx < lines.count - 1 else { return }

        lines.swapAt(lineIdx, lineIdx + 1)
        tabs[index].content = lines.joined(separator: "\n")

        // Move cursor to the new line position
        let offsetInLine = cursorPos - info.lineStart
        var newLineStart = 0
        for i in 0..<(lineIdx + 1) {
            newLineStart += lines[i].count + 1
        }
        guard lineIdx + 1 < lines.count else { return }
        multiCursorState.reset(to: newLineStart + min(offsetInLine, lines[lineIdx + 1].count))
    }

    /// Duplicate current line upward (Shift+Alt+Up)
    func duplicateLineUp() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        var lines = content.components(separatedBy: "\n")

        let cursorPos = multiCursorState.primaryCursor?.position ?? 0
        let info = lineInfo(for: cursorPos, in: lines)
        let lineIdx = info.lineIndex

        guard lineIdx < lines.count else { return }

        let duplicatedLine = lines[lineIdx]
        lines.insert(duplicatedLine, at: lineIdx)
        tabs[index].content = lines.joined(separator: "\n")

        // Cursor stays on the original (now moved down) line position
    }

    /// Duplicate current line downward (Shift+Alt+Down)
    func duplicateLineDown() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        var lines = content.components(separatedBy: "\n")

        let cursorPos = multiCursorState.primaryCursor?.position ?? 0
        let info = lineInfo(for: cursorPos, in: lines)
        let lineIdx = info.lineIndex

        guard lineIdx < lines.count else { return }

        let duplicatedLine = lines[lineIdx]
        lines.insert(duplicatedLine, at: lineIdx + 1)
        tabs[index].content = lines.joined(separator: "\n")

        // Move cursor to the duplicated line below
        let offsetInLine = cursorPos - info.lineStart
        var newLineStart = 0
        for i in 0..<(lineIdx + 1) {
            newLineStart += lines[i].count + 1
        }
        multiCursorState.reset(to: newLineStart + min(offsetInLine, duplicatedLine.count))
    }

    // MARK: - Code Folding

    /// Collapse all foldable regions in the active editor
    func collapseAllFolds() {
        guard let index = activeTabIndex else { return }
        // Post notification that will be picked up by the editor view
        NotificationCenter.default.post(
            name: .collapseAllFolds,
            object: nil,
            userInfo: ["tabId": tabs[index].id]
        )
    }

    /// Expand all collapsed regions in the active editor
    func expandAllFolds() {
        guard let index = activeTabIndex else { return }
        // Post notification that will be picked up by the editor view
        NotificationCenter.default.post(
            name: .expandAllFolds,
            object: nil,
            userInfo: ["tabId": tabs[index].id]
        )
    }

    /// Format the active document using CodeFormatter
    func formatDocument() {
        guard let index = activeTabIndex else { return }
        let content = tabs[index].content
        let filename = tabs[index].fileName
        guard !content.isEmpty else { return }
        
        let formatted = CodeFormatter.shared.format(code: content, filename: filename)
        guard formatted != content else { return }
        
        tabs[index].content = formatted
        objectWillChange.send()
        
        // Also post notification so the active editor view updates
        NotificationCenter.default.post(name: .formatDocument, object: nil)
    }
}

// MARK: - Workspace Persistence

extension EditorCore {
    /// Save workspace bookmark so it can be restored after crash/relaunch
    func saveWorkspaceBookmark(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: Self.lastWorkspaceBookmarkKey)
        } catch {
            AppLogger.editor.error("Failed to save workspace bookmark: \(error)")
        }
    }
    
    /// Restore saved workspace URL from bookmark
    func restoreWorkspaceURL() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: Self.lastWorkspaceBookmarkKey) else {
            return nil
        }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
            if isStale {
                // Re-save fresh bookmark
                saveWorkspaceBookmark(url)
            }
            return url
        } catch {
            AppLogger.editor.error("Failed to restore workspace bookmark: \(error)")
            UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceBookmarkKey)
            return nil
        }
    }
    
    /// Save current open tab paths for restoration
    /// Uses relative paths from workspace root to handle duplicate filenames in different directories
    func saveOpenTabPaths() {
        let workspaceURL = restoreWorkspaceURL()
        let paths: [String] = tabs.compactMap { tab in
            guard let url = tab.url else { return nil }
            if let workspace = workspaceURL {
                // Save relative path from workspace root
                let workspacePath = workspace.path.hasSuffix("/") ? workspace.path : workspace.path + "/"
                if url.path.hasPrefix(workspacePath) {
                    return String(url.path.dropFirst(workspacePath.count))
                }
            }
            // Fallback to filename only
            return url.lastPathComponent
        }
        UserDefaults.standard.set(paths, forKey: Self.lastOpenTabPathsKey)
        if let activeTab = activeTab, let url = activeTab.url {
            if let workspace = workspaceURL {
                let workspacePath = workspace.path.hasSuffix("/") ? workspace.path : workspace.path + "/"
                if url.path.hasPrefix(workspacePath) {
                    UserDefaults.standard.set(String(url.path.dropFirst(workspacePath.count)), forKey: Self.lastActiveTabPathKey)
                    return
                }
            }
            UserDefaults.standard.set(url.lastPathComponent, forKey: Self.lastActiveTabPathKey)
        }
    }
    
    /// Restore tabs from saved paths relative to workspace root
    func restoreOpenTabs(workspaceURL: URL) {
        guard let savedPaths = UserDefaults.standard.stringArray(forKey: Self.lastOpenTabPathsKey),
              !savedPaths.isEmpty else { return }
        
        let activeTabPath = UserDefaults.standard.string(forKey: Self.lastActiveTabPathKey)
        
        // Try to resolve each saved path relative to workspace
        for path in savedPaths {
            let fileURL = workspaceURL.appendingPathComponent(path)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL),
                   let result = self.detectEncodedContent(from: data) {
                    let tab = Tab(
                        fileName: fileURL.lastPathComponent,
                        content: result.content,
                        url: fileURL,
                        fileEncoding: result.encoding.rawValue
                    )
                    tabs.append(tab)

                    // Track recently opened file
                    Task { @MainActor in RecentFileManager.shared.addRecentFile(fileURL) }

                    if path == activeTabPath {
                        activeTabId = tab.id
                    }
                }
            }
        }
        
        // Set first tab active if no match
        if activeTabId == nil, let first = tabs.first {
            activeTabId = first.id
        }
        updateLargeFileStatus()
    }
    
    /// Clear saved workspace state
    func clearWorkspaceState() {
        UserDefaults.standard.removeObject(forKey: Self.lastWorkspaceBookmarkKey)
        UserDefaults.standard.removeObject(forKey: Self.lastOpenTabPathsKey)
        UserDefaults.standard.removeObject(forKey: Self.lastActiveTabPathKey)
        restoredWorkspace = false
    }
}

// MARK: - Notification Names for Code Folding

// Notification names (collapseAllFolds, expandAllFolds) defined in Notification+Names.swift
