import SwiftUI

// MARK: - LoadingView

/// Displays a themed loading indicator with optional message text.
///
/// Supports three display styles:
/// - `.fullScreen`  — covers the entire screen with a solid background.
/// - `.inline`      — compact, fits naturally in a stack or list.
/// - `.overlay`     — semi-transparent backdrop, ideal for blocking interaction.
///
/// Usage:
/// ```swift
/// LoadingView("Opening workspace…", style: .fullScreen)
///
/// LoadingView(style: .inline)
///
/// LoadingView(style: .overlay, message: "Saving changes…")
/// ```
struct LoadingView: View {

    // MARK: - Style

    /// Determines how the loading view is presented.
    enum Style {
        /// Covers the entire available space with the theme background.
        case fullScreen

        /// A minimal spinner with optional label; no background fill.
        case inline

        /// Semi-transparent backdrop that blocks interaction beneath it.
        case overlay
    }

    // MARK: - Theme

    @ObservedObject private var themeManager = ThemeManager.shared

    /// Convenience accessor matching the project convention.
    private var theme: Theme { themeManager.currentTheme }

    // MARK: - Configuration

    /// The display style.
    let style: Style

    /// Optional descriptive text shown below the spinner.
    let message: String?

    // MARK: - Init

    /// Creates a loading view.
    ///
    /// - Parameters:
    ///   - message: Optional text displayed beneath the progress indicator.
    ///   - style: The presentation style (defaults to `.fullScreen`).
    init(_ message: String? = nil, style: Style = .fullScreen) {
        self.message = message
        self.style = style
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background layer depends on style
            switch style {
            case .fullScreen:
                theme.editorBackground
                    .ignoresSafeArea()

            case .inline:
                Color.clear

            case .overlay:
                theme.isDark
                    ? Color.black.opacity(0.5)
                    : Color.white.opacity(0.5)
                    .ignoresSafeArea()
            }

            // Content
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(theme.statusBarBackground)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(theme.isDark ? Color(hex: "#858585") : Color(hex: "#6A6A6A"))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(
                maxWidth: style == .fullScreen ? .infinity : nil,
                maxHeight: style == .fullScreen ? .infinity : nil
            )
            .padding(style == .fullScreen ? 32 : 16)
        }
        .frame(
            maxWidth: style == .inline ? nil : .infinity,
            maxHeight: style == .inline ? nil : .infinity
        )
    }
}

// MARK: - Convenience Modifiers

extension View {

    /// Conditionally shows a full-screen `LoadingView` overlay when `isLoading` is true.
    ///
    /// ```swift
    /// MyContentView()
    ///     .loadingOverlay(isLoading: $isBusy, message: "Loading…")
    /// ```
    func loadingOverlay(isLoading: Binding<Bool>, message: String? = nil) -> some View {
        ZStack {
            self
            if isLoading.wrappedValue {
                LoadingView(message, style: .fullScreen)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading.wrappedValue)
    }

    /// Conditionally shows an overlay-style `LoadingView` (semi-transparent) when `isLoading` is true.
    ///
    /// ```swift
    /// MyContentView()
    ///     .loadingOverlay(isLoading: $isBusy, message: "Saving…", style: .overlay)
    /// ```
    func loadingOverlay(isLoading: Binding<Bool>, message: String? = nil, style: LoadingView.Style = .overlay) -> some View {
        ZStack {
            self
            if isLoading.wrappedValue {
                LoadingView(message, style: style)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading.wrappedValue)
    }
}

// MARK: - Preview

#Preview("Full Screen") {
    ZStack {
        Color(hex: "#1E1E1E").ignoresSafeArea()
        LoadingView("Loading workspace…", style: .fullScreen)
    }
}

#Preview("Inline") {
    VStack(spacing: 24) {
        Text("Some content above")
        LoadingView("Fetching data…", style: .inline)
        Text("Some content below")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#1E1E1E").ignoresSafeArea())
    .foregroundStyle(.white)
}

#Preview("Overlay") {
    ZStack {
        VStack {
            Text("Content behind the overlay")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#1E1E1E").ignoresSafeArea())
        LoadingView("Processing…", style: .overlay)
    }
}
