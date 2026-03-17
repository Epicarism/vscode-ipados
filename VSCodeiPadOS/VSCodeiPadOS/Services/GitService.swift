import Foundation
import Combine

struct GitStash: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let date: Date
}

/// Thin observable façade that forwards all git operations to GitManager.shared.
///
/// Previously this class contained mock data and simulated delays.
/// Now every method calls through to the real GitManager backend so that
/// the StatusBar / quick-actions UI drives actual git state.
@MainActor
final class GitService: ObservableObject {
    static let shared = GitService()

    // MARK: - Published State (kept for existing UI consumers)

    @Published var currentBranch: String = "main"
    @Published var statusText: String = ""
    @Published var aheadCount: Int = 0
    @Published var behindCount: Int = 0
    @Published var stashes: [GitStash] = []
    private var busyCount: Int = 0 {
        didSet { isBusy = busyCount > 0 }
    }
    @Published var isBusy: Bool = false
    @Published var branches: [String] = []
    @Published var lastErrorMessage: String?

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private let gitManager = GitManager.shared

    private init() {
        syncFromGitManager()
    }

    // MARK: - Periodic Sync

    /// Polls GitManager every second so published properties stay up-to-date
    /// with the real backend state.
    private func syncFromGitManager() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateFromManager()
            }
            .store(in: &cancellables)
    }

    private func updateFromManager() {
        currentBranch  = gitManager.currentBranch
        branches       = gitManager.branches.map { $0.name }
        aheadCount     = gitManager.aheadCount
        behindCount    = gitManager.behindCount

        // Convert GitStashEntry → GitStash
        stashes = gitManager.stashes.map {
            GitStash(message: $0.message, date: Date())
        }

        // Build human-readable status text from change lists
        let staged   = gitManager.stagedChanges.count
        let unstaged = gitManager.unstagedChanges.count
        let untracked = gitManager.untrackedFiles.count

        if staged + unstaged + untracked == 0 {
            statusText = "Working tree clean"
        } else {
            var parts: [String] = []
            if staged > 0   { parts.append("\(staged) staged") }
            if unstaged > 0 { parts.append("\(unstaged) modified") }
            if untracked > 0 { parts.append("\(untracked) untracked") }
            statusText = parts.joined(separator: ", ")
        }
    }

    // MARK: - Branch Operations

    func switchBranch(to branch: String) {
        busyCount += 1
        Task {
            do {
                try await gitManager.checkout(branch: branch)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func createBranch(named name: String, checkout: Bool = true) {
        guard !name.isEmpty else {
            lastErrorMessage = "Branch name cannot be empty"
            return
        }
        busyCount += 1
        Task {
            do {
                try await gitManager.createBranch(name: name)
                if checkout {
                    try await gitManager.checkout(branch: name)
                }
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func deleteBranch(named branch: String) {
        guard branch != currentBranch else {
            lastErrorMessage = "Cannot delete current branch"
            return
        }
        busyCount += 1
        Task {
            do {
                try await gitManager.deleteBranch(name: branch)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    // MARK: - Status / Commit

    func refreshStatus() {
        busyCount += 1
        Task {
            await gitManager.refresh()
            lastErrorMessage = gitManager.lastError
            busyCount -= 1
        }
    }

    func commit(message: String) {
        busyCount += 1
        Task {
            do {
                try await gitManager.commit(message: message)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    // MARK: - Remote Operations

    func pull() {
        busyCount += 1
        Task {
            do {
                try await gitManager.pull()
                await gitManager.refresh()
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func push() {
        busyCount += 1
        Task {
            do {
                try await gitManager.push()
                await gitManager.refresh()
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func fetch() {
        busyCount += 1
        Task {
            do {
                try await gitManager.fetch()
                await gitManager.refresh()
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    // MARK: - Stash

    func stashSave(message: String?) {
        busyCount += 1
        Task {
            do {
                try await gitManager.stashPush(message: message)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func stashApply(index: Int) {
        busyCount += 1
        Task {
            do {
                // GitManager has stashPop which applies + drops; use it as the
                // nearest equivalent since stashApply is not separately implemented.
                try await gitManager.stashPop(index: index)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }

    func stashPop(index: Int) {
        busyCount += 1
        Task {
            do {
                try await gitManager.stashPop(index: index)
                lastErrorMessage = nil
            } catch {
                lastErrorMessage = error.localizedDescription
            }
            busyCount -= 1
        }
    }
}
