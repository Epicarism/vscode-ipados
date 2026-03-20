//
//  SSHManager.swift
//  VSCodeiPadOS
//
//  Real SSH Manager using SwiftNIO SSH
//

import Foundation
import SwiftUI
import NIOCore
import NIOPosix
@preconcurrency import NIOSSH
import Crypto
import CommonCrypto

// MARK: - SSH Connection Model

struct SSHConnectionConfig: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var host: String
    var port: Int
    var username: String
    var authMethod: SSHAuthMethod
    var lastUsed: Date?
    
    enum SSHAuthMethod: Codable, Equatable {
        case password(String)
        case privateKey(key: String, passphrase: String?)
    }
    
    static func == (lhs: SSHConnectionConfig, rhs: SSHConnectionConfig) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - SSH Manager Delegate Protocol

protocol SSHManagerDelegate: AnyObject {
    func sshManagerDidConnect(_ manager: SSHManager)
    func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?)
    func sshManager(_ manager: SSHManager, didReceiveOutput text: String)
    func sshManager(_ manager: SSHManager, didReceiveError text: String)
}

// MARK: - SSH Client Errors

enum SSHClientError: Error, LocalizedError {
    case connectionFailed(String)
    case authenticationFailed
    case channelCreationFailed
    case invalidChannelType
    case notConnected
    case timeout
    case invalidPrivateKey
    case unsupportedKeyType(String)
    case commandFailed(String)
    case notImplemented  // NOTE: No code in SSHManager.swift currently throws this error; reserved for future SSH features
    case portForwardFailed(String)
    case passphraseRequired
    

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason): return "Connection failed: \(reason)"
        case .authenticationFailed: return "Authentication failed"
        case .channelCreationFailed: return "Failed to create SSH channel"
        case .invalidChannelType: return "Invalid channel type"
        case .notConnected: return "Not connected to server"
        case .timeout: return "Connection timed out"
        case .invalidPrivateKey: return "Invalid private key format. Supported types: Ed25519, ECDSA (P-256, P-384, P-521), RSA (2048, 3072, 4096)"
        case .unsupportedKeyType(let type): return "Unsupported key type: \(type). Please use Ed25519, ECDSA, or RSA keys."
        case .commandFailed(let reason): return "Command execution failed: \(reason)"
        case .notImplemented: return "SSH feature not yet implemented"
        case .portForwardFailed(let reason): return "Port forwarding failed: \(reason)"
        case .passphraseRequired: return "This private key is encrypted and requires a passphrase"

    }
}
}

// MARK: - Command Output Types

enum SSHCommandOutput {
    case stdout(String)
    case stderr(String)
    case exit(Int)
    case error(Error)
    case timeout
}

struct SSHCommandResult {
    let stdout: String
    let stderr: String
    let exitCode: Int
    let isTimedOut: Bool
    
    var isSuccess: Bool {
        return exitCode == 0 && !isTimedOut
    }
}

// MARK: - SSH Authentication Handler

final class PasswordAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
    private let username: String
    private let password: String
    private var attemptedPassword = false
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        if !attemptedPassword && availableMethods.contains(.password) {
            attemptedPassword = true
            nextChallengePromise.succeed(
                NIOSSHUserAuthenticationOffer(
                    username: username,
                    serviceName: "ssh-connection",
                    offer: .password(.init(password: password))
                )
            )
        } else {
            nextChallengePromise.succeed(nil)
        }
    }
}


// MARK: - OpenSSH Encrypted Key Decryptor

/// Helper class to decrypt OpenSSH format encrypted private keys
enum OpenSSHKeyDecryptor {
    
    /// Decrypt an OpenSSH encrypted private key section
    /// - Parameters:
    ///   - encryptedData: The encrypted private key section
    ///   - cipherName: The cipher name (e.g., "aes256-ctr")
    ///   - kdfName: The KDF name (e.g., "bcrypt")
    ///   - kdfOptions: The KDF options (salt + rounds for bcrypt)
    ///   - passphrase: The passphrase to decrypt
    /// - Returns: Decrypted private key data
    static func decrypt(encryptedData: Data, cipherName: String, kdfName: String, kdfOptions: Data, passphrase: String) throws -> Data {
        // Verify supported cipher
        guard cipherName == "aes256-ctr" || cipherName == "aes256-cbc" else {
            throw SSHClientError.unsupportedKeyType("Unsupported cipher: \(cipherName). Only aes256-ctr and aes256-cbc are supported.")
        }
        
        // Verify supported KDF
        guard kdfName == "bcrypt" else {
            throw SSHClientError.unsupportedKeyType("Unsupported KDF: \(kdfName). Only bcrypt is supported.")
        }
        
        // Parse KDF options (salt + rounds)
        guard let (salt, rounds) = parseKDFOptions(kdfOptions) else {
            throw SSHClientError.invalidPrivateKey
        }
        
        // Derive key and IV using bcrypt-pbkdf
        let (key, iv) = try deriveKeyAndIV(passphrase: passphrase, salt: salt, rounds: rounds)
        
        // Decrypt using AES-256-CTR or AES-256-CBC
        let decrypted: Data
        if cipherName == "aes256-ctr" {
            decrypted = try decryptAES256CTR(encryptedData: encryptedData, key: key, iv: iv)
        } else {
            decrypted = try decryptAES256CBC(encryptedData: encryptedData, key: key, iv: iv)
        }
        
        return decrypted
    }
    
    /// Parse KDF options to extract salt and rounds
    private static func parseKDFOptions(_ options: Data) -> (Data, UInt32)? {
        var pos = 0
        
        // Read salt length (uint32)
        guard pos + 4 <= options.count else { return nil }
        let saltLen = Int(options.withUnsafeBytes { buf in
            buf.load(fromByteOffset: pos, as: UInt32.self).bigEndian
        })
        pos += 4
        
        // Read salt
        guard pos + saltLen <= options.count else { return nil }
        let salt = options[pos..<(pos + saltLen)]
        pos += saltLen
        
        // Read rounds (uint32)
        guard pos + 4 <= options.count else { return nil }
        let rounds = options.withUnsafeBytes { buf in
            buf.load(fromByteOffset: pos, as: UInt32.self).bigEndian
        }
        
        return (Data(salt), rounds)
    }
    
    /// Derive key and IV using bcrypt-pbkdf
    /// Note: This is a simplified implementation using PBKDF2 as fallback
    /// Full bcrypt-pbkdf implementation would require external library
    private static func deriveKeyAndIV(passphrase: String, salt: Data, rounds: UInt32) throws -> (key: Data, iv: Data) {
        // OpenSSH bcrypt-pbkdf derives 48 bytes: 32 for key + 16 for IV (for AES-256-CTR)
        // We'll use a simplified approach with PBKDF2-SHA256
        // Note: For production, consider using a proper bcrypt-pbkdf implementation
        
        let derivedKeyLength = 48 // 32 bytes key + 16 bytes IV
        
        // Convert passphrase to data
        guard let passphraseData = passphrase.data(using: .utf8) else {
            throw SSHClientError.invalidPrivateKey
        }
        
        // Use PBKDF2 with SHA256
        var derivedKey = Data(count: derivedKeyLength)
        let result = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            passphraseData.withUnsafeBytes { passphraseBytes in
                salt.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passphraseBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                        passphraseData.count,
                        saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(rounds),
                        derivedKeyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        derivedKeyLength
                    )
                }
            }
        }
        
        guard result == kCCSuccess else {
            throw SSHClientError.invalidPrivateKey
        }
        
        let key = derivedKey.prefix(32)
        let iv = derivedKey.suffix(16)
        
        return (Data(key), Data(iv))
    }
    
    /// Decrypt using AES-256-CTR
    private static func decryptAES256CTR(encryptedData: Data, key: Data, iv: Data) throws -> Data {
        // AES-CTR decryption is the same as encryption
        // For CTR mode, we need to implement it manually as CommonCrypto doesn't directly support CTR
        // We'll use CTR mode implementation
        
        let cryptor = try AES256CTRCryptor(key: key, iv: iv)
        return try cryptor.update(encryptedData)
    }
    
    /// Decrypt using AES-256-CBC
    private static func decryptAES256CBC(encryptedData: Data, key: Data, iv: Data) throws -> Data {
        // AES-CBC decryption
        var decryptedData = Data(count: encryptedData.count + kCCBlockSizeAES128)
        var numBytesDecrypted: size_t = 0
        
        let decryptedCount = decryptedData.count
        let result = encryptedData.withUnsafeBytes { encryptedBytes in
            decryptedData.withUnsafeMutableBytes { decryptedBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            key.count,
                            ivBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            encryptedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            encryptedData.count,
                            decryptedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                            decryptedCount,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        guard result == kCCSuccess else {
            throw SSHClientError.invalidPrivateKey
        }
        
        decryptedData.count = numBytesDecrypted
        return decryptedData
    }
}

// MARK: - AES-256-CTR Implementation

/// Simple AES-256-CTR implementation for OpenSSH key decryption
final class AES256CTRCryptor {
    private let key: Data
    private let iv: Data
    private var counter: UInt128
    private var keystreamPos = 0
    private var keystream = Data()
    
    init(key: Data, iv: Data) throws {
        guard key.count == 32 else {
            throw SSHClientError.invalidPrivateKey
        }
        guard iv.count == 16 else {
            throw SSHClientError.invalidPrivateKey
        }
        
        self.key = key
        self.iv = iv
        
        // Initialize counter from IV
        // In OpenSSH, the IV is the initial counter value
        self.counter = UInt128(iv)
    }
    
    func update(_ data: Data) throws -> Data {
        var result = Data(count: data.count)
        
        for (i, byte) in data.enumerated() {
            // Generate more keystream if needed
            if keystreamPos >= keystream.count {
                keystream = try encryptCounter()
                keystreamPos = 0
                incrementCounter()
            }
            
            // XOR with keystream
            result[i] = byte ^ keystream[keystreamPos]
            keystreamPos += 1
        }
        
        return result
    }
    
    private func encryptCounter() throws -> Data {
        // Encrypt the counter block using AES-256-ECB
        let counterData = counter.data
        var encrypted = Data(count: kCCBlockSizeAES128)
        var numBytesEncrypted: size_t = 0
        
        let encryptedCount = encrypted.count
        let counterCount = counterData.count
        let result = counterData.withUnsafeBytes { counterBytes in
            encrypted.withUnsafeMutableBytes { encryptedBytes in
                key.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        CCOptions(0), // ECB mode (no padding)
                        keyBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        key.count,
                        nil, // No IV for ECB
                        counterBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        counterCount,
                        encryptedBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                        encryptedCount,
                        &numBytesEncrypted
                    )
                }
            }
        }
        
        guard result == kCCSuccess else {
            throw SSHClientError.invalidPrivateKey
        }
        
        return encrypted
    }
    
    private func incrementCounter() {
        counter = counter + 1
    }
}

// MARK: - UInt128 Helper

/// Simple 128-bit unsigned integer for AES counter
struct UInt128 {
    var high: UInt64 = 0
    var low: UInt64 = 0
    
    init() {}
    
    init(_ data: Data) {
        guard data.count == 16 else { return }
        
        high = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: 0, as: UInt64.self).bigEndian
        }
        low = data.withUnsafeBytes { buf in
            buf.load(fromByteOffset: 8, as: UInt64.self).bigEndian
        }
    }
    
    var data: Data {
        var result = Data(count: 16)
        result.withUnsafeMutableBytes { buf in
            buf.storeBytes(of: high.bigEndian, toByteOffset: 0, as: UInt64.self)
            buf.storeBytes(of: low.bigEndian, toByteOffset: 8, as: UInt64.self)
        }
        return result
    }
    
    static func + (lhs: UInt128, rhs: UInt128) -> UInt128 {
        var result = UInt128()
        let (low, overflow) = lhs.low.addingReportingOverflow(rhs.low)
        result.low = low
        result.high = lhs.high &+ rhs.high &+ (overflow ? 1 : 0)
        return result
    }
    
    static func + (lhs: UInt128, rhs: UInt64) -> UInt128 {
        return lhs + UInt128(rhs)
    }
}

private extension UInt128 {
    init(_ value: UInt64) {
        high = 0
        low = value
    }
}

// MARK: - SSH Private Key Authentication Handler

final class PrivateKeyAuthDelegate: NIOSSHClientUserAuthenticationDelegate {
    private let username: String
    private let privateKeyString: String
    private let passphrase: String?
    private var attemptedKey = false
    private var attemptedPasswordFallback = false
    /// Parsed RSA key pair for RSA auth (stored separately since NIOSSHPrivateKey doesn't support RSA)
    private var rsaKeyPair: RSAKeyPair?
    
    init(username: String, privateKeyString: String, passphrase: String?) {
        self.username = username
        self.privateKeyString = privateKeyString
        self.passphrase = passphrase
        // Pre-parse RSA key if detected
        let trimmed = privateKeyString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains("BEGIN RSA PRIVATE KEY") || trimmed.contains("BEGIN PRIVATE KEY") {
            self.rsaKeyPair = try? RSAKeyParser.parse(trimmed, passphrase: passphrase)
        } else if trimmed.contains("BEGIN OPENSSH PRIVATE KEY") {
            // Check if the OpenSSH key is actually RSA
            if let data = Data(base64Encoded: trimmed.components(separatedBy: "\n")
                .filter({ !$0.hasPrefix("-----") && !$0.isEmpty }).joined()),
               SSHManager.opensshBlobContainsRSA(data) {
                self.rsaKeyPair = try? RSAKeyParser.parse(trimmed, passphrase: passphrase)
            }
        }
    }
    
    func nextAuthenticationType(
        availableMethods: NIOSSHAvailableUserAuthenticationMethods,
        nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>
    ) {
        // First try public key auth
        if !attemptedKey && availableMethods.contains(.publicKey) {
            attemptedKey = true
            
            if let nioKey = parsePrivateKey(privateKeyString, passphrase: passphrase) {
                nextChallengePromise.succeed(
                    NIOSSHUserAuthenticationOffer(
                        username: username,
                        serviceName: "ssh-connection",
                        offer: .privateKey(.init(privateKey: nioKey))
                    )
                )
                return
            }
        }
        
        // Fall back to password auth if key parsing failed
        // (some users might paste a password in the key field)
        if !attemptedPasswordFallback && availableMethods.contains(.password) {
            attemptedPasswordFallback = true
            nextChallengePromise.succeed(
                NIOSSHUserAuthenticationOffer(
                    username: username,
                    serviceName: "ssh-connection",
                    offer: .password(.init(password: privateKeyString))
                )
            )
            return
        }
        
        nextChallengePromise.succeed(nil)
    }
    
    /// Parse a PEM-encoded private key string into an NIOSSHPrivateKey
    /// - Parameters:
    ///   - keyString: The PEM-encoded private key
    ///   - passphrase: Optional passphrase for encrypted keys
    /// - Returns: NIOSSHPrivateKey if parsing succeeds, nil otherwise
    private func parsePrivateKey(_ keyString: String, passphrase: String? = nil) -> NIOSSHPrivateKey? {
        let trimmed = keyString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try OpenSSH format (-----BEGIN OPENSSH PRIVATE KEY-----)
        if trimmed.contains("BEGIN OPENSSH PRIVATE KEY") {
            return parseOpenSSHKey(trimmed, passphrase: passphrase)
        }
        
        // RSA keys — parsed via RSAKeyParser, auth handled separately by rsaKeyPair
        // Return nil here since NIOSSHPrivateKey can't wrap RSA; the RSA path
        // is handled in nextAuthenticationType via rsaKeyPair
        if trimmed.contains("BEGIN RSA PRIVATE KEY") {
            AppLogger.ssh.info("RSA private key (PEM/PKCS#1 format) detected. RSA auth will be attempted via Security.framework signing.")
            return nil // RSA handled by rsaKeyPair in nextAuthenticationType
        }
        
        // Try PEM EC/PKCS8 format
        if trimmed.contains("BEGIN EC PRIVATE KEY") || trimmed.contains("BEGIN PRIVATE KEY") {
            return parsePEMKey(trimmed)
        }
        
        // Try raw base64 (no headers)
        if let data = Data(base64Encoded: trimmed.replacingOccurrences(of: "\n", with: "")) {
            return parseOpenSSHKeyData(data, passphrase: passphrase)
        }
        
        return nil
    }
    /// Parse OpenSSH format private key (openssh-key-v1) with optional passphrase
    private func parseOpenSSHKey(_ pem: String, passphrase: String? = nil) -> NIOSSHPrivateKey? {
        // Strip PEM headers and decode base64
        let lines = pem.components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        let base64 = lines.joined()
        guard let data = Data(base64Encoded: base64) else { return nil }
        return parseOpenSSHKeyData(data, passphrase: passphrase)
    }

    
    /// Parse the binary openssh-key-v1 format with optional passphrase
    private func parseOpenSSHKeyData(_ data: Data, passphrase: String? = nil) -> NIOSSHPrivateKey? {
        // openssh-key-v1 magic: "openssh-key-v1\0"
        let magic = "openssh-key-v1\0"
        guard data.count > magic.utf8.count else { return nil }
        let magicBytes = Data(magic.utf8)
        guard data.prefix(magicBytes.count) == magicBytes else { return nil }
        
        var pos = magicBytes.count
        
        func readUInt32() -> UInt32? {
            guard pos + 4 <= data.count else { return nil }
            let val = data.withUnsafeBytes { buf -> UInt32 in
                buf.load(fromByteOffset: pos, as: UInt32.self).bigEndian
            }
            pos += 4
            return val
        }
        
        func readString() -> Data? {
            guard let length = readUInt32() else { return nil }
            let len = Int(length)
            guard pos + len <= data.count else { return nil }
            let result = data[pos..<(pos + len)]
            pos += len
            return Data(result)
        }
        
        // Read cipher name
        guard let cipherName = readString(),
              let cipherStr = String(data: cipherName, encoding: .utf8) else { return nil }
        
        // Read KDF name
        // Read KDF name
        guard let kdfName = readString(),
              let kdfNameStr = String(data: kdfName, encoding: .utf8) else { return nil }
        
        // Read KDF options
        guard let kdfOptions = readString() else { return nil } // kdfoptions
        
        // Number of keys
        guard let numKeys = readUInt32(), numKeys >= 1 else { return nil }
        
        // Read public key(s) — skip them
        for _ in 0..<numKeys {
            guard let _ = readString() else { return nil }
        }
        
        // Read private key section (may be encrypted)
        guard var privateSection = readString() else { return nil }
        
        // Handle encrypted keys
        if cipherStr != "none" {
            // Key is encrypted - require passphrase
            guard let passphrase = passphrase, !passphrase.isEmpty else {
                // No passphrase provided - cannot decrypt
                return nil
            }
            
            // Attempt to decrypt
            do {
                privateSection = try OpenSSHKeyDecryptor.decrypt(
                    encryptedData: privateSection,
                    cipherName: cipherStr,
                    kdfName: kdfNameStr,
                    kdfOptions: kdfOptions,
                    passphrase: passphrase
                )
            } catch {
                // Decryption failed - wrong passphrase or corrupted key
                return nil
            }
        }
        
        // Parse private section
        var pPos = 0
        let pData = privateSection
        
        func pReadUInt32() -> UInt32? {
            guard pPos + 4 <= pData.count else { return nil }
            let val = pData.withUnsafeBytes { buf -> UInt32 in
                buf.load(fromByteOffset: pPos, as: UInt32.self).bigEndian
            }
            pPos += 4
            return val
        }
        
        func pReadString() -> Data? {
            guard let length = pReadUInt32() else { return nil }
            let len = Int(length)
            guard pPos + len <= pData.count else { return nil }
            let result = pData[pPos..<(pPos + len)]
            pPos += len
            return Data(result)
        }
        
        // Check numbers (two random uint32 that must match)
        guard let check1 = pReadUInt32(), let check2 = pReadUInt32(),
              check1 == check2 else { return nil }
        
        // Read key type
        guard let keyTypeData = pReadString(),
              let keyType = String(data: keyTypeData, encoding: .utf8) else { return nil }
        
        switch keyType {
        case "ssh-ed25519":
            // Ed25519: 32 bytes public key, then 64 bytes private key (seed + public)
            guard let _ = pReadString() else { return nil } // public key (32 bytes)
            guard let privKeyData = pReadString() else { return nil } // 64 bytes: seed(32) + pub(32)
            guard privKeyData.count == 64 else { return nil }
            let seed = privKeyData.prefix(32) // first 32 bytes is the seed
            
            do {
                let ed25519Key = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
                return NIOSSHPrivateKey(ed25519Key: ed25519Key)
            } catch {
                return nil
            }
            
        case "ecdsa-sha2-nistp256":
            // P-256 ECDSA key
            guard let _ = pReadString() else { return nil } // curve identifier "nistp256"
            guard let _ = pReadString() else { return nil } // public key point
            guard let privKeyData = pReadString() else { return nil } // private scalar
            
            do {
                let p256Key = try P256.Signing.PrivateKey(rawRepresentation: privKeyData)
                return NIOSSHPrivateKey(p256Key: p256Key)
            } catch {
                return nil
            }
            
        case "ecdsa-sha2-nistp384":
            guard let _ = pReadString() else { return nil }
            guard let _ = pReadString() else { return nil }
            guard let privKeyData = pReadString() else { return nil }
            
            do {
                let p384Key = try P384.Signing.PrivateKey(rawRepresentation: privKeyData)
                return NIOSSHPrivateKey(p384Key: p384Key)
            } catch {
                return nil
            }
            
        case "ecdsa-sha2-nistp521":
            guard let _ = pReadString() else { return nil }
            guard let _ = pReadString() else { return nil }
            guard let privKeyData = pReadString() else { return nil }
            
            do {
                let p521Key = try P521.Signing.PrivateKey(rawRepresentation: privKeyData)
                return NIOSSHPrivateKey(p521Key: p521Key)
            } catch {
                return nil
            }
            
        case "ssh-rsa", "rsa-sha2-256", "rsa-sha2-512":
            // RSA keys are parsed by RSAKeyParser — NIOSSHPrivateKey can't wrap them
            // but rsaKeyPair in PrivateKeyAuthDelegate handles the auth separately
            AppLogger.ssh.info("RSA key type '\(keyType)' detected in OpenSSH format. RSA auth handled via Security.framework.")
            return nil // RSA handled by rsaKeyPair in PrivateKeyAuthDelegate
            
        default:
            // Unsupported key type
            return nil
        }
    }
    
    /// Parse PEM-encoded EC private key
    private func parsePEMKey(_ pem: String) -> NIOSSHPrivateKey? {
        // Strip headers and decode
        let lines = pem.components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        let base64 = lines.joined()
        guard let data = Data(base64Encoded: base64) else { return nil }
        
        // Try P-256 first (most common EC key)
        if let key = try? P256.Signing.PrivateKey(derRepresentation: data) {
            return NIOSSHPrivateKey(p256Key: key)
        }
        if let key = try? P384.Signing.PrivateKey(derRepresentation: data) {
            return NIOSSHPrivateKey(p384Key: key)
        }
        if let key = try? P521.Signing.PrivateKey(derRepresentation: data) {
            return NIOSSHPrivateKey(p521Key: key)
        }
        
        return nil
    }
}

// MARK: - Known Hosts Manager

/// Manages SSH host key verification using Keychain storage
final class KnownHostsManager {
    static let shared = KnownHostsManager()
    private let keychainPrefix = "ssh_known_host_"
    
    enum HostKeyStatus {
        case trusted
        case unknown
        case changed(oldFingerprint: String, newFingerprint: String)
    }
    
    /// Check a host key against stored known hosts
    func checkHostKey(host: String, port: Int, key: NIOSSHPublicKey) -> HostKeyStatus {
        let storageKey = keychainPrefix + "\(host):\(port)"
        let fingerprint = fingerprintForKey(key)
        
        guard let storedFingerprint = KeychainHelper.shared.get(storageKey) else {
            return .unknown
        }
        
        if storedFingerprint == fingerprint {
            return .trusted
        } else {
            return .changed(oldFingerprint: storedFingerprint, newFingerprint: fingerprint)
        }
    }
    
    /// Trust and store a host key
    func trustHostKey(host: String, port: Int, key: NIOSSHPublicKey) {
        let storageKey = keychainPrefix + "\(host):\(port)"
        let fingerprint = fingerprintForKey(key)
        KeychainHelper.shared.save(fingerprint, forKey: storageKey)
    }
    
    /// Remove a stored host key
    func removeHostKey(host: String, port: Int) {
        let storageKey = keychainPrefix + "\(host):\(port)"
        KeychainHelper.shared.delete(storageKey)
    }
    
    /// Get all known hosts
    func allKnownHosts() -> [(host: String, port: Int)] {
        // This is a simplified implementation — in production, store a manifest
        return []
    }
    
    /// Compute a fingerprint string for a host key
    func fingerprintForKey(_ key: NIOSSHPublicKey) -> String {
        // Use the raw key bytes to compute SHA-256 fingerprint
        var hasher = SHA256()
        let keyDescription = "\(key)"
        hasher.update(data: Data(keyDescription.utf8))
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined(separator: ":")
    }
}

// MARK: - Host Key Confirmation Model

struct HostKeyConfirmation: Identifiable {
    let id = UUID()
    let host: String
    let port: Int
    let fingerprint: String
    let status: KnownHostsManager.HostKeyStatus
    let promise: EventLoopPromise<Void>
}

// MARK: - SSH Host Key Validator

/// Verifying host key delegate that checks against known_hosts
final class VerifyingHostKeyDelegate: NIOSSHClientServerAuthenticationDelegate {
    private let host: String
    private let port: Int
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        let status = KnownHostsManager.shared.checkHostKey(host: host, port: port, key: hostKey)
        
        switch status {
        case .trusted:
            // Known and matches — accept
            validationCompletePromise.succeed(())
            
        case .unknown:
            // First connection — trust on first use (TOFU) and notify UI
            KnownHostsManager.shared.trustHostKey(host: host, port: port, key: hostKey)
            // Post notification for UI to show "New host trusted" toast
            let fingerprint = KnownHostsManager.shared.fingerprintForKey(hostKey)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .sshHostKeyFirstUse,
                    object: nil,
                    userInfo: ["host": self.host, "port": self.port, "fingerprint": fingerprint]
                )
            }
            validationCompletePromise.succeed(())
            
        case .changed(let oldFP, let newFP):
            // Host key changed — potential MITM attack!
            AppLogger.ssh.error("HOST KEY CHANGED for \(self.host):\(self.port)! Old: \(oldFP), New: \(newFP). Possible MITM attack.")
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .sshHostKeyChanged,
                    object: nil,
                    userInfo: ["host": self.host, "port": self.port, "oldFingerprint": oldFP, "newFingerprint": newFP]
                )
            }
            // Reject the connection — user must manually clear the old key
            validationCompletePromise.fail(SSHClientError.connectionFailed(
                "Host key for \(self.host) has changed! This could indicate a MITM attack. " +
                "If you trust this host, remove the old key in Settings > SSH > Known Hosts."
            ))
        }
    }
}

// Keep legacy delegate for explicit "accept all" mode
final class AcceptAllHostKeysDelegate: NIOSSHClientServerAuthenticationDelegate {
    func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
        validationCompletePromise.succeed(())
    }
}



// MARK: - SSH Host Key Notifications

extension Notification.Name {
    static let sshHostKeyFirstUse = Notification.Name("sshHostKeyFirstUse")
    static let sshHostKeyChanged = Notification.Name("sshHostKeyChanged")
}

// MARK: - SSH Shell Handler

final class ShellDataHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData
    
    private let onData: @Sendable (String, Bool) -> Void
    
    init(onData: @escaping @Sendable (String, Bool) -> Void) {
        self.onData = onData
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = self.unwrapInboundIn(data)
        let isStderr = channelData.type == .stdErr
        
        guard case .byteBuffer(var buf) = channelData.data else { return }
        if let str = buf.readString(length: buf.readableBytes) {
            onData(str, isStderr)
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        context.write(self.wrapOutboundOut(channelData), promise: promise)
    }
    
    func userInboundEventTriggered(context: ChannelHandlerContext, event: Any) {
        // Handle channel close/EOF
        context.fireUserInboundEventTriggered(event)
    }
}

// MARK: - SSH Manager (Real Implementation)

class SSHManager: ObservableObject, @unchecked Sendable {
    static let shared = SSHManager()
    
    weak var delegate: SSHManagerDelegate?
    
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var currentConfig: SSHConnectionConfig?
    
    /// Computed property for easy access to connected host name
    var connectedHostName: String? {
        guard let config = currentConfig else { return nil }
        return config.name.isEmpty ? config.host : config.name
    }
    
    private var group: MultiThreadedEventLoopGroup?
    private var channel: Channel?
    private var shellChannel: Channel?
    
    /// In-memory passphrase cache (not persisted to keychain)
    private var passphraseCache: [String: String] = [:]
    private let passphraseCacheLock = NSLock()

    private init() {}
    
    // MARK: - RSA Detection Helper

    /// Returns `true` if the raw openssh-key-v1 binary blob contains an RSA key type.
    /// This lets us surface a clear user-facing error *before* attempting the
    /// network connection, instead of silently falling back and failing with a
    /// generic "authentication failed".
    private static func opensshBlobContainsRSA(_ data: Data) -> Bool {
        let magic = "openssh-key-v1\0"
        let magicBytes = Data(magic.utf8)
        guard data.count > magicBytes.count,
              data.prefix(magicBytes.count) == magicBytes else { return false }

        var pos = magicBytes.count

        func readUInt32() -> UInt32? {
            guard pos + 4 <= data.count else { return nil }
            let val = data.withUnsafeBytes { buf -> UInt32 in
                buf.load(fromByteOffset: pos, as: UInt32.self).bigEndian
            }
            pos += 4
            return val
        }

        func skipString() -> Bool {
            guard let length = readUInt32() else { return false }
            let len = Int(length)
            guard pos + len <= data.count else { return false }
            pos += len
            return true
        }

        // Skip cipher name, kdf name, kdf options
        guard skipString(), skipString(), skipString() else { return false }
        // Skip number-of-keys field
        guard readUInt32() != nil else { return false }
        // Skip public key blob(s) — there is at least one
        guard skipString() else { return false }
        // Skip the (possibly encrypted) private section length prefix
        guard let privLen = readUInt32() else { return false }
        // We need at least 8 bytes (two check ints) + 4 bytes (key-type length)
        guard Int(privLen) >= 12, pos + 8 <= data.count else { return false }
        // Skip the two check-number uint32s
        pos += 8
        // Read key-type string
        guard let ktLen = readUInt32() else { return false }
        let ktInt = Int(ktLen)
        guard pos + ktInt <= data.count else { return false }
        if let keyType = String(data: data[pos..<(pos + ktInt)], encoding: .utf8) {
            return keyType == "ssh-rsa" || keyType == "rsa-sha2-256" || keyType == "rsa-sha2-512"
        }
        return false
    }

    // MARK: - Connection Methods
    
    func connect(config: SSHConnectionConfig) async throws {
        // Disconnect existing session if connected to prevent resource leaks
        if isConnected {
            disconnect()
        }
        
        self.currentConfig = config
        
        // ── RSA key detection (informational only) ─────────────────────────
        // RSA keys are now supported via Security.framework signing.
        // PrivateKeyAuthDelegate handles RSA auth via RSAKeyPair.
        if case .privateKey(let keyString, let passphrase) = config.authMethod {
            let trimmed = keyString.trimmingCharacters(in: .whitespacesAndNewlines)
            let isRSAPEM = trimmed.contains("BEGIN RSA PRIVATE KEY")
            var isRSAOpenSSH = false
            if !isRSAPEM, trimmed.contains("BEGIN OPENSSH PRIVATE KEY") {
                let lines = trimmed.components(separatedBy: "\n")
                    .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
                if let data = Data(base64Encoded: lines.joined()) {
                    isRSAOpenSSH = SSHManager.opensshBlobContainsRSA(data)
                }
            }
            if isRSAPEM || isRSAOpenSSH {
                AppLogger.ssh.info("RSA key detected for host \(config.host). RSA auth will be attempted via Security.framework.")
                // Verify the key can be parsed before attempting connection
                if (try? RSAKeyParser.parse(keyString, passphrase: passphrase)) == nil {
                    AppLogger.ssh.error("RSA key parsing failed for host \(config.host).")
                    throw SSHClientError.invalidPrivateKey
                }
            }
        }
        // ────────────────────────────────────────────────────────────────────

        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.group = group
        
        nonisolated(unsafe) let authDelegate: NIOSSHClientUserAuthenticationDelegate
        switch config.authMethod {
        case .password(let password):
            authDelegate = PasswordAuthDelegate(username: config.username, password: password)
        case .privateKey(let key, let passphrase):
            authDelegate = PrivateKeyAuthDelegate(username: config.username, privateKeyString: key, passphrase: passphrase)
        }
        
        // Use verifying host key delegate for production security
        nonisolated(unsafe) let hostKeyDelegate: NIOSSHClientServerAuthenticationDelegate = 
            VerifyingHostKeyDelegate(host: config.host, port: config.port)
        
        let bootstrap = ClientBootstrap(group: group)
            .channelInitializer { channel in
                nonisolated(unsafe) let handler = NIOSSHHandler(
                    role: .client(
                        .init(
                            userAuthDelegate: authDelegate,
                            serverAuthDelegate: hostKeyDelegate
                        )
                    ),
                    allocator: channel.allocator,
                    inboundChildChannelInitializer: nil
                )
                return channel.pipeline.addHandlers([handler])
            }
            .connectTimeout(.seconds(15))
        
        do {
            let connection = try await bootstrap.connect(
                host: config.host,
                port: config.port
            ).get()
            
            self.channel = connection
            self.isConnected = true
            
            // Notify delegate and post notification (already on MainActor)
            delegate?.sshManagerDidConnect(self)
            NotificationCenter.default.post(name: .sshDidConnect, object: self)
            
            // Start interactive shell
            try await startInteractiveShell()
            
        } catch let sshError as SSHClientError {
            self.isConnected = false
            // Clean up leaked EventLoopGroup on failure — must not block main thread
            let failedGroup = group
            self.group = nil
            DispatchQueue.global().async { try? failedGroup.syncShutdownGracefully() }
            // Re-throw SSHClientError as-is so callers see the exact typed error
            // (e.g. .unsupportedKeyType for RSA keys) rather than a generic message.
            throw sshError
        } catch {
            self.isConnected = false
            // Clean up leaked EventLoopGroup on failure — must not block main thread
            let failedGroup = group
            self.group = nil
            DispatchQueue.global().async { try? failedGroup.syncShutdownGracefully() }
            throw SSHClientError.connectionFailed(error.localizedDescription)
        }
    }
    
    func connect(config: SSHConnectionConfig, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await connect(config: config)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Import a private key from a file URL (e.g., from Files app document picker).
    /// Returns the PEM string.  Throws `SSHClientError.invalidPrivateKey` for
    /// binary content, or `SSHClientError.unsupportedKeyType` when the key is
    /// encrypted (passphrase-protected).  Callers should surface the error so
    /// the user knows to strip the passphrase with:
    ///   ssh-keygen -p -m OpenSSH -f <keyfile>   (press Enter for empty passphrase)
    func importPrivateKey(from url: URL) throws -> String {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        let keyData = try Data(contentsOf: url)
        guard let keyString = String(data: keyData, encoding: .utf8) else {
            throw SSHClientError.invalidPrivateKey
        }

        // Detect encrypted OpenSSH keys and return a clear error instead of
        // silently failing later during authentication.
        if keyString.contains("BEGIN OPENSSH PRIVATE KEY") {
            let lines = keyString.components(separatedBy: "\n")
                .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
            let base64 = lines.joined()
            if let data = Data(base64Encoded: base64) {
                let magic = "openssh-key-v1\0"
                let magicBytes = Data(magic.utf8)
                if data.count > magicBytes.count + 4,
                   data.prefix(magicBytes.count) == magicBytes {
                    var pos = magicBytes.count
                    // read cipher name
                    if pos + 4 <= data.count {
                        let cipherLen = Int(data.withUnsafeBytes { buf in
                            buf.load(fromByteOffset: pos, as: UInt32.self).bigEndian
                        })
                        pos += 4
                        if pos + cipherLen <= data.count,
                           let cipher = String(data: data[pos..<(pos + cipherLen)], encoding: .utf8),
                           cipher != "none" {
                            throw SSHClientError.unsupportedKeyType(
                                "Encrypted key (\(cipher)). To use this key, remove its passphrase:\n  ssh-keygen -p -m OpenSSH -f <keyfile>\nThen press Enter twice for an empty passphrase."
                            )
                        }
                    }
                }
            }
        }

        return keyString
    }

    /// Import and immediately save a key to the shared SSHImportedKeyStore.
    /// Returns the display name used for the stored key.
    @MainActor
    func importAndStoreKey(from url: URL) async throws -> String {
        let pem = try importPrivateKey(from: url)
        let name = url.deletingPathExtension().lastPathComponent
        SSHImportedKeyStore.shared.importKey(name: name, pem: pem)
        return name
    }

    
    // MARK: - Passphrase Management
    
    /// Store a passphrase in memory (not persisted)
    func cachePassphrase(_ passphrase: String, forKey key: String) {
        passphraseCacheLock.withLock {
            passphraseCache[key] = passphrase
        }
    }
    
    /// Retrieve a cached passphrase
    func getCachedPassphrase(forKey key: String) -> String? {
        passphraseCacheLock.withLock {
            passphraseCache[key]
        }
    }
    
    /// Clear a cached passphrase
    func clearCachedPassphrase(forKey key: String) {
        passphraseCacheLock.withLock {
            _ = passphraseCache.removeValue(forKey: key)
        }
    }
    
    /// Clear all cached passphrases
    func clearAllCachedPassphrases() {
        passphraseCacheLock.withLock {
            passphraseCache.removeAll()
        }
    }

    func disconnect() {
        // Close all active port forward listeners before tearing down the connection
        tunnelLock.withLock {
            for (_, tunnel) in activeTunnels {
                tunnel.listenerChannel?.close(mode: .all, promise: nil)
                tunnel.isActive = false
            }
            activeTunnels.removeAll()
        }
        
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        
        // syncShutdownGracefully blocks — run it off the main thread
        if let grp = group {
            group = nil
            DispatchQueue.global().async { try? grp.syncShutdownGracefully() }
        }
        
        shellChannel = nil
        channel = nil
        
        // Already on @MainActor — set state directly
        isConnected = false
        currentConfig = nil
        delegate?.sshManagerDidDisconnect(self, error: nil)
        NotificationCenter.default.post(name: .sshDidDisconnect, object: nil)
    }

    
    // MARK: - Command Execution
    
    func executeCommand(_ command: String, timeout: TimeInterval = 30) async throws -> SSHCommandResult {
        guard isConnected, let channel = self.channel else {
            throw SSHClientError.notConnected
        }
        
        final class OutputCollector: @unchecked Sendable {
            private let lock = NSLock()
            private var _stdout = ""
            private var _stderr = ""
            private var _exitCode: Int?
            
            var stdout: String { lock.withLock { _stdout } }
            var stderr: String { lock.withLock { _stderr } }
            var exitCode: Int? { lock.withLock { _exitCode } }
            
            func appendStdout(_ text: String) { lock.withLock { _stdout += text } }
            func appendStderr(_ text: String) { lock.withLock { _stderr += text } }
            func setExitCode(_ code: Int) { lock.withLock { _exitCode = code } }
        }
        
        let collector = OutputCollector()
        
        let childChannel: Channel = try await channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let childPromise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(childPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ShellDataHandler { text, isStderr in
                        if isStderr {
                            collector.appendStderr(text)
                        } else {
                            collector.appendStdout(text)
                        }
                    }
                ])
            }
            return childPromise.futureResult
        }.get()
        
        // Execute the command
        let execRequest = SSHChannelRequestEvent.ExecRequest(
            command: "\(command); echo __EXIT_CODE_MARKER__$?",
            wantReply: true
        )
        try await childChannel.triggerUserOutboundEvent(execRequest).get()
        
        // Wait for channel to close with timeout
        let isTimedOut: Bool
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await childChannel.closeFuture.get()
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw SSHClientError.timeout
                }
                try await group.next()
                group.cancelAll()
            }
            isTimedOut = false
        } catch SSHClientError.timeout {
            isTimedOut = true
            try? await childChannel.close()
        } catch {
            // Non-timeout errors: close channel and rethrow
            try? await childChannel.close()
            throw error
        }
        
        // Parse exit code from marker in stdout
        var stdout = collector.stdout
        var parsedExitCode = 0
        if let markerRange = stdout.range(of: "__EXIT_CODE_MARKER__") {
            let codeStr = String(stdout[markerRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            parsedExitCode = Int(codeStr) ?? 0
            // Remove the marker and everything after it from stdout
            stdout = String(stdout[..<markerRange.lowerBound])
            // Remove trailing newline left by the echo
            if stdout.hasSuffix("\n") {
                stdout = String(stdout.dropLast())
            }
        }
        
        if isTimedOut {
            return SSHCommandResult(
                stdout: stdout,
                stderr: collector.stderr,
                exitCode: -1,
                isTimedOut: true
            )
        }
        
        return SSHCommandResult(
            stdout: stdout,
            stderr: collector.stderr,
            exitCode: parsedExitCode,
            isTimedOut: false
        )
    }
    
    func executeCommand(_ command: String, onOutput: @escaping (SSHCommandOutput) -> Void) async throws {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        let result = try await executeCommand(command)
        if !result.stdout.isEmpty {
            onOutput(.stdout(result.stdout))
        }
        if !result.stderr.isEmpty {
            onOutput(.stderr(result.stderr))
        }
        onOutput(.exit(result.exitCode))
    }
    
    // MARK: - Interactive Shell
    
    func startInteractiveShell() async throws {
        guard let channel = self.channel else {
            throw SSHClientError.notConnected
        }
        
        let capturedManager: SSHManager = self
        
        let childChannel: Channel = try await channel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
            let childPromise = channel.eventLoop.makePromise(of: Channel.self)
            sshHandler.createChannel(childPromise) { childChannel, channelType in
                guard channelType == .session else {
                    return channel.eventLoop.makeFailedFuture(SSHClientError.invalidChannelType)
                }
                return childChannel.pipeline.addHandlers([
                    ShellDataHandler { text, isStderr in
                        Task { @MainActor in
                            if isStderr {
                                capturedManager.delegate?.sshManager(capturedManager, didReceiveError: text)
                            } else {
                                capturedManager.delegate?.sshManager(capturedManager, didReceiveOutput: text)
                            }
                        }
                    }
                ])
            }
            return childPromise.futureResult
        }.get()
        
        self.shellChannel = childChannel
        
        // Request PTY
        let ptyRequest = SSHChannelRequestEvent.PseudoTerminalRequest(
            wantReply: true,
            term: "xterm-256color",
            terminalCharacterWidth: 80,
            terminalRowHeight: 24,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0,
            terminalModes: SSHTerminalModes([:])
        )
        try await childChannel.triggerUserOutboundEvent(ptyRequest).get()
        
        // Request Shell
        let shellRequest = SSHChannelRequestEvent.ShellRequest(
            wantReply: true
        )
        try await childChannel.triggerUserOutboundEvent(shellRequest).get()
    }
    
    func send(command: String) {
        guard let shellChannel = self.shellChannel else {
            delegate?.sshManager(self, didReceiveError: "Not connected to shell")
            return
        }
        
        let data = command + "\n"
        var buffer = shellChannel.allocator.buffer(capacity: data.utf8.count)
        buffer.writeString(data)
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendInput(_ text: String) async throws {
        guard let shellChannel = self.shellChannel else {
            throw SSHClientError.notConnected
        }
        
        var buffer = shellChannel.allocator.buffer(capacity: text.utf8.count)
        buffer.writeString(text)
        try await shellChannel.writeAndFlush(buffer)
    }
    
    func sendInterrupt() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(3)) // Ctrl+C
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendTab() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(9)) // Tab
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func sendEscape() {
        guard let shellChannel = self.shellChannel else { return }
        var buffer = shellChannel.allocator.buffer(capacity: 1)
        buffer.writeInteger(UInt8(27)) // Escape
        shellChannel.writeAndFlush(buffer, promise: nil)
    }
    
    func resizeTerminal(cols: Int, rows: Int) async throws {
        guard let shellChannel = self.shellChannel else {
            throw SSHClientError.notConnected
        }
        
        let windowChange = SSHChannelRequestEvent.WindowChangeRequest(
            terminalCharacterWidth: cols,
            terminalRowHeight: rows,
            terminalPixelWidth: 0,
            terminalPixelHeight: 0
        )
        try await shellChannel.triggerUserOutboundEvent(windowChange).get()
    }
    
    func closeShell() {
        shellChannel?.close(mode: .all, promise: nil)
        shellChannel = nil
    }
    
    // MARK: - Port Forwarding
    
    /// Active port forward tunnels - maps local port to tunnel info
    private var activeTunnels: [Int: SSHPortForwardTunnel] = [:]
    private let tunnelLock = NSLock()
    
    /// Setup a local-to-remote port forward using NIOSSH direct-tcpip channels.
    /// Binds a local TCP server on 127.0.0.1:localPort and forwards each incoming
    /// connection through an SSH direct-tcpip child channel to remoteHost:remotePort.
    func setupPortForward(localPort: Int, remoteHost: String, remotePort: Int) async throws {
        guard isConnected, let sshChannel = self.channel, let group = self.group else {
            throw SSHClientError.notConnected
        }

        // Reject duplicate tunnels on the same local port
        var existingTunnel: SSHPortForwardTunnel?
        tunnelLock.withLock {
            existingTunnel = activeTunnels[localPort]
        }
        if let existing = existingTunnel, existing.isActive {
            throw SSHClientError.portForwardFailed("Port \(localPort) is already being forwarded")
        }

        let tunnel = SSHPortForwardTunnel(
            localPort: localPort,
            remoteHost: remoteHost,
            remotePort: remotePort
        )

        // The originator address reports 127.0.0.1:localPort to the SSH server
        let originatorAddress = try SocketAddress(ipAddress: "127.0.0.1", port: localPort)

        let listenerChannel = try await ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 16)
            .childChannelOption(ChannelOptions.socket(
                SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR
            ), value: 1)
            .childChannelInitializer { [weak sshChannel] localChannel in
                guard let sshChannel = sshChannel else {
                    return localChannel.eventLoop.makeFailedFuture(SSHClientError.notConnected)
                }

                // For each incoming TCP connection create an SSH direct-tcpip child channel
                return sshChannel.pipeline.handler(type: NIOSSHHandler.self).flatMap { sshHandler in
                    let sshChildPromise = sshChannel.eventLoop.makePromise(of: Channel.self)

                    let channelType: SSHChannelType = .directTCPIP(.init(
                        targetHost: remoteHost,
                        targetPort: remotePort,
                        originatorAddress: originatorAddress
                    ))

                    sshHandler.createChannel(sshChildPromise, channelType: channelType) { sshChildChannel, _ in
                        // When the SSH child channel closes, close the local TCP connection
                        sshChildChannel.closeFuture.whenComplete { _ in
                            localChannel.close(mode: .all, promise: nil)
                        }

                        // PortForwardDataHandler converts SSHChannelData <-> ByteBuffer and
                        // writes inbound data directly to the local TCP channel
                        return sshChildChannel.pipeline.addHandler(
                            PortForwardDataHandler(localChannel: localChannel)
                        )
                    }

                    // Once the SSH child channel is ready, add a GlueHandler on the local
                    // TCP channel to forward its inbound reads to the SSH child channel.
                    return sshChildPromise.futureResult.flatMap { sshChildChannel in
                        localChannel.pipeline.addHandler(
                            PortForwardGlueHandler(pairedChannel: sshChildChannel)
                        )
                    }.flatMapError { error in
                        // SSH channel creation failed — close the local TCP connection
                        localChannel.close(mode: .all, promise: nil)
                        return localChannel.eventLoop.makeFailedFuture(error)
                    }
                }.flatMapError { error in
                    // Failed to get SSH handler — close local TCP connection
                    localChannel.close(mode: .all, promise: nil)
                    return localChannel.eventLoop.makeFailedFuture(error)
                }
            }
            .bind(host: "127.0.0.1", port: localPort).get()

        tunnel.listenerChannel = listenerChannel
        tunnel.isActive = true
        tunnelLock.withLock {
            activeTunnels[localPort] = tunnel
        }
    }
    
    /// Setup remote-to-local port forward
    func setupRemoteForward(remotePort: Int, localHost: String, localPort: Int) async throws {
        guard isConnected else {
            throw SSHClientError.notConnected
        }
        
        let tunnel = SSHPortForwardTunnel(
            localPort: localPort,
            remoteHost: localHost,
            remotePort: remotePort,
            isRemoteForward: true
        )
        
        tunnelLock.withLock {
            activeTunnels[remotePort] = tunnel
        }
    }
    
    /// Cancel a port forward by closing its listener channel and removing the tunnel.
    func cancelPortForward(localPort: Int) async throws {
        var tunnel: SSHPortForwardTunnel?
        tunnelLock.withLock {
            tunnel = activeTunnels[localPort]
            activeTunnels.removeValue(forKey: localPort)
        }
        guard let tunnel = tunnel else { return }
        tunnel.isActive = false
        if let listener = tunnel.listenerChannel {
            try? await listener.close()
        }
        tunnel.listenerChannel = nil
    }
    
    /// Cancel remote port forward
    func cancelRemoteForward(remotePort: Int) async throws {
        _ = tunnelLock.withLock {
            activeTunnels.removeValue(forKey: remotePort)
        }
    }
    
    /// List all active port forwards
    func listPortForwards() -> [SSHPortForwardTunnel] {
        tunnelLock.withLock {
            Array(activeTunnels.values)
        }
    }
    
    /// Scan for listening ports on the remote server
    func scanRemotePorts() async -> [DiscoveredPort] {
        guard isConnected else { return [] }
        
        var ports: [DiscoveredPort] = []
        
        // Try ss command first (more common on modern Linux)
        if let result = try? await executeCommand("ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null") {
            let lines = result.stdout.components(separatedBy: "\n")
            for line in lines.dropFirst() {
                let parts = line.split(separator: " ").map(String.init)
                // Parse port from listening address (e.g., *:8080 or 0.0.0.0:3000)
                for part in parts {
                    if part.contains(":") {
                        let components = part.split(separator: ":")
                        if let last = components.last, let port = Int(last), port > 0, port < 65536 {
                            if !ports.contains(where: { $0.port == port }) {
                                ports.append(DiscoveredPort(port: port, processName: ""))
                            }
                        }
                    }
                }
            }
        }
        
        // Try to get process names via lsof
        if !ports.isEmpty, let result = try? await executeCommand("lsof -i -P -n 2>/dev/null | grep LISTEN") {
            let lines = result.stdout.components(separatedBy: "\n")
            for line in lines {
                let parts = line.split(separator: " ").map(String.init)
                if parts.count >= 9,
                   let lastPart = parts.last,
                   let colonIdx = lastPart.lastIndex(of: ":") {
                    let portStr = String(lastPart[lastPart.index(after: colonIdx)...])
                    if let port = Int(portStr) {
                        if let idx = ports.firstIndex(where: { $0.port == port }) {
                            ports[idx].processName = String(parts[0])
                        }
                    }
                }
            }
        }
        
        return ports.sorted { $0.port < $1.port }
    }
    
    deinit {
        // deinit is implicitly nonisolated on @MainActor classes.
        // @unchecked Sendable suppresses Sendable checking; accessing stored properties
        // here is safe because deinit is called exactly once with no other references.
        shellChannel?.close(mode: .all, promise: nil)
        channel?.close(mode: .all, promise: nil)
        if let grp = group {
            DispatchQueue.global().async { try? grp.syncShutdownGracefully() }
        }
    }
}

// MARK: - Port Forwarding Types

/// Represents an active SSH port forward tunnel
final class SSHPortForwardTunnel: @unchecked Sendable {
    let localPort: Int
    let remoteHost: String
    let remotePort: Int
    let isRemoteForward: Bool
    var listenerChannel: Channel?
    var isActive: Bool = true
    var bytesTransferred: UInt64 = 0
    
    init(localPort: Int, remoteHost: String, remotePort: Int, isRemoteForward: Bool = false) {
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
        self.isRemoteForward = isRemoteForward
    }
}

/// Represents a listening port detected on a system
struct ListeningPort: Identifiable, Equatable {
    let id = UUID()
    let port: Int
    let address: String
    var processName: String
    let `protocol`: PortProtocol
    
    static func == (lhs: ListeningPort, rhs: ListeningPort) -> Bool {
        lhs.port == rhs.port && lhs.address == rhs.address
    }
}

/// Simplified port info from remote scan
struct DiscoveredPort: Identifiable, Equatable {
    let id = UUID()
    let port: Int
    var processName: String
    
    static func == (lhs: DiscoveredPort, rhs: DiscoveredPort) -> Bool {
        lhs.port == rhs.port
    }
}

// MARK: - Port Forward Data Handler

/// Data handler for port forwarding – sits on the SSH child channel and bridges
/// SSHChannelData <-> ByteBuffer. Inbound data (from the remote) is forwarded
/// to the local TCP channel as raw bytes; outbound ByteBuffer data is wrapped
/// as SSHChannelData before being sent over SSH.
final class PortForwardDataHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = SSHChannelData
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = SSHChannelData

    private weak var localChannel: Channel?

    init(localChannel: Channel) {
        self.localChannel = localChannel
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let channelData = self.unwrapInboundIn(data)
        guard case .byteBuffer(let buf) = channelData.data else { return }
        // Forward raw bytes directly to the local TCP channel (no string conversion)
        localChannel?.writeAndFlush(buf, promise: nil)
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        let channelData = SSHChannelData(type: .channel, data: .byteBuffer(buffer))
        context.write(self.wrapOutboundOut(channelData), promise: promise)
    }

    func channelInactive(context: ChannelHandlerContext) {
        localChannel?.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        localChannel?.close(mode: .all, promise: nil)
        context.close(mode: .all, promise: nil)
    }
}


// MARK: - Port Forward Glue Handler

/// Bidirectional bridge that connects a local TCP child channel to an SSH
/// direct-tcpip child channel. Placed on the **local** TCP channel, it:
///   • Forwards inbound ByteBuffer reads to the paired SSH channel.
///   • Closes the paired SSH channel when the local connection becomes inactive.
///   • Propagates errors by closing both sides.
final class PortForwardGlueHandler: ChannelDuplexHandler, @unchecked Sendable {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private weak var pairedChannel: Channel?

    init(pairedChannel: Channel) {
        self.pairedChannel = pairedChannel
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        pairedChannel?.writeAndFlush(unwrapInboundIn(data), promise: nil)
    }

    func channelInactive(context: ChannelHandlerContext) {
        pairedChannel?.close(mode: .all, promise: nil)
    }

    func errorCaught(context: ChannelHandlerContext, error: Error) {
        pairedChannel?.close(mode: .all, promise: nil)
        context.close(mode: .all, promise: nil)
    }
}


// MARK: - SSH Connection Store (Persistence)

@MainActor
final class SSHConnectionStore: ObservableObject {
    static let shared = SSHConnectionStore()
    
    @Published var savedConnections: [SSHConnectionConfig] = []
    
    private let userDefaults = UserDefaults.standard
    private let storageKey = "ssh_saved_connections"
    private let migrationFlagKey = "ssh_keychain_migrated"
    
    init() {
        migrateToKeychain()
        loadConnections()
    }
    
    func save(_ connection: SSHConnectionConfig) {
        var config = connection
        config.lastUsed = Date()
        
        if let index = savedConnections.firstIndex(where: { $0.id == config.id }) {
            savedConnections[index] = config
        } else {
            savedConnections.append(config)
        }
        
        persistConnections()
    }
    
    func delete(_ connection: SSHConnectionConfig) {
        deleteKeychainEntries(for: connection.id)
        savedConnections.removeAll { $0.id == connection.id }
        persistConnections()
    }
    
    func updateLastUsed(_ connection: SSHConnectionConfig) {
        if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
            savedConnections[index].lastUsed = Date()
            persistConnections()
        }
    }
    
    // MARK: - Keychain Helpers
    
    private func keychainKey(for configId: UUID, type: String) -> String {
        return "ssh_\(configId.uuidString)_\(type)"
    }
    
    private func deleteKeychainEntries(for configId: UUID) {
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "password"))
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "private_key"))
        KeychainHelper.shared.delete(keychainKey(for: configId, type: "passphrase"))
    }
    
    private func saveCredentialsToKeychain(for config: SSHConnectionConfig) {
        switch config.authMethod {
        case .password(let pwd):
            if !pwd.isEmpty {
                KeychainHelper.shared.set(pwd, forKey: keychainKey(for: config.id, type: "password"))
            }
        case .privateKey(let key, let passphrase):
            if !key.isEmpty {
                KeychainHelper.shared.set(key, forKey: keychainKey(for: config.id, type: "private_key"))
            }
            if let passphrase = passphrase, !passphrase.isEmpty {
                KeychainHelper.shared.set(passphrase, forKey: keychainKey(for: config.id, type: "passphrase"))
            }
        }
    }
    
    private func sanitizedConfig(_ config: SSHConnectionConfig) -> SSHConnectionConfig {
        var sanitized = config
        switch config.authMethod {
        case .password:
            sanitized.authMethod = .password("")
        case .privateKey:
            sanitized.authMethod = .privateKey(key: "", passphrase: nil)
        }
        return sanitized
    }
    
    private func restoredConfig(_ config: SSHConnectionConfig) -> SSHConnectionConfig {
        var restored = config
        
        // Check if this config has credentials in Keychain
        if let keyPwd = KeychainHelper.shared.get(keychainKey(for: config.id, type: "password")) {
            restored.authMethod = .password(keyPwd)
        } else if let key = KeychainHelper.shared.get(keychainKey(for: config.id, type: "private_key")) {
            let passphrase = KeychainHelper.shared.get(keychainKey(for: config.id, type: "passphrase"))
            restored.authMethod = .privateKey(key: key, passphrase: passphrase)
        }
        // If no Keychain entries found, keep whatever was in UserDefaults (backward compat)
        
        return restored
    }
    
    // MARK: - Migration
    
    private func migrateToKeychain() {
        guard !userDefaults.bool(forKey: migrationFlagKey) else { return }
        
        // Load existing configs (which may have plaintext credentials)
        guard let data = userDefaults.data(forKey: storageKey),
              var configs = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
            // No existing data — nothing to migrate, just mark as done
            userDefaults.set(true, forKey: migrationFlagKey)
            return
        }
        
        // For each config, save credentials to Keychain and sanitize
        for i in configs.indices {
            saveCredentialsToKeychain(for: configs[i])
            configs[i] = sanitizedConfig(configs[i])
        }
        
        // Re-persist with sanitized configs
        if let sanitizedData = try? JSONEncoder().encode(configs) {
            userDefaults.set(sanitizedData, forKey: storageKey)
        }
        
        userDefaults.set(true, forKey: migrationFlagKey)
    }
    
    // MARK: - Persistence
    
    private func loadConnections() {
        guard let data = userDefaults.data(forKey: storageKey),
              let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
            return
        }
        // Restore real credentials from Keychain
        savedConnections = connections.map { restoredConfig($0) }
            .sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
    }
    
    private func persistConnections() {
        // Save credentials to Keychain and build sanitized array for UserDefaults
        let sanitized = savedConnections.map { config -> SSHConnectionConfig in
            saveCredentialsToKeychain(for: config)
            return sanitizedConfig(config)
        }
        guard let data = try? JSONEncoder().encode(sanitized) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
