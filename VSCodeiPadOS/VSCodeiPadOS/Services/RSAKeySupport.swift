//
//  RSAKeySupport.swift
//  VSCodeiPadOS
//
//  RSA key parsing, generation, and signing using Apple Security.framework.
//  Fills the gap where NIOSSH only supports Ed25519/ECDSA.
//

import Foundation
import Security
import CommonCrypto
import os

// MARK: - RSA Key Errors

enum RSAKeyError: Error, LocalizedError {
    case invalidKeyFormat
    case keyGenerationFailed
    case signingFailed
    case unsupportedKeySize(Int)
    case decryptionFailed
    case passphraseRequired
    case invalidPEMStructure
    case securityFrameworkError(OSStatus)
    case invalidDEREncoding
    
    var errorDescription: String? {
        switch self {
        case .invalidKeyFormat: return "Invalid RSA key format"
        case .keyGenerationFailed: return "RSA key generation failed"
        case .signingFailed: return "RSA signing operation failed"
        case .unsupportedKeySize(let bits): return "Unsupported RSA key size: \(bits) bits. Use 2048, 3072, or 4096."
        case .decryptionFailed: return "Failed to decrypt RSA private key. Wrong passphrase?"
        case .passphraseRequired: return "This RSA key is encrypted. A passphrase is required."
        case .invalidPEMStructure: return "Invalid PEM key structure"
        case .securityFrameworkError(let status): return "Security framework error: \(status)"
        case .invalidDEREncoding: return "Invalid DER/ASN.1 encoding in RSA key"
        }
    }
}

// MARK: - RSA Key Pair

/// Represents a parsed RSA key pair with signing capability
final class RSAKeyPair: @unchecked Sendable {
    let privateKey: SecKey
    let publicKey: SecKey
    let keySizeBits: Int
    
    /// Raw public key data for SSH encoding
    let publicKeyData: Data
    /// Raw private key components for SSH encoding  
    let privateKeyData: Data
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "RSAKeySupport")
    
    init(privateKey: SecKey, publicKey: SecKey, keySizeBits: Int, publicKeyData: Data, privateKeyData: Data) {
        self.privateKey = privateKey
        self.publicKey = publicKey
        self.keySizeBits = keySizeBits
        self.publicKeyData = publicKeyData
        self.privateKeyData = privateKeyData
    }
    
    // MARK: - Key Generation
    
    /// Generate a new RSA key pair
    /// - Parameter bits: Key size (2048, 3072, or 4096)
    /// - Returns: RSAKeyPair ready for use
    static func generate(bits: Int = 4096) throws -> RSAKeyPair {
        guard [2048, 3072, 4096].contains(bits) else {
            throw RSAKeyError.unsupportedKeySize(bits)
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: bits,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            logger.error("RSA key generation failed: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            throw RSAKeyError.keyGenerationFailed
        }
        
        guard let pubKey = SecKeyCopyPublicKey(privKey) else {
            throw RSAKeyError.keyGenerationFailed
        }
        
        // Extract raw key data
        let pubData = try extractPublicKeyData(pubKey)
        let privData = try extractPrivateKeyData(privKey)
        
        return RSAKeyPair(
            privateKey: privKey,
            publicKey: pubKey,
            keySizeBits: bits,
            publicKeyData: pubData,
            privateKeyData: privData
        )
    }
    
    // MARK: - SSH Signing
    
    /// Sign data using rsa-sha2-256 (SHA-256 with RSA PKCS#1 v1.5)
    func signSHA256(_ data: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            data as CFData,
            &error
        ) else {
            Self.logger.error("RSA SHA-256 signing failed: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            throw RSAKeyError.signingFailed
        }
        return signature as Data
    }
    
    /// Sign data using rsa-sha2-512 (SHA-512 with RSA PKCS#1 v1.5)
    func signSHA512(_ data: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .rsaSignatureMessagePKCS1v15SHA512,
            data as CFData,
            &error
        ) else {
            Self.logger.error("RSA SHA-512 signing failed: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            throw RSAKeyError.signingFailed
        }
        return signature as Data
    }
    
    // MARK: - OpenSSH Public Key Export
    
    /// Export public key in OpenSSH format: "ssh-rsa AAAA... comment"
    func openSSHPublicKey(comment: String = "generated-key") -> String {
        // SSH RSA public key blob: string("ssh-rsa") + mpint(e) + mpint(n)
        var blob = Data()
        blob.appendSSHString("ssh-rsa")
        
        // Extract e and n from public key data
        if let (e, n) = extractRSAPublicComponents() {
            blob.appendSSHMPInt(e)
            blob.appendSSHMPInt(n)
        }
        
        let base64 = blob.base64EncodedString()
        return "ssh-rsa \(base64) \(comment)"
    }
    
    /// Export private key in OpenSSH PEM format
    func openSSHPrivateKeyPEM() -> String {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(privateKey, &error) else {
            return ""
        }
        let base64 = (data as Data).base64EncodedString(options: .lineLength64Characters)
        return "-----BEGIN RSA PRIVATE KEY-----\n\(base64)\n-----END RSA PRIVATE KEY-----\n"
    }
    
    // MARK: - SSH Auth Blob Construction
    
    /// Build the SSH public key blob for authentication
    func sshPublicKeyBlob() -> Data {
        var blob = Data()
        blob.appendSSHString("ssh-rsa")
        if let (e, n) = extractRSAPublicComponents() {
            blob.appendSSHMPInt(e)
            blob.appendSSHMPInt(n)
        }
        return blob
    }
    
    /// Build the signature blob for SSH rsa-sha2-256 authentication
    /// - Parameters:
    ///   - sessionId: The SSH session identifier
    ///   - username: The username for authentication
    ///   - serviceName: The SSH service name (usually "ssh-connection")
    ///   - publicKeyBlob: The SSH public key blob
    func buildAuthSignatureData(
        sessionId: Data,
        username: String,
        serviceName: String = "ssh-connection",
        algorithmName: String = "rsa-sha2-256"
    ) -> Data {
        let pkBlob = sshPublicKeyBlob()
        
        var signData = Data()
        // string    session identifier
        signData.appendSSHString(sessionId)
        // byte      SSH_MSG_USERAUTH_REQUEST (50)
        signData.append(50)
        // string    user name
        signData.appendSSHString(username)
        // string    service name
        signData.appendSSHString(serviceName)
        // string    "publickey"
        signData.appendSSHString("publickey")
        // boolean   TRUE
        signData.append(1)
        // string    public key algorithm name
        signData.appendSSHString(algorithmName)
        // string    public key blob
        signData.appendSSHString(pkBlob)
        
        return signData
    }
    
    // MARK: - Private Helpers
    
    private func extractRSAPublicComponents() -> (exponent: Data, modulus: Data)? {
        var error: Unmanaged<CFError>?
        guard let pubData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            return nil
        }
        
        // SecKey RSA public key external representation is PKCS#1 DER:
        // SEQUENCE { INTEGER(n), INTEGER(e) }
        return parseRSAPublicKeyDER(pubData)
    }
    
    /// Parse PKCS#1 DER-encoded RSA public key to extract n and e
    private func parseRSAPublicKeyDER(_ data: Data) -> (exponent: Data, modulus: Data)? {
        var pos = 0
        
        // SEQUENCE tag
        guard pos < data.count, data[pos] == 0x30 else { return nil }
        pos += 1
        
        // Skip length
        pos = skipDERLength(data, at: pos)
        guard pos < data.count else { return nil }
        
        // First INTEGER = modulus (n)
        guard data[pos] == 0x02 else { return nil }
        pos += 1
        let (nLen, nStart) = readDERLength(data, at: pos)
        guard nStart + nLen <= data.count else { return nil }
        let n = Data(data[nStart..<(nStart + nLen)])
        pos = nStart + nLen
        
        // Second INTEGER = exponent (e)
        guard pos < data.count, data[pos] == 0x02 else { return nil }
        pos += 1
        let (eLen, eStart) = readDERLength(data, at: pos)
        guard eStart + eLen <= data.count else { return nil }
        let e = Data(data[eStart..<(eStart + eLen)])
        
        return (exponent: e, modulus: n)
    }
    
    private func skipDERLength(_ data: Data, at pos: Int) -> Int {
        let (_, nextPos) = readDERLength(data, at: pos)
        return nextPos
    }
    
    private func readDERLength(_ data: Data, at pos: Int) -> (length: Int, nextPos: Int) {
        guard pos < data.count else { return (0, pos) }
        let firstByte = data[pos]
        if firstByte & 0x80 == 0 {
            // Short form
            return (Int(firstByte), pos + 1)
        } else {
            let numBytes = Int(firstByte & 0x7F)
            guard pos + 1 + numBytes <= data.count else { return (0, pos) }
            var length = 0
            for i in 0..<numBytes {
                length = (length << 8) | Int(data[pos + 1 + i])
            }
            return (length, pos + 1 + numBytes)
        }
    }
    
    private static func extractPublicKeyData(_ key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) else {
            throw RSAKeyError.securityFrameworkError(-1)
        }
        return data as Data
    }
    
    private static func extractPrivateKeyData(_ key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) else {
            throw RSAKeyError.securityFrameworkError(-1)
        }
        return data as Data
    }
}

// MARK: - RSA Key Parser

/// Parses RSA private keys from PEM and OpenSSH formats
enum RSAKeyParser {
    
    private static let logger = Logger(subsystem: "com.codepad.app", category: "RSAKeyParser")
    
    /// Parse an RSA private key from PEM string (any format)
    static func parse(_ keyString: String, passphrase: String? = nil) throws -> RSAKeyPair {
        let trimmed = keyString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // PKCS#1 format: BEGIN RSA PRIVATE KEY
        if trimmed.contains("BEGIN RSA PRIVATE KEY") {
            return try parsePKCS1PEM(trimmed, passphrase: passphrase)
        }
        
        // PKCS#8 format: BEGIN PRIVATE KEY
        if trimmed.contains("BEGIN PRIVATE KEY") {
            return try parsePKCS8PEM(trimmed)
        }
        
        // OpenSSH format: BEGIN OPENSSH PRIVATE KEY
        if trimmed.contains("BEGIN OPENSSH PRIVATE KEY") {
            return try parseOpenSSHKey(trimmed, passphrase: passphrase)
        }
        
        throw RSAKeyError.invalidKeyFormat
    }
    
    // MARK: - PKCS#1 PEM Parser
    
    /// Parse PKCS#1 (traditional RSA) PEM key
    private static func parsePKCS1PEM(_ pem: String, passphrase: String?) throws -> RSAKeyPair {
        let lines = pem.components(separatedBy: "\n")
        
        // Check for encrypted key (Proc-Type: 4,ENCRYPTED)
        let isEncrypted = lines.contains { $0.starts(with: "Proc-Type:") && $0.contains("ENCRYPTED") }
        
        if isEncrypted {
            guard let passphrase = passphrase, !passphrase.isEmpty else {
                throw RSAKeyError.passphraseRequired
            }
            return try decryptPKCS1PEM(lines: lines, passphrase: passphrase)
        }
        
        // Strip headers and decode
        let base64 = lines
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty && !$0.contains(":") }
            .joined()
        
        guard let data = Data(base64Encoded: base64) else {
            throw RSAKeyError.invalidPEMStructure
        }
        
        return try createKeyPairFromPKCS1Data(data)
    }
    
    // MARK: - PKCS#8 PEM Parser
    
    private static func parsePKCS8PEM(_ pem: String) throws -> RSAKeyPair {
        let lines = pem.components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        let base64 = lines.joined()
        
        guard let data = Data(base64Encoded: base64) else {
            throw RSAKeyError.invalidPEMStructure
        }
        
        // PKCS#8 wraps PKCS#1 in a SEQUENCE { AlgorithmIdentifier, OCTET STRING { PKCS1Key } }
        // Try to import directly via Security framework which handles both formats
        return try createKeyPairFromDERData(data, format: kSecAttrKeyClassPrivate)
    }
    
    // MARK: - OpenSSH Format Parser
    
    private static func parseOpenSSHKey(_ pem: String, passphrase: String?) throws -> RSAKeyPair {
        let lines = pem.components(separatedBy: "\n")
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty }
        let base64 = lines.joined()
        guard let data = Data(base64Encoded: base64) else {
            throw RSAKeyError.invalidPEMStructure
        }
        
        // openssh-key-v1 magic
        let magic = "openssh-key-v1\0"
        let magicData = Data(magic.utf8)
        guard data.prefix(magicData.count) == magicData else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        var pos = magicData.count
        
        func readUInt32() -> UInt32? {
            guard pos + 4 <= data.count else { return nil }
            let val = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt32.self).bigEndian }
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
        
        // Read cipher, kdf, kdf options
        guard let cipherData = readString(), let cipherStr = String(data: cipherData, encoding: .utf8),
              let kdfData = readString(), let kdfStr = String(data: kdfData, encoding: .utf8),
              let kdfOptions = readString(),
              let numKeys = readUInt32(), numKeys >= 1 else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        // Skip public keys
        for _ in 0..<numKeys {
            guard let _ = readString() else { throw RSAKeyError.invalidKeyFormat }
        }
        
        // Read private section
        guard var privateSection = readString() else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        // Decrypt if encrypted
        if cipherStr != "none" {
            guard let passphrase = passphrase, !passphrase.isEmpty else {
                throw RSAKeyError.passphraseRequired
            }
            // Use the existing OpenSSH decryptor from SSHManager
            privateSection = try OpenSSHKeyDecryptor.decrypt(
                encryptedData: privateSection,
                cipherName: cipherStr,
                kdfName: kdfStr,
                kdfOptions: kdfOptions,
                passphrase: passphrase
            )
        }
        
        // Parse the private section to extract RSA components
        return try parseOpenSSHRSAPrivateSection(privateSection)
    }
    
    /// Parse the decrypted private section of an OpenSSH RSA key
    private static func parseOpenSSHRSAPrivateSection(_ data: Data) throws -> RSAKeyPair {
        var pos = 0
        
        func readUInt32() -> UInt32? {
            guard pos + 4 <= data.count else { return nil }
            let val = data.withUnsafeBytes { $0.load(fromByteOffset: pos, as: UInt32.self).bigEndian }
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
        
        // Check numbers
        guard let check1 = readUInt32(), let check2 = readUInt32(), check1 == check2 else {
            throw RSAKeyError.decryptionFailed
        }
        
        // Key type
        guard let keyTypeData = readString(),
              let keyType = String(data: keyTypeData, encoding: .utf8),
              keyType == "ssh-rsa" || keyType == "rsa-sha2-256" || keyType == "rsa-sha2-512" else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        // RSA components in OpenSSH format:
        // n (modulus), e (exponent), d (private exponent), iqmp (inverse of q mod p), p, q
        guard let n = readString(),
              let e = readString(),
              let d = readString(),
              let iqmp = readString(),
              let p = readString(),
              let q = readString() else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        // Build PKCS#1 DER from components (including CRT parameters)
        let pkcs1Data = buildPKCS1DER(n: n, e: e, d: d, p: p, q: q, iqmp: iqmp)
        return try createKeyPairFromPKCS1Data(pkcs1Data)
    }
    
    // MARK: - DER Construction
    
    /// Build PKCS#1 RSAPrivateKey DER from raw components
    private static func buildPKCS1DER(n: Data, e: Data, d: Data, p: Data, q: Data, iqmp: Data? = nil) -> Data {
        // RSAPrivateKey ::= SEQUENCE {
        //   version           INTEGER,  -- 0
        //   modulus           INTEGER,  -- n
        //   publicExponent    INTEGER,  -- e
        //   privateExponent   INTEGER,  -- d
        //   prime1            INTEGER,  -- p
        //   prime2            INTEGER,  -- q
        //   exponent1         INTEGER,  -- d mod (p-1)  (dp)
        //   exponent2         INTEGER,  -- d mod (q-1)  (dq)
        //   coefficient       INTEGER   -- (inverse of q) mod p  (qinv)
        // }
        
        // Compute CRT parameters: dp = d mod (p-1), dq = d mod (q-1)
        let dp = bigIntMod(d, bigIntSubtractOne(p))
        let dq = bigIntMod(d, bigIntSubtractOne(q))
        let qinv = iqmp ?? Data([0])  // Use parsed iqmp if available
        
        var content = Data()
        content.append(derInteger(Data([0])))  // version = 0
        content.append(derInteger(n))
        content.append(derInteger(e))
        content.append(derInteger(d))
        content.append(derInteger(p))
        content.append(derInteger(q))
        content.append(derInteger(dp))
        content.append(derInteger(dq))
        content.append(derInteger(qinv))
        
        return derSequence(content)
    }
    
    // MARK: - Big Integer Helpers for CRT
    
    /// Subtract 1 from a big-endian unsigned integer Data
    private static func bigIntSubtractOne(_ data: Data) -> Data {
        var bytes = Array(data)
        // Strip leading zero used for sign in DER
        if bytes.first == 0 && bytes.count > 1 { bytes.removeFirst() }
        var i = bytes.count - 1
        while i >= 0 {
            if bytes[i] > 0 {
                bytes[i] -= 1
                break
            }
            bytes[i] = 0xFF
            i -= 1
        }
        return Data(bytes)
    }
    
    /// Compute a mod m for big-endian unsigned integer Data values
    /// Uses schoolbook division — adequate for RSA key sizes (2048-4096 bit)
    private static func bigIntMod(_ a: Data, _ m: Data) -> Data {
        // Convert to arrays, strip leading zeros
        var aBytes = Array(a)
        if aBytes.first == 0 && aBytes.count > 1 { aBytes = Array(aBytes.drop(while: { $0 == 0 })) }
        if aBytes.isEmpty { aBytes = [0] }
        var mBytes = Array(m)
        if mBytes.first == 0 && mBytes.count > 1 { mBytes = Array(mBytes.drop(while: { $0 == 0 })) }
        if mBytes.isEmpty { return Data([0]) }
        
        // Use repeated subtraction with shifting for modular reduction
        // This is O(n^2) in the number of bytes but only runs once per key import
        var remainder = aBytes
        
        // Quick path: if a < m, result is a
        if compareUnsigned(remainder, mBytes) < 0 {
            return Data(remainder)
        }
        
        // Long division approach: process byte by byte
        var result: [UInt8] = [0]
        for byte in aBytes {
            // Shift result left by 8 bits and add new byte
            result.append(byte)
            // Strip leading zeros
            while result.count > 1 && result.first == 0 { result.removeFirst() }
            // Subtract m while result >= m
            while compareUnsigned(result, mBytes) >= 0 {
                result = subtractUnsigned(result, mBytes)
            }
        }
        
        if result.isEmpty { result = [0] }
        return Data(result)
    }
    
    /// Compare two unsigned big-endian byte arrays. Returns -1, 0, or 1
    private static func compareUnsigned(_ a: [UInt8], _ b: [UInt8]) -> Int {
        let aStripped = Array(a.drop(while: { $0 == 0 }))
        let bStripped = Array(b.drop(while: { $0 == 0 }))
        if aStripped.count != bStripped.count {
            return aStripped.count < bStripped.count ? -1 : 1
        }
        for i in 0..<aStripped.count {
            if aStripped[i] < bStripped[i] { return -1 }
            if aStripped[i] > bStripped[i] { return 1 }
        }
        return 0
    }
    
    /// Subtract b from a (unsigned, assumes a >= b)
    private static func subtractUnsigned(_ a: [UInt8], _ b: [UInt8]) -> [UInt8] {
        var result = a
        var borrow: Int = 0
        let diff = a.count - b.count
        for i in stride(from: a.count - 1, through: 0, by: -1) {
            let bIdx = i - diff
            let bVal = bIdx >= 0 ? Int(b[bIdx]) : 0
            var sub = Int(result[i]) - bVal - borrow
            if sub < 0 {
                sub += 256
                borrow = 1
            } else {
                borrow = 0
            }
            result[i] = UInt8(sub)
        }
        // Strip leading zeros
        while result.count > 1 && result.first == 0 { result.removeFirst() }
        return result
    }
    }
    
    private static func derInteger(_ data: Data) -> Data {
        var intData = data
        // Strip leading zeros but keep one if needed for positive sign
        while intData.count > 1 && intData[intData.startIndex] == 0 {
            intData = intData.dropFirst().asData()
        }
        // Prepend 0x00 if high bit is set (positive number)
        if let first = intData.first, first & 0x80 != 0 {
            intData = Data([0x00]) + intData
        }
        return Data([0x02]) + derLength(intData.count) + intData
    }
    
    private static func derSequence(_ content: Data) -> Data {
        return Data([0x30]) + derLength(content.count) + content
    }
    
    private static func derLength(_ length: Int) -> Data {
        if length < 128 {
            return Data([UInt8(length)])
        } else if length < 256 {
            return Data([0x81, UInt8(length)])
        } else if length < 65536 {
            return Data([0x82, UInt8(length >> 8), UInt8(length & 0xFF)])
        } else {
            return Data([0x83, UInt8(length >> 16), UInt8((length >> 8) & 0xFF), UInt8(length & 0xFF)])
        }
    }
    
    // MARK: - Encrypted PKCS#1 Key Decryption
    
    private static func decryptPKCS1PEM(lines: [String], passphrase: String) throws -> RSAKeyPair {
        // Parse DEK-Info header for cipher and IV
        var cipher = ""
        var ivHex = ""
        for line in lines {
            if line.starts(with: "DEK-Info:") {
                let parts = line.replacingOccurrences(of: "DEK-Info: ", with: "").split(separator: ",")
                if parts.count >= 2 {
                    cipher = String(parts[0]).trimmingCharacters(in: .whitespaces)
                    ivHex = String(parts[1]).trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        guard !cipher.isEmpty, !ivHex.isEmpty else {
            throw RSAKeyError.invalidPEMStructure
        }
        
        // Decode base64 body
        let base64 = lines
            .filter { !$0.hasPrefix("-----") && !$0.isEmpty && !$0.contains(":") && !$0.starts(with: "Proc-Type") && !$0.starts(with: "DEK-Info") }
            .joined()
        guard let encryptedData = Data(base64Encoded: base64) else {
            throw RSAKeyError.invalidPEMStructure
        }
        
        // Derive key from passphrase + IV using MD5 (OpenSSL's EVP_BytesToKey)
        let iv = hexToData(ivHex)
        let key = deriveKeyOpenSSL(passphrase: passphrase, salt: iv.prefix(8), keyLen: 32)
        
        // Decrypt (typically AES-256-CBC for RSA keys)
        let decrypted: Data
        if cipher.contains("AES-256-CBC") || cipher.contains("aes-256-cbc") {
            decrypted = try decryptAES256CBC(data: encryptedData, key: key, iv: iv)
        } else if cipher.contains("AES-128-CBC") || cipher.contains("aes-128-cbc") {
            let key128 = deriveKeyOpenSSL(passphrase: passphrase, salt: iv.prefix(8), keyLen: 16)
            decrypted = try decryptAES256CBC(data: encryptedData, key: key128, iv: iv)
        } else if cipher.contains("DES-EDE3-CBC") {
            let key3des = deriveKeyOpenSSL(passphrase: passphrase, salt: iv.prefix(8), keyLen: 24)
            decrypted = try decrypt3DESCBC(data: encryptedData, key: key3des, iv: iv)
        } else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        return try createKeyPairFromPKCS1Data(decrypted)
    }
    
    // MARK: - Crypto Helpers
    
    /// OpenSSL-compatible key derivation (EVP_BytesToKey with MD5)
    private static func deriveKeyOpenSSL(passphrase: String, salt: Data, keyLen: Int) -> Data {
        let passphraseData = Data(passphrase.utf8)
        var derived = Data()
        var lastHash = Data()
        
        while derived.count < keyLen {
            var toHash = lastHash + passphraseData + salt
            var hash = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            _ = toHash.withUnsafeBytes { toHashBytes in
                hash.withUnsafeMutableBytes { hashBytes in
                    CC_MD5(toHashBytes.baseAddress, CC_LONG(toHash.count), hashBytes.baseAddress?.assumingMemoryBound(to: UInt8.self))
                }
            }
            derived.append(hash)
            lastHash = hash
        }
        
        return derived.prefix(keyLen).asData()
    }
    
    private static func decryptAES256CBC(data: Data, key: Data, iv: Data) throws -> Data {
        var decrypted = Data(count: data.count + kCCBlockSizeAES128)
        var numBytes: size_t = 0
        
        let status = decrypted.withUnsafeMutableBytes { decBuf in
            data.withUnsafeBytes { dataBuf in
                key.withUnsafeBytes { keyBuf in
                    iv.withUnsafeBytes { ivBuf in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBuf.baseAddress, key.count,
                            ivBuf.baseAddress,
                            dataBuf.baseAddress, data.count,
                            decBuf.baseAddress, decrypted.count,
                            &numBytes
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else { throw RSAKeyError.decryptionFailed }
        decrypted.count = numBytes
        return decrypted
    }
    
    private static func decrypt3DESCBC(data: Data, key: Data, iv: Data) throws -> Data {
        var decrypted = Data(count: data.count + kCCBlockSize3DES)
        var numBytes: size_t = 0
        
        let status = decrypted.withUnsafeMutableBytes { decBuf in
            data.withUnsafeBytes { dataBuf in
                key.withUnsafeBytes { keyBuf in
                    iv.withUnsafeBytes { ivBuf in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithm3DES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBuf.baseAddress, key.count,
                            ivBuf.baseAddress,
                            dataBuf.baseAddress, data.count,
                            decBuf.baseAddress, decrypted.count,
                            &numBytes
                        )
                    }
                }
            }
        }
        
        guard status == kCCSuccess else { throw RSAKeyError.decryptionFailed }
        decrypted.count = numBytes
        return decrypted
    }
    
    private static func hexToData(_ hex: String) -> Data {
        var data = Data()
        var i = hex.startIndex
        while i < hex.endIndex {
            let next = hex.index(i, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
            if let byte = UInt8(hex[i..<next], radix: 16) {
                data.append(byte)
            }
            i = next
        }
        return data
    }
    
    // MARK: - Security.framework Key Import
    
    private static func createKeyPairFromPKCS1Data(_ pkcs1Data: Data) throws -> RSAKeyPair {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 0  // Auto-detect from key data
        ]
        
        var error: Unmanaged<CFError>?
        guard let privKey = SecKeyCreateWithData(pkcs1Data as CFData, attributes as CFDictionary, &error) else {
            logger.error("Failed to import RSA key: \(error?.takeRetainedValue().localizedDescription ?? "unknown")")
            throw RSAKeyError.invalidKeyFormat
        }
        
        guard let pubKey = SecKeyCopyPublicKey(privKey) else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        // Determine key size
        let keyAttrs = SecKeyCopyAttributes(privKey) as? [String: Any] ?? [:]
        let keySizeBits = keyAttrs[kSecAttrKeySizeInBits as String] as? Int ?? 0
        
        let pubData = try RSAKeyPair.extractPublicKeyData(pubKey)
        let privData = try RSAKeyPair.extractPrivateKeyData(privKey)
        
        return RSAKeyPair(
            privateKey: privKey,
            publicKey: pubKey,
            keySizeBits: keySizeBits,
            publicKeyData: pubData,
            privateKeyData: privData
        )
    }
    
    private static func createKeyPairFromDERData(_ data: Data, format: CFString) throws -> RSAKeyPair {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: format
        ]
        
        var error: Unmanaged<CFError>?
        guard let privKey = SecKeyCreateWithData(data as CFData, attributes as CFDictionary, &error) else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        guard let pubKey = SecKeyCopyPublicKey(privKey) else {
            throw RSAKeyError.invalidKeyFormat
        }
        
        let keyAttrs = SecKeyCopyAttributes(privKey) as? [String: Any] ?? [:]
        let keySizeBits = keyAttrs[kSecAttrKeySizeInBits as String] as? Int ?? 0
        
        let pubData = try RSAKeyPair.extractPublicKeyData(pubKey)
        let privData = try RSAKeyPair.extractPrivateKeyData(privKey)
        
        return RSAKeyPair(
            privateKey: privKey,
            publicKey: pubKey,
            keySizeBits: keySizeBits,
            publicKeyData: pubData,
            privateKeyData: privData
        )
    }
    
    private static func extractPublicKeyData(_ key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) else {
            throw RSAKeyError.securityFrameworkError(-1)
        }
        return data as Data
    }
    
    private static func extractPrivateKeyData(_ key: SecKey) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) else {
            throw RSAKeyError.securityFrameworkError(-1)
        }
        return data as Data
    }
}

// MARK: - SSH Data Extensions

extension Data {
    /// Append an SSH string (uint32 length + bytes)
    mutating func appendSSHString(_ string: String) {
        let data = Data(string.utf8)
        appendSSHString(data)
    }
    
    /// Append an SSH string (uint32 length + bytes)
    mutating func appendSSHString(_ data: Data) {
        var length = UInt32(data.count).bigEndian
        append(Data(bytes: &length, count: 4))
        append(data)
    }
    
    /// Append an SSH mpint (big integer with leading zero if needed)
    mutating func appendSSHMPInt(_ data: Data) {
        var stripped = data
        // Remove leading zeros
        while stripped.count > 1 && stripped[stripped.startIndex] == 0 {
            stripped = stripped.dropFirst().asData()
        }
        // Add leading zero if high bit set
        if let first = stripped.first, first & 0x80 != 0 {
            stripped = Data([0x00]) + stripped
        }
        appendSSHString(stripped)
    }
}

private extension Data.SubSequence {
    func asData() -> Data { Data(self) }
}

private extension Data {
    func asData() -> Data { self }
}
