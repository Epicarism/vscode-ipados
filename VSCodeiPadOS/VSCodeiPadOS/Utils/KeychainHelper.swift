import Foundation
import Security

/// A lightweight wrapper around the iOS Keychain for securely storing API keys.
/// Replaces `@AppStorage` (UserDefaults) which stores keys in plaintext.
final class KeychainHelper {
    static let shared = KeychainHelper()
    
    private let service = "com.vscode-ipados.api-keys"
    
    private init() {}
    
    // MARK: - Public API
    
    /// Save a string value to Keychain for the given key.
    @discardableResult
    func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing item first
        delete(key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieve a string value from Keychain for the given key.
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    /// Delete a value from Keychain for the given key.
    @discardableResult
    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Check if a value exists in Keychain for the given key.
    func exists(_ key: String) -> Bool {
        get(key) != nil
    }
    
    // MARK: - Migration
    
    /// Migrate API keys from UserDefaults to Keychain.
    /// Call once on app launch. Removes keys from UserDefaults after migration.
    static func migrateFromUserDefaults() {
        let keysToMigrate = [
            "openai_api_key",
            "anthropic_api_key",
            "google_api_key",
            "kimi_api_key",
            "glm_api_key",
            "groq_api_key",
            "deepseek_api_key",
            "mistral_api_key"
        ]
        
        let defaults = UserDefaults.standard
        let keychain = KeychainHelper.shared
        
        for key in keysToMigrate {
            if let value = defaults.string(forKey: key), !value.isEmpty {
                // Only migrate if not already in keychain
                if keychain.get(key) == nil {
                    keychain.set(value, forKey: key)
                    AppLogger.general.info("Migrated \(key) from UserDefaults to Keychain")
                }
                // Remove from UserDefaults (plaintext)
                defaults.removeObject(forKey: key)
            }
        }
    }
}

// MARK: - Convenience API Key Constants

extension KeychainHelper {
    static let openAIKey = "openai_api_key"
    static let anthropicKey = "anthropic_api_key"
    static let googleKey = "google_api_key"
    static let kimiKey = "kimi_api_key"
    static let glmKey = "glm_api_key"
    static let groqKey = "groq_api_key"
    static let deepseekKey = "deepseek_api_key"
    static let mistralKey = "mistral_api_key"
}
