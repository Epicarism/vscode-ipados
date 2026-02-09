import Foundation
import Security

// MARK: - Keychain Errors
enum KeychainError: Error, LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidStatus(OSStatus)
    case invalidItemFormat
    case conversionFailed
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Keychain item not found"
        case .duplicateItem:
            return "Keychain item already exists"
        case .invalidStatus(let status):
            return "Keychain error with status: \(status)"
        case .invalidItemFormat:
            return "Invalid keychain item format"
        case .conversionFailed:
            return "Failed to convert data to string"
        }
    }
}

// MARK: - Keychain Keys
enum KeychainKey: String {
    case openAIKey = "com.vscodeipad.openai_api_key"
    case anthropicKey = "com.vscodeipad.anthropic_api_key"
    case googleAIKey = "com.vscodeipad.googleai_api_key"
    case azureOpenAIKey = "com.vscodeipad.azure_openai_api_key"
    case githubToken = "com.vscodeipad.github_token"
    case gitlabToken = "com.vscodeipad.gitlab_token"
}

// MARK: - Keychain Manager
class KeychainManager {
    
    // MARK: - Properties
    static let shared = KeychainManager()
    
    private let serviceIdentifier = "com.vscodeipad.keychain"
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Core Methods
    
    /// Save a value to the keychain
    /// - Parameters:
    ///   - key: The key identifier for the item
    ///   - value: The string value to store
    ///   - service: The service identifier for the keychain item
    /// - Throws: KeychainError if the operation fails
    func save(key: String, value: String, service: String? = nil) throws {
        let serviceID = service ?? serviceIdentifier
        
        // Convert string to data
        guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.conversionFailed
        }
        
        // Check if item already exists
        let existingQuery = buildQuery(key: key, service: serviceID, returnData: false)
        let existingStatus = SecItemCopyMatching(existingQuery as CFDictionary, nil)
        
        if existingStatus == errSecSuccess {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecAttrService as String: serviceID
            ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: valueData,
                kSecAttrModificationDate as String: Date()
            ]
            
            let status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == errSecSuccess else {
                throw KeychainError.invalidStatus(status)
            }
        } else {
            // Add new item
            let query = buildQuery(key: key, service: serviceID, value: valueData)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            
            guard status == errSecSuccess else {
                throw KeychainError.invalidStatus(status)
            }
        }
    }
    
    /// Retrieve a value from the keychain
    /// - Parameters:
    ///   - key: The key identifier for the item
    ///   - service: The service identifier for the keychain item
    /// - Returns: The stored string value, or nil if not found
    /// - Throws: KeychainError if the operation fails
    func get(key: String, service: String? = nil) throws -> String? {
        let serviceID = service ?? serviceIdentifier
        
        let query = buildQuery(key: key, service: serviceID, returnData: true)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.invalidStatus(status)
        }
        
        guard let item = result as? [String: Any],
              let data = item[kSecValueData as String] as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        guard let stringValue = String(data: data, encoding: .utf8) else {
            throw KeychainError.conversionFailed
        }
        
        return stringValue
    }
    
    /// Delete a value from the keychain
    /// - Parameters:
    ///   - key: The key identifier for the item
    ///   - service: The service identifier for the keychain item
    /// - Throws: KeychainError if the operation fails
    func delete(key: String, service: String? = nil) throws {
        let serviceID = service ?? serviceIdentifier
        
        let query = buildQuery(key: key, service: serviceID, returnData: false)
        
        let status = SecItemDelete(query as CFDictionary)
        
        // errSecItemNotFound is acceptable when deleting
        if status == errSecItemNotFound {
            return
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.invalidStatus(status)
        }
    }
    
    /// Check if a key exists in the keychain
    /// - Parameters:
    ///   - key: The key identifier for the item
    ///   - service: The service identifier for the keychain item
    /// - Returns: Boolean indicating if the key exists
    func exists(key: String, service: String? = nil) -> Bool {
        do {
            let serviceID = service ?? serviceIdentifier
            let query = buildQuery(key: key, service: serviceID, returnData: false)
            
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            return status == errSecSuccess
        } catch {
            return false
        }
    }
    
    /// Delete all items for a given service
    /// - Parameter service: The service identifier
    /// - Throws: KeychainError if the operation fails
    func deleteAll(for service: String? = nil) throws {
        let serviceID = service ?? serviceIdentifier
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceID
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        // errSecItemNotFound is acceptable when bulk deleting
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.invalidStatus(status)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Build a keychain query dictionary
    private func buildQuery(key: String, service: String, value: Data? = nil, returnData: Bool = false) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service
        ]
        
        if let value = value {
            query[kSecValueData as String] = value
        }
        
        if returnData {
            query[kSecReturnData as String] = true
            query[kSecReturnAttributes as String] = true
            query[kSecMatchLimit as String] = kSecMatchLimitOne
        } else {
            query[kSecReturnData as String] = false
        }
        
        // Add accessible level - require device unlock
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        return query
    }
    
    // MARK: - Convenience Methods for Common Keys
    
    // MARK: OpenAI
    func saveOpenAIKey(_ apiKey: String) throws {
        try save(key: KeychainKey.openAIKey.rawValue, value: apiKey)
    }
    
    func getOpenAIKey() -> String? {
        return try? get(key: KeychainKey.openAIKey.rawValue)
    }
    
    func deleteOpenAIKey() throws {
        try delete(key: KeychainKey.openAIKey.rawValue)
    }
    
    var hasOpenAIKey: Bool {
        return exists(key: KeychainKey.openAIKey.rawValue)
    }
    
    // MARK: Anthropic
    func saveAnthropicKey(_ apiKey: String) throws {
        try save(key: KeychainKey.anthropicKey.rawValue, value: apiKey)
    }
    
    func getAnthropicKey() -> String? {
        return try? get(key: KeychainKey.anthropicKey.rawValue)
    }
    
    func deleteAnthropicKey() throws {
        try delete(key: KeychainKey.anthropicKey.rawValue)
    }
    
    var hasAnthropicKey: Bool {
        return exists(key: KeychainKey.anthropicKey.rawValue)
    }
    
    // MARK: Google AI
    func saveGoogleAIKey(_ apiKey: String) throws {
        try save(key: KeychainKey.googleAIKey.rawValue, value: apiKey)
    }
    
    func getGoogleAIKey() -> String? {
        return try? get(key: KeychainKey.googleAIKey.rawValue)
    }
    
    func deleteGoogleAIKey() throws {
        try delete(key: KeychainKey.googleAIKey.rawValue)
    }
    
    var hasGoogleAIKey: Bool {
        return exists(key: KeychainKey.googleAIKey.rawValue)
    }
    
    // MARK: Azure OpenAI
    func saveAzureOpenAIKey(_ apiKey: String) throws {
        try save(key: KeychainKey.azureOpenAIKey.rawValue, value: apiKey)
    }
    
    func getAzureOpenAIKey() -> String? {
        return try? get(key: KeychainKey.azureOpenAIKey.rawValue)
    }
    
    func deleteAzureOpenAIKey() throws {
        try delete(key: KeychainKey.azureOpenAIKey.rawValue)
    }
    
    var hasAzureOpenAIKey: Bool {
        return exists(key: KeychainKey.azureOpenAIKey.rawValue)
    }
    
    // MARK: GitHub
    func saveGitHubToken(_ token: String) throws {
        try save(key: KeychainKey.githubToken.rawValue, value: token)
    }
    
    func getGitHubToken() -> String? {
        return try? get(key: KeychainKey.githubToken.rawValue)
    }
    
    func deleteGitHubToken() throws {
        try delete(key: KeychainKey.githubToken.rawValue)
    }
    
    var hasGitHubToken: Bool {
        return exists(key: KeychainKey.githubToken.rawValue)
    }
    
    // MARK: GitLab
    func saveGitLabToken(_ token: String) throws {
        try save(key: KeychainKey.gitlabToken.rawValue, value: token)
    }
    
    func getGitLabToken() -> String? {
        return try? get(key: KeychainKey.gitlabToken.rawValue)
    }
    
    func deleteGitLabToken() throws {
        try delete(key: KeychainKey.gitlabToken.rawValue)
    }
    
    var hasGitLabToken: Bool {
        return exists(key: KeychainKey.gitlabToken.rawValue)
    }
    
    // MARK: - Validation Helpers
    
    /// Validate that an API key is not empty and meets minimum length requirements
    func validateAPIKey(_ key: String, minimumLength: Int = 10) -> Bool {
        return !key.isEmpty && key.count >= minimumLength
    }
    
    /// Mask an API key for display purposes
    func maskAPIKey(_ key: String) -> String {
        guard key.count > 8 else { return "****" }
        let prefix = String(key.prefix(4))
        let suffix = String(key.suffix(4))
        return "\(prefix)...\(suffix)"
    }
}

// MARK: - SwiftUI Integration
#if canImport(SwiftUI)
import SwiftUI

@propertyWrapper
struct KeychainStorage: DynamicProperty {
    private let key: String
    private let service: String?
    
    init(_ key: String, service: String? = nil) {
        self.key = key
        self.service = service
    }
    
    var wrappedValue: String? {
        get {
            try? KeychainManager.shared.get(key: key, service: service)
        }
        nonmutating set {
            if let newValue = newValue {
                try? KeychainManager.shared.save(key: key, value: newValue, service: service)
            } else {
                try? KeychainManager.shared.delete(key: key, service: service)
            }
        }
    }
}
#endif