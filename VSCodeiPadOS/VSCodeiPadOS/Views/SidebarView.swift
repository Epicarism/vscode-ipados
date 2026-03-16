import SwiftUI

// MARK: - Sidebar View Structure

struct SidebarView: View {
    @ObservedObject var editorCore: EditorCore
    @ObservedObject var fileNavigator: FileSystemNavigator
    @Binding var selectedTab: Int
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    @Binding var showFolderPicker: Bool
    var theme: Theme = ThemeManager.shared.currentTheme
    @State private var showCommitAlert: Bool = false
    @State private var commitMessage: String = ""
    
    var body: some View {
        HStack(spacing: 0) {
            // 1. Activity Bar (Far Left)
            IDEActivityBar(
                editorCore: editorCore,
                selectedTab: $selectedTab,
                showSettings: $showSettings,
                showTerminal: $showTerminal
            )
            
            // 2. Sidebar Panel (Resizable)
            if editorCore.showSidebar {
                ZStack(alignment: .trailing) {
                    VStack(spacing: 0) {
                        // Header Area
                        HStack {
                            Text(sidebarTitle)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .accessibilityLabel("Sidebar: \(sidebarTitle)")
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityIdentifier("sidebar.header.title")
                            Spacer()
                            sidebarHeaderActions
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        
                        Divider()
                            .background(Color(UIColor.separator))
                        
                        // Content Area
                        sidebarContent
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: editorCore.sidebarWidth)
                    .background(Color(UIColor.secondarySystemBackground)) // Theme aware
                    .accessibilityLabel("Sidebar panel")
                    .accessibilityIdentifier("sidebar.panel")
                    
                    // 5. Resize Handle
                    ResizeHandle(width: $editorCore.sidebarWidth)
                }
            }
        }
        .alert("Commit Changes", isPresented: $showCommitAlert) {
            TextField("Commit message", text: $commitMessage)
            Button("Commit", role: nil) {
                guard !commitMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                Task { try? await GitManager.shared.commit(message: commitMessage) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a message for this commit.")
        }
    }

    // Dynamic Title based on selection
    private var sidebarTitle: String {
        switch selectedTab {
        case 0: return "EXPLORER"
        case 1: return "SEARCH"
        case 2: return "SOURCE CONTROL"
        case 3: return "RUN AND DEBUG"
        case 4: return "REMOTE EXPLORER"
        case 5: return "EXTENSIONS"
        case 6: return "TESTING"
        default: return "EXPLORER"
        }
    }
    
    // Header Actions
    @ViewBuilder
    private var sidebarHeaderActions: some View {
        if selectedTab == 0 {
            HStack(spacing: 12) {
                Button(action: { showFolderPicker = true }) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Open Folder")
                .accessibilityHint("Double tap to open a folder")
                .help("Open Folder")
                
                Button(action: { editorCore.addTab() }) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("New File")
                .accessibilityHint("Double tap to create a new file")
                .help("New File")
                
                Button(action: { fileNavigator.refreshFileTree() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Refresh File Tree")
                .accessibilityHint("Double tap to refresh the file tree")
                .help("Refresh")
                
                Button(action: { 
                     // Collapse All Action 
                     fileNavigator.expandedPaths.removeAll()
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right") // Collapse icon
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Collapse All Folders")
                .accessibilityHint("Double tap to collapse all expanded folders")
                .help("Collapse All Folders")
            }
        } else if selectedTab == 2 {
            HStack(spacing: 12) {
                Button(action: {
                    Task { await GitManager.shared.refresh() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Refresh Source Control")
                .accessibilityHint("Double tap to refresh git status")
                .help("Refresh")

                Button(action: {
                    commitMessage = ""
                    showCommitAlert = true
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Commit Changes")
                .accessibilityHint("Double tap to commit staged changes")
                .help("Commit")

                Menu {
                    Button(action: {
                        Task { try? await GitManager.shared.pull() }
                    }) {
                        Label("Pull", systemImage: "arrow.down.circle")
                    }
                    Button(action: {
                        Task { try? await GitManager.shared.push() }
                    }) {
                        Label("Push", systemImage: "arrow.up.circle")
                    }
                    Divider()
                    Button(action: {
                        Task { try? await GitManager.shared.stashPush(message: nil) }
                    }) {
                        Label("Stash", systemImage: "tray.and.arrow.down")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("More Source Control Actions")
                .accessibilityHint("Double tap to see pull, push, and stash options")
                .help("More Actions...")
            }
        }
    }

    // Content Switching
    @ViewBuilder
    private var sidebarContent: some View {
        switch selectedTab {
        case 0:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showFolderPicker, theme: theme)
        case 1:
            if let rootURL = fileNavigator.rootURL {
                SearchView(
                    onResultSelected: { filePath, lineNumber in
                        if let url = URL(string: "file://" + filePath) {
                            editorCore.openFile(from: url)
                            editorCore.requestedGoToLine = lineNumber
                        }
                    },
                    rootURL: rootURL
                )
            } else {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "folder.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(theme.sidebarForeground.opacity(0.3))
                    Text("Open a folder to search")
                        .font(.caption)
                        .foregroundColor(theme.sidebarForeground.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(theme.sidebarBackground)
            }
        case 2:
            GitView()
        case 3:
            DebugView()
        case 4:
            RemoteExplorerView(editorCore: editorCore)
        case 5:
            ExtensionsPanel()
        case 6:
            TestView()
        default:
            IDESidebarFiles(editorCore: editorCore, fileNavigator: fileNavigator, showFolderPicker: $showFolderPicker, theme: theme)
        }
    }
}

// MARK: - Activity Bar Implementation

struct IDEActivityBar: View {
    @ObservedObject var editorCore: EditorCore
    @Binding var selectedTab: Int
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Group
            Group {
                ActivityBarIcon(icon: "doc.on.doc", title: "Explorer", index: 0, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.explorer")
                ActivityBarIcon(icon: "magnifyingglass", title: "Search", index: 1, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.search")
                ActivityBarIcon(icon: "arrow.triangle.branch", title: "Source Control", index: 2, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.sourceControl")
                ActivityBarIcon(icon: "play.fill", title: "Run and Debug", index: 3, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.runAndDebug")
                ActivityBarIcon(icon: "server.rack", title: "Remote Explorer", index: 4, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.remoteExplorer")
                ActivityBarIcon(icon: "square.grid.2x2", title: "Extensions", index: 5, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.extensions")
                ActivityBarIcon(icon: "testtube.2", title: "Testing", index: 6, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.testing")
            }
            
            Spacer()
            
            // Bottom Group
            Group {
                Menu {
                    Button(action: { /* Sign in with GitHub - placeholder */ }) {
                        Label("Sign in with GitHub...", systemImage: "person.crop.circle.badge.questionmark")
                    }
                    Button(action: { /* Manage Trusted Extensions - placeholder */ }) {
                        Label("Manage Trusted Extensions", systemImage: "shield.lefthalf.filled")
                    }
                } label: {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.secondary)
                        .frame(width: 50, height: 50)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Accounts")
                .accessibilityLabel("Accounts")
                .accessibilityHint("Double tap to manage accounts")
                ActivityBarButton(icon: "gear", title: "Manage") {
                    showSettings = true
                }
            }
            .padding(.bottom, 10)
        }
        .frame(width: 50)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.8)) // Darker shade for activity bar
        .border(width: 1, edges: [.trailing], color: Color(UIColor.separator))
    }
}

struct ActivityBarIcon: View {
    let icon: String
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    @ObservedObject var editorCore: EditorCore
    let accessibilityID: String
    
    var isSelected: Bool { selectedTab == index }
    
    var body: some View {
        Button(action: {
            if isSelected {
                // Toggle sidebar visibility if clicking already selected tab
                editorCore.toggleSidebar()
            } else {
                selectedTab = index
                if !editorCore.showSidebar { editorCore.toggleSidebar() }
            }
        }) {
            ZStack {
                // Active indicator line on left
                if isSelected && editorCore.showSidebar {
                    HStack {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 2)
                        Spacer()
                    }
                }
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(isSelected && editorCore.showSidebar ? .primary : .secondary)
                    .frame(width: 50, height: 50)
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(PlainButtonStyle())
        .help(title)
        .accessibilityIdentifier(accessibilityID)
        .accessibilityLabel("\(title) panel")
        .accessibilityHint(isSelected && editorCore.showSidebar ? "Double tap to hide the \(title) panel" : "Double tap to show the \(title) panel")
        .accessibilityAddTraits(isSelected && editorCore.showSidebar ? [.isSelected, .isButton] : .isButton)
    }
}

struct ActivityBarButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.secondary)
                .frame(width: 50, height: 50)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .help(title)
        .accessibilityLabel("\(title)")
        .accessibilityHint("Double tap to \(title.lowercased())")
    }
}

// MARK: - Resize Handle (iPad Compatible)

struct ResizeHandle: View {
    @Binding var width: CGFloat
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            ZStack {
                // Invisible larger hit area
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 10)
                
                // Visible separator line
                Rectangle()
                    .fill(isDragging ? Color.accentColor : Color(UIColor.separator))
                    .frame(width: 1)
            }
            .accessibilityLabel("Resize sidebar")
            .accessibilityHint("Drag to adjust sidebar width")
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let newWidth = width + value.translation.width
                        // Clamp width (Min 170, Max 600)
                        if newWidth >= 170 && newWidth <= 600 {
                            width = newWidth
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
        }
    }
}

// MARK: - Placeholders removed - ExtensionsView moved to Panels/ExtensionsView.swift
