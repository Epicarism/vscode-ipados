import SwiftUI

import SwiftUI

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    private let features: [(String, String)] = [
        ("doc.text", "Powerful Code Editor"),
        ("paintbrush", "19 Color Themes"),
        ("sparkles", "AI Assistant"),
        ("cpu", "On-Device LLM"),
        ("branch", "Git Integration"),
        ("terminal", "Built-in Terminal"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                // App Icon
                Group {
                    if let uiImage = UIImage(named: "AppIcon") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 120, height: 120)
                            .cornerRadius(26)
                            .shadow(radius: 8)
                    } else {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.system(size: 72))
                            .foregroundStyle(.blue)
                            .frame(width: 120, height: 120)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
                            .shadow(radius: 8)
                    }
                }
                .accessibilityLabel("CodePad app icon")

                // App Name
                Text("CodePad")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                // Version
                Text("Version \(version) (\(build))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Tagline
                Text("A native code editor for iPad")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, -8)

                Divider()
                    .padding(.horizontal, 80)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("Features")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(features, id: \.0) { icon, label in
                        Label(label, systemImage: icon)
                            .font(.body)
                            .accessibilityLabel(label)
                    }
                }
                .padding(.horizontal, 40)

                Divider()
                    .padding(.horizontal, 80)

                // Footer
                Text("Made with ❤️ using Swift & SwiftUI")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)

                Spacer(minLength: 40)
            }
            .frame(maxWidth: 500)
        }
        .navigationTitle("About")
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
