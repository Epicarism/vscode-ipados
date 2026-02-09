import SwiftUI

// MARK: - Warning Types

enum RunnerWarningType: Equatable {
    case remoteRequired(reason: String, limitations: [String])
    case limitedFunctionality(reason: String, unavailableFeatures: [String])
    case securityRisk(reason: String, detectedIssues: [String])
    
    var iconName: String {
        switch self {
        case .remoteRequired:
            return "exclamationmark.triangle.fill"
        case .limitedFunctionality:
            return "exclamationmark.circle.fill"
        case .securityRisk:
            return "exclamationmark.shield.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .remoteRequired:
            return .orange
        case .limitedFunctionality:
            return .yellow
        case .securityRisk:
            return .red
        }
    }
    
    var title: String {
        switch self {
        case .remoteRequired:
            return "Remote Execution Required"
        case .limitedFunctionality:
            return "Limited Functionality"
        case .securityRisk:
            return "Security Warning"
        }
    }
    
    var primaryReason: String {
        switch self {
        case .remoteRequired(let reason, _),
             .limitedFunctionality(let reason, _),
             .securityRisk(let reason, _):
            return reason
        }
    }
    
    var listItems: [String] {
        switch self {
        case .remoteRequired(_, let limitations):
            return limitations
        case .limitedFunctionality(_, let features):
            return features
        case .securityRisk(_, let issues):
            return issues
        }
    }
    
    var listTitle: String {
        switch self {
        case .remoteRequired:
            return "Missing Dependencies"
        case .limitedFunctionality:
            return "Unavailable Features"
        case .securityRisk:
            return "Detected Issues"
        }
    }
}

// MARK: - View Model

class RunnerWarningViewModel: ObservableObject {
    @Published var isPresented: Bool = false
    @Published var warningType: RunnerWarningType = .remoteRequired(reason: "", limitations: [])
    @Published var alwaysAllowRemote: Bool = false
    
    var onRunRemotely: (() -> Void)?
    var onCancel: (() -> Void)?
    var onEditCode: (() -> Void)?
    
    func showWarning(type: RunnerWarningType) {
        self.warningType = type
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.isPresented = true
        }
    }
    
    func dismiss() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.isPresented = false
        }
    }
    
    func runRemotely() {
        onRunRemotely?()
        dismiss()
    }
    
    func cancel() {
        onCancel?()
        dismiss()
    }
    
    func editCode() {
        onEditCode?()
        dismiss()
    }
}

// MARK: - Main View

struct RunnerWarningView: View {
    @ObservedObject var viewModel: RunnerWarningViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isPresented {
                // Background overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        viewModel.cancel()
                    }
                
                // Alert card
                warningCard
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
    }
    
    private var warningCard: some View {
        VStack(spacing: 0) {
            // Icon
            Image(systemName: viewModel.warningType.iconName)
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(viewModel.warningType.iconColor)
                .padding(.top, 24)
                .padding(.bottom, 16)
            
            // Title
            Text(viewModel.warningType.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            // Explanation
            Text(viewModel.warningType.primaryReason)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            // List of items
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.warningType.listTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                ForEach(viewModel.warningType.listItems, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 4))
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                        
                        Text(item)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // Toggle
            Toggle("Always allow remote execution for this project", isOn: $viewModel.alwaysAllowRemote)
                .font(.system(size: 13))
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            // Divider before buttons
            Divider()
                .padding(.top, 20)
            
            // Buttons
            HStack(spacing: 0) {
                Button(action: { viewModel.cancel() }) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                
                Divider()
                    .frame(height: 44)
                
                Button(action: { viewModel.editCode() }) {
                    Text("Edit Code")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                
                Divider()
                    .frame(height: 44)
                
                Button(action: { viewModel.runRemotely() }) {
                    Text("Run Remotely")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(viewModel.warningType.iconColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.2), radius: 40, x: 0, y: 20)
        )
        .frame(maxWidth: 320)
    }
}

// MARK: - Preview Provider

#Preview("Remote Required") {
    let viewModel = RunnerWarningViewModel()
    viewModel.warningType = .remoteRequired(
        reason: "This project requires dependencies that are not available on iOS.",
        limitations: [
            "numpy - Scientific computing library",
            "pandas - Data analysis library",
            "matplotlib - Plotting library"
        ]
    )
    viewModel.isPresented = true
    
    return ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        RunnerWarningView(viewModel: viewModel)
    }
}

#Preview("Limited Functionality") {
    let viewModel = RunnerWarningViewModel()
    viewModel.warningType = .limitedFunctionality(
        reason: "Some features will be unavailable when running locally.",
        unavailableFeatures: [
            "File system access",
            "Network requests to external APIs",
            "System process execution"
        ]
    )
    viewModel.isPresented = true
    
    return ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        RunnerWarningView(viewModel: viewModel)
    }
}

#Preview("Security Risk") {
    let viewModel = RunnerWarningViewModel()
    viewModel.warningType = .securityRisk(
        reason: "Potentially dangerous operations detected in your code.",
        detectedIssues: [
            "Use of eval() function",
            "Dynamic code execution",
            "Import of restricted modules"
        ]
    )
    viewModel.isPresented = true
    
    return ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        RunnerWarningView(viewModel: viewModel)
    }
}

#Preview("Dark Mode - Remote Required") {
    let viewModel = RunnerWarningViewModel()
    viewModel.warningType = .remoteRequired(
        reason: "This project requires dependencies that are not available on iOS.",
        limitations: [
            "numpy - Scientific computing library",
            "pandas - Data analysis library"
        ]
    )
    viewModel.isPresented = true
    
    return ZStack {
        Color.black.ignoresSafeArea()
        RunnerWarningView(viewModel: viewModel)
    }
    .preferredColorScheme(.dark)
}

#Preview("Animation Demo") {
    struct AnimationDemo: View {
        @StateObject private var viewModel = RunnerWarningViewModel()
        
        var body: some View {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                VStack {
                    Button("Show Remote Required Warning") {
                        viewModel.showWarning(type: .remoteRequired(
                            reason: "Dependencies not available on iOS.",
                            limitations: ["numpy", "scipy", "matplotlib"]
                        ))
                    }
                    .padding()
                    
                    Button("Show Limited Functionality Warning") {
                        viewModel.showWarning(type: .limitedFunctionality(
                            reason: "Some features unavailable locally.",
                            unavailableFeatures: ["File I/O", "Network requests"]
                        ))
                    }
                    .padding()
                    
                    Button("Show Security Risk Warning") {
                        viewModel.showWarning(type: .securityRisk(
                            reason: "Dangerous operations detected.",
                            detectedIssues: ["eval() usage", "exec() call"]
                        ))
                    }
                    .padding()
                }
                
                RunnerWarningView(viewModel: viewModel)
            }
        }
    }
    
    return AnimationDemo()
}
