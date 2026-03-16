//
//  SFTPManager.swift
//  VSCodeiPadOS
//
//  SFTP file transfer using SwiftNIO SSH
//  Note: SwiftNIO SSH doesn't have built-in SFTP, this provides the foundation
//

import Foundation
import NIO
import NIOSSH

// MARK: - SFTP Error Types

enum SFTPError: Error, LocalizedError {
    case notConnected
    case transferFailed(String)
    case fileNotFound
    case permissionDenied
    case directoryListFailed
    case operationCancelled
    
    var errorDescription: String? {
        switch self {
        case .notConnected: return "Not connected to server"
        case .transferFailed(let reason): return "Transfer failed: \(reason)"
        case .fileNotFound: return "File not found"
        case .permissionDenied: return "Permission denied"
        case .directoryListFailed: return "Failed to list directory"
        case .operationCancelled: return "Operation cancelled"
        }
    }
}

// MARK: - SFTP File Info

struct SFTPFileInfo: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let isDirectory: Bool
    let size: UInt64
    let modificationDate: Date?
    let permissions: String
}

// MARK: - Transfer Progress

struct SFTPTransferProgress {
    let fileName: String
    let bytesTransferred: UInt64
    let totalBytes: UInt64
    let isUpload: Bool
    
    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesTransferred) / Double(totalBytes)
    }
    
    var progressString: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        let transferred = formatter.string(fromByteCount: Int64(bytesTransferred))
        let total = formatter.string(fromByteCount: Int64(totalBytes))
        return "\(transferred) / \(total)"
    }
}

// MARK: - SFTP Manager Delegate

protocol SFTPManagerDelegate: AnyObject {
    func sftpManager(_ manager: SFTPManager, didStartTransfer fileName: String, isUpload: Bool)
    func sftpManager(_ manager: SFTPManager, didUpdateProgress progress: SFTPTransferProgress)
    func sftpManager(_ manager: SFTPManager, didCompleteTransfer fileName: String, isUpload: Bool)
    func sftpManager(_ manager: SFTPManager, didFailWithError error: Error)
    func sftpManager(_ manager: SFTPManager, didListDirectory files: [SFTPFileInfo])
}

// MARK: - SFTP Manager

/// SFTP Manager for file transfers
/// Note: SwiftNIO SSH doesn't include SFTP subsystem directly.
/// This implementation uses SSH exec channels to run scp/sftp commands.
/// For full SFTP support, consider using a dedicated SFTP library.
class SFTPManager: @unchecked Sendable {
    weak var delegate: SFTPManagerDelegate?
    
    private var sshManager: SSHManager?
    private(set) var isConnected = false
    private(set) var currentDirectory = "~"
    
    /// Shell-escape a string for safe use in SSH commands.
    /// Wraps the string in single quotes and escapes any embedded single quotes.
    private func shellEscape(_ string: String) -> String {
        return "'\(string.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
    
    // MARK: - Initializers
    
    /// Create SFTPManager with an existing SSHManager (assumed already connected)
    init(sshManager: SSHManager) {
        self.sshManager = sshManager
        self.isConnected = true
    }
    
    /// Create SFTPManager (call connect() to establish a connection)
    init() {
        self.sshManager = nil
        self.isConnected = false
    }
    
    // MARK: - Connection
    
    /// Connect using a provided SSHManager instance
    func connect(sshManager: SSHManager, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        self.sshManager = sshManager
        self.isConnected = true
        completion(.success(()))
    }
    
    /// Connect using SSHManager.shared
    func connect(config: SSHConnectionConfig, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        sshManager = SSHManager.shared
        sshManager?.connect(config: config) { [weak self] result in
            switch result {
            case .success:
                self?.isConnected = true
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func disconnect() {
        sshManager?.disconnect()
        sshManager = nil
        isConnected = false
    }
    
    // MARK: - Directory Operations
    
    /// List files in a remote directory using ls command
    func listDirectory(_ path: String, completion: @escaping @Sendable (Result<[SFTPFileInfo], Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let command = "ls -la \(shellEscape(path))"
        
        Task {
            do {
                guard let result = try await sshManager?.executeCommand(command) else {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                
                let files = parseLSOutput(result.stdout, basePath: path)
                completion(.success(files))
            } catch {
                completion(.failure(SFTPError.directoryListFailed))
            }
        }
    }
    
    /// Parse ls -la output into SFTPFileInfo objects
    private func parseLSOutput(_ output: String, basePath: String) -> [SFTPFileInfo] {
        let lines = output.components(separatedBy: "\n")
        var files: [SFTPFileInfo] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for line in lines {
            // Skip "total" line
            guard !line.hasPrefix("total") else { continue }
            
            let fields = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            
            // ls -la format: permissions, links, owner, group, size, month, day, time/year, name
            guard fields.count >= 9 else { continue }
            
            let permissions = fields[0]
            let name = fields[8]
            
            // Skip . and .. entries
            guard name != "." && name != ".." else { continue }
            
            let isDirectory = permissions.first == "d"
            let size = UInt64(fields[4]) ?? 0
            
            // Parse date: "Mar 15 10:30" or "Mar 15  2023"
            let month = fields[5]
            let day = fields[6]
            let yearOrTime = fields[7]
            
            // If yearOrTime contains ":", it's a time; otherwise it's a year
            let date: Date?
            if yearOrTime.contains(":") {
                dateFormatter.dateFormat = "MMM dd HH:mm"
                let currentYear = Calendar.current.component(.year, from: Date())
                let dateString = "\(month) \(day) \(yearOrTime)"
                if let d = dateFormatter.date(from: dateString) {
                    let adjusted = Calendar.current.date(bySetting: .year, value: currentYear, of: d)
                    if let adjusted = adjusted, adjusted > Date() {
                        date = Calendar.current.date(byAdding: .year, value: -1, to: adjusted)
                    } else {
                        date = adjusted ?? d
                    }
                } else {
                    date = nil
                }
            } else {
                dateFormatter.dateFormat = "MMM dd yyyy"
                let dateString = "\(month) \(day) \(yearOrTime)"
                date = dateFormatter.date(from: dateString)
            }
            
            let fullPath = basePath.hasSuffix("/") ? "\(basePath)\(name)" : "\(basePath)/\(name)"
            files.append(SFTPFileInfo(name: name, path: fullPath, isDirectory: isDirectory, size: size, modificationDate: date, permissions: permissions))
        }
        
        return files
    }
    
    // MARK: - File Transfer
    
    /// Download a file from remote server using base64 encoding over SSH.
    /// Note: Uses base64 to safely transfer binary data through the SSH text channel.
    func downloadFile(remotePath: String, localURL: URL, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let fileName = (remotePath as NSString).lastPathComponent
        let totalSize = UInt64(0) // Unknown until transfer starts
        delegate?.sftpManager(self, didStartTransfer: fileName, isUpload: false)
        delegate?.sftpManager(self, didUpdateProgress: SFTPTransferProgress(
            fileName: fileName, bytesTransferred: 0, totalBytes: totalSize, isUpload: false
        ))
        
        Task {
            do {
                // Use base64 encoding to safely transfer binary files
                guard let result = try await sshManager?.executeCommand("base64 \(shellEscape(remotePath))") else {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                
                guard let data = Data(base64Encoded: result.stdout, options: .ignoreUnknownCharacters) else {
                    completion(.failure(SFTPError.transferFailed("Failed to decode base64 data from remote file")))
                    return
                }
                
                do {
                    try data.write(to: localURL)
                    delegate?.sftpManager(self, didUpdateProgress: SFTPTransferProgress(
                        fileName: fileName, bytesTransferred: UInt64(data.count), totalBytes: UInt64(data.count), isUpload: false
                    ))
                    delegate?.sftpManager(self, didCompleteTransfer: fileName, isUpload: false)
                    completion(.success(()))
                } catch {
                    completion(.failure(SFTPError.transferFailed("Failed to write local file: \(error.localizedDescription)")))
                }
            } catch {
                completion(.failure(SFTPError.transferFailed("Download failed: \(error.localizedDescription)")))
            }
        }
    }
    
    /// Upload a file to remote server using base64 encoding over SSH
    func uploadFile(localURL: URL, remotePath: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let fileName = localURL.lastPathComponent
        delegate?.sftpManager(self, didStartTransfer: fileName, isUpload: true)
        delegate?.sftpManager(self, didUpdateProgress: SFTPTransferProgress(
            fileName: fileName, bytesTransferred: 0, totalBytes: 0, isUpload: true
        ))
        
        Task {
            do {
                let fileData = try Data(contentsOf: localURL)
                
                guard fileData.count < 100 * 1024 else {
                    completion(.failure(SFTPError.transferFailed("File too large for base64 upload (max 100KB). Size: \(fileData.count) bytes")))
                    return
                }
                
                let base64String = fileData.base64EncodedString()
                delegate?.sftpManager(self, didUpdateProgress: SFTPTransferProgress(
                    fileName: fileName, bytesTransferred: 0, totalBytes: UInt64(fileData.count), isUpload: true
                ))
                
                // Ensure parent directory exists
                let parentDir = (remotePath as NSString).deletingLastPathComponent
                _ = try? await sshManager?.executeCommand("mkdir -p \(shellEscape(parentDir))")
                
                // Write base64 data using printf to avoid echo issues with special characters
                let escapedPath = shellEscape(remotePath)
                let command = "printf '%s' \(shellEscape(base64String)) | base64 -d > \(escapedPath)"
                let cmdResult = try await sshManager?.executeCommand(command)
                if cmdResult == nil {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                
                delegate?.sftpManager(self, didUpdateProgress: SFTPTransferProgress(
                    fileName: fileName, bytesTransferred: UInt64(fileData.count), totalBytes: UInt64(fileData.count), isUpload: true
                ))
                delegate?.sftpManager(self, didCompleteTransfer: fileName, isUpload: true)
                completion(.success(()))
            } catch {
                completion(.failure(SFTPError.transferFailed("Upload failed: \(error.localizedDescription)")))
            }
        }
    }
    
    // MARK: - Quick File Operations via Shell
    
    /// Read a small text file using cat command
    func readTextFile(remotePath: String, completion: @escaping @Sendable (Result<String, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        Task {
            do {
                guard let result = try await sshManager?.executeCommand("cat \(shellEscape(remotePath))") else {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                completion(.success(result.stdout))
            } catch {
                completion(.failure(SFTPError.transferFailed("Failed to read file: \(error.localizedDescription)")))
            }
        }
    }
    
    /// Write a small text file using base64 encoding
    func writeTextFile(remotePath: String, content: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        Task {
            do {
                guard let data = content.data(using: .utf8) else {
                    completion(.failure(SFTPError.transferFailed("Failed to encode content")))
                    return
                }
                let base64String = data.base64EncodedString()
                let escapedPath = shellEscape(remotePath)
                let command = "printf '%s' \(shellEscape(base64String)) | base64 -d > \(escapedPath)"
                let cmdResult = try await sshManager?.executeCommand(command)
                if cmdResult == nil {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                completion(.success(()))
            } catch {
                completion(.failure(SFTPError.transferFailed("Failed to write file: \(error.localizedDescription)")))
            }
        }
    }
    
    /// Create a directory
    func createDirectory(remotePath: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        Task {
            do {
                let cmdResult = try await sshManager?.executeCommand("mkdir -p \(shellEscape(remotePath))")
                if cmdResult == nil {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                completion(.success(()))
            } catch {
                completion(.failure(SFTPError.transferFailed("Failed to create directory: \(error.localizedDescription)")))
            }
        }
    }
    
    /// Delete a file or directory
    func delete(remotePath: String, recursive: Bool = false, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let flag = recursive ? "-rf" : "-f"
        
        Task {
            do {
                let cmdResult = try await sshManager?.executeCommand("rm \(flag) \(shellEscape(remotePath))")
                if cmdResult == nil {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                completion(.success(()))
            } catch {
                completion(.failure(SFTPError.transferFailed("Failed to delete: \(error.localizedDescription)")))
            }
        }
    }
    
    /// Rename/move a file
    func rename(from oldPath: String, to newPath: String, completion: @escaping @Sendable (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        Task {
            do {
                let cmdResult = try await sshManager?.executeCommand("mv \(shellEscape(oldPath)) \(shellEscape(newPath))")
                if cmdResult == nil {
                    completion(.failure(SFTPError.notConnected))
                    return
                }
                completion(.success(()))
            } catch {
                completion(.failure(SFTPError.transferFailed("Failed to rename: \(error.localizedDescription)")))
            }
        }
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - SFTP Session View Model

@MainActor class SFTPSessionViewModel: ObservableObject {
    @Published var files: [SFTPFileInfo] = []
    @Published var currentPath: String = "~"
    @Published var isLoading = false
    @Published var error: String?
    @Published var transferProgress: SFTPTransferProgress?
    
    private(set) var sftpManager: SFTPManager?
    
    func connect(config: SSHConnectionConfig) {
        isLoading = true
        error = nil
        
        sftpManager = SFTPManager()
        sftpManager?.delegate = self
        sftpManager?.connect(config: config) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success:
                    self?.listCurrentDirectory()
                case .failure(let err):
                    self?.error = err.localizedDescription
                }
            }
        }
    }
    
    func disconnect() {
        sftpManager?.disconnect()
        sftpManager = nil
        files = []
    }
    
    func listCurrentDirectory() {
        isLoading = true
        sftpManager?.listDirectory(currentPath) { [weak self] result in
            Task { @MainActor in
                self?.isLoading = false
                switch result {
                case .success(let fileList):
                    self?.files = fileList
                case .failure(let err):
                    self?.error = err.localizedDescription
                }
            }
        }
    }
    
    func navigateToDirectory(_ path: String) {
        currentPath = path
        listCurrentDirectory()
    }
    
    func goUp() {
        // NSString.deletingLastPathComponent doesn't handle "~" correctly,
        // so we handle tilde paths explicitly
        if currentPath == "~" || currentPath.hasPrefix("~/") {
            if currentPath == "~" {
                currentPath = "/"
            } else {
                // Remove last component after ~/
                let relativePath = String(currentPath.dropFirst(2)) // drop "~/"
                let parent = (relativePath as NSString).deletingLastPathComponent
                currentPath = parent.isEmpty ? "~" : "~/\(parent)"
            }
            listCurrentDirectory()
            return
        }
        
        let parent = (currentPath as NSString).deletingLastPathComponent
        navigateToDirectory(parent.isEmpty ? "/" : parent)
    }
}

extension SFTPSessionViewModel: SFTPManagerDelegate {
    nonisolated func sftpManager(_ manager: SFTPManager, didStartTransfer fileName: String, isUpload: Bool) {
        Task { @MainActor in
            self.transferProgress = SFTPTransferProgress(
                fileName: fileName,
                bytesTransferred: 0,
                totalBytes: 0,
                isUpload: isUpload
            )
        }
    }
    
    nonisolated func sftpManager(_ manager: SFTPManager, didUpdateProgress progress: SFTPTransferProgress) {
        Task { @MainActor in
            self.transferProgress = progress
        }
    }
    
    nonisolated func sftpManager(_ manager: SFTPManager, didCompleteTransfer fileName: String, isUpload: Bool) {
        Task { @MainActor in
            self.transferProgress = nil
            self.listCurrentDirectory()
        }
    }
    
    nonisolated func sftpManager(_ manager: SFTPManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.error = error.localizedDescription
            self.transferProgress = nil
        }
    }
    
    nonisolated func sftpManager(_ manager: SFTPManager, didListDirectory files: [SFTPFileInfo]) {
        Task { @MainActor in
            self.files = files
        }
    }
}
