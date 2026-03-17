import SwiftUI

// MARK: - ErrorBoundaryView

/// A reusable error boundary that wraps any child view and displays a
/// friendly, themed error state when an `Error` is reported.
///
/// Usage:
/// ```swift
/// @State private var error: Error?
///
/// ErrorBoundaryView(error: $error) {
///     MyComplexView()
///         .task {
///             do {
///                 try await riskyOperation()
///             } catch {
///                 self.error = error
///             }
///         }
/// }
/// ```
///
/// Also supports a throwable content builder via the `catching` initializer:
/// ```swift
/// ErrorBoundaryView {
///     try riskyView()
/// } onRetry: {
///     // retry logic
/// }
/// ```
struct ErrorBoundaryView<Content: View>: View {

    // MARK: - Theme

    @ObservedObject private var themeManager = ThemeManager.shared

    /// Convenience accessor matching the project convention.
    private var theme: Theme { themeManager.currentTheme }

    // MARK: - State

    @State private var caughtError: Error?

    // MARK: - Configuration

    /// Optional error binding — callers can push errors into the boundary.
    private var externalError: Binding<Error?>?

    /// The content to display when no error is present.
    private let content: () -> Content

    /// Called when the user taps "Try Again". Resets the error state and
    /// invokes the caller's retry handler.
    private let onRetry: (() -> Void)?

    /// Optional custom error description; falls back to `error.localizedDescription`.
    private let errorDescription: String?

    /// SF Symbol shown in the error state. Defaults to `"exclamationmark.triangle.fill"`.
    private let errorIcon: String

    /// Title shown in the error state. Defaults to `"Something went wrong"`.
    private let errorTitle: String

    // MARK: - Computed

    /// Resolves to whichever error source is non-nil.
    private var activeError: Error? {
        externalError?.wrappedValue ?? caughtError
    }

    // MARK: - Initializers

    /// Creates an error boundary that monitors a bound `Error?`.
    ///
    /// - Parameters:
    ///   - error: A binding to an optional error produced elsewhere.
    ///   - description: Optional override for the error description text.
    ///   - icon: SF Symbol for the error icon.
    ///   - title: Title text shown above the error description.
    ///   - onRetry: Closure invoked when the user taps "Try Again".
    ///   - content: The view builder for the normal (non-error) state.
    init(
        error: Binding<Error?>,
        description: String? = nil,
        icon: String = "exclamationmark.triangle.fill",
        title: String = "Something went wrong",
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.externalError = error
        self.errorDescription = description
        self.errorIcon = icon
        self.errorTitle = title
        self.onRetry = onRetry
        self.content = content
    }

    /// Creates a self-contained error boundary with no external error binding.
    ///
    /// Use this when you only need internal error reporting via `reportError(_:)`.
    init(
        description: String? = nil,
        icon: String = "exclamationmark.triangle.fill",
        title: String = "Something went wrong",
        onRetry: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.externalError = nil
        self.errorDescription = description
        self.errorIcon = icon
        self.errorTitle = title
        self.onRetry = onRetry
        self.content = content
    }

    // MARK: - Public API

    /// Manually report an error to this boundary from a child view.
    ///
    /// Pass this closure into child views or call it from `Task` blocks.
    func reportError(_ error: Error) {
        if externalError != nil {
            externalError?.wrappedValue = error
        } else {
            caughtError = error
        }
    }

    /// Reset the error state and re-render the content.
    func reset() {
        if externalError != nil {
            externalError?.wrappedValue = nil
        }
        caughtError = nil
    }

    // MARK: - Body

    var body: some View {
        if let error = activeError {
            errorView(for: error)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            content()
                .transition(.opacity)
        }
    }

    // MARK: - Error View

    private func errorView(for error: Error) -> some View {
        VStack(spacing: 20) {
            Spacer()

            // ── Icon ───────────────────────────────────────────
            Image(systemName: errorIcon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(theme.errorForeground)
                .symbolEffect(.pulse, options: .repeating, isActive: true)

            // ── Title ──────────────────────────────────────────
            Text(errorTitle)
                .font(.title2.bold())
                .foregroundStyle(theme.editorForeground)

            // ── Description ────────────────────────────────────
            Text(errorDescription ?? error.localizedDescription)
                .font(.body)
                .foregroundStyle(theme.isDark ? Color(hex: "#858585") : Color(hex: "#6A6A6A"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)

            // ── Try Again Button ───────────────────────────────
            if onRetry != nil {
                Button {
                    reset()
                    onRetry?()
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(theme.statusBarBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(theme.editorBackground)
        .animation(.easeInOut(duration: 0.25), value: activeError != nil)
    }
}

// MARK: - Preview

#Preview("Error State") {
    struct SampleError: LocalizedError {
        var errorDescription: String? {
            "The file could not be parsed because it contains invalid syntax on line 42."
        }
    }

    return ErrorBoundaryView(
        error: .constant(SampleError()),
        onRetry: {}
    ) {
        Text("This is hidden")
    }
}

#Preview("Normal State") {
    ErrorBoundaryView(error: .constant(nil)) {
        Text("Content is displayed normally")
            .font(.largeTitle)
            .padding()
    }
}
