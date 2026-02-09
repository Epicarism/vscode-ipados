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
class SFTPManager {
    weak var delegate: SFTPManagerDelegate?
    
    private var sshManager: SSHManager?
    private(set) var isConnected = false
    private(set) var currentDirectory = "~"
    
    // MARK: - Connection
    
    func connect(config: SSHConnectionConfig, completion: @escaping (Result<Void, Error>) -> Void) {
        sshManager = SSHManager()
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
    func listDirectory(_ path: String, completion: @escaping (Result<[SFTPFileInfo], Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        // Use ls -la to get file listing
        // This is a workaround since SwiftNIO SSH doesn't have SFTP subsystem
        let command = "ls -la \(path)"
        
        // For now, we would need to capture the output and parse it
        // This is a simplified placeholder - full implementation would require
        // exec channel with output capture
        
        // Placeholder response
        let files: [SFTPFileInfo] = []
        completion(.success(files))
    }
    
    // MARK: - File Transfer
    
    /// Download a file from remote server
    /// Uses SCP protocol through SSH
    func downloadFile(remotePath: String, localURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let fileName = (remotePath as NSString).lastPathComponent
        delegate?.sftpManager(self, didStartTransfer: fileName, isUpload: false)
        
        // For full SCP/SFTP implementation, we would need to:
        // 1. Create an exec channel with "scp -f remotePath"
        // 2. Handle the SCP protocol handshake
        // 3. Receive file data and write to local URL
        // 4. Report progress
        
        // This requires more complex channel handling than simple shell commands
        // For production, consider using a library with built-in SFTP support
        
        completion(.failure(SFTPError.transferFailed("Full SFTP not yet implemented. Use shell commands like: cat remotePath > localPath")))
    }
    
    /// Upload a file to remote server
    func uploadFile(localURL: URL, remotePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let fileName = localURL.lastPathComponent
        delegate?.sftpManager(self, didStartTransfer: fileName, isUpload: true)
        
        // Similar to download - full SCP upload requires:
        // 1. Create exec channel with "scp -t remotePath"
        // 2. Handle SCP protocol
        // 3. Send file data
        // 4. Report progress
        
        completion(.failure(SFTPError.transferFailed("Full SFTP not yet implemented. Use shell commands for file transfer.")))
    }
    
    // MARK: - Quick File Operations via Shell
    
    /// Read a small text file using cat command
    func readTextFile(remotePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        // This would send "cat remotePath" and capture output
        // Simplified - full implementation needs exec channel output capture
        sshManager?.send(command: "cat \(remotePath)")
        
        // Output will come through delegate - this is async
        // Real implementation would collect output until command completes
    }
    
    /// Write a small text file using echo/cat
    func writeTextFile(remotePath: String, content: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        // Escape content for shell
        let escaped = content.replacingOccurrences(of: "'", with: "'\"'\"'")
        let command = "echo '\(escaped)' > \(remotePath)"
        sshManager?.send(command: command)
    }
    
    /// Create a directory
    func createDirectory(remotePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        sshManager?.send(command: "mkdir -p \(remotePath)")
    }
    
    /// Delete a file or directory
    func delete(remotePath: String, recursive: Bool = false, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        let command = recursive ? "rm -rf \(remotePath)" : "rm \(remotePath)"
        sshManager?.send(command: command)
    }
    
    /// Rename/move a file
    func rename(from oldPath: String, to newPath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard isConnected else {
            completion(.failure(SFTPError.notConnected))
            return
        }
        
        sshManager?.send(command: "mv \(oldPath) \(newPath)")
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - SFTP Session View Model

class SFTPSessionViewModel: ObservableObject {
    @Published var files: [SFTPFileInfo] = []
    @Published var currentPath: String = "~"
    @Published var isLoading = false
    @Published var error: String?
    @Published var transferProgress: SFTPTransferProgress?
    
    private var sftpManager: SFTPManager?
    
    func connect(config: SSHConnectionConfig) {
        isLoading = true
        error = nil
        
        sftpManager = SFTPManager()
        sftpManager?.delegate = self
        sftpManager?.connect(config: config) { [weak self] result in
            DispatchQueue.main.async {
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
            DispatchQueue.main.async {
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
        let parent = (currentPath as NSString).deletingLastPathComponent
        navigateToDirectory(parent.isEmpty ? "/" : parent)
    }
}

extension SFTPSessionViewModel: SFTPManagerDelegate {
    func sftpManager(_ manager: SFTPManager, didStartTransfer fileName: String, isUpload: Bool) {
        DispatchQueue.main.async {
            self.transferProgress = SFTPTransferProgress(
                fileName: fileName,
                bytesTransferred: 0,
                totalBytes: 0,
                isUpload: isUpload
            )
        }
    }
    
    func sftpManager(_ manager: SFTPManager, didUpdateProgress progress: SFTPTransferProgress) {
        DispatchQueue.main.async {
            self.transferProgress = progress
        }
    }
    
    func sftpManager(_ manager: SFTPManager, didCompleteTransfer fileName: String, isUpload: Bool) {
        DispatchQueue.main.async {
            self.transferProgress = nil
            self.listCurrentDirectory()
        }
    }
    
    func sftpManager(_ manager: SFTPManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error.localizedDescription
            self.transferProgress = nil
        }
    }
    
    func sftpManager(_ manager: SFTPManager, didListDirectory files: [SFTPFileInfo]) {
        DispatchQueue.main.async {
            self.files = files
        }
    }
}
