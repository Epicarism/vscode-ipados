import SwiftUI

// MARK: - Activity Bar Components
//
// IDEActivityBar, ActivityBarIcon, and ActivityBarButton are used by
// ContentView.swift to render the left-side activity bar in the IDE layout.

// MARK: - Activity Bar Implementation

struct IDEActivityBar: View {
    @ObservedObject var editorCore: EditorCore
    @Binding var selectedTab: Int
    @Binding var showSettings: Bool
    @Binding var showTerminal: Bool
    @State private var showGitHubLogin = false
    @StateObject private var gitManager = GitManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Group
            Group {
                ActivityBarIcon(icon: "doc.on.doc", title: "Explorer", index: 0, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.explorer")
                ActivityBarIcon(icon: "magnifyingglass", title: "Search", index: 1, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.search")
                ZStack(alignment: .topTrailing) {
                    ActivityBarIcon(icon: "arrow.triangle.branch", title: "Source Control", index: 2, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.sourceControl")
                    let gitChangeCount = gitManager.stagedChanges.count + gitManager.unstagedChanges.count + gitManager.untrackedFiles.count
                    if gitChangeCount > 0 {
                        Text("\(gitChangeCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }
                ActivityBarIcon(icon: "play.fill", title: "Run and Debug", index: 3, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.runAndDebug")
                ActivityBarIcon(icon: "server.rack", title: "Remote Explorer", index: 4, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.remoteExplorer")
                ActivityBarIcon(icon: "square.grid.2x2", title: "Extensions", index: 5, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.extensions")
                ActivityBarIcon(icon: "testtube.2", title: "Testing", index: 6, selectedTab: $selectedTab, editorCore: editorCore, accessibilityID: "activityBar.testing")
            }
            
            Spacer()
            
            // Bottom Group
            Group {
                Menu {
                    Button(action: { showGitHubLogin = true }) {
                        Label("Sign in with GitHub...", systemImage: "person.crop.circle.badge.questionmark")
                    }
                    Button(action: { selectedTab = 5 }) {
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
        .sheet(isPresented: $showGitHubLogin) {
            GitHubLoginView()
        }
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
