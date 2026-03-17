//
//  ExtensionsView.swift
//  VSCodeiPadOS
//
//  Full VS Code-style Extensions panel with search, filters,
//  install/uninstall, enable/disable, and detail view.
//

import SwiftUI

// MARK: - Main Extensions View

struct ExtensionsPanel: View {
    @StateObject private var manager = ExtensionManager.shared
    @State private var selectedExtensionId: String? = nil
    @State private var showingDetail: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            extensionSearchBar
            
            // Filter tabs
            filterTabs
            
            Divider()
            
            // Extension list
            if manager.isLoading {
                loadingState
            } else if manager.filteredExtensions.isEmpty {
                emptyState
            } else {
                extensionList
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Extensions panel")
        .sheet(isPresented: $showingDetail) {
            if let extId = selectedExtensionId,
               let ext = manager.currentExtension(for: extId) {
                ExtensionDetailView(extension_: ext, manager: manager)
            }
        }
        .alert("Error", isPresented: .init(
            get: { manager.lastError != nil },
            set: { if !$0 { manager.clearError() } }
        )) {
            Button("OK", role: .cancel) { manager.clearError() }
        } message: {
            Text(manager.lastError?.errorDescription ?? "Unknown error")
        }
    }
    
    // MARK: - Search Bar
    
    private var extensionSearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
                .accessibilityHidden(true)
            
            TextField("Search Extensions in Marketplace", text: $manager.searchText)
                .font(.system(size: 13))
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .accessibilityLabel("Search extensions in marketplace")
            
            if !manager.searchText.isEmpty {
                Button(action: { manager.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search text")
                .accessibilityHint("Double tap to clear the search field")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(6)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    // MARK: - Filter Tabs
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(ExtensionFilter.allCases, id: \.rawValue) { filter in
                    filterButton(filter)
                }
                
                Divider()
                    .frame(height: 16)
                    .padding(.horizontal, 4)
                    .accessibilityHidden(true)
                
                // Category dropdown
                Menu {
                    Button("All Categories") {
                        manager.selectedCategory = nil
                    }
                    Divider()
                    ForEach(ExtensionCategory.allCases, id: \.rawValue) { category in
                        Button(action: { manager.selectedCategory = category }) {
                            Label(category.rawValue, systemImage: category.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: manager.selectedCategory?.icon ?? "line.3.horizontal.decrease")
                            .font(.system(size: 10))
                        Text(manager.selectedCategory?.rawValue ?? "Category")
                            .font(.system(size: 11))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(manager.selectedCategory != nil ? Color.accentColor.opacity(0.15) : Color.clear)
                    .cornerRadius(4)
                    .foregroundColor(manager.selectedCategory != nil ? .accentColor : .secondary)
                }
                .accessibilityLabel("Filter by category")
                .accessibilityHint("Double tap to choose an extension category")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
    }
    
    private func filterButton(_ filter: ExtensionFilter) -> some View {
        let isSelected = manager.selectedFilter == filter
        let count = filterCount(filter)
        
        return Button(action: { manager.selectedFilter = filter }) {
            HStack(spacing: 4) {
                Text(filter.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                if count > 0 && filter == .installed {
                    Text("\(count)")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(4)
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) filter\(count > 0 && filter == .installed ? ", \(count) installed" : "")")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to filter extensions by \(filter.rawValue)")
    }
    
    private func filterCount(_ filter: ExtensionFilter) -> Int {
        switch filter {
        case .installed: return manager.installedCount
        default: return 0
        }
    }
    
    // MARK: - Extension List
    
    private var extensionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(manager.filteredExtensions) { ext in
                    ExtensionRowView(
                        extension_: ext,
                        manager: manager,
                        onTap: {
                            selectedExtensionId = ext.id
                            showingDetail = true
                        }
                    )
                    Divider().padding(.leading, 52)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Extensions list, \(manager.filteredExtensions.count) extensions")
    }
    
    // MARK: - Loading State
    
    private var loadingState: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading extensions...")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: emptyIcon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
                .accessibilityHidden(true)
            Text(emptyMessage)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if manager.selectedFilter == .installed && manager.searchText.isEmpty {
                Button("Browse Marketplace") {
                    manager.selectedFilter = .popular
                }
                .font(.system(size: 13))
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .accessibilityLabel("Browse Marketplace")
                .accessibilityHint("Double tap to browse popular extensions")
            }
            Spacer()
        }
        .padding()
    }
    
    private var emptyIcon: String {
        manager.searchText.isEmpty ? "puzzlepiece" : "magnifyingglass"
    }
    
    private var emptyMessage: String {
        if !manager.searchText.isEmpty {
            return "No extensions matching '\(manager.searchText)'"
        }
        switch manager.selectedFilter {
        case .installed: return "No extensions installed yet"
        case .recommended: return "No recommendations available"
        default: return "No extensions found"
        }
    }
}

// MARK: - Extension Row

struct ExtensionRowView: View {
    let extension_: IDEExtension
    @ObservedObject var manager: ExtensionManager
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                // Icon
                extensionIcon
                    .accessibilityHidden(true)
                
                // Info
                VStack(alignment: .leading, spacing: 3) {
                    // Name + version
                    HStack(spacing: 6) {
                        Text(extension_.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("v\(extension_.version)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    Text(extension_.description)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Publisher + stats
                    HStack(spacing: 8) {
                        Text(extension_.publisher)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.circle")
                                .font(.system(size: 9))
                            Text(extension_.formattedDownloads)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                        .accessibilityLabel("\(extension_.formattedDownloads) downloads")
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", extension_.rating))
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Rating: \(String(format: "%.1f", extension_.rating)) out of 5")
                    }
                }
                
                Spacer()
                
                // Install/Manage button
                actionButton
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isPressed ? Color(UIColor.systemFill).opacity(0.5) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .accessibilityLabel("\(extension_.displayName), by \(extension_.publisher)")
        .accessibilityHint("\(extension_.isInstalled ? "Installed" : "Not installed"). \(extension_.description). Double tap to view details.")
        .accessibilityAddTraits(.isButton)
    }
    
    private var extensionIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(iconBackground)
                .frame(width: 36, height: 36)
            Image(systemName: extension_.iconName)
                .font(.system(size: 16))
                .foregroundColor(iconForeground)
        }
    }
    
    private var iconBackground: Color {
        switch extension_.category {
        case .themes: return Color.purple.opacity(0.15)
        case .languages: return Color.blue.opacity(0.15)
        case .snippets: return Color.green.opacity(0.15)
        case .linters: return Color.orange.opacity(0.15)
        case .formatters: return Color.teal.opacity(0.15)
        case .debuggers: return Color.red.opacity(0.15)
        case .keymaps: return Color.gray.opacity(0.15)
        case .other: return Color.indigo.opacity(0.15)
        }
    }
    
    private var iconForeground: Color {
        switch extension_.category {
        case .themes: return .purple
        case .languages: return .blue
        case .snippets: return .green
        case .linters: return .orange
        case .formatters: return .teal
        case .debuggers: return .red
        case .keymaps: return .gray
        case .other: return .indigo
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        let isOperating = manager.operationInProgress == extension_.id
        
        if isOperating {
            ProgressView()
                .scaleEffect(0.7)
                .frame(width: 60)
        } else if extension_.isInstalled {
            Menu {
                if extension_.isEnabled {
                    Button(action: { manager.toggleEnabled(extension_) }) {
                        Label("Disable", systemImage: "pause.circle")
                    }
                    .accessibilityLabel("Disable \(extension_.displayName)")
                    .accessibilityHint("Double tap to disable this extension")
                } else {
                    Button(action: { manager.toggleEnabled(extension_) }) {
                        Label("Enable", systemImage: "play.circle")
                    }
                    .accessibilityLabel("Enable \(extension_.displayName)")
                    .accessibilityHint("Double tap to enable this extension")
                }
                Divider()
                Button(role: .destructive, action: { manager.uninstall(extension_) }) {
                    Label("Uninstall", systemImage: "trash")
                }
                .accessibilityLabel("Uninstall \(extension_.displayName)")
                .accessibilityHint("Double tap to uninstall this extension")
            } label: {
                HStack(spacing: 4) {
                    if !extension_.isEnabled {
                        Image(systemName: "pause.circle")
                            .font(.system(size: 10))
                    }
                    Text(extension_.isEnabled ? "Installed" : "Disabled")
                        .font(.system(size: 11))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(UIColor.systemFill))
                .cornerRadius(4)
                .foregroundColor(extension_.isEnabled ? .secondary : .orange)
            }
            .accessibilityLabel("Manage \(extension_.displayName), currently \(extension_.isEnabled ? "enabled" : "disabled")")
            .accessibilityHint("Double tap to disable, enable, or uninstall this extension")
        } else {
            Button(action: { manager.install(extension_) }) {
                Text("Install")
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Install \(extension_.displayName)")
            .accessibilityHint("Double tap to install this extension")
        }
    }
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Extension Detail View

struct ExtensionDetailView: View {
    let extension_: IDEExtension
    @ObservedObject var manager: ExtensionManager
    @Environment(\.dismiss) var dismiss
    
    // Get current state from manager
    private var currentExtension: IDEExtension? {
        manager.currentExtension(for: extension_.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection
                    
                    Divider()
                    
                    // Details
                    detailsSection
                    
                    Divider()
                    
                    // Category & Tags
                    categorySection
                    
                    Divider()
                    
                    // Description
                    descriptionSection
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(extension_.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .accessibilityHint("Double tap to dismiss extension details")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Details for \(extension_.displayName)")
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // Large icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.tertiarySystemBackground))
                    .frame(width: 64, height: 64)
                Image(systemName: extension_.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(.accentColor)
            }
            .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(extension_.displayName)
                    .font(.system(size: 20, weight: .bold))
                
                HStack(spacing: 4) {
                    Text(extension_.publisher)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.accentColor)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(extension_.publisher), verified publisher")
                
                Text(extension_.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action button
            actionButton
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        if let current = currentExtension {
            let isOperating = manager.operationInProgress == current.id
            
            if isOperating {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 80)
            } else if current.isInstalled {
                VStack(spacing: 8) {
                    Button(action: { manager.uninstall(current) }) {
                        Text("Uninstall")
                            .font(.system(size: 13, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Uninstall \(current.displayName)")
                    .accessibilityHint("Double tap to uninstall this extension")
                    
                    Button(action: { manager.toggleEnabled(current) }) {
                        Text(current.isEnabled ? "Disable" : "Enable")
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color(UIColor.systemFill))
                            .foregroundColor(current.isEnabled ? .secondary : .green)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(current.isEnabled ? "Disable \(current.displayName)" : "Enable \(current.displayName)")
                    .accessibilityHint("Double tap to \(current.isEnabled ? "disable" : "enable") this extension")
                }
                .frame(width: 100)
            } else {
                Button(action: { manager.install(current) }) {
                    Text("Install")
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Install \(current.displayName)")
                .accessibilityHint("Double tap to install this extension")
                .frame(width: 100)
            }
        }
    }
    
    private var detailsSection: some View {
        HStack(spacing: 24) {
            detailItem(title: "Version", value: extension_.version)
            detailItem(title: "Downloads", value: extension_.formattedDownloads)
            detailItem(title: "Rating", value: String(format: "%.1f ★", extension_.rating))
            detailItem(title: "Publisher", value: extension_.publisher)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Extension details. Version \(extension_.version). \(extension_.formattedDownloads) downloads. Rating \(String(format: "%.1f", extension_.rating)) out of 5. Publisher: \(extension_.publisher)")
    }
    
    private func detailItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            HStack {
                Label(extension_.category.rawValue, systemImage: extension_.category.icon)
                    .font(.system(size: 12))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(4)
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
            
            Text(extension_.description)
                .font(.system(size: 13))
                .foregroundColor(.primary)
            
            Text("Extension ID: \(extension_.fullId)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .accessibilityLabel("Extension identifier: \(extension_.fullId)")
        }
    }
}

// MARK: - Previews

#Preview("Extensions Panel") {
    ExtensionsPanel()
        .frame(width: 350, height: 600)
}

#Preview("Extension Row") {
    let manager = ExtensionManager.shared
    return VStack {
        ExtensionRowView(
            extension_: ExtensionManager.builtInCatalog[0],
            manager: manager,
            onTap: {}
        )
    }
    .padding()
}
