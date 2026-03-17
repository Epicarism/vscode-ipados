//
//  GitHubLoginView.swift
//  VSCodeiPadOS
//
//  GitHub account login UI using Device Flow
//

import SwiftUI

struct GitHubLoginView: View {
    @ObservedObject var authManager = GitHubAuthManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            if authManager.isAuthenticated {
                authenticatedView
            } else if let deviceCode = authManager.deviceCodeResponse {
                deviceFlowView(deviceCode: deviceCode)
            } else {
                signInView
            }
            
            if let error = authManager.errorMessage {
                errorView(message: error)
            }
        }
    }
    
    // MARK: - Sign In View
    
    private var signInView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            Text("Sign in to GitHub")
                .font(.headline)
            
            Text("Access your repositories, push commits, and sync settings across devices.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    try? await authManager.startDeviceFlow()
                }
            }) {
                HStack(spacing: 8) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                    Text(authManager.isLoading ? "Connecting..." : "Sign in with GitHub")
                }
                .font(.body.weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(red: 0.14, green: 0.14, blue: 0.14))
                .cornerRadius(8)
            }
            .disabled(authManager.isLoading)
            .padding(.top, 8)
        }
        .padding()
    }
    
    // MARK: - Device Flow View
    
    private func deviceFlowView(deviceCode: DeviceCodeResponse) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            Text("Enter this code on GitHub:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // User code display
            HStack(spacing: 4) {
                Text(deviceCode.userCode)
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .tracking(2)
                
                Button(action: {
                    UIPasteboard.general.string = deviceCode.userCode
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 8)
            
            Text("Go to:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                if let url = URL(string: deviceCode.verificationUri) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text(deviceCode.verificationUri)
                    .font(.callout.weight(.medium))
                    .foregroundColor(.accentColor)
                    .underline()
            }
            
            if authManager.isPolling {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.7)
                    Text("Waiting for authorization...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            Button(action: {
                authManager.cancelLogin()
            }) {
                Text("Cancel")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
    }
    
    // MARK: - Authenticated View
    
    private var authenticatedView: some View {
        VStack(spacing: 12) {
            // User avatar and info
            HStack(spacing: 12) {
                if let user = authManager.user {
                    AsyncImage(url: URL(string: user.avatarUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                        case .failure:
                            defaultAvatar
                        case .empty:
                            ProgressView()
                                .frame(width: 48, height: 48)
                        @unknown default:
                            defaultAvatar
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name ?? user.login)
                            .font(.headline)
                        Text("@\(user.login)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let bio = user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                } else {
                    defaultAvatar
                    VStack(alignment: .leading, spacing: 2) {
                        Text("GitHub Connected")
                            .font(.headline)
                        Text("Loading profile...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Stats row
            if let user = authManager.user {
                HStack(spacing: 16) {
                    statBadge(icon: "book.closed", value: user.publicRepos ?? 0, label: "repos")
                    statBadge(icon: "person.2", value: user.followers ?? 0, label: "followers")
                    statBadge(icon: "person.badge.plus", value: user.following ?? 0, label: "following")
                    Spacer()
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            // Sign out button
            Button(action: {
                authManager.logout()
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .font(.callout)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding()
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.orange)
            Spacer()
            Button(action: { authManager.errorMessage = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(6)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Helpers
    
    private var defaultAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .frame(width: 48, height: 48)
            .foregroundColor(.secondary)
    }
    
    private func statBadge(icon: String, value: Int, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.caption.weight(.semibold))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    GitHubLoginView()
}
