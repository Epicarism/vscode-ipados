import SwiftUI

enum PanelTab: String, CaseIterable, Identifiable {
    case problems = "Problems"
    case output = "Output"
    case terminal = "Terminal"
    case debugConsole = "Debug Console"
    case ports = "Ports"
    case timeline = "Timeline"
    case sourceControl = "Source Control"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .problems: return "exclamationmark.triangle"
        case .output: return "list.bullet.rectangle"
        case .terminal: return "terminal"
        case .debugConsole: return "ant.circle"
        case .ports: return "network"
        case .timeline: return "clock.arrow.circlepath"
        case .sourceControl: return "arrow.triangle.branch"
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
    @State private var problemCount: Int = 0
    @StateObject private var themeManager = ThemeManager.shared

    private var theme: Theme { themeManager.currentTheme }

    // MARK: - Layout Constants
    /// Combined height of the resize handle (1 pt) + tab bar (35 pt).
    private static let panelChromeHeight: CGFloat = 36
    /// Vertical space reserved for the toolbar / header area above the panel.
    private static let topReservedHeight: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            let maxHeight = geometry.size.height

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
                                        height = max(Self.topReservedHeight,
                                                      min(newHeight, maxHeight - Self.topReservedHeight))
                                    }
                            )
                    )

                // Tab Bar
                HStack(spacing: 0) {
                    ForEach(PanelTab.allCases) { tab in
                        PanelTabButton(tab: tab, isSelected: selectedTab == tab, theme: theme, problemCount: tab == .problems ? problemCount : 0) {
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
                                height = maxHeight - Self.topReservedHeight
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
                    case .timeline:
                        TimelineView()
                    case .sourceControl:
                        GitView()
                    }
                }
                .frame(height: isMaximized
                       ? maxHeight - Self.topReservedHeight - Self.panelChromeHeight
                       : height - Self.panelChromeHeight)
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
            .onReceive(NotificationCenter.default.publisher(for: .switchToTimelinePanel)) { _ in
                selectedTab = .timeline
            }
            .onReceive(NotificationCenter.default.publisher(for: .switchToSourceControlPanel)) { _ in
                selectedTab = .sourceControl
            }
            .onReceive(NotificationCenter.default.publisher(for: .diagnosticsUpdated)) { notification in
                if let items = notification.userInfo?["items"] as? [[String: Any]] {
                    problemCount = items.count
                } else if let clear = notification.userInfo?["clear"] as? Bool, clear {
                    problemCount = 0
                }
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
}

struct PanelTabButton: View {
    let tab: PanelTab
    let isSelected: Bool
    let theme: Theme
    var problemCount: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 10))

                Text(tab.rawValue.uppercased())
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))

                if tab == .problems && problemCount > 0 {
                    Text("\(problemCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(Color(UIColor.systemRed).opacity(0.8)))
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
