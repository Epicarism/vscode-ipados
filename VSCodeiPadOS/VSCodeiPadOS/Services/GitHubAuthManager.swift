//
//  GitHubAuthManager.swift
//  VSCodeiPadOS
//
//  GitHub OAuth using Device Flow (RFC 8628)
//  Works on iPad without redirect URIs
//

import Foundation
import SwiftUI

// MARK: - GitHub User Model

struct GitHubUser: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let name: String?
    let email: String?
    let bio: String?
    let publicRepos: Int?
    let followers: Int?
    let following: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, email, bio, followers, following
        case avatarUrl = "avatar_url"
        case publicRepos = "public_repos"
    }
}

// MARK: - Device Code Response

struct DeviceCodeResponse: Codable {
    let deviceCode: String
    let userCode: String
    let verificationUri: String
    let expiresIn: Int
    let interval: Int
    
    enum CodingKeys: String, CodingKey {
        case interval
        case deviceCode = "device_code"
        case userCode = "user_code"
        case verificationUri = "verification_uri"
        case expiresIn = "expires_in"
    }
}

// MARK: - Auth Errors

enum GitHubAuthError: Error, LocalizedError {
    case deviceFlowFailed(String)
    case tokenPollExpired
    case tokenPollDenied
    case networkError(Error)
    case invalidResponse
    case userFetchFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .deviceFlowFailed(let msg): return "Device flow failed: \(msg)"
        case .tokenPollExpired: return "Login expired. Please try again."
        case .tokenPollDenied: return "Login was denied by user."
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .invalidResponse: return "Invalid response from GitHub."
        case .userFetchFailed(let msg): return "Failed to fetch user: \(msg)"
        }
    }
}

// MARK: - GitHub Auth Manager

@MainActor
class GitHubAuthManager: ObservableObject {
    static let shared = GitHubAuthManager()
    
    // ═══════════════════════════════════════════════════════════════════════════════
    // GITHUB OAUTH APP SETUP (Required for login to work)
    // ═══════════════════════════════════════════════════════════════════════════════
    // 1. Go to: https://github.com/settings/applications/new
    // 2. Fill in:
    //    - Application name: "VSCode iPadOS"
    //    - Homepage URL: "https://github.com/your-username/vscode-ipados"
    //    - Authorization callback URL: "https://github.com/" (not used for device flow)
    // 3. Click "Register application"
    // 4. On the app page, check "Enable Device Flow" under "Device Authorization"
    // 5. Copy the "Client ID" (starts with "Ov23li...") and paste below
    // ═══════════════════════════════════════════════════════════════════════════════
    private static let clientID = "178c6fc778ccc68e1d6a" // GitHub CLI's public client ID (works for device flow)
    private static let scope = "repo user read:org"
    
    // MARK: - Published State
    
    @Published var isAuthenticated = false
    @Published var user: GitHubUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    /// Active device code response (shown to user during login)
    @Published var deviceCodeResponse: DeviceCodeResponse?
    
    /// Whether we're currently polling for the token
    @Published var isPolling = false
    
    private var pollTask: Task<Void, Never>?
    
    // MARK: - Init
    
    private init() {
        checkExistingAuth()
    }
    
    // MARK: - Check Existing Auth
    
    func checkExistingAuth() {
        guard let token = KeychainManager.shared.getGitHubToken() else {
            isAuthenticated = false
            user = nil
            return
        }
        
        isAuthenticated = true
        
        // Fetch user profile in background
        Task {
            do {
                try await fetchUser(token: token)
            } catch {
                // Token might be expired/revoked
                AppLogger.git.error("Failed to fetch user with stored token: \(error)")
                // Don't logout - token might still work for API calls
                // User can manually logout if needed
            }
        }
    }
    
    // MARK: - Device Flow Login
    
    /// Step 1: Request a device code from GitHub
    func startDeviceFlow() async throws {
        isLoading = true
        errorMessage = nil
        deviceCodeResponse = nil
        
        defer { isLoading = false }
        
        let url = URL(string: "https://github.com/login/device/code")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "client_id": Self.clientID,
            "scope": Self.scope
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubAuthError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw GitHubAuthError.deviceFlowFailed("HTTP \(httpResponse.statusCode): \(errorBody)")
            }
            
            let decoder = JSONDecoder()
            let deviceCode = try decoder.decode(DeviceCodeResponse.self, from: data)
            self.deviceCodeResponse = deviceCode
            
            AppLogger.git.info("Device code received. User code: \(deviceCode.userCode)")
            AppLogger.git.debug("Verification URL: \(deviceCode.verificationUri)")
            
            // Automatically open the verification URL in Safari
            if let verifyURL = URL(string: deviceCode.verificationUri) {
                await UIApplication.shared.open(verifyURL)
            }
            
            // Start polling for token
            startPolling(
                deviceCode: deviceCode.deviceCode,
                interval: deviceCode.interval,
                expiresIn: deviceCode.expiresIn
            )
            
        } catch let error as GitHubAuthError {
            self.errorMessage = error.localizedDescription
            throw error
        } catch {
            let authError = GitHubAuthError.networkError(error)
            self.errorMessage = authError.localizedDescription
            throw authError
        }
    }
    
    // MARK: - Token Polling
    
    /// Step 2: Poll GitHub until user authorizes (or timeout)
    private func startPolling(deviceCode: String, interval: Int, expiresIn: Int) {
        // Cancel any existing poll
        pollTask?.cancel()
        isPolling = true
        
        pollTask = Task {
            let pollInterval = max(interval, 5) // GitHub minimum is 5 seconds
            let deadline = Date().addingTimeInterval(TimeInterval(expiresIn))
            
            while !Task.isCancelled && Date() < deadline {
                // Wait the required interval
                try? await Task.sleep(nanoseconds: UInt64(pollInterval) * 1_000_000_000)
                
                guard !Task.isCancelled else { break }
                
                do {
                    let token = try await pollForToken(deviceCode: deviceCode)
                    
                    // Success! Save token and fetch user
                    try? KeychainManager.shared.saveGitHubToken(token)
                    self.isAuthenticated = true
                    self.isPolling = false
                    self.deviceCodeResponse = nil
                    
                    try? await fetchUser(token: token)
                    
                    AppLogger.git.info("Successfully authenticated!")
                    
                    // Notify other parts of the app
                    NotificationCenter.default.post(
                        name: .gitHubAuthDidChange,
                        object: nil,
                        userInfo: ["authenticated": true]
                    )
                    return
                    
                } catch GitHubAuthError.tokenPollDenied {
                    self.errorMessage = "Login was denied."
                    self.isPolling = false
                    self.deviceCodeResponse = nil
                    return
                    
                } catch GitHubAuthError.tokenPollExpired {
                    // Keep polling until deadline
                    continue
                    
                } catch {
                    // authorization_pending - keep polling
                    continue
                }
            }
            
            // Timed out
            if !Task.isCancelled {
                self.errorMessage = "Login timed out. Please try again."
                self.isPolling = false
                self.deviceCodeResponse = nil
            }
        }
    }
    
    /// Single poll attempt to exchange device code for token
    private func pollForToken(deviceCode: String) async throws -> String {
        let url = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "client_id": Self.clientID,
            "device_code": deviceCode,
            "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GitHubAuthError.invalidResponse
        }
        
        // Check for access token
        if let accessToken = json["access_token"] as? String {
            return accessToken
        }
        
        // Check for error states
        if let error = json["error"] as? String {
            switch error {
            case "authorization_pending":
                throw GitHubAuthError.tokenPollExpired // Not really expired, just pending
            case "slow_down":
                // Need to increase interval - sleep extra 5 seconds
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                throw GitHubAuthError.tokenPollExpired
            case "expired_token":
                throw GitHubAuthError.tokenPollExpired
            case "access_denied":
                throw GitHubAuthError.tokenPollDenied
            default:
                let description = json["error_description"] as? String ?? error
                throw GitHubAuthError.deviceFlowFailed(description)
            }
        }
        
        throw GitHubAuthError.invalidResponse
    }
    
    // MARK: - Fetch User
    
    func fetchUser(token: String? = nil) async throws {
        let authToken = token ?? KeychainManager.shared.getGitHubToken()
        guard let authToken else {
            throw GitHubAuthError.userFetchFailed("No token available")
        }
        
        let url = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw GitHubAuthError.userFetchFailed("HTTP \(statusCode)")
        }
        
        let decoder = JSONDecoder()
        self.user = try decoder.decode(GitHubUser.self, from: data)
    }
    
    // MARK: - Logout
    
    func logout() {
        pollTask?.cancel()
        pollTask = nil
        isPolling = false
        deviceCodeResponse = nil
        
        try? KeychainManager.shared.deleteGitHubToken()
        isAuthenticated = false
        user = nil
        errorMessage = nil
        
        NotificationCenter.default.post(
            name: .gitHubAuthDidChange,
            object: nil,
            userInfo: ["authenticated": false]
        )
        
        AppLogger.git.info("Logged out")
    }
    
    // MARK: - Cancel Login
    
    func cancelLogin() {
        pollTask?.cancel()
        pollTask = nil
        isPolling = false
        deviceCodeResponse = nil
        isLoading = false
        errorMessage = nil
    }
    
    // MARK: - Token Access (for other services)
    
    /// Get the current GitHub token for API calls (used by GitManager, etc.)
    var token: String? {
        KeychainManager.shared.getGitHubToken()
    }
}
