import SwiftUI

enum PanelTab: String, CaseIterable, Identifiable {
    case problems = "Problems"
    case output = "Output"
    case terminal = "Terminal"
    case debugConsole = "Debug Console"
    case ports = "Ports"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .problems: return "exclamationmark.triangle"
        case .output: return "list.bullet.rectangle"
        case .terminal: return "terminal"
        case .debugConsole: return "ant.circle"
        case .ports: return "network"
        }
    }
}

struct PanelView: View {
    @Binding var isVisible: Bool
    @Binding var height: CGFloat
    @FocusState.Binding var terminalFocused: Bool
    @State private var selectedTab: PanelTab = .terminal
    @State private var isMaximized: Bool = false
    @State private var previousHeight: CGFloat = 200
    @ObservedObject private var themeManager = ThemeManager.shared
    
    private var theme: Theme { themeManager.currentTheme }
    
    var body: some View {
        VStack(spacing: 0) {
            // Resize Handle
            Rectangle()
                .fill(theme.editorForeground.opacity(0.15))
                .frame(height: 1)
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 8)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = height - value.translation.height
                                    height = max(100, min(newHeight, UIScreen.main.bounds.height - 100))
                                }
                        )
                )
            
            // Tab Bar
            HStack(spacing: 0) {
                ForEach(PanelTab.allCases) { tab in
                    PanelTabButton(tab: tab, isSelected: selectedTab == tab, theme: theme) {
                        selectedTab = tab
                    }
                }
                
                Spacer()
                
                // Panel Controls
                HStack(spacing: 12) {
                    Button(action: {
                        if isMaximized {
                            height = previousHeight
                        } else {
                            previousHeight = height
                            height = UIScreen.main.bounds.height - 100
                        }
                        isMaximized.toggle()
                    }) {
                        Image(systemName: isMaximized ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12))
                    }
                    .accessibilityLabel(isMaximized ? "Restore panel size" : "Maximize panel")
                    .accessibilityHint("Double tap to \(isMaximized ? "restore" : "maximize") the panel")
                    
                    Button(action: { isVisible = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                    }
                    .accessibilityLabel("Close panel")
                    .accessibilityHint("Double tap to hide the bottom panel")
                }
                .foregroundColor(theme.comment)
                .padding(.horizontal, 12)
            }
            .frame(height: 35)
            .background(theme.tabBarBackground)
            
            Divider()
                .background(theme.editorForeground.opacity(0.15))
            
            // Content
            Group {
                switch selectedTab {
                case .problems:
                    ProblemsView()
                case .output:
                    OutputView()
                case .terminal:
                    TerminalView(terminalFocused: $terminalFocused)
                case .debugConsole:
                    DebugConsoleView()
                case .ports:
                    PortsView()
                }
            }
            .frame(height: isMaximized ? UIScreen.main.bounds.height - 140 : height - 36)
        }
        .background(theme.editorBackground)
        .onReceive(NotificationCenter.default.publisher(for: .switchToOutputPanel)) { _ in
            selectedTab = .output
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToDebugConsole)) { _ in
            selectedTab = .debugConsole
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToTerminalPanel)) { _ in
            selectedTab = .terminal
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToPortsPanel)) { _ in
            selectedTab = .ports
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToProblemsPanel)) { _ in
            selectedTab = .problems
        }
        .onChange(of: isVisible) { _, newValue in
            if !newValue {
                terminalFocused = false
            }
        }
        .onChange(of: terminalFocused) { _, isFocused in
            if isFocused {
                // Force the editor to resign first responder so keyboard input
                // goes exclusively to the terminal, not to both simultaneously.
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
            }
        }
    }
}

struct PanelTabButton: View {
    let tab: PanelTab
    let isSelected: Bool
    let theme: Theme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(tab.rawValue.uppercased())
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                
                if tab == .problems {
                    Circle()
                        .fill(theme.comment)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundColor(isSelected ? theme.tabActiveForeground : theme.comment)
            .padding(.horizontal, 12)
            .frame(maxHeight: .infinity)
            .background(isSelected ? theme.editorBackground : Color.clear)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(isSelected ? .clear : theme.editorForeground.opacity(0.15)),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tab.rawValue) tab")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to switch to \(tab.rawValue) panel")
    }
}
