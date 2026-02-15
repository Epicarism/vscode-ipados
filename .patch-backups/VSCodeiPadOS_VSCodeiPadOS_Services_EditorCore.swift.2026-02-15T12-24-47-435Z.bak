import UniformTypeIdentifiers
import SwiftUI

// MARK: - Navigation Location
struct NavigationLocation {
    let tabId: UUID
    let line: Int
    let column: Int
}

// MARK: - Sidebar Panel (renamed from SidebarView to avoid conflict with SidebarView struct in Views)
enum SidebarPanel {
    case explorer
    case git
    case search
    case extensions
}

// MARK: - Terminal Session Stub
struct TerminalSession: Identifiable {
    let id: UUID
    var title: String
    var output: String
    
    init(id: UUID = UUID(), title: String = "Terminal", output: String = "") {
        self.id = id
        self.title = title
        self.output = output
    }
}

// MARK: - Debug State Stubs
struct DebugSessionState {
    var isPaused: Bool = false
    var currentLine: Int?
    var currentFile: String?
    var callStack: [String] = []
    var variables: [String: String] = [:]
}

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

// MARK: - Editor Core (Central State Manager)
class EditorCore: ObservableObject {
    @Published var peekState: PeekState?
    @Published var tabs: [Tab] = []
    @Published var activeTabId: UUID?
    @Published var showSidebar = true
    @Published var sidebarWidth: CGFloat = 250
    @Published var showFilePicker = false
    @Published var searchText = ""
    @Published var showSearch = false
    @Published var showCommandPalette = false
    @Published var showQuickOpen = false
    @Published var showAIAssistant = false
    @Published var showGoToLine = false
    @Published var showGoToSymbol = false
    @Published var editorFontSize: CGFloat = 14.0
    @Published var isZenMode = false
    @Published var isFocusMode = false

    // Snippet picker support
    @Published var showSnippetPicker = false
    @Published var pendingSnippetInsertion: Snippet?

    // Cursor tracking
    @Published var cursorPosition = CursorPosition()

    // Multi-cursor support
    @Published var multiCursorState = MultiCursorState()
    @Published var currentSelection: String = ""
    @Published var currentSelectionRange: NSRange?

    // Selection request for find/replace navigation
    @Published var requestedSelection: NSRange?

    // UI Panel state
    @Published var showPanel = false
    @Published var showRenameSymbol = false
    @Published var focusedSidebarTab = 0

    // Terminal state
    @Published var terminalSessions: [TerminalSession] = []
    @Published var activeTerminalId: UUID?
    @Published var isTerminalMaximized: Bool = false
    @Published var terminalPanelHeight: CGFloat = 200

    // Debug state
    @Published var isDebugging: Bool = false
    @Published var isRunning: Bool = false
    @Published var canStartDebugging: Bool = true
    @Published var showAddConfiguration: Bool = false
    @Published var debugSessionState: DebugSessionState?
    @Published var breakpoints: [DebugBreakpoint] = []

    // Focused sidebar panel
    @Published var focusedView: SidebarPanel = .explorer

    // Reference to file navigator for workspace search
    weak var fileNavigator: FileSystemNavigator?

    // Navigation history
    private var navigationHistory: [NavigationLocation] = []
    private var navigationIndex = -1

    /// Track active security-scoped URL access while files are open in tabs.
    /// This avoids losing access after opening a document (common on iPadOS).
    private var securityScopedAccessCounts: [URL: Int] = [:]

    var activeTab: Tab? {
        tabs.first { $0.id == activeTabId }
    }

    var activeTabIndex: Int? {
        tabs.firstIndex { $0.id == activeTabId }
    }

    init() {
        // Create example tabs for all supported languages
        let exampleTabs = Self.createExampleTabs()
        tabs.append(contentsOf: exampleTabs)
        activeTabId = exampleTabs.first?.id ?? UUID()
    }
    
    /// Creates example tabs demonstrating syntax highlighting for all supported languages
    private static func createExampleTabs() -> [Tab] {
        var examples: [Tab] = []
        
        // Swift example
        examples.append(Tab(
            fileName: "Welcome.swift",
            content: """
// Welcome to VS Code for iPadOS! 🎉
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
    <title>VS Code for iPadOS</title>
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

    // MARK: - Tab Management

    func addTab(fileName: String = "Untitled.swift", content: String = "", url: URL? = nil) {
        // Check if file is already open
        if let url = url, let existingTab = tabs.first(where: { $0.url == url }) {
            activeTabId = existingTab.id
            return
        }

        let newTab = Tab(fileName: fileName, content: content, url: url)
        tabs.append(newTab)
        activeTabId = newTab.id
    }

    func closeTab(id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }

        // Release security-scoped access if this tab was holding it.
        if let url = tabs[index].url {
            releaseSecurityScopedAccess(to: url)
        }

        tabs.remove(at: index)

        // Update active tab if we closed the active one
        if activeTabId == id {
            if tabs.isEmpty {
                activeTabId = nil
            } else if index >= tabs.count {
                activeTabId = tabs[tabs.count - 1].id
            } else {
                activeTabId = tabs[index].id
            }
        }
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
        // Release security-scoped access for tabs being closed.
        for tab in tabs where tab.id != id {
            if let url = tab.url {
                releaseSecurityScopedAccess(to: url)
            }
        }

        tabs.removeAll { $0.id != id }
        activeTabId = id
    }

    func selectTab(id: UUID) {
        activeTabId = id
    }

    func nextTab() {
        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
        let nextIndex = (currentIndex + 1) % tabs.count
        activeTabId = tabs[nextIndex].id
    }

    func previousTab() {
        guard let currentIndex = activeTabIndex, tabs.count > 1 else { return }
        let prevIndex = currentIndex == 0 ? tabs.count - 1 : currentIndex - 1
        activeTabId = tabs[prevIndex].id
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
    }

    func saveActiveTab() {
        guard let index = activeTabIndex,
              let url = tabs[index].url else { return }

        do {
            if let fileNavigator {
                try fileNavigator.writeFile(at: url, content: tabs[index].content)
            } else {
                // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
                let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
                defer { if didStart { url.stopAccessingSecurityScopedResource() } }
                try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
            }

            tabs[index].isUnsaved = false
        } catch {
            print("Error saving file: \(error)")
        }
    }

    func saveAllTabs() {
        for index in tabs.indices {
            guard let url = tabs[index].url, tabs[index].isUnsaved else { continue }

            do {
                if let fileNavigator {
                    try fileNavigator.writeFile(at: url, content: tabs[index].content)
                } else {
                    // Fallback: Ensure we have access when writing, even if this URL wasn't opened via openFile().
                    let didStart = (securityScopedAccessCounts[url] == nil) ? url.startAccessingSecurityScopedResource() : false
                    defer { if didStart { url.stopAccessingSecurityScopedResource() } }
                    try tabs[index].content.write(to: url, atomically: true, encoding: .utf8)
                }

                tabs[index].isUnsaved = false
            } catch {
                print("Error saving file: \(error)")
            }
        }
    }

    // MARK: - File Operations

    /// Retain security scoped access for as long as a tab referencing the URL is open.
    /// - Returns: `true` if access was retained (either already retained or started successfully).
    @discardableResult
    private func retainSecurityScopedAccess(to url: URL) -> Bool {
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
            let content = try String(contentsOf: url, encoding: .utf8)
            addTab(fileName: url.lastPathComponent, content: content, url: url)

            // Index the file in Spotlight for search
            SpotlightManager.shared.indexFile(url: url, content: content, fileName: url.lastPathComponent)
        } catch {
            print("Error opening file: \(error)")
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
        withAnimation(.spring(response: 0.3)) {
            showPanel.toggle()
        }
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
        focusedView = .explorer
        focusedSidebarTab = 0
        withAnimation {
            showSidebar = true
        }
    }

    func focusGit() {
        focusedView = .git
        focusedSidebarTab = 1
        withAnimation {
            showSidebar = true
        }
    }

    func renameSymbol() {
        showRenameSymbol.toggle()
    }

    // NOTE:
    // goToDefinitionAtCursor(), peekDefinitionAtCursor(), navigateBack(), and navigateForward()
    // are implemented in an EditorCore extension in Services/NavigationManager.swift.

    // MARK: - Peek Definition

    func triggerPeekDefinition(file: String, line: Int, content: String, sourceLine: Int) {
        peekState = PeekState(file: file, line: line, content: content, sourceLine: sourceLine)
    }

    func closePeekDefinition() {
        peekState = nil
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
        guard position >= 0 && position <= text.count else { return nil }

        let nsText = text as NSString
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

        if start == end {
            return nil
        }

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
}

// MARK: - Notification Names for Code Folding

extension Notification.Name {
    static let collapseAllFolds = Notification.Name("collapseAllFolds")
    static let expandAllFolds = Notification.Name("expandAllFolds")
}
