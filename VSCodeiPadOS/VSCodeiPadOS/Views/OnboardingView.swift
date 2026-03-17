//  OnboardingView.swift
//  VSCodeiPadOS
//
//  First-launch onboarding walkthrough — 5 pages.
//  Presented as .fullScreenCover when hasCompletedOnboarding == false.
//

import SwiftUI

// MARK: - Onboarding Page Model

private struct OnboardingPage: Identifiable {
    let id: Int
    let symbolName: String
    let symbolColor: Color
    let title: String
    let subtitle: String?
    let bullets: [String]
    let isLastPage: Bool

    init(
        id: Int,
        symbolName: String,
        symbolColor: Color,
        title: String,
        subtitle: String? = nil,
        bullets: [String] = [],
        isLastPage: Bool = false
    ) {
        self.id = id
        self.symbolName = symbolName
        self.symbolColor = symbolColor
        self.title = title
        self.subtitle = subtitle
        self.bullets = bullets
        self.isLastPage = isLastPage
    }
}

// MARK: - OnboardingView

struct OnboardingView: View {

    // Persisted flag – set to true when user taps "Get Started"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    // Checkbox on the last page
    @AppStorage("showKeyboardCheatSheet") private var showKeyboardCheatSheet: Bool = true

    @StateObject private var themeManager = ThemeManager.shared
    @State private var currentPage: Int = 0
    @State private var symbolScale: CGFloat = 0.5
    @State private var symbolOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var contentOpacity: Double = 0

    private var theme: Theme { themeManager.currentTheme }

    // MARK: Pages

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbolName: "chevron.left.forwardslash.chevron.right",
            symbolColor: Color(hex: "#007ACC"),
            title: "Welcome to Code",
            subtitle: "A powerful code editor for iPad"
        ),
        OnboardingPage(
            id: 1,
            symbolName: "folder.badge.plus",
            symbolColor: Color(hex: "#E8C17D"),
            title: "Open Any Project",
            bullets: [
                "Open folders from Files app",
                "Browse remote servers via SSH",
                "Full file tree with search"
            ]
        ),
        OnboardingPage(
            id: 2,
            symbolName: "keyboard",
            symbolColor: Color(hex: "#9CDCFE"),
            title: "Keyboard-First Editing",
            bullets: [
                "Full keyboard shortcut support (Cmd+S, Cmd+P, etc.)",
                "Syntax highlighting for 20+ languages",
                "Find and Replace with regex"
            ]
        ),
        OnboardingPage(
            id: 3,
            symbolName: "arrow.triangle.branch",
            symbolColor: Color(hex: "#F14E32"),
            title: "Git Integration",
            bullets: [
                "Commit, push, pull from the sidebar",
                "Branch management",
                "Visual diff viewer"
            ]
        ),
        OnboardingPage(
            id: 4,
            symbolName: "sparkles",
            symbolColor: Color(hex: "#FFD700"),
            title: "Ready to Code",
            isLastPage: true
        )
    ]

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            theme.editorBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        pageView(for: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)
                .onChange(of: currentPage) { _, _ in
                    animatePageIn()
                }

                // Bottom controls
                bottomBar
                    .padding(.bottom, 40)
            }
        }
        .onAppear { animatePageIn() }
    }

    // MARK: - Page View

    @ViewBuilder
    private func pageView(for page: OnboardingPage) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.symbolColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.symbolName)
                    .font(.system(size: 52, weight: .light))
                    .foregroundColor(page.symbolColor)
            }
            .scaleEffect(symbolScale)
            .opacity(symbolOpacity)
            .padding(.bottom, 36)
            .accessibilityHidden(true)

            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(theme.editorForeground)
                .multilineTextAlignment(.center)
                .offset(y: contentOffset)
                .opacity(contentOpacity)
                .padding(.horizontal, 32)
                .accessibilityLabel("Step \(page.id + 1) of \(pages.count): \(page.title)")
                .accessibilityAddTraits(.isHeader)

            // Subtitle (page 1 only)
            if let subtitle = page.subtitle {
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(theme.editorForeground.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)
                    .padding(.top, 12)
                    .padding(.horizontal, 40)
                    .accessibilityLabel(subtitle)
            }

            // Bullet points
            if !page.bullets.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(page.bullets.enumerated()), id: \.offset) { index, bullet in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(page.symbolColor)
                                .font(.system(size: 18))
                                .padding(.top, 1)
                                .accessibilityHidden(true)

                            Text(bullet)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(theme.editorForeground.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel(bullet)
                        }
                        .offset(y: contentOffset)
                        .opacity(contentOpacity)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.85)
                                .delay(Double(index) * 0.07),
                            value: contentOpacity
                        )
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 48)
            }

            // Last page extras
            if page.isLastPage {
                lastPageExtras
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: 560)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Last Page Extras

    private var lastPageExtras: some View {
        VStack(spacing: 24) {
            // Checkbox
            Button {
                showKeyboardCheatSheet.toggle()
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(theme.border, lineWidth: 1.5)
                            .frame(width: 22, height: 22)

                        if showKeyboardCheatSheet {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(hex: "#007ACC"))
                                .frame(width: 22, height: 22)

                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showKeyboardCheatSheet)
                    .accessibilityHidden(true)

                    Text("Show keyboard shortcuts cheat sheet")
                        .font(.system(size: 15))
                        .foregroundColor(theme.editorForeground.opacity(0.8))
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showKeyboardCheatSheet ? "Show keyboard shortcuts cheat sheet, checked" : "Show keyboard shortcuts cheat sheet, unchecked")
            .accessibilityHint("Toggles whether the keyboard shortcuts cheat sheet is shown after onboarding.")
            .accessibilityAddTraits(showKeyboardCheatSheet ? [.isButton, .isSelected] : .isButton)
            .padding(.top, 16)

            // Get Started button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color(hex: "#007ACC"))
                    )
                    .shadow(color: Color(hex: "#007ACC").opacity(0.45), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Get Started")
            .accessibilityHint("Completes onboarding and opens the editor.")
            .padding(.horizontal, 48)
            .padding(.top, 8)
        }
    }

    // MARK: - Bottom Bar (page dots + next button)

    private var bottomBar: some View {
        VStack(spacing: 20) {
            // Page indicator dots
            HStack(spacing: 8) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(currentPage == page.id
                              ? Color(hex: "#007ACC")
                              : theme.editorForeground.opacity(0.25))
                        .frame(width: currentPage == page.id ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                        .accessibilityLabel("Step \(page.id + 1) of \(pages.count)\(currentPage == page.id ? ", current" : "")")
                }
            }
            .accessibilityLabel("Onboarding progress: step \(currentPage + 1) of \(pages.count)")

            // Skip / Next buttons (hidden on last page — Get Started is inside the page)
            if currentPage < pages.count - 1 {
                HStack(spacing: 24) {
                    Button("Skip") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            hasCompletedOnboarding = true
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundColor(theme.editorForeground.opacity(0.45))
                    .buttonStyle(.plain)
                    .accessibilityLabel("Skip onboarding")
                    .accessibilityHint("Skips the remaining onboarding steps and opens the editor.")

                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            currentPage += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(.system(size: 15, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .accessibilityHidden(true)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 11)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#007ACC"))
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Next")
                    .accessibilityHint("Goes to step \(currentPage + 2) of \(pages.count).")
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Animation Helpers

    private func animatePageIn() {
        // Reset
        symbolScale = 0.5
        symbolOpacity = 0
        contentOffset = 30
        contentOpacity = 0

        // Animate symbol
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.05)) {
            symbolScale = 1.0
            symbolOpacity = 1.0
        }

        // Animate content
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85).delay(0.15)) {
            contentOffset = 0
            contentOpacity = 1.0
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environmentObject(ThemeManager.shared)
}
