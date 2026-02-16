# Agent: scout-git-implementation
**Status:** done
**Tokens:** 2,761
**Cost:** $0.0000
**Time:** 2026-02-16T08:57:36.625Z

## Task
Read all git-related files in VSCodeiPadOS. Search for GitManager, GitView, NativeGit folder, any git services. Report: 1) Does branch switching actually work? 2) Is there real git integration or is it mocked/fake? 3) Why would it always show 'main'? List all git functionality that exists vs what's missing.

## Response
I'll investigate the git-related files systematically. Let me start by searching for git-related code.



I'll explore the codebase structure to find git-related files.



---

## 🔧 TOOL RESULTS

[list_dir]
📁 ./
📁 .claude/
📁 .claudefluff/
📁 .garbage/
📁 .patch-backups/
📁 .vscode/
📁 Docs/
📁 Extensions/
📁 logs/
📁 Models/
📁 Services/
📁 test-results/
📁 Tests/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOSUITests/
   .gitignore
   build.log
   FULL_FEATURE_TEST_PLAN.md
   LICENSE
   README.md
   StressTest.swift
   test_editor_typing.sh
   update.md
   VSCodeiPadOS_idb_test_plan.sh
   VSCodeiPadOS_Ui_Element_Coordinates.md




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/
📁 .garbage/
📁 AUDIT/
📁 Docs/
📁 Views/
📁 VSCodeiPadOS/
📁 VSCodeiPadOS.xcodeproj/
📁 VSCodeiPadOSTests/
   bugs.md
   FeatureFlags.swift
   Info.plist
   Package.swift
   TreeSitterLanguages.swift
   TypingLagTest.swift




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Models/
📁 Resources/
📁 Services/
📁 Tests/
📁 UITests/
📁 Utils/
📁 Views/
   .tooling_note.txt
   ContentView_shift_arrow.patch
   ContentView.swift
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KEYBOARD_SHORTCUTS_SOURCE_OF_TRUTH.md
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/
📁 NativeGit/
📁 OnDevice/
📁 Runners/
   AIManager.swift
   AutocompleteManager.swift
   BracketMatchingManager.swift
   CodeExecutionService.swift
   CodeFoldingManager.swift
   ColorPickerManager.swift
   DebugManager.swift
   EditorCore.swift
   ErrorParser.swift
   FileSystemNavigator.swift
   GitManager.swift
   GitService.swift
   HoverInfoManager.swift
   InlayHintsManager.swift
   InlineSuggestionManager.swift
   KeychainManager.swift
   LaunchManager.swift
   NavigationManager.swift
   OutputPanelManager.swift
   RecentFileManager.swift
   RemoteDebugger.swift
   RemoteRunner.swift
   RunestoneThemeAdapter 2.swift
   RunestoneThemeAdapter.swift
   RunnerSelector.existing.swift
   RunnerSelector.swift
   SearchManager.swift
   SettingsManager.swift
   SFTPManager.swift
   SnippetsManager.swift
   SpotlightManager.swift
   SSHManager.swift
   SuggestionCache.swift
   TasksManager.swift
   ThemeManager.swift.bak
   WindowStateManager.swift
   WordOccurrenceHighlighter.swift
   WorkspaceManager.swift
   WorkspaceTrustManager.swift


Found key files. Let me read them:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: d0d74d454dba
File: VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift (lines 1-368 of 368)
────────────────────────────────────────
1|8d0643|//
2|a681a4|//  GitManager.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|42f73a|//  Minimal Git Manager - stub implementation
6|a3ef3b|//  TODO: Implement real git operations via SSH
7|8d0643|//
8|adc83b|
9|d755ba|import SwiftUI
10|421767|import Combine
11|adc83b|
12|eb00b3|// MARK: - Git Errors
13|adc83b|
14|6f65df|enum GitManagerError: Error, LocalizedError {
15|cc70ea|    case noRepository
16|93ecb0|    case gitExecutableNotFound
17|f1987e|    case commandFailed(args: [String], exitCode: Int32, message: String)
18|0e5867|    case notAvailableOnIOS
19|1b602e|    case sshNotConnected
20|cbe433|    case invalidRepository
21|b4687f|    
22|242b78|    var errorDescription: String? {
23|2e6d08|        switch self {
24|ca1a2f|        case .noRepository:
25|7f2cf6|            return "No git repository configured"
26|25890c|        case .gitExecutableNotFound:
27|52af57|            return "Git executable not found"
28|5932f2|        case let .commandFailed(args, exitCode, message):
29|444553|            return "git \(args.joined(separator: " ")) failed (\(exitCode)): \(message)"
30|0b47a4|        case .notAvailableOnIOS:
31|291392|            return "Git is not available on iOS"
32|6f8a3e|        case .sshNotConnected:
33|c79c8b|            return "SSH connection required for git operations"
34|d0b11e|        case .invalidRepository:
35|64fe32|            return "Invalid git repository"
36|5f3077|        }
37|27e597|    }
38|b31277|}
39|adc83b|
40|a7fcab|// MARK: - Git Types
41|adc83b|
42|43496d|enum GitChangeKind: String, Codable, Hashable {
43|f004f5|    case modified = "M"
44|3ef6a0|    case added = "A"
45|7bcdf0|    case deleted = "D"
46|5c09be|    case renamed = "R"
47|ab337b|    case copied = "C"
48|ba162f|    case untracked = "?"
49|55b711|    case ignored = "!"
50|29a9c9|    case unmerged = "U"
51|51d520|    case typeChanged = "T"
52|36025e|    case unknown = "X"
53|b4687f|    
54|4108d4|    var icon: String {
55|2e6d08|        switch self {
56|4ebf17|        case .modified: return "pencil"
57|75bb80|        case .added: return "plus"
58|9abae5|        case .deleted: return "minus"
59|8272ae|        case .renamed: return "arrow.right"
60|c6117d|        case .copied: return "doc.on.doc"
61|f0454e|        case .untracked: return "questionmark"
62|0e5603|        case .ignored: return "eye.slash"
63|2fb838|        case .unmerged: return "exclamationmark.triangle"
64|577382|        case .typeChanged: return "arrow.triangle.2.circlepath"
65|a5d9f5|        case .unknown: return "questionmark.circle"
66|5f3077|        }
67|27e597|    }
68|b4687f|    
69|3e4a5e|    var color: Color {
70|2e6d08|        switch self {
71|98415d|        case .modified: return .orange
72|f43147|        case .added: return .green
73|3950d3|        case .deleted: return .red
74|65f393|        case .renamed: return .blue
75|cf6619|        case .copied: return .blue
76|68ee74|        case .untracked: return .gray
77|6307da|        case .ignored: return .gray
78|f10c45|        case .unmerged: return .yellow
79|6d6ade|        case .typeChanged: return .purple
80|1602ee|        case .unknown: return .gray
81|5f3077|        }
82|27e597|    }
83|b31277|}
84|adc83b|
85|8d3d0e|struct GitBranch: Identifiable, Hashable {
86|c90f8e|    let id = UUID()
87|a5193b|    let name: String
88|507e47|    let isRemote: Bool
89|cef4b1|    let isCurrent: Bool
90|b4687f|    
91|e6dbea|    init(name: String, isRemote: Bool = false, isCurrent: Bool = false) {
92|b8025b|        self.name = name
93|7323cd|        self.isRemote = isRemote
94|8a5300|        self.isCurrent = isCurrent
95|27e597|    }
96|b31277|}
97|adc83b|
98|30dc0f|struct GitCommit: Identifiable, Hashable {
99|df0942|    let id: String // SHA
100|edcb08|    let message: String
101|ab0604|    let author: String
102|b7dcb9|    let date: Date
103|b4687f|    
104|3bd0bb|    var shortSHA: String {
105|531b88|        String(id.prefix(7))
106|27e597|    }
107|b31277|}
108|adc83b|
109|2cc240|struct GitFileChange: Identifiable, Hashable {
110|c90f8e|    let id = UUID()
111|1c6e32|    let path: String
112|a7c046|    let kind: GitChangeKind
113|846299|    let staged: Bool
114|b4687f|    
115|3ee623|    init(path: String, kind: GitChangeKind, staged: Bool = false) {
116|ba629a|        self.path = path
117|6c8f03|        self.kind = kind
118|043d06|        self.staged = staged
119|27e597|    }
120|b31277|}
121|adc83b|
122|7d67f3|struct GitStashEntry: Identifiable, Hashable {
123|c90f8e|    let id = UUID()
124|b081e6|    let index: Int
125|edcb08|    let message: String
126|a43303|    let branch: String
127|b31277|}
128|adc83b|
129|3c6875|// Type alias for compatibility with GitView
130|1b98c0|typealias GitStatusEntry = GitFileChange
131|adc83b|
132|007bc9|// MARK: - Git Manager
133|adc83b|
134|69d728|@MainActor
135|fe2d1c|class GitManager: ObservableObject {
136|3ee011|    static let shared = GitManager()
137|b4687f|    
138|a6df6f|    // MARK: - Published State
139|b4687f|    
140|f8b7f2|    @Published var isRepository: Bool = false
141|143b6b|    @Published var currentBranch: String = "main"
142|4f0eb3|    @Published var branches: [GitBranch] = []
143|254438|    @Published var remoteBranches: [GitBranch] = []
144|087468|    @Published var stagedChanges: [GitFileChange] = []
145|2f344d|    @Published var unstagedChanges: [GitFileChange] = []
146|6d948f|    @Published var untrackedFiles: [GitFileChange] = []
147|79fc52|    @Published var recentCommits: [GitCommit] = []
148|ac5590|    @Published var stashes: [GitStashEntry] = []
149|e588e6|    @Published var isLoading: Bool = false
150|ced50d|    @Published var lastError: String?
151|2c2fe3|    @Published var aheadCount: Int = 0
152|470fd2|    @Published var behindCount: Int = 0
153|b4687f|    
154|e28cad|    private var workingDirectory: URL?
155|28e1f5|    private var nativeReader: NativeGitReader?
156|924ed0|    private var nativeWriter: NativeGitWriter?
157|b4687f|    
158|54113e|    private init() {}
159|b4687f|    
160|43f74b|    // MARK: - Repository Setup
161|b4687f|    
162|754bc0|    func setWorkingDirectory(_ url: URL?) {
163|795ec8|        self.workingDirectory = url
164|d6ed84|        
165|e43f58|        if let url {
166|0d8835|            self.nativeReader = NativeGitReader(repositoryURL: url)
167|d5f9ae|            self.nativeWriter = NativeGitWriter(repositoryURL: url)
168|71286a|            self.isRepository = (self.nativeReader != nil)
169|b31999|        } else {
170|13238f|            self.nativeReader = nil
171|afe6f4|            self.nativeWriter = nil
172|6bc6df|            self.isRepository = false
173|5f3077|        }
174|d6ed84|        
175|f4140b|        if isRepository {
176|2bb1e0|            Task { await refresh() }
177|b31999|        } else {
178|e4ade3|            clearRepository()
179|5f3077|        }
180|27e597|    }
181|b4687f|    
182|46db57|    func clearRepository() {
183|78dc66|        isRepository = false
184|d7f3a5|        currentBranch = "main"
185|b42be3|        branches = []
186|98fabb|        remoteBranches = []
187|9501c8|        stagedChanges = []
188|f62fa3|        unstagedChanges = []
189|a42b5b|        untrackedFiles = []
190|082a68|        recentCommits = []
191|7604df|        stashes = []
192|f0416e|        lastError = nil
193|27e597|    }
194|b4687f|    
195|24d09e|    // MARK: - Git Operations
196|b4687f|    
197|698888|    func refresh() async {
198|d52924|        isLoading = true
199|9c61fa|        defer { isLoading = false }
200|f0416e|        lastError = nil
201|d6ed84|        
202|b444e2|        guard let reader = nativeReader else {
203|8b820e|            lastError = "No git repository found"
204|bef5d6|            return
205|5f3077|        }
206|d6ed84|        
207|804616|        // Current branch
208|a2eb60|        currentBranch = reader.currentBranch() ?? "HEAD"
209|d6ed84|        
210|51e308|        // Branches
211|45f1be|        let localBranchNames = reader.localBranches()
212|caf998|        branches = localBranchNames.map { name in
213|53c644|            GitBranch(name: name, isRemote: false, isCurrent: name == currentBranch)
214|5f3077|        }
215|d6ed84|        
216|95ddd9|        let remoteBranchPairs = reader.remoteBranches()
217|8c6249|        remoteBranches = remoteBranchPairs.map { (remote, branch) in
218|6f1cd3|            GitBranch(name: "\(remote)/\(branch)", isRemote: true, isCurrent: false)
219|5f3077|        }
220|d6ed84|        
221|0a3885|        // Status
222|92252a|        let fileStatuses = reader.status()
223|d6ed84|        
224|4f9ab0|        stagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
225|99c683|            guard let staged = status.staged else { return nil }
226|5ac02f|            return GitFileChange(path: status.path, kind: mapStatusType(staged), staged: true)
227|5f3077|        }
228|d6ed84|        
229|a813d6|        unstagedChanges = fileStatuses.compactMap { status -> GitFileChange? in
230|3d5fa5|            guard let working = status.working else { return nil }
231|c3fce9|            return GitFileChange(path: status.path, kind: mapStatusType(working), staged: false)
232|5f3077|        }
233|d6ed84|        
234|251543|        untrackedFiles = fileStatuses.compactMap { status -> GitFileChange? in
235|c3b94d|            guard status.working == .untracked else { return nil }
236|80a4a3|            return GitFileChange(path: status.path, kind: .untracked, staged: false)
237|5f3077|        }
238|d6ed84|        
239|e17e18|        // Recent commits
240|1f2245|        let commits = reader.recentCommits(count: 20)
241|ae143e|        recentCommits = commits.map { commit in
242|a4114d|            GitCommit(id: commit.sha, message: commit.message, author: commit.author, date: commit.authorDate)
243|5f3077|        }
244|27e597|    }
245|b4687f|    
246|cd06a1|    private func mapStatusType(_ status: GitStatusType) -> GitChangeKind {
247|845f72|        switch status {
248|710db6|        case .modified: return .modified
249|899ede|        case .added: return .added
250|4e70e5|        case .deleted: return .deleted
251|b204a9|        case .renamed: return .renamed
252|997535|        case .copied: return .copied
253|fa020b|        case .untracked: return .untracked
254|6f806d|        case .ignored: return .ignored
255|5f3077|        }
256|27e597|    }
257|b4687f|    
258|7a1b57|    /// Build a real diff for a working-copy file against HEAD (offline, using NativeGitReader).
259|422db6|    func diffWorkingCopyToHEAD(path: String, kind: GitChangeKind) async -> DiffFile? {
260|a40fde|        guard let repoURL = workingDirectory else { return nil }
261|d6ed84|        
262|0dc171|        return await Task.detached {
263|3519ac|            guard let reader = NativeGitReader(repositoryURL: repoURL) else { return nil }
264|3070d1|            
265|83a740|            let headSha = reader.headSHA()
266|85bb51|            let oldText = reader.fileContentsString(atPath: path, commitSHA: headSha) ?? ""
267|3070d1|            
268|b35691|            let workingURL = repoURL.appendingPathComponent(path)
269|567024|            let newText = (try? String(contentsOf: workingURL, encoding: .utf8)) ?? ""
270|3070d1|            
271|848698|            return DiffBuilder.build(
272|d02bb2|                fileName: path,
273|7e8d9b|                status: kind.rawValue,
274|7f9b45|                old: oldText,
275|87834e|                new: newText
276|43d041|            )
277|2ecb78|        }.value
278|27e597|    }
279|b4687f|    
280|707ea2|    func stage(file: String) async throws {
281|e1bfbb|        guard let writer = nativeWriter else {
282|2085bb|            throw GitManagerError.invalidRepository
283|5f3077|        }
284|bd709d|        try writer.stageFile(path: file)
285|61ed9d|        await refresh()
286|27e597|    }
287|b4687f|    
288|6b4fc1|    func stageAll() async throws {
289|e1bfbb|        guard let writer = nativeWriter else {
290|2085bb|            throw GitManagerError.invalidRepository
291|5f3077|        }
292|9be99e|        try writer.stageAll()
293|61ed9d|        await refresh()
294|27e597|    }
295|b4687f|    
296|8e6f38|    func unstage(file: String) async throws {
297|e1bfbb|        guard let writer = nativeWriter else {
298|2085bb|            throw GitManagerError.invalidRepository
299|5f3077|        }
300|e95e41|        try writer.unstageFile(path: file)
301|61ed9d|        await refresh()
302|27e597|    }
303|b4687f|    
304|0163dc|    func commit(message: String) async throws {
305|d9ce95|        guard let dir = workingDirectory else {
306|bfc324|            throw GitManagerError.noRepository
307|5f3077|        }
308|e1bfbb|        guard let writer = nativeWriter else {
309|2085bb|            throw GitManagerError.invalidRepository
310|5f3077|        }
311|d66412|        let sha = try writer.commit(message: message)
312|61ed9d|        await refresh()
313|27e597|    }
314|b4687f|    
315|8bd662|    func checkout(branch: String) async throws {
316|832915|        throw GitManagerError.sshNotConnected
317|27e597|    }
318|b4687f|    
319|7440d7|    func createBranch(name: String) async throws {
320|832915|        throw GitManagerError.sshNotConnected
321|27e597|    }
322|b4687f|    
323|7ecbb9|    func deleteBranch(name: String) async throws {
324|832915|        throw GitManagerError.sshNotConnected
325|27e597|    }
326|b4687f|    
327|6555bb|    func pull() async throws {
328|832915|        throw GitManagerError.sshNotConnected
329|27e597|    }
330|b4687f|    
331|52b305|    func push() async throws {
332|832915|        throw GitManagerError.sshNotConnected
333|27e597|    }
334|b4687f|    
335|63ca01|    func stashPush(message: String?) async throws {
336|832915|        throw GitManagerError.sshNotConnected
337|27e597|    }
338|b4687f|    
339|e99e09|    func stashPop(index: Int) async throws {
340|832915|        throw GitManagerError.sshNotConnected
341|27e597|    }
342|b4687f|    
343|319b4c|    func stashDrop(index: Int) async throws {
344|832915|        throw GitManagerError.sshNotConnected
345|27e597|    }
346|b4687f|    
347|3b3ea2|    func discard(file: String) async throws {
348|832915|        throw GitManagerError.sshNotConnected
349|27e597|    }
350|b4687f|    
351|a51d62|    func discardAll() async throws {
352|832915|        throw GitManagerError.sshNotConnected
353|27e597|    }
354|b4687f|    
355|83db62|    func discardChanges(file: String) async throws {
356|832915|        throw GitManagerError.sshNotConnected
357|27e597|    }
358|b4687f|    
359|7b4d97|    func fetch() async throws {
360|832915|        throw GitManagerError.sshNotConnected
361|27e597|    }
362|b4687f|    
363|7dd28d|    /// Alias for lastError for compatibility
364|a3fa2d|    var error: String? {
365|0f8a8a|        return lastError
366|27e597|    }
367|b31277|}
368|adc83b|




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/
   NativeGitReader.swift
   NativeGitWriter.swift
   SSHGitClient.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 44312bbce5ef
File: VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/NativeGitReader.swift (lines 1-805 of 805)
────────────────────────────────────────
1|8d0643|//
2|fd5878|//  NativeGitReader.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|e48b92|//  Native Swift git repository reader - parses .git directory directly
6|2f8657|//  Works offline without git binary (iOS compatible)
7|8d0643|//
8|adc83b|
9|8b6b78|import Foundation
10|43dc2e|import Compression
11|adc83b|
12|fc6988|// MARK: - Git Object Types
13|adc83b|
14|464f02|enum GitObjectType: String {
15|50ec5f|    case commit
16|7b0a43|    case tree
17|791f9b|    case blob
18|61da71|    case tag
19|b31277|}
20|adc83b|
21|9b0ea6|struct GitObject {
22|164b99|    let type: GitObjectType
23|714851|    let size: Int
24|49549b|    let data: Data
25|b31277|}
26|adc83b|
27|1e740a|// MARK: - Native Git Reader
28|adc83b|
29|7a70da|class NativeGitReader {
30|5fb483|    let repoURL: URL
31|c1462f|    let gitDir: URL
32|b4687f|    
33|42c86d|    private var indexCache: GitIndex?
34|37e205|    private var headCache: String?
35|b4687f|    
36|f40006|    init?(repositoryURL: URL) {
37|d497c0|        self.repoURL = repositoryURL
38|46721d|        self.gitDir = repositoryURL.appendingPathComponent(".git")
39|d6ed84|        
40|b424a0|        // Verify .git directory exists
41|6e4239|        var isDir: ObjCBool = false
42|1af6b0|        guard FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDir),
43|2f0e01|              isDir.boolValue else {
44|1c8557|            return nil
45|5f3077|        }
46|27e597|    }
47|b4687f|    
48|398a68|    // MARK: - HEAD & Current Branch
49|b4687f|    
50|3bcff1|    /// Read current branch name from .git/HEAD
51|c2d48b|    func currentBranch() -> String? {
52|c01141|        let headFile = gitDir.appendingPathComponent("HEAD")
53|004423|        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else {
54|1c8557|            return nil
55|5f3077|        }
56|d6ed84|        
57|8e4a4d|        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
58|d6ed84|        
59|c694b1|        // HEAD can be:
60|a7b212|        // 1. "ref: refs/heads/branch-name" (normal)
61|a76f4d|        // 2. A raw SHA (detached HEAD)
62|f10368|        if trimmed.hasPrefix("ref: refs/heads/") {
63|721146|            return String(trimmed.dropFirst("ref: refs/heads/".count))
64|748a9c|        } else if trimmed.hasPrefix("ref: ") {
65|5ec7b8|            // Other ref type
66|85992a|            return String(trimmed.dropFirst("ref: ".count))
67|b31999|        } else {
68|08811e|            // Detached HEAD - return short SHA
69|696200|            return String(trimmed.prefix(7)) + " (detached)"
70|5f3077|        }
71|27e597|    }
72|b4687f|    
73|6f76cd|    /// Get the SHA that HEAD points to
74|5a818c|    func headSHA() -> String? {
75|c01141|        let headFile = gitDir.appendingPathComponent("HEAD")
76|004423|        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else {
77|1c8557|            return nil
78|5f3077|        }
79|d6ed84|        
80|8e4a4d|        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
81|d6ed84|        
82|3c1b88|        if trimmed.hasPrefix("ref: ") {
83|b57d9d|            // Resolve the reference
84|78a0da|            let refPath = String(trimmed.dropFirst("ref: ".count))
85|5382b2|            return resolveRef(refPath)
86|b31999|        } else {
87|e08369|            // Direct SHA
88|868c3a|            return trimmed
89|5f3077|        }
90|27e597|    }
91|adc83b|
92|70a99f|    // MARK: - File contents (from commit)
93|adc83b|
94|fd9b5f|    /// Read a file's blob contents at a given commit (default: HEAD).
95|064e9f|    func fileContents(atPath path: String, commitSHA: String? = nil) -> Data? {
96|aa260d|        let commitSha = commitSHA ?? headSHA()
97|83d610|        guard let commitSha,
98|9a7761|              let commit = parseCommit(sha: commitSha),
99|5ff640|              let treeSha = commit.treeSHA,
100|d2f635|              let blobSha = blobSHA(forPath: path, inTree: treeSha),
101|03cbae|              let blob = readObject(sha: blobSha),
102|27b412|              blob.type == .blob else {
103|1c8557|            return nil
104|5f3077|        }
105|adc83b|
106|62c510|        return blob.data
107|27e597|    }
108|adc83b|
109|6b23b8|    func fileContentsString(atPath path: String, commitSHA: String? = nil, encoding: String.Encoding = .utf8) -> String? {
110|908025|        guard let data = fileContents(atPath: path, commitSHA: commitSHA) else { return nil }
111|291e97|        return String(data: data, encoding: encoding)
112|27e597|    }
113|adc83b|
114|3ca80f|    private func blobSHA(forPath path: String, inTree treeSHA: String) -> String? {
115|dd1ba6|        let components = path.split(separator: "/").map(String.init)
116|0d24f8|        return blobSHA(pathComponents: components, inTree: treeSHA)
117|27e597|    }
118|adc83b|
119|915912|    private func blobSHA(pathComponents: [String], inTree treeSHA: String) -> String? {
120|303cca|        guard !pathComponents.isEmpty else { return nil }
121|806f4b|        guard let object = readObject(sha: treeSHA), object.type == .tree else { return nil }
122|adc83b|
123|2e5b1b|        let entries = parseTreeEntries(data: object.data)
124|4c61d8|        let head = pathComponents[0]
125|adc83b|
126|0cc2c0|        if pathComponents.count == 1 {
127|d5fd96|            guard let entry = entries.first(where: { $0.name == head }) else { return nil }
128|3a9535|            // Not a directory
129|d5bcbd|            guard !entry.mode.hasPrefix("40") else { return nil }
130|5db263|            return entry.sha
131|5f3077|        }
132|adc83b|
133|22fffc|        // Directory
134|f2a7e6|        guard let dir = entries.first(where: { $0.name == head && $0.mode.hasPrefix("40") }) else { return nil }
135|caa2b1|        return blobSHA(pathComponents: Array(pathComponents.dropFirst()), inTree: dir.sha)
136|27e597|    }
137|b4687f|    
138|7a4981|    // MARK: - Branches
139|b4687f|    
140|d9f5af|    /// List all local branches from .git/refs/heads/
141|61fdda|    func localBranches() -> [String] {
142|35e981|        let headsDir = gitDir.appendingPathComponent("refs/heads")
143|277309|        return listRefsRecursively(at: headsDir, prefix: "")
144|27e597|    }
145|b4687f|    
146|288dfe|    /// List all remote branches from .git/refs/remotes/
147|6a5f2b|    func remoteBranches() -> [(remote: String, branch: String)] {
148|7c87c3|        let remotesDir = gitDir.appendingPathComponent("refs/remotes")
149|3645fa|        var results: [(String, String)] = []
150|d6ed84|        
151|92c7b3|        guard let remotes = try? FileManager.default.contentsOfDirectory(atPath: remotesDir.path) else {
152|b0f460|            return []
153|5f3077|        }
154|d6ed84|        
155|970efe|        for remote in remotes {
156|018407|            let remoteDir = remotesDir.appendingPathComponent(remote)
157|f4d662|            let branches = listRefsRecursively(at: remoteDir, prefix: "")
158|08bdc5|            for branch in branches where branch != "HEAD" {
159|a0e091|                results.append((remote, branch))
160|a7dc16|            }
161|5f3077|        }
162|d6ed84|        
163|32b4af|        return results
164|27e597|    }
165|b4687f|    
166|13f893|    private func listRefsRecursively(at url: URL, prefix: String) -> [String] {
167|c71ba9|        var results: [String] = []
168|d6ed84|        
169|374743|        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
170|b0f460|            return []
171|5f3077|        }
172|d6ed84|        
173|425d38|        for item in contents {
174|c37432|            let itemURL = url.appendingPathComponent(item)
175|b4d7a5|            var isDir: ObjCBool = false
176|25ae39|            FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)
177|3070d1|            
178|236d40|            let fullName = prefix.isEmpty ? item : "\(prefix)/\(item)"
179|3070d1|            
180|b9649c|            if isDir.boolValue {
181|65e4fd|                results.append(contentsOf: listRefsRecursively(at: itemURL, prefix: fullName))
182|f5a6eb|            } else {
183|201d71|                results.append(fullName)
184|a7dc16|            }
185|5f3077|        }
186|d6ed84|        
187|32b4af|        return results
188|27e597|    }
189|b4687f|    
190|75ce3f|    // MARK: - Reference Resolution
191|b4687f|    
192|778290|    /// Resolve a ref path (like refs/heads/main) to a SHA
193|19e1b1|    func resolveRef(_ refPath: String) -> String? {
194|8a8abb|        // First check loose refs
195|a3e341|        let refFile = gitDir.appendingPathComponent(refPath)
196|43b4ff|        if let content = try? String(contentsOf: refFile, encoding: .utf8) {
197|6c4c5f|            return content.trimmingCharacters(in: .whitespacesAndNewlines)
198|5f3077|        }
199|d6ed84|        
200|668bcf|        // Check packed-refs
201|54d73b|        return resolvePackedRef(refPath)
202|27e597|    }
203|b4687f|    
204|a7f14d|    private func resolvePackedRef(_ refPath: String) -> String? {
205|5b1253|        let packedRefsFile = gitDir.appendingPathComponent("packed-refs")
206|49faab|        guard let content = try? String(contentsOf: packedRefsFile, encoding: .utf8) else {
207|1c8557|            return nil
208|5f3077|        }
209|d6ed84|        
210|d2b4bd|        for line in content.components(separatedBy: .newlines) {
211|ec6750|            let trimmed = line.trimmingCharacters(in: .whitespaces)
212|27ab74|            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("^") {
213|1df510|                continue
214|a7dc16|            }
215|3070d1|            
216|bc4e64|            let parts = trimmed.split(separator: " ", maxSplits: 1)
217|46a25b|            if parts.count == 2, String(parts[1]) == refPath {
218|d663bb|                return String(parts[0])
219|a7dc16|            }
220|5f3077|        }
221|d6ed84|        
222|c2ae65|        return nil
223|27e597|    }
224|b4687f|    
225|9d6728|    // MARK: - Commit Parsing
226|b4687f|    
227|2d2a59|    /// Parse a commit object by SHA
228|f6a7f3|    func parseCommit(sha: String) -> GitCommitInfo? {
229|43cac9|        guard let object = readObject(sha: sha),
230|08cd24|              object.type == .commit,
231|5cd4b2|              let content = String(data: object.data, encoding: .utf8) else {
232|1c8557|            return nil
233|5f3077|        }
234|d6ed84|        
235|0e0031|        return GitCommitInfo.parse(sha: sha, content: content)
236|27e597|    }
237|b4687f|    
238|e7ad65|    /// Get recent commits from HEAD
239|d5a901|    func recentCommits(count: Int = 20) -> [GitCommitInfo] {
240|289d01|        guard let headSha = headSHA() else { return [] }
241|d6ed84|        
242|f582b6|        var commits: [GitCommitInfo] = []
243|a462a7|        var currentSha: String? = headSha
244|d6ed84|        
245|363a4a|        while let sha = currentSha, commits.count < count {
246|46914a|            guard let commit = parseCommit(sha: sha) else { break }
247|dde72b|            commits.append(commit)
248|e73242|            currentSha = commit.parentSHA
249|5f3077|        }
250|d6ed84|        
251|b34909|        return commits
252|27e597|    }
253|b4687f|    
254|5ea5a1|    // MARK: - Object Storage
255|b4687f|    
256|d46395|    /// Read a git object by SHA (from loose objects or pack files)
257|bd06e9|    func readObject(sha: String) -> GitObject? {
258|76351a|        // First try loose objects
259|b4e01c|        if let obj = readLooseObject(sha: sha) {
260|e9f8c9|            return obj
261|5f3077|        }
262|d6ed84|        
263|cc74b4|        // Then try pack files
264|a51ea8|        return readPackedObject(sha: sha)
265|27e597|    }
266|b4687f|    
267|8b65c5|    private func readLooseObject(sha: String) -> GitObject? {
268|d9a6f1|        guard sha.count >= 2 else { return nil }
269|d6ed84|        
270|bac8e2|        let prefix = String(sha.prefix(2))
271|fc0849|        let suffix = String(sha.dropFirst(2))
272|d50afc|        let objectPath = gitDir
273|392379|            .appendingPathComponent("objects")
274|565f86|            .appendingPathComponent(prefix)
275|3c6ffe|            .appendingPathComponent(suffix)
276|d6ed84|        
277|46f24e|        guard let compressedData = try? Data(contentsOf: objectPath) else {
278|1c8557|            return nil
279|5f3077|        }
280|d6ed84|        
281|7bab35|        // Git objects are zlib compressed
282|e2ad71|        guard let decompressed = decompressZlib(compressedData) else {
283|1c8557|            return nil
284|5f3077|        }
285|d6ed84|        
286|f1263c|        return parseGitObject(data: decompressed)
287|27e597|    }
288|b4687f|    
289|9d0a29|    private func readPackedObject(sha: String) -> GitObject? {
290|9cc670|        // Pack file reading is complex - for now return nil
291|e20ec6|        // Full implementation would:
292|627f69|        // 1. Read .git/objects/pack/*.idx files
293|35c3f6|        // 2. Find SHA in index
294|e5321f|        // 3. Read corresponding .pack file
295|fda1b3|        // 4. Handle delta compression
296|d6ed84|        
297|049880|        // For MVP, rely on loose objects + SSH fallback for packed repos
298|c2ae65|        return nil
299|27e597|    }
300|b4687f|    
301|1da514|    private func parseGitObject(data: Data) -> GitObject? {
302|2a4885|        // Git object format: "type size\0content"
303|8567f6|        guard let nullIndex = data.firstIndex(of: 0) else { return nil }
304|d6ed84|        
305|81d9ba|        let headerData = data[..<nullIndex]
306|a9b044|        guard let header = String(data: headerData, encoding: .utf8) else { return nil }
307|d6ed84|        
308|9df3b4|        let parts = header.split(separator: " ")
309|fc60f4|        guard parts.count == 2,
310|bf6cb4|              let type = GitObjectType(rawValue: String(parts[0])),
311|01cc7d|              let size = Int(parts[1]) else {
312|1c8557|            return nil
313|5f3077|        }
314|d6ed84|        
315|ae5929|        let contentStart = data.index(after: nullIndex)
316|b863d6|        let content = data[contentStart...]
317|d6ed84|        
318|5ba359|        return GitObject(type: type, size: size, data: Data(content))
319|27e597|    }
320|b4687f|    
321|b2c734|    // MARK: - Index (Staging Area)
322|b4687f|    
323|5ad1fd|    /// Read .git/index to get staged files
324|cfed20|    func readIndex() -> GitIndex? {
325|1b1a27|        let indexPath = gitDir.appendingPathComponent("index")
326|e60569|        guard let data = try? Data(contentsOf: indexPath) else {
327|1c8557|            return nil
328|5f3077|        }
329|d6ed84|        
330|b9b252|        return GitIndex.parse(data: data)
331|27e597|    }
332|b4687f|    
333|63bec4|    // MARK: - Working Directory Status
334|b4687f|    
335|6b5f2a|    /// Compare working directory to index and HEAD to determine status
336|d2a62e|    func status() -> [GitFileStatus] {
337|3a7b2f|        var statuses: [GitFileStatus] = []
338|d6ed84|        
339|f52630|        // Get index entries
340|c41fe1|        let index = readIndex()
341|e0a297|        let indexEntries = index?.entries ?? []
342|67b5f4|        let indexPaths = Set(indexEntries.map { $0.path })
343|d6ed84|        
344|d26aa8|        // Get HEAD tree entries
345|df700f|        let headTree = headTreeEntries()
346|3af7b7|        let headPaths = Set(headTree.keys)
347|d6ed84|        
348|104273|        // Get working directory files
349|1e6044|        let workingFiles = scanWorkingDirectory()
350|66054e|        let workingPaths = Set(workingFiles.keys)
351|d6ed84|        
352|dd8d32|        // Determine status for each file
353|6a2e97|        let allPaths = indexPaths.union(headPaths).union(workingPaths)
354|d6ed84|        
355|1da01e|        for path in allPaths {
356|d48197|            let inIndex = indexPaths.contains(path)
357|2bf8c4|            let inHead = headPaths.contains(path)
358|ce674b|            let inWorking = workingPaths.contains(path)
359|3070d1|            
360|0f267c|            let indexEntry = indexEntries.first { $0.path == path }
361|79f9e2|            let headSha = headTree[path]
362|e24ca9|            let workingInfo = workingFiles[path]
363|3070d1|            
364|ff67a0|            // Determine staged status (index vs HEAD)
365|32ca74|            var stagedStatus: GitStatusType? = nil
366|90e632|            if inIndex && !inHead {
367|e619b2|                stagedStatus = .added
368|8a5d88|            } else if !inIndex && inHead {
369|c9c548|                stagedStatus = .deleted
370|f186a0|            } else if inIndex && inHead {
371|a758f2|                if indexEntry?.sha != headSha {
372|8e7322|                    stagedStatus = .modified
373|4e2d32|                }
374|a7dc16|            }
375|3070d1|            
376|002272|            // Determine working status (working dir vs index)
377|619e11|            var workingStatus: GitStatusType? = nil
378|84f003|            if inWorking && !inIndex && !inHead {
379|8dccc4|                workingStatus = .untracked
380|26a2de|            } else if !inWorking && inIndex {
381|da90cf|                workingStatus = .deleted
382|0b04c9|            } else if inWorking && inIndex {
383|a1abb3|                // Compare working file to index
384|cfed41|                if let entry = indexEntry, let info = workingInfo {
385|c71b0c|                    if info.mtime != entry.mtime || info.size != entry.size {
386|c960ed|                        // File changed - verify with content hash if needed
387|a10a6f|                        workingStatus = .modified
388|c9717a|                    }
389|4e2d32|                }
390|a7dc16|            }
391|3070d1|            
392|52339a|            if stagedStatus != nil || workingStatus != nil {
393|2c0507|                statuses.append(GitFileStatus(
394|869d14|                    path: path,
395|b0f02d|                    staged: stagedStatus,
396|da5693|                    working: workingStatus
397|2188d8|                ))
398|a7dc16|            }
399|5f3077|        }
400|d6ed84|        
401|e65ba7|        return statuses.sorted { $0.path < $1.path }
402|27e597|    }
403|b4687f|    
404|741290|    /// Get tree entries from HEAD commit
405|af070d|    private func headTreeEntries() -> [String: String] {
406|eedd84|        guard let headSha = headSHA(),
407|a8bfab|              let commit = parseCommit(sha: headSha),
408|851b09|              let treeSha = commit.treeSHA else {
409|a3b117|            return [:]
410|5f3077|        }
411|d6ed84|        
412|d18f0b|        return flattenTree(sha: treeSha, prefix: "")
413|27e597|    }
414|b4687f|    
415|0913c8|    private func flattenTree(sha: String, prefix: String) -> [String: String] {
416|43cac9|        guard let object = readObject(sha: sha),
417|d461de|              object.type == .tree else {
418|a3b117|            return [:]
419|5f3077|        }
420|d6ed84|        
421|6ee0b5|        var results: [String: String] = [:]
422|2e5b1b|        let entries = parseTreeEntries(data: object.data)
423|d6ed84|        
424|238380|        for entry in entries {
425|7543ca|            let fullPath = prefix.isEmpty ? entry.name : "\(prefix)/\(entry.name)"
426|3070d1|            
427|e5c04d|            if entry.mode.hasPrefix("40") { // Directory (tree)
428|4ed8a4|                let subtree = flattenTree(sha: entry.sha, prefix: fullPath)
429|a86751|                results.merge(subtree) { _, new in new }
430|f5a6eb|            } else {
431|8853d8|                results[fullPath] = entry.sha
432|a7dc16|            }
433|5f3077|        }
434|d6ed84|        
435|32b4af|        return results
436|27e597|    }
437|b4687f|    
438|da6b38|    private func parseTreeEntries(data: Data) -> [(mode: String, name: String, sha: String)] {
439|10efd1|        var entries: [(String, String, String)] = []
440|2cb527|        var offset = 0
441|d6ed84|        
442|126a3b|        while offset < data.count {
443|747911|            // Find space after mode
444|67fc5d|            guard let spaceIndex = data[offset...].firstIndex(of: 0x20) else { break }
445|a3cc9c|            let modeData = data[offset..<spaceIndex]
446|6d483e|            guard let mode = String(data: modeData, encoding: .ascii) else { break }
447|3070d1|            
448|4ec6cd|            // Find null after name
449|d36b62|            let nameStart = spaceIndex + 1
450|306227|            guard let nullIndex = data[nameStart...].firstIndex(of: 0) else { break }
451|327bc9|            let nameData = data[nameStart..<nullIndex]
452|237c3c|            guard let name = String(data: nameData, encoding: .utf8) else { break }
453|3070d1|            
454|92403e|            // Read 20-byte SHA
455|c5842b|            let shaStart = nullIndex + 1
456|be9d3b|            let shaEnd = shaStart + 20
457|eb4a79|            guard shaEnd <= data.count else { break }
458|0075b7|            let shaData = data[shaStart..<shaEnd]
459|bb46c1|            let sha = shaData.map { String(format: "%02x", $0) }.joined()
460|3070d1|            
461|3e2294|            entries.append((mode, name, sha))
462|372dcb|            offset = shaEnd
463|5f3077|        }
464|d6ed84|        
465|f9dee7|        return entries
466|27e597|    }
467|b4687f|    
468|365fba|    /// Scan working directory for files
469|6baeb6|    private func scanWorkingDirectory() -> [String: (mtime: Date, size: Int)] {
470|578db3|        var results: [String: (Date, Int)] = [:]
471|d6ed84|        
472|460d36|        let fm = FileManager.default
473|7b0e72|        guard let enumerator = fm.enumerator(
474|465a86|            at: repoURL,
475|050fec|            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey, .isDirectoryKey],
476|8f84cb|            options: [.skipsHiddenFiles]
477|f77fdf|        ) else {
478|a3b117|            return [:]
479|5f3077|        }
480|d6ed84|        
481|fd76eb|        while let url = enumerator.nextObject() as? URL {
482|59433a|            // Skip .git directory
483|125938|            if url.path.contains("/.git/") || url.lastPathComponent == ".git" {
484|1df510|                continue
485|a7dc16|            }
486|3070d1|            
487|71cc09|            do {
488|410a97|                let values = try url.resourceValues(forKeys: [.isDirectoryKey, .contentModificationDateKey, .fileSizeKey])
489|216278|                
490|2d3b42|                if values.isDirectory == true {
491|f41bef|                    continue
492|4e2d32|                }
493|216278|                
494|9f4481|                let relativePath = url.path.replacingOccurrences(of: repoURL.path + "/", with: "")
495|566577|                let mtime = values.contentModificationDate ?? Date.distantPast
496|e204a4|                let size = values.fileSize ?? 0
497|216278|                
498|e56feb|                results[relativePath] = (mtime, size)
499|91b9a2|            } catch {
500|1df510|                continue
501|a7dc16|            }
502|5f3077|        }
503|d6ed84|        
504|32b4af|        return results
505|27e597|    }
506|b4687f|    
507|02dfb8|    // MARK: - Zlib Decompression (using iOS Compression framework)
508|b4687f|    
509|53b94b|    private func decompressZlib(_ data: Data) -> Data? {
510|9b6576|        // Git uses zlib compression (DEFLATE with zlib header)
511|82065f|        // iOS Compression framework supports COMPRESSION_ZLIB
512|d6ed84|        
513|072510|        guard data.count > 2 else { return nil }
514|d6ed84|        
515|92162c|        // Zlib format: 1 byte CMF + 1 byte FLG + compressed data + 4 byte Adler-32
516|3b7b90|        // We need to skip the 2-byte header for raw DEFLATE
517|66961e|        let sourceData: Data
518|22af4c|        if data[0] == 0x78 { // Zlib header present
519|833c99|            // Skip zlib header (2 bytes) and Adler-32 checksum (last 4 bytes)
520|440446|            if data.count > 6 {
521|446361|                sourceData = data.dropFirst(2).dropLast(4)
522|f5a6eb|            } else {
523|3efd1d|                sourceData = data.dropFirst(2)
524|a7dc16|            }
525|b31999|        } else {
526|63b8ac|            sourceData = data
527|5f3077|        }
528|d6ed84|        
529|b8be62|        // Allocate destination buffer (git objects are usually small, but can be large)
530|ef28bc|        let destinationBufferSize = max(sourceData.count * 10, 65536)
531|edfde8|        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
532|e94821|        defer { destinationBuffer.deallocate() }
533|d6ed84|        
534|abe232|        let decompressedSize = sourceData.withUnsafeBytes { sourcePtr -> Int in
535|81db49|            guard let sourceBaseAddress = sourcePtr.baseAddress else { return 0 }
536|3070d1|            
537|7e34e8|            return compression_decode_buffer(
538|60d8f8|                destinationBuffer,
539|3e48b6|                destinationBufferSize,
540|fe1a17|                sourceBaseAddress.assumingMemoryBound(to: UInt8.self),
541|0b0392|                sourceData.count,
542|8da2f2|                nil,
543|ae388b|                COMPRESSION_ZLIB
544|43d041|            )
545|5f3077|        }
546|d6ed84|        
547|058db1|        guard decompressedSize > 0 else {
548|d4695a|            // Try with raw DEFLATE if zlib failed
549|1d084e|            return decompressRawDeflate(sourceData)
550|5f3077|        }
551|d6ed84|        
552|c630d8|        return Data(bytes: destinationBuffer, count: decompressedSize)
553|27e597|    }
554|b4687f|    
555|9d3f35|    private func decompressRawDeflate(_ data: Data) -> Data? {
556|a91c92|        let destinationBufferSize = max(data.count * 10, 65536)
557|edfde8|        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
558|e94821|        defer { destinationBuffer.deallocate() }
559|d6ed84|        
560|f6b690|        let decompressedSize = data.withUnsafeBytes { sourcePtr -> Int in
561|81db49|            guard let sourceBaseAddress = sourcePtr.baseAddress else { return 0 }
562|3070d1|            
563|7e34e8|            return compression_decode_buffer(
564|60d8f8|                destinationBuffer,
565|3e48b6|                destinationBufferSize,
566|fe1a17|                sourceBaseAddress.assumingMemoryBound(to: UInt8.self),
567|007983|                data.count,
568|8da2f2|                nil,
569|bd7bcc|                COMPRESSION_LZFSE // Try LZFSE as fallback
570|43d041|            )
571|5f3077|        }
572|d6ed84|        
573|b38eca|        guard decompressedSize > 0 else { return nil }
574|c630d8|        return Data(bytes: destinationBuffer, count: decompressedSize)
575|27e597|    }
576|b31277|}
577|adc83b|
578|71e2e4|// MARK: - Supporting Types
579|adc83b|
580|780c75|struct GitCommitInfo {
581|0810ff|    let sha: String
582|5d4dd5|    let treeSHA: String?
583|6ce70b|    let parentSHA: String?
584|ab0604|    let author: String
585|20ac71|    let authorEmail: String
586|b53468|    let authorDate: Date
587|8d37cf|    let committer: String
588|636fa3|    let committerEmail: String
589|1990c7|    let committerDate: Date
590|edcb08|    let message: String
591|b4687f|    
592|e0cc9a|    static func parse(sha: String, content: String) -> GitCommitInfo? {
593|fe2fef|        var treeSHA: String?
594|9dbb84|        var parentSHA: String?
595|7991e2|        var author = "Unknown"
596|11dea6|        var authorEmail = ""
597|0df0be|        var authorDate = Date()
598|a2b463|        var committer = "Unknown"
599|5e5f77|        var committerEmail = ""
600|c6d2a1|        var committerDate = Date()
601|7fadf4|        var message = ""
602|d6ed84|        
603|cae86c|        let lines = content.components(separatedBy: "\n")
604|c0beb5|        var inMessage = false
605|0070ed|        var messageLines: [String] = []
606|d6ed84|        
607|08a605|        for line in lines {
608|fcb30a|            if inMessage {
609|bd6632|                messageLines.append(line)
610|1df510|                continue
611|a7dc16|            }
612|3070d1|            
613|cc4fcd|            if line.isEmpty {
614|448498|                inMessage = true
615|1df510|                continue
616|a7dc16|            }
617|3070d1|            
618|6c5a21|            if line.hasPrefix("tree ") {
619|411cef|                treeSHA = String(line.dropFirst(5))
620|99cfe7|            } else if line.hasPrefix("parent ") {
621|921a45|                // Take first parent only
622|644a43|                if parentSHA == nil {
623|734c33|                    parentSHA = String(line.dropFirst(7))
624|4e2d32|                }
625|b15d69|            } else if line.hasPrefix("author ") {
626|a94a2e|                let parsed = parseIdentity(String(line.dropFirst(7)))
627|02cb86|                author = parsed.name
628|014e15|                authorEmail = parsed.email
629|3510a6|                authorDate = parsed.date
630|a8443a|            } else if line.hasPrefix("committer ") {
631|ca0deb|                let parsed = parseIdentity(String(line.dropFirst(10)))
632|6b8883|                committer = parsed.name
633|129986|                committerEmail = parsed.email
634|f50a8c|                committerDate = parsed.date
635|a7dc16|            }
636|5f3077|        }
637|d6ed84|        
638|c79f09|        message = messageLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
639|d6ed84|        
640|4f6ba7|        return GitCommitInfo(
641|4f876a|            sha: sha,
642|5188b7|            treeSHA: treeSHA,
643|fbc2e5|            parentSHA: parentSHA,
644|18f437|            author: author,
645|c18d99|            authorEmail: authorEmail,
646|5e59a3|            authorDate: authorDate,
647|f74ec5|            committer: committer,
648|f892b5|            committerEmail: committerEmail,
649|9b8716|            committerDate: committerDate,
650|a1300a|            message: message
651|3143a4|        )
652|27e597|    }
653|b4687f|    
654|3841ee|    private static func parseIdentity(_ str: String) -> (name: String, email: String, date: Date) {
655|1369ed|        // Format: "Name <email> timestamp timezone"
656|57a328|        // Example: "John Doe <john@example.com> 1234567890 +0000"
657|d6ed84|        
658|d2cd08|        guard let emailStart = str.firstIndex(of: "<"),
659|ec06df|              let emailEnd = str.firstIndex(of: ">") else {
660|d229c9|            return (str, "", Date())
661|5f3077|        }
662|d6ed84|        
663|85c61f|        let name = String(str[..<emailStart]).trimmingCharacters(in: .whitespaces)
664|8474b6|        let email = String(str[str.index(after: emailStart)..<emailEnd])
665|d6ed84|        
666|362b3c|        // Parse timestamp
667|8c5df2|        let afterEmail = str[str.index(after: emailEnd)...]
668|936763|        let parts = afterEmail.split(separator: " ")
669|4d3a9c|        var date = Date()
670|b7fde4|        if let timestampStr = parts.first, let timestamp = TimeInterval(timestampStr) {
671|1662de|            date = Date(timeIntervalSince1970: timestamp)
672|5f3077|        }
673|d6ed84|        
674|819a87|        return (name, email, date)
675|27e597|    }
676|b31277|}
677|adc83b|
678|44bbe5|enum GitStatusType {
679|734ea7|    case modified
680|56fc3b|    case added
681|f7e3d2|    case deleted
682|b7ed69|    case renamed
683|72deca|    case copied
684|229c83|    case untracked
685|8a7e39|    case ignored
686|b31277|}
687|adc83b|
688|6d9a26|struct GitFileStatus {
689|1c6e32|    let path: String
690|9c4920|    let staged: GitStatusType?     // Status in index vs HEAD
691|30b874|    let working: GitStatusType?    // Status in working dir vs index
692|b31277|}
693|adc83b|
694|9f702a|// MARK: - Git Index Parser
695|adc83b|
696|9e4a69|struct GitIndexEntry {
697|206d64|    let ctime: Date
698|903928|    let mtime: Date
699|55f627|    let dev: UInt32
700|89b9d7|    let ino: UInt32
701|3fdcaf|    let mode: UInt32
702|141928|    let uid: UInt32
703|f6a1bb|    let gid: UInt32
704|714851|    let size: Int
705|0810ff|    let sha: String
706|8a98e4|    let flags: UInt16
707|1c6e32|    let path: String
708|b31277|}
709|adc83b|
710|412441|struct GitIndex {
711|0d5289|    let version: UInt32
712|d5551c|    let entries: [GitIndexEntry]
713|b4687f|    
714|4b2cd0|    static func parse(data: Data) -> GitIndex? {
715|ba2859|        guard data.count >= 12 else { return nil }
716|d6ed84|        
717|28bfd7|        // Check signature "DIRC"
718|02c810|        let signature = String(data: data[0..<4], encoding: .ascii)
719|b2a497|        guard signature == "DIRC" else { return nil }
720|d6ed84|        
721|4e3304|        // Read version (4 bytes, big endian)
722|c8e065|        let version = data[4..<8].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
723|144bc7|        guard version >= 2 && version <= 4 else { return nil }
724|d6ed84|        
725|7a9546|        // Read entry count
726|dcc3f5|        let entryCount = data[8..<12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
727|d6ed84|        
728|6a7d34|        // Parse entries
729|57c846|        var entries: [GitIndexEntry] = []
730|6c9e6b|        var offset = 12
731|d6ed84|        
732|4db410|        for _ in 0..<entryCount {
733|e588b0|            guard offset + 62 <= data.count else { break }
734|3070d1|            
735|ae47e8|            // Read fixed-size fields (62 bytes for v2)
736|b7166d|            let ctimeSec = data[offset..<offset+4].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
737|50f88a|            let ctimeNano = data[offset+4..<offset+8].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
738|e16d6f|            let mtimeSec = data[offset+8..<offset+12].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
739|60fa09|            let mtimeNano = data[offset+12..<offset+16].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
740|48fa0e|            let dev = data[offset+16..<offset+20].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
741|66bd82|            let ino = data[offset+20..<offset+24].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
742|417501|            let mode = data[offset+24..<offset+28].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
743|922cef|            let uid = data[offset+28..<offset+32].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
744|a64f3a|            let gid = data[offset+32..<offset+36].withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
745|2b8b05|            let size = data[offset+36..<offset+40].withUnsafeBytes { Int($0.load(as: UInt32.self).bigEndian) }
746|3070d1|            
747|e9dd74|            // SHA (20 bytes)
748|bfc593|            let shaData = data[offset+40..<offset+60]
749|bb46c1|            let sha = shaData.map { String(format: "%02x", $0) }.joined()
750|3070d1|            
751|b05074|            // Flags (2 bytes)
752|323051|            let flags = data[offset+60..<offset+62].withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
753|af2bd4|            let nameLen = Int(flags & 0x0FFF)
754|3070d1|            
755|d554f5|            offset += 62
756|3070d1|            
757|3cce59|            // Extended flags for v3+
758|549e8b|            if version >= 3 && (flags & 0x4000) != 0 {
759|f38f88|                offset += 2
760|a7dc16|            }
761|3070d1|            
762|b1b492|            // Read path name
763|8df390|            let pathEnd: Int
764|15ee1e|            if nameLen < 0xFFF {
765|4a16df|                pathEnd = offset + nameLen
766|f5a6eb|            } else {
767|7e3bcf|                // Name length is >= 0xFFF, find null terminator
768|d6f469|                if let nullIdx = data[offset...].firstIndex(of: 0) {
769|740382|                    pathEnd = nullIdx
770|fdd0e2|                } else {
771|8dcb2c|                    break
772|4e2d32|                }
773|a7dc16|            }
774|3070d1|            
775|776294|            guard pathEnd <= data.count else { break }
776|defd0c|            let pathData = data[offset..<pathEnd]
777|fe1240|            guard let path = String(data: pathData, encoding: .utf8) else { break }
778|3070d1|            
779|d243e8|            // Entries are padded to 8 bytes
780|05b889|            let entryLen = 62 + path.utf8.count + 1 // +1 for null terminator
781|0818ab|            let padding = (8 - (entryLen % 8)) % 8
782|b175c3|            offset = pathEnd + 1 + padding
783|3070d1|            
784|44e881|            let ctime = Date(timeIntervalSince1970: Double(ctimeSec) + Double(ctimeNano) / 1_000_000_000)
785|25c3df|            let mtime = Date(timeIntervalSince1970: Double(mtimeSec) + Double(mtimeNano) / 1_000_000_000)
786|3070d1|            
787|39dd8d|            entries.append(GitIndexEntry(
788|192553|                ctime: ctime,
789|5a6e94|                mtime: mtime,
790|2bac62|                dev: dev,
791|dd1a51|                ino: ino,
792|cfe53e|                mode: mode,
793|7cb2e7|                uid: uid,
794|74b33e|                gid: gid,
795|22e923|                size: size,
796|c97dd9|                sha: sha,
797|bf7ce6|                flags: flags,
798|18c940|                path: path
799|30ec32|            ))
800|5f3077|        }
801|d6ed84|        
802|8b5724|        return GitIndex(version: version, entries: entries)
803|27e597|    }
804|b31277|}
805|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 7f38cb743029
File: VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/NativeGitWriter.swift (lines 1-616 of 616)
────────────────────────────────────────
1|02257b|//  NativeGitWriter.swift
2|e45c97|//  VSCodeiPadOS
3|8d0643|//
4|66eb72|//  Minimal native git writer - writes loose objects and updates refs.
5|140b55|//  Supports local commit creation from staged (index) entries.
6|8d0643|//
7|adc83b|
8|8b6b78|import Foundation
9|43dc2e|import Compression
10|8342ac|import CommonCrypto
11|adc83b|
12|861980|final class NativeGitWriter {
13|5fb483|    let repoURL: URL
14|c1462f|    let gitDir: URL
15|adc83b|
16|f40006|    init?(repositoryURL: URL) {
17|d497c0|        self.repoURL = repositoryURL
18|46721d|        self.gitDir = repositoryURL.appendingPathComponent(".git")
19|adc83b|
20|6e4239|        var isDir: ObjCBool = false
21|18f3e0|        guard FileManager.default.fileExists(atPath: gitDir.path, isDirectory: &isDir), isDir.boolValue else {
22|1c8557|            return nil
23|5f3077|        }
24|27e597|    }
25|adc83b|
26|36e755|    // MARK: - Public API
27|adc83b|
28|bcdcd3|    /// Create a real local commit from the current index.
29|6ec65d|    /// - Returns: New commit SHA
30|d6f8eb|    func commit(message: String, authorName: String = "VSCodeiPadOS", authorEmail: String = "vscode@localhost") throws -> String {
31|e33b57|        // Build tree from stage-0 index entries
32|b7c39d|        let index = try readIndex()
33|deb8f6|        let entries = index.entries.filter { entry in
34|0f98c0|            // Git index stage is stored in flags bits 12-13
35|2e7d93|            let stage = (entry.flags >> 12) & 0x3
36|8a792b|            return stage == 0
37|5f3077|        }
38|adc83b|
39|3709f5|        let root = TreeNode()
40|238380|        for entry in entries {
41|f3dbe1|            insert(entry: entry, into: root)
42|5f3077|        }
43|adc83b|
44|603cab|        let treeSha = try writeTree(node: root)
45|adc83b|
46|f0aebc|        // Parent commit = current HEAD (if any)
47|4248a0|        let parentSha = try headCommitSHA()
48|adc83b|
49|7444b0|        // Create commit object
50|1e6c05|        let now = Date()
51|a0ae1c|        let timestamp = Int(now.timeIntervalSince1970)
52|8efa74|        let tz = Self.formatTimezone(secondsFromGMT: TimeZone.current.secondsFromGMT(for: now))
53|adc83b|
54|7f5950|        var commitText = ""
55|ffb158|        commitText += "tree \(treeSha)\n"
56|159cae|        if let parentSha {
57|c871f0|            commitText += "parent \(parentSha)\n"
58|5f3077|        }
59|5a823f|        commitText += "author \(authorName) <\(authorEmail)> \(timestamp) \(tz)\n"
60|6a978e|        commitText += "committer \(authorName) <\(authorEmail)> \(timestamp) \(tz)\n"
61|235f9f|        commitText += "\n"
62|c0b2c4|        commitText += message
63|598c45|        if !message.hasSuffix("\n") {
64|0132fe|            commitText += "\n"
65|5f3077|        }
66|adc83b|
67|6e6c9c|        let commitSha = try writeObject(type: .commit, content: Data(commitText.utf8))
68|d1d555|        try updateHEAD(to: commitSha)
69|a86115|        return commitSha
70|27e597|    }
71|adc83b|
72|afcc69|    // MARK: - Index
73|adc83b|
74|9047fa|    private func readIndex() throws -> GitIndex {
75|1b1a27|        let indexPath = gitDir.appendingPathComponent("index")
76|633a9c|        let data = try Data(contentsOf: indexPath)
77|0cc74b|        guard let index = GitIndex.parse(data: data) else {
78|2085bb|            throw GitManagerError.invalidRepository
79|5f3077|        }
80|aab224|        return index
81|27e597|    }
82|adc83b|
83|c0ee05|    // MARK: - HEAD / refs
84|adc83b|
85|5ebbb3|    private func headCommitSHA() throws -> String? {
86|c01141|        let headFile = gitDir.appendingPathComponent("HEAD")
87|689318|        guard let content = try? String(contentsOf: headFile, encoding: .utf8) else { return nil }
88|8e4a4d|        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
89|adc83b|
90|3c1b88|        if trimmed.hasPrefix("ref: ") {
91|78a0da|            let refPath = String(trimmed.dropFirst("ref: ".count))
92|7c5ab2|            if let sha = resolveRef(refPath) {
93|bb014a|                return sha
94|a7dc16|            }
95|1c8557|            return nil
96|5f3077|        }
97|adc83b|
98|e8119b|        // Detached HEAD SHA or unborn
99|969f29|        return trimmed.isEmpty ? nil : trimmed
100|27e597|    }
101|adc83b|
102|d3d02a|    private func updateHEAD(to commitSHA: String) throws {
103|c01141|        let headFile = gitDir.appendingPathComponent("HEAD")
104|128268|        let content = (try? String(contentsOf: headFile, encoding: .utf8)) ?? ""
105|8e4a4d|        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
106|adc83b|
107|3c1b88|        if trimmed.hasPrefix("ref: ") {
108|78a0da|            let refPath = String(trimmed.dropFirst("ref: ".count))
109|ffb687|            let refURL = gitDir.appendingPathComponent(refPath)
110|27505a|            try FileManager.default.createDirectory(at: refURL.deletingLastPathComponent(), withIntermediateDirectories: true)
111|9e177f|            try (commitSHA + "\n").write(to: refURL, atomically: true, encoding: .utf8)
112|b31999|        } else {
113|820972|            // Detached HEAD
114|10e579|            try (commitSHA + "\n").write(to: headFile, atomically: true, encoding: .utf8)
115|5f3077|        }
116|27e597|    }
117|adc83b|
118|4e146e|    private func resolveRef(_ refPath: String) -> String? {
119|a3e341|        let refFile = gitDir.appendingPathComponent(refPath)
120|43b4ff|        if let content = try? String(contentsOf: refFile, encoding: .utf8) {
121|c10091|            let sha = content.trimmingCharacters(in: .whitespacesAndNewlines)
122|bb4983|            return sha.isEmpty ? nil : sha
123|5f3077|        }
124|54d73b|        return resolvePackedRef(refPath)
125|27e597|    }
126|adc83b|
127|a7f14d|    private func resolvePackedRef(_ refPath: String) -> String? {
128|5b1253|        let packedRefsFile = gitDir.appendingPathComponent("packed-refs")
129|cab06c|        guard let content = try? String(contentsOf: packedRefsFile, encoding: .utf8) else { return nil }
130|adc83b|
131|d2b4bd|        for line in content.components(separatedBy: .newlines) {
132|ec6750|            let trimmed = line.trimmingCharacters(in: .whitespaces)
133|27ab74|            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix("^") {
134|1df510|                continue
135|a7dc16|            }
136|bc4e64|            let parts = trimmed.split(separator: " ", maxSplits: 1)
137|46a25b|            if parts.count == 2, String(parts[1]) == refPath {
138|d663bb|                return String(parts[0])
139|a7dc16|            }
140|5f3077|        }
141|c2ae65|        return nil
142|27e597|    }
143|adc83b|
144|395333|    private static func formatTimezone(secondsFromGMT: Int) -> String {
145|c60efd|        let sign = secondsFromGMT >= 0 ? "+" : "-"
146|ceff5d|        let absSeconds = abs(secondsFromGMT)
147|096583|        let hours = absSeconds / 3600
148|f9db0f|        let minutes = (absSeconds % 3600) / 60
149|ffc828|        return String(format: "%@%02d%02d", sign, hours, minutes)
150|27e597|    }
151|adc83b|
152|e836e7|    // MARK: - Tree building
153|adc83b|
154|5b1627|    private final class TreeNode {
155|c3b060|        var blobs: [String: (mode: String, sha: String)] = [:]
156|4c0c27|        var children: [String: TreeNode] = [:]
157|27e597|    }
158|adc83b|
159|4c3c31|    private func insert(entry: GitIndexEntry, into root: TreeNode) {
160|420a2c|        let parts = entry.path.split(separator: "/").map(String.init)
161|9da5f9|        guard let last = parts.last else { return }
162|adc83b|
163|cb203c|        var node = root
164|184d0c|        if parts.count > 1 {
165|844e19|            for dir in parts.dropLast() {
166|f035ff|                if let next = node.children[dir] {
167|e6bc6d|                    node = next
168|fdd0e2|                } else {
169|141061|                    let new = TreeNode()
170|09fea5|                    node.children[dir] = new
171|729a67|                    node = new
172|4e2d32|                }
173|a7dc16|            }
174|5f3077|        }
175|adc83b|
176|bd3e69|        let mode = Self.gitModeString(fromIndexMode: entry.mode)
177|caae91|        node.blobs[last] = (mode: mode, sha: entry.sha)
178|27e597|    }
179|adc83b|
180|dadada|    private static func gitModeString(fromIndexMode mode: UInt32) -> String {
181|522792|        // Index mode includes type bits in upper part.
182|f843ee|        // We only need canonical tree entry modes.
183|4ba37b|        let type = mode & 0o170000
184|79e7ce|        if type == 0o120000 {
185|8973d3|            return "120000" // symlink
186|5f3077|        }
187|7b384c|        if (mode & 0o111) != 0 {
188|a9405f|            return "100755"
189|5f3077|        }
190|d490c2|        return "100644"
191|27e597|    }
192|adc83b|
193|3c0ae7|    private struct TreeEntry {
194|515158|        let mode: String
195|ee6669|        let name: String
196|c7240c|        let sha: String
197|789c1b|        let isTree: Bool
198|27e597|    }
199|adc83b|
200|6c7e60|    private func writeTree(node: TreeNode) throws -> String {
201|5fb70c|        var entries: [TreeEntry] = []
202|adc83b|
203|4ec453|        // Children trees first (hashes computed recursively)
204|e440fe|        for (name, child) in node.children {
205|37e775|            let childSha = try writeTree(node: child)
206|1dc17e|            entries.append(TreeEntry(mode: "40000", name: name, sha: childSha, isTree: true))
207|5f3077|        }
208|adc83b|
209|e75b5d|        // Blobs
210|6f8e62|        for (name, blob) in node.blobs {
211|b9f46a|            entries.append(TreeEntry(mode: blob.mode, name: name, sha: blob.sha, isTree: false))
212|5f3077|        }
213|adc83b|
214|0e513d|        // Git sorts entries by name, but compares directories as name + '/'
215|53a80f|        entries.sort { a, b in
216|2b9d07|            let aKey = a.name + (a.isTree ? "/" : "")
217|bd8876|            let bKey = b.name + (b.isTree ? "/" : "")
218|df330a|            return Self.lexicographicLess(aKey.utf8, bKey.utf8)
219|5f3077|        }
220|adc83b|
221|72d469|        var data = Data()
222|238380|        for entry in entries {
223|85ff94|            data.append(contentsOf: "\(entry.mode) \(entry.name)\u{0}".utf8)
224|eb0662|            data.append(contentsOf: try Self.hexToBytes(entry.sha))
225|5f3077|        }
226|adc83b|
227|1274f5|        return try writeObject(type: .tree, content: data)
228|27e597|    }
229|adc83b|
230|a5c85f|    private static func lexicographicLess(_ a: String.UTF8View, _ b: String.UTF8View) -> Bool {
231|f94110|        var ita = a.makeIterator()
232|aa5d5c|        var itb = b.makeIterator()
233|722ae9|        while true {
234|d0134b|            let ca = ita.next()
235|a32c82|            let cb = itb.next()
236|77efa3|            switch (ca, cb) {
237|61b1fe|            case let (x?, y?):
238|905acb|                if x != y { return x < y }
239|bbe0af|            case (nil, nil):
240|473d08|                return false
241|74eab7|            case (nil, _?):
242|50bdea|                return true
243|f4d5d4|            case (_?, nil):
244|473d08|                return false
245|a7dc16|            }
246|5f3077|        }
247|27e597|    }
248|adc83b|
249|1c90d2|    // MARK: - Object writing
250|adc83b|
251|17a448|    private func writeObject(type: GitObjectType, content: Data) throws -> String {
252|2a4885|        // Git object format: "type size\0content"
253|bca733|        let header = "\(type.rawValue) \(content.count)\u{0}"
254|15477b|        var store = Data(header.utf8)
255|32a0e0|        store.append(content)
256|adc83b|
257|143a59|        let sha = Self.sha1Hex(store)
258|adc83b|
259|74cf85|        // Write loose object if not already present
260|571cfc|        let objectDir = gitDir.appendingPathComponent("objects").appendingPathComponent(String(sha.prefix(2)))
261|177b3b|        let objectFile = objectDir.appendingPathComponent(String(sha.dropFirst(2)))
262|adc83b|
263|721e27|        if FileManager.default.fileExists(atPath: objectFile.path) {
264|393cc7|            return sha
265|5f3077|        }
266|adc83b|
267|51b55d|        try FileManager.default.createDirectory(at: objectDir, withIntermediateDirectories: true)
268|adc83b|
269|64c811|        let compressed = try Self.compressZlib(store)
270|6b12ad|        try compressed.write(to: objectFile, options: [.atomic])
271|888dae|        return sha
272|27e597|    }
273|adc83b|
274|d78bc9|    private static func sha1Hex(_ data: Data) -> String {
275|2f8f19|        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
276|8bad8d|        data.withUnsafeBytes { ptr in
277|373cad|            _ = CC_SHA1(ptr.baseAddress, CC_LONG(data.count), &digest)
278|5f3077|        }
279|512202|        return digest.map { String(format: "%02x", $0) }.joined()
280|27e597|    }
281|adc83b|
282|5ba044|    private static func compressZlib(_ data: Data) throws -> Data {
283|3d9c6d|        // Compression framework needs a destination buffer large enough.
284|eb928d|        // Start with a reasonable guess and grow if needed.
285|0e4706|        var destSize = max(data.count / 2, 1024)
286|4b34fa|        for _ in 0..<6 {
287|7ab7ba|            let destBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
288|23e0db|            defer { destBuffer.deallocate() }
289|adc83b|
290|c35693|            let written: Int = data.withUnsafeBytes { sourcePtr in
291|8af049|                guard let base = sourcePtr.baseAddress else { return 0 }
292|53473b|                return compression_encode_buffer(
293|8c4161|                    destBuffer,
294|871512|                    destSize,
295|08b8a6|                    base.assumingMemoryBound(to: UInt8.self),
296|b87b1c|                    data.count,
297|f3e974|                    nil,
298|4dc23f|                    COMPRESSION_ZLIB
299|6f642e|                )
300|a7dc16|            }
301|adc83b|
302|420212|            if written > 0 {
303|2c941e|                return Data(bytes: destBuffer, count: written)
304|a7dc16|            }
305|adc83b|
306|3a8e96|            // Increase and retry
307|a2e26f|            destSize *= 2
308|5f3077|        }
309|adc83b|
310|e3f56e|        throw GitManagerError.invalidRepository
311|27e597|    }
312|adc83b|
313|58265e|    // MARK: - Staging Operations
314|adc83b|
315|e3266d|    /// Stage a file by adding/updating its entry in the git index
316|382d84|    func stageFile(path: String) throws {
317|539bfe|        // Read working directory file
318|37cf4b|        let fileURL = repoURL.appendingPathComponent(path)
319|e6acc8|        let fileData = try Data(contentsOf: fileURL)
320|d6ed84|        
321|2343bc|        // Get file attributes
322|18dc21|        let attrs = try FileManager.default.attributesOfItem(atPath: fileURL.path)
323|34e0b3|        let mtime = (attrs[.modificationDate] as? Date) ?? Date()
324|44a1f3|        let size = (attrs[.size] as? Int) ?? fileData.count
325|d6ed84|        
326|321671|        // Write blob object and get SHA
327|737dda|        let blobSha = try writeObject(type: .blob, content: fileData)
328|d6ed84|        
329|44c8eb|        // Read current index
330|30e534|        var entries = (try? readIndex().entries) ?? []
331|d6ed84|        
332|f52429|        // Determine file mode
333|065feb|        let mode: UInt32
334|28ea2e|        if let posixPerms = attrs[.posixPermissions] as? Int, (posixPerms & 0o111) != 0 {
335|14bb07|            mode = 0o100755
336|b31999|        } else {
337|1d2fc3|            mode = 0o100644
338|5f3077|        }
339|d6ed84|        
340|9ea4ad|        // Create new entry
341|78a2bc|        let newEntry = GitIndexEntry(
342|7c17d0|            ctime: mtime,
343|efca55|            mtime: mtime,
344|0716c0|            dev: 0,
345|a7f2d0|            ino: 0,
346|27359d|            mode: mode,
347|173b2a|            uid: 0,
348|6942b4|            gid: 0,
349|3ba82d|            size: size,
350|274a67|            sha: blobSha,
351|1bd8c9|            flags: UInt16(min(path.utf8.count, 0xFFF)),
352|329548|            path: path
353|3143a4|        )
354|d6ed84|        
355|7c9c77|        // Update or add entry
356|fe8b3e|        if let idx = entries.firstIndex(where: { $0.path == path }) {
357|48de05|            entries[idx] = newEntry
358|b31999|        } else {
359|7ab0fa|            entries.append(newEntry)
360|5f3077|        }
361|d6ed84|        
362|56c3f8|        // Sort entries by path (git requires sorted index)
363|456ea1|        entries.sort { $0.path < $1.path }
364|d6ed84|        
365|f8f140|        // Write updated index
366|d232bf|        try writeIndex(entries: entries)
367|27e597|    }
368|b4687f|    
369|4292fb|    /// Unstage a file by restoring HEAD entry or removing if new file
370|45d38e|    func unstageFile(path: String) throws {
371|30e534|        var entries = (try? readIndex().entries) ?? []
372|d6ed84|        
373|722646|        // Get HEAD tree entry for this path
374|fbea1c|        let headSha = headTreeSHA(forPath: path)
375|d6ed84|        
376|e2c346|        if let headSha = headSha {
377|b67cbc|            // File was in HEAD - restore that entry
378|7d25f0|            if let idx = entries.firstIndex(where: { $0.path == path }) {
379|1d4ca0|                // Keep most fields but restore SHA from HEAD
380|cffef2|                let old = entries[idx]
381|03ce27|                let restored = GitIndexEntry(
382|50e0e5|                    ctime: old.ctime,
383|e1bc98|                    mtime: old.mtime,
384|a9391a|                    dev: old.dev,
385|27c54d|                    ino: old.ino,
386|91a64b|                    mode: old.mode,
387|b209b9|                    uid: old.uid,
388|76a66a|                    gid: old.gid,
389|2aaeeb|                    size: old.size,
390|9768ad|                    sha: headSha,
391|318da3|                    flags: old.flags,
392|cc2979|                    path: path
393|6f642e|                )
394|30472a|                entries[idx] = restored
395|a7dc16|            }
396|b31999|        } else {
397|0ae6f2|            // File was NOT in HEAD (new file) - remove from index
398|cedf04|            entries.removeAll { $0.path == path }
399|5f3077|        }
400|d6ed84|        
401|d232bf|        try writeIndex(entries: entries)
402|27e597|    }
403|b4687f|    
404|2e10e9|    /// Stage all modified and untracked files
405|346723|    func stageAll() throws {
406|c1d619|        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
407|2085bb|            throw GitManagerError.invalidRepository
408|5f3077|        }
409|d6ed84|        
410|528fb0|        let statuses = reader.status()
411|d6ed84|        
412|a441c9|        for status in statuses {
413|94dc67|            // Stage files that have working directory changes
414|4d0f95|            if status.working == .modified || status.working == .deleted || status.working == .untracked {
415|968a97|                if status.working == .deleted {
416|5e3de7|                    // For deleted files, remove from index
417|be4a40|                    var entries = (try? readIndex().entries) ?? []
418|6632ab|                    entries.removeAll { $0.path == status.path }
419|2fb367|                    try writeIndex(entries: entries)
420|fdd0e2|                } else {
421|0c5518|                    try stageFile(path: status.path)
422|4e2d32|                }
423|a7dc16|            }
424|5f3077|        }
425|27e597|    }
426|b4687f|    
427|175b67|    /// Get the blob SHA for a path in HEAD tree
428|2b714a|    private func headTreeSHA(forPath path: String) -> String? {
429|31b272|        guard let headSha = (try? headCommitSHA()) ?? nil else {
430|1c8557|            return nil
431|5f3077|        }
432|d6ed84|        
433|c1d619|        guard let reader = NativeGitReader(repositoryURL: repoURL) else {
434|1c8557|            return nil
435|5f3077|        }
436|d6ed84|        
437|94eafb|        guard let commit = reader.parseCommit(sha: headSha),
438|851b09|              let treeSha = commit.treeSHA else {
439|1c8557|            return nil
440|5f3077|        }
441|d6ed84|        
442|9802de|        return blobSHAFromTree(path: path, treeSHA: treeSha, reader: reader)
443|27e597|    }
444|b4687f|    
445|70cd91|    private func blobSHAFromTree(path: String, treeSHA: String, reader: NativeGitReader) -> String? {
446|dd1ba6|        let components = path.split(separator: "/").map(String.init)
447|97a663|        return blobSHAFromTree(components: components, treeSHA: treeSHA, reader: reader)
448|27e597|    }
449|b4687f|    
450|983731|    private func blobSHAFromTree(components: [String], treeSHA: String, reader: NativeGitReader) -> String? {
451|76a335|        guard !components.isEmpty,
452|043602|              let treeObj = reader.readObject(sha: treeSHA),
453|78bd0e|              treeObj.type == .tree else {
454|1c8557|            return nil
455|5f3077|        }
456|d6ed84|        
457|8fc0fb|        let entries = parseTreeEntriesForWrite(data: treeObj.data)
458|3d0308|        let head = components[0]
459|d6ed84|        
460|703828|        if components.count == 1 {
461|4c8d7b|            // Looking for a blob
462|ab8b97|            return entries.first { $0.name == head && !$0.mode.hasPrefix("40") }?.sha
463|b31999|        } else {
464|0521dc|            // Looking for a subtree
465|2b7757|            guard let dir = entries.first(where: { $0.name == head && $0.mode.hasPrefix("40") }) else {
466|15034a|                return nil
467|a7dc16|            }
468|b241d5|            return blobSHAFromTree(components: Array(components.dropFirst()), treeSHA: dir.sha, reader: reader)
469|5f3077|        }
470|27e597|    }
471|b4687f|    
472|b2b9ca|    private func parseTreeEntriesForWrite(data: Data) -> [(mode: String, name: String, sha: String)] {
473|10efd1|        var entries: [(String, String, String)] = []
474|2cb527|        var offset = 0
475|d6ed84|        
476|126a3b|        while offset < data.count {
477|67fc5d|            guard let spaceIndex = data[offset...].firstIndex(of: 0x20) else { break }
478|a3cc9c|            let modeData = data[offset..<spaceIndex]
479|6d483e|            guard let mode = String(data: modeData, encoding: .ascii) else { break }
480|3070d1|            
481|d36b62|            let nameStart = spaceIndex + 1
482|306227|            guard let nullIndex = data[nameStart...].firstIndex(of: 0) else { break }
483|327bc9|            let nameData = data[nameStart..<nullIndex]
484|237c3c|            guard let name = String(data: nameData, encoding: .utf8) else { break }
485|3070d1|            
486|c5842b|            let shaStart = nullIndex + 1
487|be9d3b|            let shaEnd = shaStart + 20
488|eb4a79|            guard shaEnd <= data.count else { break }
489|0075b7|            let shaData = data[shaStart..<shaEnd]
490|bb46c1|            let sha = shaData.map { String(format: "%02x", $0) }.joined()
491|3070d1|            
492|3e2294|            entries.append((mode, name, sha))
493|372dcb|            offset = shaEnd
494|5f3077|        }
495|d6ed84|        
496|f9dee7|        return entries
497|27e597|    }
498|b4687f|    
499|83aa7b|    // MARK: - Index Writing
500|b4687f|    
501|16b0ca|    /// Write a valid git index v2 file
502|615185|    private func writeIndex(entries: [GitIndexEntry]) throws {
503|72d469|        var data = Data()
504|d6ed84|        
505|814b70|        // Header: DIRC magic
506|488ecc|        data.append(contentsOf: "DIRC".utf8)
507|d6ed84|        
508|ca5c39|        // Version 2 (4 bytes, big endian)
509|4bf3bd|        var version: UInt32 = 2
510|17e70a|        data.append(contentsOf: withUnsafeBytes(of: version.bigEndian) { Array($0) })
511|d6ed84|        
512|b2f163|        // Entry count (4 bytes, big endian)
513|bf6590|        var entryCount = UInt32(entries.count)
514|3a08b4|        data.append(contentsOf: withUnsafeBytes(of: entryCount.bigEndian) { Array($0) })
515|d6ed84|        
516|580821|        // Write each entry
517|238380|        for entry in entries {
518|b18830|            let entryStart = data.count
519|3070d1|            
520|9615f0|            // ctime seconds (4 bytes)
521|457e87|            var ctimeSec = UInt32(entry.ctime.timeIntervalSince1970)
522|3b6606|            data.append(contentsOf: withUnsafeBytes(of: ctimeSec.bigEndian) { Array($0) })
523|3070d1|            
524|ae529b|            // ctime nanoseconds (4 bytes)
525|4bc71d|            let ctimeNano = UInt32((entry.ctime.timeIntervalSince1970 - Double(ctimeSec)) * 1_000_000_000)
526|0ae3a5|            var ctimeNanoVal = ctimeNano
527|188dc2|            data.append(contentsOf: withUnsafeBytes(of: ctimeNanoVal.bigEndian) { Array($0) })
528|3070d1|            
529|826baa|            // mtime seconds (4 bytes)
530|ba1bcf|            var mtimeSec = UInt32(entry.mtime.timeIntervalSince1970)
531|61a3fd|            data.append(contentsOf: withUnsafeBytes(of: mtimeSec.bigEndian) { Array($0) })
532|3070d1|            
533|b47d16|            // mtime nanoseconds (4 bytes)
534|a5af47|            let mtimeNano = UInt32((entry.mtime.timeIntervalSince1970 - Double(mtimeSec)) * 1_000_000_000)
535|c5c2b5|            var mtimeNanoVal = mtimeNano
536|db37ac|            data.append(contentsOf: withUnsafeBytes(of: mtimeNanoVal.bigEndian) { Array($0) })
537|3070d1|            
538|2e4112|            // dev (4 bytes)
539|6f9151|            var dev = entry.dev
540|6b908b|            data.append(contentsOf: withUnsafeBytes(of: dev.bigEndian) { Array($0) })
541|3070d1|            
542|ac992e|            // ino (4 bytes)
543|f69e61|            var ino = entry.ino
544|625c0c|            data.append(contentsOf: withUnsafeBytes(of: ino.bigEndian) { Array($0) })
545|3070d1|            
546|af9350|            // mode (4 bytes)
547|0369a8|            var mode = entry.mode
548|9be821|            data.append(contentsOf: withUnsafeBytes(of: mode.bigEndian) { Array($0) })
549|3070d1|            
550|edf9df|            // uid (4 bytes)
551|bdc94a|            var uid = entry.uid
552|04b24d|            data.append(contentsOf: withUnsafeBytes(of: uid.bigEndian) { Array($0) })
553|3070d1|            
554|f67531|            // gid (4 bytes)
555|b675be|            var gid = entry.gid
556|a44764|            data.append(contentsOf: withUnsafeBytes(of: gid.bigEndian) { Array($0) })
557|3070d1|            
558|8f9add|            // size (4 bytes)
559|26b80b|            var size = UInt32(entry.size)
560|1eb923|            data.append(contentsOf: withUnsafeBytes(of: size.bigEndian) { Array($0) })
561|3070d1|            
562|e9dd74|            // SHA (20 bytes)
563|e27c87|            let shaBytes = try Self.hexToBytes(entry.sha)
564|b37c6c|            data.append(contentsOf: shaBytes)
565|3070d1|            
566|0a82a3|            // Flags (2 bytes) - name length in lower 12 bits
567|4bf87b|            let nameLen = min(entry.path.utf8.count, 0xFFF)
568|5cd921|            var flags = UInt16(nameLen)
569|46819f|            data.append(contentsOf: withUnsafeBytes(of: flags.bigEndian) { Array($0) })
570|3070d1|            
571|a2bb34|            // Path (variable length, null terminated)
572|2dbcb5|            data.append(contentsOf: entry.path.utf8)
573|ed42ae|            data.append(0) // null terminator
574|3070d1|            
575|18615f|            // Padding to 8-byte boundary
576|a85d86|            let entryLen = data.count - entryStart
577|0818ab|            let padding = (8 - (entryLen % 8)) % 8
578|ca00ec|            for _ in 0..<padding {
579|e282cb|                data.append(0)
580|a7dc16|            }
581|5f3077|        }
582|d6ed84|        
583|a578b9|        // Footer: SHA1 checksum of entire file content
584|0562a4|        let checksum = Self.sha1Bytes(data)
585|9d9820|        data.append(contentsOf: checksum)
586|d6ed84|        
587|6c868c|        // Write to index file
588|1b1a27|        let indexPath = gitDir.appendingPathComponent("index")
589|02d86a|        try data.write(to: indexPath, options: [.atomic])
590|27e597|    }
591|b4687f|    
592|cae9a9|    private static func sha1Bytes(_ data: Data) -> [UInt8] {
593|2f8f19|        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
594|8bad8d|        data.withUnsafeBytes { ptr in
595|373cad|            _ = CC_SHA1(ptr.baseAddress, CC_LONG(data.count), &digest)
596|5f3077|        }
597|291d46|        return digest
598|27e597|    }
599|adc83b|
600|7308cd|    private static func hexToBytes(_ hex: String) throws -> [UInt8] {
601|c790cb|        guard hex.count % 2 == 0 else { throw GitManagerError.invalidRepository }
602|6e340e|        var bytes: [UInt8] = []
603|974f86|        bytes.reserveCapacity(hex.count / 2)
604|adc83b|
605|cb7555|        var idx = hex.startIndex
606|4ccb7f|        while idx < hex.endIndex {
607|e0d9f5|            let nextIdx = hex.index(idx, offsetBy: 2)
608|ccae3d|            let byteStr = hex[idx..<nextIdx]
609|a86b70|            guard let b = UInt8(byteStr, radix: 16) else { throw GitManagerError.invalidRepository }
610|a51ab6|            bytes.append(b)
611|ad9549|            idx = nextIdx
612|5f3077|        }
613|3ccb9c|        return bytes
614|27e597|    }
615|b31277|}
616|adc83b|




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/
📁 Editor/
📁 Panels/
   _tmp.txt
   BranchMenu.swift
   CommandPalette.swift
   CommandPaletteView.swift
   DiffComponents.swift
   FileIconView.swift
   FileTreeView.swift
   GoToSymbol.swift
   LaunchConfigView.swift
   QuickOpen.swift
   RunConfigView.swift
   SidebarView.swift
   SnippetPickerView.swift
   StatusBarView.swift
   TabBarView.swift
   TasksView.swift
   WorkspaceSettingsView.swift
   WorkspaceTrustDialog.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: a6d2c98c2ff9
File: VSCodeiPadOS/VSCodeiPadOS/Views/BranchMenu.swift (lines 1-150 of 150)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|adc83b|
3|c15546|/// Reusable git branch selector + management menu.
4|9e42d5|struct BranchMenu<Label: View>: View {
5|f5d2e5|    @ObservedObject var git: GitManager
6|987a93|    let label: () -> Label
7|b4687f|    
8|bcce67|    @State private var showCreateBranchAlert: Bool = false
9|0843e5|    @State private var newBranchName: String = ""
10|629251|    @State private var pendingDeleteBranch: String? = nil
11|23b8d6|    @State private var showErrorAlert: Bool = false
12|25ab5e|    @State private var errorMessage: String = ""
13|9d8951|    @State private var showDeleteAlert: Bool = false
14|b4687f|    
15|507523|    private var localBranches: [GitBranch] {
16|e054ab|        git.branches.filter { !$0.isRemote }
17|27e597|    }
18|b4687f|    
19|f8a484|    private var deletableBranches: [GitBranch] {
20|694a3b|        localBranches.filter { !$0.isCurrent }
21|27e597|    }
22|b4687f|    
23|504e43|    var body: some View {
24|9af4b8|        Menu {
25|a60e98|            branchListSection
26|e744dc|            Divider()
27|a039e6|            createBranchButton
28|dab5d1|            deleteBranchMenu
29|045107|        } label: {
30|51e769|            label()
31|5f3077|        }
32|cd969e|        .alert("Create Branch", isPresented: $showCreateBranchAlert) {
33|7d8a6f|            createBranchAlertContent
34|209f59|        } message: {
35|4515e2|            Text("Enter a new branch name")
36|5f3077|        }
37|875151|        .alert("Delete Branch", isPresented: $showDeleteAlert) {
38|cbfefb|            deleteBranchAlertContent
39|209f59|        } message: {
40|fc2c66|            deleteBranchAlertMessage
41|5f3077|        }
42|71c7ce|        .alert("Git Error", isPresented: $showErrorAlert) {
43|590e57|            Button("OK", role: .cancel) {}
44|209f59|        } message: {
45|adca27|            Text(errorMessage)
46|5f3077|        }
47|27e597|    }
48|b4687f|    
49|6931c1|    // MARK: - Branch List
50|b4687f|    
51|ab06c2|    @ViewBuilder
52|7042e6|    private var branchListSection: some View {
53|297eef|        ForEach(localBranches) { branch in
54|70c70b|            Button {
55|80bd74|                Task { try? await git.checkout(branch: branch.name) }
56|d8abfb|            } label: {
57|d591fc|                HStack {
58|fd2230|                    Text(branch.name)
59|0e1790|                    if branch.isCurrent {
60|0fb187|                        Spacer()
61|00fe34|                        Image(systemName: "checkmark")
62|c9717a|                    }
63|4e2d32|                }
64|a7dc16|            }
65|644732|            .disabled(git.isLoading)
66|5f3077|        }
67|27e597|    }
68|b4687f|    
69|7fd295|    // MARK: - Create Branch
70|b4687f|    
71|3b0234|    private var createBranchButton: some View {
72|7afc66|        Button("Create Branch…") {
73|63668a|            newBranchName = ""
74|b69786|            showCreateBranchAlert = true
75|5f3077|        }
76|0bd061|        .disabled(git.isLoading)
77|27e597|    }
78|b4687f|    
79|ab06c2|    @ViewBuilder
80|1c830e|    private var createBranchAlertContent: some View {
81|955283|        TextField("Branch name", text: $newBranchName)
82|bc23b5|        Button("Cancel", role: .cancel) {}
83|557b5c|        Button("Create") {
84|47ed67|            Task {
85|a9ed45|                do {
86|9934b5|                    try await git.createBranch(name: newBranchName)
87|6bf1ca|                } catch {
88|72e736|                    await MainActor.run {
89|e7ce50|                        errorMessage = error.localizedDescription
90|aeb432|                        showErrorAlert = true
91|c9717a|                    }
92|4e2d32|                }
93|a7dc16|            }
94|5f3077|        }
95|27e597|    }
96|b4687f|    
97|85d952|    // MARK: - Delete Branch
98|b4687f|    
99|ab06c2|    @ViewBuilder
100|4a32e3|    private var deleteBranchMenu: some View {
101|c8bc82|        Menu("Delete Branch") {
102|784a44|            if deletableBranches.isEmpty {
103|aca158|                Text("No other branches")
104|f5a6eb|            } else {
105|14ea5a|                ForEach(deletableBranches) { branch in
106|691c5b|                    Button(role: .destructive) {
107|6285c5|                        pendingDeleteBranch = branch.name
108|2696d0|                        showDeleteAlert = true
109|83be2c|                    } label: {
110|84fcc2|                        Text(branch.name)
111|c9717a|                    }
112|a9569d|                    .disabled(git.isLoading)
113|4e2d32|                }
114|a7dc16|            }
115|5f3077|        }
116|0bd061|        .disabled(git.isLoading)
117|27e597|    }
118|b4687f|    
119|ab06c2|    @ViewBuilder
120|0ce305|    private var deleteBranchAlertContent: some View {
121|af6b6c|        Button("Cancel", role: .cancel) {
122|f152ac|            pendingDeleteBranch = nil
123|5f3077|        }
124|23cbce|        Button("Delete", role: .destructive) {
125|dccd13|            if let name = pendingDeleteBranch {
126|0f0930|                Task {
127|af84d6|                    do {
128|f22356|                        try await git.deleteBranch(name: name)
129|02795d|                    } catch {
130|dea255|                        await MainActor.run {
131|d8adb1|                            errorMessage = error.localizedDescription
132|317940|                            showErrorAlert = true
133|392b35|                        }
134|c9717a|                    }
135|4e2d32|                }
136|a110ea|                pendingDeleteBranch = nil
137|a7dc16|            }
138|5f3077|        }
139|27e597|    }
140|b4687f|    
141|ab06c2|    @ViewBuilder
142|5d6557|    private var deleteBranchAlertMessage: some View {
143|ef11d4|        if let branch = pendingDeleteBranch {
144|0d0e39|            Text("Are you sure you want to delete \"\(branch)\"?")
145|b31999|        } else {
146|ecc3d3|            Text("")
147|5f3077|        }
148|27e597|    }
149|b31277|}
150|adc83b|




---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SettingsView.swift
   TerminalView.swift
   TestView.swift
   TimelineView.swift




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: e56342799a51
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 1-521 of 521)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|d755ba|import SwiftUI
3|adc83b|
4|c01d12|// MARK: - Git View (Source Control Panel)
5|adc83b|
6|0fcaed|struct GitView: View {
7|50d46f|    @ObservedObject private var gitManager = GitManager.shared
8|088df4|    @EnvironmentObject var editorCore: EditorCore
9|9b2073|    @State private var commitMessage = ""
10|2a963c|    @State private var selectedEntry: GitStatusEntry?
11|84903c|    @State private var showingDiffEntry: GitStatusEntry?
12|101c3f|    @State private var showBranchPicker = false
13|b4687f|    
14|504e43|    var body: some View {
15|0865e6|        VStack(alignment: .leading, spacing: 0) {
16|bb59bc|            // Header
17|f49fd2|            HStack {
18|510e5d|                Text("SOURCE CONTROL")
19|e442d4|                    .font(.system(size: 11, weight: .semibold))
20|72464b|                    .foregroundColor(.secondary)
21|a02350|                Spacer()
22|216278|                
23|065ec0|                if gitManager.isLoading {
24|ac3ac4|                    ProgressView()
25|3a9f98|                        .scaleEffect(0.6)
26|4e2d32|                }
27|216278|                
28|0d2db9|                Button(action: refreshGit) {
29|b886d3|                    Image(systemName: "arrow.clockwise")
30|22b3e3|                        .font(.system(size: 12))
31|4e2d32|                }
32|556acc|                .buttonStyle(.plain)
33|b978c5|                .disabled(gitManager.isLoading)
34|a7dc16|            }
35|87be8f|            .padding(.horizontal, 12)
36|5b6fc5|            .padding(.vertical, 8)
37|3070d1|            
38|e744dc|            Divider()
39|3070d1|            
40|dc7435|            // Branch selector
41|f49fd2|            HStack {
42|fd9a47|                Image(systemName: "arrow.triangle.branch")
43|a5b455|                    .font(.system(size: 11))
44|72464b|                    .foregroundColor(.secondary)
45|216278|                
46|514623|                Button(action: { showBranchPicker = true }) {
47|b6cb5c|                    HStack(spacing: 4) {
48|8abc54|                        Text(gitManager.currentBranch)
49|d0c061|                            .font(.system(size: 12, weight: .medium))
50|1d9687|                        Image(systemName: "chevron.down")
51|7132aa|                            .font(.system(size: 9))
52|c9717a|                    }
53|4e2d32|                }
54|556acc|                .buttonStyle(.plain)
55|216278|                
56|a02350|                Spacer()
57|216278|                
58|3a05d8|                // Sync status
59|144cac|                if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
60|b6cb5c|                    HStack(spacing: 4) {
61|8af9f4|                        if gitManager.aheadCount > 0 {
62|bbb6b1|                            HStack(spacing: 2) {
63|337b6e|                                Image(systemName: "arrow.up")
64|b15c5c|                                Text("\(gitManager.aheadCount)")
65|89d40a|                            }
66|c379cc|                            .font(.system(size: 10))
67|f33d5e|                            .foregroundColor(.orange)
68|392b35|                        }
69|d3f4eb|                        if gitManager.behindCount > 0 {
70|bbb6b1|                            HStack(spacing: 2) {
71|fb250c|                                Image(systemName: "arrow.down")
72|ce43d8|                                Text("\(gitManager.behindCount)")
73|89d40a|                            }
74|c379cc|                            .font(.system(size: 10))
75|080287|                            .foregroundColor(.blue)
76|392b35|                        }
77|c9717a|                    }
78|4e2d32|                }
79|a7dc16|            }
80|87be8f|            .padding(.horizontal, 12)
81|f86fc3|            .padding(.vertical, 6)
82|508ae7|            .background(Color(UIColor.secondarySystemBackground))
83|3070d1|            
84|e744dc|            Divider()
85|3070d1|            
86|8167b4|            // Commit input
87|fe291f|            VStack(spacing: 8) {
88|7122d4|                TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
89|dd6dfb|                    .textFieldStyle(.roundedBorder)
90|a7d18b|                    .font(.system(size: 12))
91|216278|                
92|94fd83|                HStack(spacing: 8) {
93|cefdda|                    Button(action: commitChanges) {
94|679877|                        HStack {
95|ac51c9|                            Image(systemName: "checkmark")
96|24ffc0|                            Text("Commit")
97|392b35|                        }
98|095f8d|                        .frame(maxWidth: .infinity)
99|6cb90b|                        .padding(.vertical, 6)
100|48c0c2|                        .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
101|b1d8de|                        .foregroundColor(.white)
102|aba602|                        .cornerRadius(6)
103|c9717a|                    }
104|858d27|                    .disabled(!canCommit)
105|9cd867|                    .buttonStyle(.plain)
106|dd2193|                    
107|a1106b|                    Menu {
108|220b9b|                        Button(action: { Task { try? await gitManager.stageAll() } }) {
109|2ae65d|                            Label("Stage All", systemImage: "plus.circle")
110|392b35|                        }
111|6d39bc|                        Button(action: commitAndPush) {
112|de0f57|                            Label("Commit & Push", systemImage: "arrow.up.circle")
113|392b35|                        }
114|83be2c|                    } label: {
115|51c540|                        Image(systemName: "ellipsis.circle")
116|6b1ca9|                            .font(.system(size: 16))
117|c9717a|                    }
118|9cd867|                    .buttonStyle(.plain)
119|4e2d32|                }
120|a7dc16|            }
121|2e404c|            .padding(12)
122|3070d1|            
123|e744dc|            Divider()
124|3070d1|            
125|d30c1b|            // Changes list
126|6b85db|            ScrollView {
127|5e9073|                VStack(alignment: .leading, spacing: 4) {
128|416dbf|                    // Staged changes
129|4641bc|                    if !gitManager.stagedChanges.isEmpty {
130|d21a9a|                        sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
131|474c26|                        ForEach(gitManager.stagedChanges) { entry in
132|e2c144|                            changeRow(entry, isStaged: true)
133|392b35|                        }
134|c9717a|                    }
135|dd2193|                    
136|d09435|                    // Unstaged changes
137|8a3749|                    if !gitManager.unstagedChanges.isEmpty {
138|da4e6b|                        sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
139|9c9c74|                        ForEach(gitManager.unstagedChanges) { entry in
140|666651|                            changeRow(entry, isStaged: false)
141|392b35|                        }
142|c9717a|                    }
143|dd2193|                    
144|5c9563|                    // Untracked files
145|3a4f2e|                    if !gitManager.untrackedFiles.isEmpty {
146|ba0c81|                        sectionHeader("Untracked", count: gitManager.untrackedFiles.count, color: .secondary)
147|b0648d|                        ForEach(gitManager.untrackedFiles) { entry in
148|666651|                            changeRow(entry, isStaged: false)
149|392b35|                        }
150|c9717a|                    }
151|dd2193|                    
152|044ccd|                    // No changes
153|7e1f1f|                    if gitManager.stagedChanges.isEmpty &&
154|e7d4ef|                        gitManager.unstagedChanges.isEmpty &&
155|80ca47|                        gitManager.untrackedFiles.isEmpty {
156|98eb72|                        VStack(spacing: 8) {
157|2019e1|                            Image(systemName: "checkmark.circle")
158|d9cb23|                                .font(.system(size: 24))
159|af0a80|                                .foregroundColor(.green)
160|b52fae|                            Text("No changes")
161|099171|                                .font(.system(size: 12))
162|1e019d|                                .foregroundColor(.secondary)
163|392b35|                        }
164|095f8d|                        .frame(maxWidth: .infinity)
165|6f8577|                        .padding(.vertical, 20)
166|c9717a|                    }
167|dd2193|                    
168|8cb8a1|                    // Recent commits
169|9fb89c|                    if !gitManager.recentCommits.isEmpty {
170|79f0ba|                        Divider()
171|bd9f79|                            .padding(.vertical, 8)
172|956cfe|                        
173|a5cbd6|                        sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
174|ad3a2a|                        ForEach(gitManager.recentCommits.prefix(5)) { commit in
175|44bc91|                            commitRow(commit)
176|392b35|                        }
177|c9717a|                    }
178|4e2d32|                }
179|3263f8|                .padding(.horizontal, 8)
180|74d510|                .padding(.bottom, 8)
181|a7dc16|            }
182|3070d1|            
183|4f509b|            Spacer(minLength: 0)
184|3070d1|            
185|024e4d|            // Error display
186|6b5a0d|            if let error = gitManager.error {
187|d591fc|                HStack {
188|5433ef|                    Image(systemName: "exclamationmark.triangle")
189|201e5d|                        .foregroundColor(.red)
190|9d05f5|                    Text(error)
191|b3f5ca|                        .font(.system(size: 10))
192|201e5d|                        .foregroundColor(.red)
193|e0f35a|                        .lineLimit(2)
194|4e2d32|                }
195|040bcc|                .padding(8)
196|b61cbb|                .background(Color.red.opacity(0.1))
197|e16349|                .cornerRadius(6)
198|010717|                .padding(.horizontal, 12)
199|a7dc16|            }
200|3070d1|            
201|e744dc|            Divider()
202|3070d1|            
203|294324|            // Bottom actions
204|8574de|            HStack(spacing: 12) {
205|3c100f|                Button(action: pullChanges) {
206|b6cb5c|                    HStack(spacing: 4) {
207|46a629|                        Image(systemName: "arrow.down.circle")
208|2e26c6|                        Text("Pull")
209|d3f4eb|                        if gitManager.behindCount > 0 {
210|7e9ad0|                            Text("(\(gitManager.behindCount))")
211|5ee2ee|                                .foregroundColor(.blue)
212|392b35|                        }
213|c9717a|                    }
214|4e2d32|                }
215|a7de34|                .font(.system(size: 11))
216|556acc|                .buttonStyle(.plain)
217|216278|                
218|21c660|                Button(action: pushChanges) {
219|b6cb5c|                    HStack(spacing: 4) {
220|9fef42|                        Image(systemName: "arrow.up.circle")
221|f9f197|                        Text("Push")
222|8af9f4|                        if gitManager.aheadCount > 0 {
223|5528b1|                            Text("(\(gitManager.aheadCount))")
224|e68962|                                .foregroundColor(.orange)
225|392b35|                        }
226|c9717a|                    }
227|4e2d32|                }
228|a7de34|                .font(.system(size: 11))
229|556acc|                .buttonStyle(.plain)
230|216278|                
231|132978|                Button(action: fetchChanges) {
232|153d29|                    Image(systemName: "arrow.triangle.2.circlepath")
233|4e2d32|                }
234|a7de34|                .font(.system(size: 11))
235|556acc|                .buttonStyle(.plain)
236|216278|                
237|a02350|                Spacer()
238|a7dc16|            }
239|2e404c|            .padding(12)
240|5f3077|        }
241|928ed0|        .background(Color(UIColor.systemBackground))
242|6c281d|        .sheet(isPresented: $showBranchPicker) {
243|1bbced|            BranchPickerSheet(gitManager: gitManager)
244|5f3077|        }
245|510eec|        .fullScreenCover(item: $showingDiffEntry) { entry in
246|705638|            GitDiffSheet(entry: entry)
247|5f3077|        }
248|27e597|    }
249|b4687f|    
250|e3eee6|    private var canCommit: Bool {
251|73853f|        !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
252|27e597|    }
253|b4687f|    
254|33e875|    private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
255|642308|        HStack {
256|ee451d|            Text(title)
257|e4c3ff|                .font(.system(size: 11, weight: .semibold))
258|831eae|                .foregroundColor(.secondary)
259|5b81fe|            Text("\(count)")
260|759090|                .font(.system(size: 10))
261|1e92ce|                .foregroundColor(color)
262|801496|                .padding(.horizontal, 6)
263|aa3473|                .padding(.vertical, 2)
264|6f0113|                .background(color.opacity(0.2))
265|b9c1d1|                .cornerRadius(8)
266|1e6289|            Spacer()
267|5f3077|        }
268|60e15e|        .padding(.vertical, 4)
269|27e597|    }
270|b4687f|    
271|3fbf57|    private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
272|d6296b|        HStack(spacing: 8) {
273|22898a|            // Status indicator
274|a1d22c|            Text(entry.kind.rawValue.prefix(1).uppercased())
275|f5af4d|                .font(.system(size: 10, weight: .bold, design: .monospaced))
276|ce0951|                .foregroundColor(entry.kind.color)
277|c404e7|                .frame(width: 16)
278|3070d1|            
279|458ade|            // File name
280|db04ed|            Text(entry.path.components(separatedBy: "/").last ?? entry.path)
281|ee466d|                .font(.system(size: 12))
282|2b4299|                .lineLimit(1)
283|3070d1|            
284|1e6289|            Spacer()
285|3070d1|            
286|5cc935|            // Stage/unstage button
287|85bc5a|            if isStaged {
288|993cf3|                Button(action: { unstageFile(entry.path) }) {
289|e91e80|                    Image(systemName: "minus")
290|b3f5ca|                        .font(.system(size: 10))
291|201e5d|                        .foregroundColor(.red)
292|4e2d32|                }
293|556acc|                .buttonStyle(.plain)
294|f5a6eb|            } else {
295|fde51c|                Button(action: { stageFile(entry.path) }) {
296|e583e1|                    Image(systemName: "plus")
297|b3f5ca|                        .font(.system(size: 10))
298|6ae18c|                        .foregroundColor(.green)
299|4e2d32|                }
300|556acc|                .buttonStyle(.plain)
301|a7dc16|            }
302|5f3077|        }
303|60e15e|        .padding(.vertical, 4)
304|0921e9|        .padding(.horizontal, 8)
305|2098b9|        .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
306|906086|        .cornerRadius(4)
307|cf12c6|        .onTapGesture {
308|ae6573|            selectedEntry = entry
309|d8eb7a|            showingDiffEntry = entry
310|5f3077|        }
311|3c5038|        .contextMenu {
312|85bc5a|            if isStaged {
313|993cf3|                Button(action: { unstageFile(entry.path) }) {
314|a083c7|                    Label("Unstage Changes", systemImage: "minus.circle")
315|4e2d32|                }
316|f5a6eb|            } else {
317|fde51c|                Button(action: { stageFile(entry.path) }) {
318|0eba9f|                    Label("Stage Changes", systemImage: "plus.circle")
319|4e2d32|                }
320|a7dc16|            }
321|3070d1|            
322|8e2107|            if !isStaged && entry.kind != .untracked {
323|fcefc3|                Button(role: .destructive, action: {
324|4760f2|                    Task { try? await gitManager.discardChanges(file: entry.path) }
325|e641c1|                }) {
326|7ae18c|                    Label("Discard Changes", systemImage: "trash")
327|4e2d32|                }
328|a7dc16|            }
329|3070d1|            
330|e744dc|            Divider()
331|3070d1|            
332|4107dd|            Button(action: {
333|fe56d7|                let url = URL(fileURLWithPath: entry.path)
334|eddb1a|                editorCore.openFile(from: url)
335|7ceec9|            }) {
336|05277e|                Label("Open File", systemImage: "doc.text")
337|a7dc16|            }
338|3070d1|            
339|4107dd|            Button(action: {
340|f88515|                UIPasteboard.general.string = entry.path
341|7ceec9|            }) {
342|2c23b3|                Label("Copy Path", systemImage: "doc.on.doc")
343|a7dc16|            }
344|5f3077|        }
345|27e597|    }
346|b4687f|    
347|a2f61f|    private func commitRow(_ commit: GitCommit) -> some View {
348|ea9354|        VStack(alignment: .leading, spacing: 2) {
349|f49fd2|            HStack {
350|571752|                Text(commit.shortSHA)
351|627134|                    .font(.system(size: 10, design: .monospaced))
352|153725|                    .foregroundColor(.accentColor)
353|216278|                
354|b23e7f|                Text(commit.message)
355|a5b455|                    .font(.system(size: 11))
356|97a348|                    .lineLimit(1)
357|a7dc16|            }
358|3070d1|            
359|f49fd2|            HStack {
360|617b5c|                Text(commit.author)
361|43cd83|                    .font(.system(size: 10))
362|72464b|                    .foregroundColor(.secondary)
363|216278|                
364|b79503|                Text("•")
365|72464b|                    .foregroundColor(.secondary)
366|216278|                
367|b95acd|                Text(commit.date, style: .relative)
368|43cd83|                    .font(.system(size: 10))
369|72464b|                    .foregroundColor(.secondary)
370|a7dc16|            }
371|5f3077|        }
372|60e15e|        .padding(.vertical, 4)
373|0921e9|        .padding(.horizontal, 8)
374|27e597|    }
375|b4687f|    
376|c906ad|    // MARK: - Actions
377|b4687f|    
378|f48074|    private func refreshGit() {
379|76558b|        Task { await gitManager.refresh() }
380|27e597|    }
381|b4687f|    
382|a818f7|    private func stageFile(_ path: String) {
383|761c91|        Task { try? await gitManager.stage(file: path) }
384|27e597|    }
385|b4687f|    
386|bb7541|    private func unstageFile(_ path: String) {
387|b1370f|        Task { try? await gitManager.unstage(file: path) }
388|27e597|    }
389|b4687f|    
390|032f2a|    private func commitChanges() {
391|4def00|        guard canCommit else { return }
392|0f1953|        Task {
393|1bd820|            try? await gitManager.commit(message: commitMessage)
394|2bac5d|            await MainActor.run { commitMessage = "" }
395|5f3077|        }
396|27e597|    }
397|b4687f|    
398|82db03|    private func commitAndPush() {
399|4def00|        guard canCommit else { return }
400|0f1953|        Task {
401|1bd820|            try? await gitManager.commit(message: commitMessage)
402|2bac5d|            await MainActor.run { commitMessage = "" }
403|b22f1b|            try? await gitManager.push()
404|5f3077|        }
405|27e597|    }
406|b4687f|    
407|5b9c1c|    private func pullChanges() {
408|f316df|        Task { try? await gitManager.pull() }
409|27e597|    }
410|b4687f|    
411|0f0bb1|    private func pushChanges() {
412|fd5391|        Task { try? await gitManager.push() }
413|27e597|    }
414|b4687f|    
415|150ed6|    private func fetchChanges() {
416|29499b|        Task { try? await gitManager.fetch() }
417|27e597|    }
418|b31277|}
419|adc83b|
420|a0e7d2|// MARK: - Branch Picker Sheet
421|adc83b|
422|83e977|struct BranchPickerSheet: View {
423|89ac75|    @ObservedObject var gitManager: GitManager
424|08e45e|    @Environment(\.dismiss) private var dismiss
425|deacfe|    @State private var newBranchName = ""
426|95a35d|    @State private var showCreateBranch = false
427|b4687f|    
428|fc87a1|    var localBranches: [GitBranch] {
429|ebc292|        gitManager.branches.filter { !$0.isRemote }
430|27e597|    }
431|b4687f|    
432|2edaa7|    var remoteBranches: [GitBranch] {
433|eab179|        gitManager.remoteBranches
434|27e597|    }
435|b4687f|    
436|504e43|    var body: some View {
437|0c7ea9|        NavigationView {
438|319386|            List {
439|afe49d|                // Create new branch
440|65412a|                Section {
441|a25faf|                    if showCreateBranch {
442|679877|                        HStack {
443|6c6bed|                            TextField("New branch name", text: $newBranchName)
444|c75abd|                                .textFieldStyle(.roundedBorder)
445|e4abf2|                            
446|83db5b|                            Button("Create") {
447|0d6621|                                createBranch()
448|89d40a|                            }
449|db4ef6|                            .disabled(newBranchName.isEmpty)
450|392b35|                        }
451|540066|                    } else {
452|420d37|                        Button(action: { showCreateBranch = true }) {
453|38b93f|                            Label("Create New Branch", systemImage: "plus.circle")
454|392b35|                        }
455|c9717a|                    }
456|4e2d32|                }
457|216278|                
458|e98f94|                // Local branches
459|2c578b|                Section("Local Branches") {
460|071d03|                    ForEach(localBranches) { branch in
461|839563|                        Button(action: { checkout(branch.name) }) {
462|94cdc3|                            HStack {
463|99c163|                                if branch.isCurrent {
464|85ca1a|                                    Image(systemName: "checkmark")
465|b97656|                                        .foregroundColor(.accentColor)
466|f83e05|                                }
467|26cbe4|                                Text(branch.name)
468|15ded1|                                    .foregroundColor(branch.isCurrent ? .accentColor : .primary)
469|7e8fcd|                                Spacer()
470|89d40a|                            }
471|392b35|                        }
472|442658|                        .buttonStyle(.plain)
473|c9717a|                    }
474|4e2d32|                }
475|216278|                
476|6f5ab0|                // Remote branches
477|1822b0|                if !remoteBranches.isEmpty {
478|fbb9e2|                    Section("Remote Branches") {
479|4ab5d2|                        ForEach(remoteBranches) { branch in
480|f44ebd|                            Button(action: { checkout(branch.name) }) {
481|ccf016|                                HStack {
482|38cfed|                                    Text(branch.name)
483|759980|                                        .foregroundColor(.secondary)
484|c7a564|                                    Spacer()
485|f83e05|                                }
486|89d40a|                            }
487|917e04|                            .buttonStyle(.plain)
488|392b35|                        }
489|c9717a|                    }
490|4e2d32|                }
491|a7dc16|            }
492|bf396b|            .navigationTitle("Branches")
493|83a489|            .navigationBarTitleDisplayMode(.inline)
494|806036|            .toolbar {
495|35e91f|                ToolbarItem(placement: .navigationBarTrailing) {
496|a66048|                    Button("Done") { dismiss() }
497|4e2d32|                }
498|a7dc16|            }
499|5f3077|        }
500|27e597|    }
501|b4687f|    
502|68883f|    private func checkout(_ branch: String) {
503|0f1953|        Task {
504|1f39d5|            try? await gitManager.checkout(branch: branch)
505|210eb5|            await MainActor.run { dismiss() }
506|5f3077|        }
507|27e597|    }
508|b4687f|    
509|f24e4e|    private func createBranch() {
510|a185d3|        guard !newBranchName.isEmpty else { return }
511|0f1953|        Task {
512|fb8f07|            try? await gitManager.createBranch(name: newBranchName)
513|a6a73d|            await MainActor.run {
514|daedf9|                newBranchName = ""
515|498ade|                showCreateBranch = false
516|a2c4a2|                dismiss()
517|a7dc16|            }
518|5f3077|        }
519|27e597|    }
520|b31277|}
521|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 3387162b890e
File: VSCodeiPadOS/VSCodeiPadOS/Services/GitService.swift (lines 1-152 of 152)
────────────────────────────────────────
1|8b6b78|import Foundation
2|adc83b|
3|98d3da|struct GitStash: Identifiable, Equatable {
4|c90f8e|    let id = UUID()
5|edcb08|    let message: String
6|b7dcb9|    let date: Date
7|b31277|}
8|adc83b|
9|bd7a91|/// Lightweight in-memory git state + mocked operations.
10|63c993|///
11|c42cbf|/// NOTE: This project does not yet have a real git backend (libgit2 / shell).
12|603a2e|/// This service exists to wire FEAT-076/077 UI and provide a single shared state
13|b25d43|/// for StatusBar + quick actions sheet.
14|3cd7c2|final class GitService: ObservableObject {
15|60893f|    static let shared = GitService()
16|adc83b|
17|143b6b|    @Published var currentBranch: String = "main"
18|bbab80|    @Published var statusText: String = "No changes"
19|adc83b|
20|14a687|    /// Commits not pushed
21|2c2fe3|    @Published var aheadCount: Int = 0
22|adc83b|
23|72c810|    /// Remote commits not pulled
24|470fd2|    @Published var behindCount: Int = 0
25|adc83b|
26|8364fc|    @Published var stashes: [GitStash] = []
27|adc83b|
28|c43ba1|    @Published var isBusy: Bool = false
29|b4687f|    
30|fa1ce0|    @Published var branches: [String] = ["main", "develop", "feature/ui-updates"]
31|b4687f|    
32|ec07bb|    @Published var lastErrorMessage: String? = nil
33|adc83b|
34|54113e|    private init() {}
35|b4687f|    
36|b89b08|    func switchBranch(to branch: String) {
37|3fe7b8|        isBusy = true
38|40d3ea|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
39|e7a97a|            self.currentBranch = branch
40|f7aca3|            self.isBusy = false
41|e0938e|            self.refreshStatus()
42|5f3077|        }
43|27e597|    }
44|b4687f|    
45|00987f|    func createBranch(named name: String, checkout: Bool = true) {
46|890000|        guard !name.isEmpty else {
47|43593c|            lastErrorMessage = "Branch name cannot be empty"
48|bef5d6|            return
49|5f3077|        }
50|3fe7b8|        isBusy = true
51|40d3ea|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
52|88b4d0|            self.branches.append(name)
53|df4f23|            if checkout {
54|cc1df8|                self.currentBranch = name
55|a7dc16|            }
56|f7aca3|            self.isBusy = false
57|5f3077|        }
58|27e597|    }
59|b4687f|    
60|6a604e|    func deleteBranch(named branch: String) {
61|04d85f|        guard branch != currentBranch else {
62|b67493|            lastErrorMessage = "Cannot delete current branch"
63|bef5d6|            return
64|5f3077|        }
65|3fe7b8|        isBusy = true
66|40d3ea|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
67|6ab044|            self.branches.removeAll { $0 == branch }
68|f7aca3|            self.isBusy = false
69|5f3077|        }
70|27e597|    }
71|adc83b|
72|f1db3d|    func refreshStatus() {
73|3fe7b8|        isBusy = true
74|5b07be|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
75|b4dd6e|            self.statusText = "On branch \(self.currentBranch)\n" +
76|080db7|            "Your branch is up to date with 'origin/\(self.currentBranch)'.\n\n" +
77|0f6d37|            "Changes not staged for commit:\n" +
78|55438a|            "  modified:   ContentView.swift\n" +
79|266684|            "  modified:   README.md"
80|f7aca3|            self.isBusy = false
81|5f3077|        }
82|27e597|    }
83|adc83b|
84|e92111|    func commit(message: String) {
85|3fe7b8|        isBusy = true
86|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
87|04295e|            self.aheadCount += 1
88|b4dd6e|            self.statusText = "On branch \(self.currentBranch)\n" +
89|8958eb|            "Your branch is ahead of 'origin/\(self.currentBranch)' by \(self.aheadCount) commit(s).\n\n" +
90|21e260|            "nothing to commit, working tree clean"
91|f7aca3|            self.isBusy = false
92|5f3077|        }
93|27e597|    }
94|adc83b|
95|cdc5c9|    func pull() {
96|3fe7b8|        isBusy = true
97|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
98|3c3495|            if self.behindCount > 0 {
99|4fb755|                self.behindCount = 0
100|a7dc16|            }
101|b4dd6e|            self.statusText = "On branch \(self.currentBranch)\n" +
102|b4e992|            "Already up to date."
103|f7aca3|            self.isBusy = false
104|5f3077|        }
105|27e597|    }
106|adc83b|
107|6ae160|    func push() {
108|3fe7b8|        isBusy = true
109|145a34|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
110|71ac8a|            if self.aheadCount > 0 {
111|02a64f|                self.aheadCount = 0
112|a7dc16|            }
113|b4dd6e|            self.statusText = "On branch \(self.currentBranch)\n" +
114|d615dd|            "Everything up-to-date"
115|f7aca3|            self.isBusy = false
116|5f3077|        }
117|27e597|    }
118|adc83b|
119|be1804|    // MARK: - Stash
120|adc83b|
121|d58a1b|    func stashSave(message: String?) {
122|3fe7b8|        isBusy = true
123|5b07be|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
124|a21659|            let trimmed = (message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
125|5c3d57|            let msg = trimmed.isEmpty ? "WIP on \(self.currentBranch)" : trimmed
126|69b2a1|            self.stashes.insert(GitStash(message: msg, date: Date()), at: 0)
127|c1d148|            self.statusText = "Saved working directory and index state: \(msg)"
128|f7aca3|            self.isBusy = false
129|5f3077|        }
130|27e597|    }
131|adc83b|
132|de20de|    func stashApply(index: Int) {
133|91826e|        guard stashes.indices.contains(index) else { return }
134|3fe7b8|        isBusy = true
135|7d951c|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
136|85868c|            self.statusText = "Applied stash@{\(index)}: \(self.stashes[index].message)"
137|f7aca3|            self.isBusy = false
138|5f3077|        }
139|27e597|    }
140|adc83b|
141|3d2837|    func stashPop(index: Int) {
142|91826e|        guard stashes.indices.contains(index) else { return }
143|3fe7b8|        isBusy = true
144|7d951c|        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
145|c4fb80|            let msg = self.stashes[index].message
146|103eb1|            self.stashes.remove(at: index)
147|308397|            self.statusText = "Dropped stash@{\(index)}: \(msg)"
148|f7aca3|            self.isBusy = false
149|5f3077|        }
150|27e597|    }
151|b31277|}
152|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 40d9f8807007
File: VSCodeiPadOS/VSCodeiPadOS/Services/NativeGit/SSHGitClient.swift (lines 1-452 of 452)
────────────────────────────────────────
1|8d0643|//
2|4b618d|//  SSHGitClient.swift
3|e45c97|//  VSCodeiPadOS
4|8d0643|//
5|a5fcf0|//  SSH-based git client - runs git commands on remote servers
6|aa1464|//  Used when native git reading isn't sufficient (push/pull/clone)
7|8d0643|//
8|adc83b|
9|8b6b78|import Foundation
10|5f1c26|import NIO
11|d40220|import NIOSSH
12|adc83b|
13|20b4e6|// MARK: - SSH Git Client
14|adc83b|
15|693b84|class SSHGitClient {
16|d022b4|    private let sshManager: SSHManager
17|96bd4d|    private var outputBuffer = ""
18|1eb5f1|    private var errorBuffer = ""
19|8c1fbb|    private var commandCompletion: ((Result<String, Error>) -> Void)?
20|b4687f|    
21|81a512|    init(sshManager: SSHManager) {
22|cd44d2|        self.sshManager = sshManager
23|27e597|    }
24|b4687f|    
25|eda943|    // MARK: - Git Commands
26|b4687f|    
27|05f452|    /// Run git status and parse output
28|fb4add|    func status(path: String) async throws -> SSHGitStatus {
29|87f161|        let output = try await runGitCommand(["status", "--porcelain=v2", "--branch"], in: path)
30|1dd12c|        return SSHGitStatus.parse(output: output)
31|27e597|    }
32|b4687f|    
33|4fb7c6|    /// Get current branch
34|28a2e7|    func currentBranch(path: String) async throws -> String {
35|5c3d31|        let output = try await runGitCommand(["branch", "--show-current"], in: path)
36|8112ad|        let branch = output.trimmingCharacters(in: .whitespacesAndNewlines)
37|a5c8a3|        return branch.isEmpty ? "HEAD" : branch
38|27e597|    }
39|b4687f|    
40|cf9480|    /// List all branches
41|015616|    func branches(path: String) async throws -> [SSHGitBranch] {
42|cd6b1a|        let output = try await runGitCommand(["branch", "-a", "--format=%(refname:short)|%(objectname:short)|%(upstream:short)|%(HEAD)"], in: path)
43|d6ed84|        
44|b76447|        var branches: [SSHGitBranch] = []
45|272497|        for line in output.components(separatedBy: "\n") where !line.isEmpty {
46|795c70|            let parts = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
47|430957|            guard parts.count >= 4 else { continue }
48|3070d1|            
49|76d777|            let name = parts[0]
50|a3f5f8|            let sha = parts[1]
51|8a08ca|            let upstream = parts[2].isEmpty ? nil : parts[2]
52|735d11|            let isCurrent = parts[3] == "*"
53|c85ee7|            let isRemote = name.hasPrefix("remotes/") || name.contains("/")
54|3070d1|            
55|cb79d8|            branches.append(SSHGitBranch(
56|40c0d1|                name: name,
57|c97dd9|                sha: sha,
58|07ef7e|                upstream: upstream,
59|87a789|                isCurrent: isCurrent,
60|06e779|                isRemote: isRemote
61|30ec32|            ))
62|5f3077|        }
63|d6ed84|        
64|c46e6c|        return branches
65|27e597|    }
66|b4687f|    
67|a4cb96|    /// Get recent commits
68|578cae|    func log(path: String, count: Int = 20) async throws -> [SSHGitCommit] {
69|f9561b|        let format = "%H|%an|%ae|%at|%s"
70|1c3531|        let output = try await runGitCommand(["log", "-\(count)", "--format=\(format)"], in: path)
71|d6ed84|        
72|2caca9|        var commits: [SSHGitCommit] = []
73|272497|        for line in output.components(separatedBy: "\n") where !line.isEmpty {
74|1ef071|            let parts = line.split(separator: "|", maxSplits: 4, omittingEmptySubsequences: false).map(String.init)
75|ff40dc|            guard parts.count >= 5 else { continue }
76|3070d1|            
77|c33e3d|            let sha = parts[0]
78|9ee1e4|            let author = parts[1]
79|cc86aa|            let email = parts[2]
80|340e83|            let timestamp = TimeInterval(parts[3]) ?? 0
81|0d5ac6|            let message = parts[4]
82|3070d1|            
83|cf8861|            commits.append(SSHGitCommit(
84|c97dd9|                sha: sha,
85|415ee1|                author: author,
86|45e593|                email: email,
87|363e65|                date: Date(timeIntervalSince1970: timestamp),
88|971fde|                message: message
89|30ec32|            ))
90|5f3077|        }
91|d6ed84|        
92|b34909|        return commits
93|27e597|    }
94|b4687f|    
95|b7fffa|    /// Stage a file
96|0256b6|    func stage(file: String, in path: String) async throws {
97|8da8a9|        _ = try await runGitCommand(["add", file], in: path)
98|27e597|    }
99|b4687f|    
100|1f206f|    /// Stage all changes
101|0cc01b|    func stageAll(in path: String) async throws {
102|91e4b3|        _ = try await runGitCommand(["add", "-A"], in: path)
103|27e597|    }
104|b4687f|    
105|9f7f55|    /// Unstage a file
106|934f10|    func unstage(file: String, in path: String) async throws {
107|011b8e|        _ = try await runGitCommand(["reset", "HEAD", file], in: path)
108|27e597|    }
109|b4687f|    
110|8d514c|    /// Commit staged changes
111|1bbf67|    func commit(message: String, in path: String) async throws -> String {
112|a327d4|        let output = try await runGitCommand(["commit", "-m", message], in: path)
113|d6ed84|        
114|30b9df|        // Extract commit SHA from output
115|a48afc|        // Format: "[branch sha] message"
116|2f4288|        if let match = output.firstMatch(of: /\[\w+ ([a-f0-9]+)\]/) {
117|1f58e7|            return String(match.1)
118|5f3077|        }
119|2ca6c1|        return ""
120|27e597|    }
121|b4687f|    
122|52ead2|    /// Checkout a branch
123|ee9ca4|    func checkout(branch: String, in path: String) async throws {
124|5104bb|        _ = try await runGitCommand(["checkout", branch], in: path)
125|27e597|    }
126|b4687f|    
127|d50455|    /// Create a new branch
128|d8e22b|    func createBranch(name: String, checkout: Bool, in path: String) async throws {
129|8719d0|        if checkout {
130|10278b|            _ = try await runGitCommand(["checkout", "-b", name], in: path)
131|b31999|        } else {
132|4ecf92|            _ = try await runGitCommand(["branch", name], in: path)
133|5f3077|        }
134|27e597|    }
135|b4687f|    
136|9a1155|    /// Delete a branch
137|6d78a3|    func deleteBranch(name: String, force: Bool, in path: String) async throws {
138|1f8abb|        let flag = force ? "-D" : "-d"
139|681e14|        _ = try await runGitCommand(["branch", flag, name], in: path)
140|27e597|    }
141|b4687f|    
142|719221|    /// Pull from remote
143|51a524|    func pull(remote: String = "origin", branch: String? = nil, in path: String) async throws -> String {
144|8bb1f6|        var args = ["pull", remote]
145|323245|        if let branch = branch {
146|a14fc3|            args.append(branch)
147|5f3077|        }
148|3c9625|        return try await runGitCommand(args, in: path)
149|27e597|    }
150|b4687f|    
151|9a70aa|    /// Push to remote
152|e83e0b|    func push(remote: String = "origin", branch: String? = nil, force: Bool = false, in path: String) async throws -> String {
153|f32233|        var args = ["push"]
154|9dfc4f|        if force {
155|0fe515|            args.append("--force")
156|5f3077|        }
157|89390f|        args.append(remote)
158|323245|        if let branch = branch {
159|a14fc3|            args.append(branch)
160|5f3077|        }
161|3c9625|        return try await runGitCommand(args, in: path)
162|27e597|    }
163|b4687f|    
164|cd57c3|    /// Fetch from remote
165|d76d92|    func fetch(remote: String = "origin", prune: Bool = false, in path: String) async throws {
166|3470e4|        var args = ["fetch", remote]
167|5e50d5|        if prune {
168|56bddb|            args.append("--prune")
169|5f3077|        }
170|eb322d|        _ = try await runGitCommand(args, in: path)
171|27e597|    }
172|b4687f|    
173|1d38d3|    /// Discard changes in a file
174|fe85bf|    func discardChanges(file: String, in path: String) async throws {
175|3e0a57|        _ = try await runGitCommand(["checkout", "--", file], in: path)
176|27e597|    }
177|b4687f|    
178|3e81a1|    /// Get diff for a file
179|1127de|    func diff(file: String? = nil, staged: Bool = false, in path: String) async throws -> String {
180|3f0a2d|        var args = ["diff"]
181|b11d22|        if staged {
182|b671d1|            args.append("--cached")
183|5f3077|        }
184|13a7bc|        if let file = file {
185|941f46|            args.append("--")
186|2cf407|            args.append(file)
187|5f3077|        }
188|3c9625|        return try await runGitCommand(args, in: path)
189|27e597|    }
190|b4687f|    
191|7ec6c8|    /// Stash changes
192|aa624d|    func stash(message: String? = nil, in path: String) async throws {
193|573679|        var args = ["stash", "push"]
194|3e4497|        if let message = message {
195|d35e77|            args.append("-m")
196|cde9cd|            args.append(message)
197|5f3077|        }
198|eb322d|        _ = try await runGitCommand(args, in: path)
199|27e597|    }
200|b4687f|    
201|6d9175|    /// List stashes
202|4d3f61|    func stashList(in path: String) async throws -> [SSHGitStash] {
203|f3d14e|        let output = try await runGitCommand(["stash", "list", "--format=%gd|%s|%at"], in: path)
204|d6ed84|        
205|aaa6eb|        var stashes: [SSHGitStash] = []
206|272497|        for line in output.components(separatedBy: "\n") where !line.isEmpty {
207|7fe329|            let parts = line.split(separator: "|", maxSplits: 2).map(String.init)
208|0a2c97|            guard parts.count >= 3 else { continue }
209|3070d1|            
210|c13e57|            let ref = parts[0] // stash@{0}
211|4fa0de|            let message = parts[1]
212|82754c|            let timestamp = TimeInterval(parts[2]) ?? 0
213|3070d1|            
214|66d790|            // Extract index from ref
215|819894|            let index: Int
216|a90dcf|            if let match = ref.firstMatch(of: /stash@\{(\d+)\}/) {
217|8a3994|                index = Int(match.1) ?? 0
218|f5a6eb|            } else {
219|a81a0c|                index = stashes.count
220|a7dc16|            }
221|3070d1|            
222|5d72e6|            stashes.append(SSHGitStash(
223|30018f|                index: index,
224|596fe8|                message: message,
225|923ca2|                date: Date(timeIntervalSince1970: timestamp)
226|30ec32|            ))
227|5f3077|        }
228|d6ed84|        
229|6e3c8a|        return stashes
230|27e597|    }
231|b4687f|    
232|262426|    /// Apply stash
233|56261d|    func stashApply(index: Int, in path: String) async throws {
234|21f10b|        _ = try await runGitCommand(["stash", "apply", "stash@{\(index)}"], in: path)
235|27e597|    }
236|b4687f|    
237|9df41f|    /// Pop stash
238|579a79|    func stashPop(index: Int, in path: String) async throws {
239|c174a0|        _ = try await runGitCommand(["stash", "pop", "stash@{\(index)}"], in: path)
240|27e597|    }
241|b4687f|    
242|cf92ba|    /// Drop stash
243|c51f9e|    func stashDrop(index: Int, in path: String) async throws {
244|fa18cb|        _ = try await runGitCommand(["stash", "drop", "stash@{\(index)}"], in: path)
245|27e597|    }
246|b4687f|    
247|1561ec|    // MARK: - Command Execution
248|b4687f|    
249|ac3b0f|    private func runGitCommand(_ args: [String], in path: String) async throws -> String {
250|ee913b|        guard sshManager.isConnected else {
251|0ceef2|            throw SSHGitError.notConnected
252|5f3077|        }
253|d6ed84|        
254|d96198|        // Build command with proper escaping
255|78e88c|        let escapedArgs = args.map { escapeShellArg($0) }
256|dc7072|        let command = "cd \(escapeShellArg(path)) && git \(escapedArgs.joined(separator: " "))"
257|d6ed84|        
258|3d0b9a|        return try await withCheckedThrowingContinuation { continuation in
259|528e5a|            self.outputBuffer = ""
260|2a1e48|            self.errorBuffer = ""
261|3070d1|            
262|76847d|            // Set up completion handler
263|d9dd46|            self.commandCompletion = { result in
264|414af6|                continuation.resume(with: result)
265|a7dc16|            }
266|3070d1|            
267|9b83ee|            // Send command
268|4c8dfc|            sshManager.send(command: command)
269|3070d1|            
270|6ea2a4|            // Set timeout
271|d491df|            DispatchQueue.main.asyncAfter(deadline: .now() + 30) { [weak self] in
272|953c72|                if let completion = self?.commandCompletion {
273|cb6bcb|                    self?.commandCompletion = nil
274|f2d053|                    completion(.failure(SSHGitError.timeout))
275|4e2d32|                }
276|a7dc16|            }
277|5f3077|        }
278|27e597|    }
279|b4687f|    
280|310f31|    private func escapeShellArg(_ arg: String) -> String {
281|5319c0|        // Simple shell escaping - wrap in single quotes and escape internal single quotes
282|d5e09e|        let escaped = arg.replacingOccurrences(of: "'", with: "'\\''")
283|983bf6|        return "'\(escaped)'"
284|27e597|    }
285|b4687f|    
286|2b4f2e|    // MARK: - SSH Output Handling
287|b4687f|    
288|4fa773|    /// Call this when SSH output is received
289|344693|    func handleOutput(_ text: String) {
290|8379df|        outputBuffer += text
291|d6ed84|        
292|062367|        // Check for command completion (prompt return)
293|c1b864|        // This is a simple heuristic - real implementation would use markers
294|810fcf|        if text.contains("$ ") || text.contains("# ") {
295|cd7f55|            completeCommand()
296|5f3077|        }
297|27e597|    }
298|b4687f|    
299|261a39|    /// Call this when SSH error is received
300|c01ca0|    func handleError(_ text: String) {
301|e5fbd4|        errorBuffer += text
302|27e597|    }
303|b4687f|    
304|ca82f9|    private func completeCommand() {
305|ea4485|        guard let completion = commandCompletion else { return }
306|0ab492|        commandCompletion = nil
307|d6ed84|        
308|703c25|        if !errorBuffer.isEmpty && errorBuffer.contains("fatal:") {
309|7c61c6|            completion(.failure(SSHGitError.commandFailed(errorBuffer)))
310|b31999|        } else {
311|5e1613|            completion(.success(outputBuffer))
312|5f3077|        }
313|27e597|    }
314|b31277|}
315|adc83b|
316|d16192|// MARK: - SSH Git Types
317|adc83b|
318|bf86b7|enum SSHGitError: Error, LocalizedError {
319|32cbe8|    case notConnected
320|553b8f|    case timeout
321|cc3a27|    case commandFailed(String)
322|96a0c7|    case parseError(String)
323|b4687f|    
324|242b78|    var errorDescription: String? {
325|2e6d08|        switch self {
326|47a650|        case .notConnected: return "Not connected to SSH server"
327|d12651|        case .timeout: return "Git command timed out"
328|caf6fd|        case .commandFailed(let msg): return "Git error: \(msg)"
329|f9a8bd|        case .parseError(let msg): return "Parse error: \(msg)"
330|5f3077|        }
331|27e597|    }
332|b31277|}
333|adc83b|
334|8ad23b|struct SSHGitStatus {
335|2bc961|    var branch: String = "HEAD"
336|ecdf3f|    var upstream: String?
337|20b479|    var ahead: Int = 0
338|83ec3c|    var behind: Int = 0
339|ec27ef|    var staged: [SSHGitFileChange] = []
340|fd32c2|    var unstaged: [SSHGitFileChange] = []
341|af3f82|    var untracked: [String] = []
342|5c76d7|    var conflicted: [String] = []
343|b4687f|    
344|7664be|    static func parse(output: String) -> SSHGitStatus {
345|313f76|        var status = SSHGitStatus()
346|d6ed84|        
347|272497|        for line in output.components(separatedBy: "\n") where !line.isEmpty {
348|cada14|            if line.hasPrefix("# branch.head ") {
349|23ac0d|                status.branch = String(line.dropFirst(14))
350|3c3cc5|            } else if line.hasPrefix("# branch.upstream ") {
351|fafeb4|                status.upstream = String(line.dropFirst(18))
352|948587|            } else if line.hasPrefix("# branch.ab ") {
353|986e03|                // Format: # branch.ab +N -M
354|14ea92|                let parts = line.dropFirst(12).split(separator: " ")
355|e9e7f5|                if parts.count >= 2 {
356|70271e|                    status.ahead = Int(parts[0].dropFirst()) ?? 0  // +N
357|72b5e8|                    status.behind = Int(parts[1].dropFirst()) ?? 0 // -M
358|4e2d32|                }
359|560f07|            } else if line.hasPrefix("1 ") || line.hasPrefix("2 ") {
360|1c8488|                // Changed entry
361|774007|                // Format: 1 XY sub mH mI mW hH hI path
362|f04524|                // or:     2 XY sub mH mI mW hH hI X score path\torigPath
363|ab860b|                let parts = line.split(separator: " ", maxSplits: 8)
364|1f4bc3|                guard parts.count >= 9 else { continue }
365|216278|                
366|c2d10a|                let xy = String(parts[1])
367|70bc62|                let path = String(parts[8]).components(separatedBy: "\t").first ?? String(parts[8])
368|216278|                
369|91dd5e|                let indexStatus = xy.first ?? " "
370|34e598|                let workingStatus = xy.last ?? " "
371|216278|                
372|2c187a|                if indexStatus != "." && indexStatus != " " {
373|74ab39|                    status.staged.append(SSHGitFileChange(
374|1847be|                        path: path,
375|fd9ed7|                        status: parseStatusChar(indexStatus)
376|c89922|                    ))
377|4e2d32|                }
378|216278|                
379|c7034c|                if workingStatus != "." && workingStatus != " " {
380|b02205|                    status.unstaged.append(SSHGitFileChange(
381|1847be|                        path: path,
382|e0fbfc|                        status: parseStatusChar(workingStatus)
383|c89922|                    ))
384|4e2d32|                }
385|786dde|            } else if line.hasPrefix("? ") {
386|b41596|                // Untracked
387|87d8d6|                let path = String(line.dropFirst(2))
388|effa17|                status.untracked.append(path)
389|603c6d|            } else if line.hasPrefix("u ") {
390|de9bfb|                // Unmerged/conflicted
391|91cb0e|                let parts = line.split(separator: " ")
392|f2be41|                if let path = parts.last {
393|828b36|                    status.conflicted.append(String(path))
394|4e2d32|                }
395|a7dc16|            }
396|5f3077|        }
397|d6ed84|        
398|547a88|        return status
399|27e597|    }
400|b4687f|    
401|c33d7a|    private static func parseStatusChar(_ char: Character) -> SSHGitChangeStatus {
402|9cfc92|        switch char {
403|418942|        case "M": return .modified
404|8074ab|        case "A": return .added
405|8abe89|        case "D": return .deleted
406|2cb3fa|        case "R": return .renamed
407|e7513e|        case "C": return .copied
408|361cc8|        case "T": return .typeChanged
409|f11a31|        case "U": return .unmerged
410|206449|        default: return .unknown
411|5f3077|        }
412|27e597|    }
413|b31277|}
414|adc83b|
415|698b7e|enum SSHGitChangeStatus: String {
416|734ea7|    case modified
417|56fc3b|    case added
418|f7e3d2|    case deleted
419|b7ed69|    case renamed
420|72deca|    case copied
421|02dfd0|    case typeChanged
422|fb1f53|    case unmerged
423|cc1487|    case unknown
424|b31277|}
425|adc83b|
426|885bbc|struct SSHGitFileChange {
427|1c6e32|    let path: String
428|0a69d4|    let status: SSHGitChangeStatus
429|b31277|}
430|adc83b|
431|f8487d|struct SSHGitBranch {
432|a5193b|    let name: String
433|0810ff|    let sha: String
434|f3ef6a|    let upstream: String?
435|cef4b1|    let isCurrent: Bool
436|507e47|    let isRemote: Bool
437|b31277|}
438|adc83b|
439|293d38|struct SSHGitCommit {
440|0810ff|    let sha: String
441|ab0604|    let author: String
442|72d2ca|    let email: String
443|b7dcb9|    let date: Date
444|edcb08|    let message: String
445|b31277|}
446|adc83b|
447|05400c|struct SSHGitStash {
448|b081e6|    let index: Int
449|edcb08|    let message: String
450|b7dcb9|    let date: Date
451|b31277|}
452|adc83b|




---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 2aa0b77f7f54
File: VSCodeiPadOS/VSCodeiPadOS/Views/StatusBarView.swift (lines 1-136 of 136)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|adc83b|
3|bd05eb|struct StatusBarView: View {
4|e5f895|    @ObservedObject var editorCore: EditorCore
5|cb3e5c|    @ObservedObject var themeManager = ThemeManager.shared
6|ad7e4e|    @ObservedObject private var git = GitManager.shared
7|adc83b|
8|489efb|    @State private var showGitSheet = false
9|adc83b|
10|01c676|    var theme: Theme { themeManager.currentTheme }
11|adc83b|
12|504e43|    var body: some View {
13|250bf4|        HStack(spacing: 0) {
14|1e3746|            // Left side items
15|3b7550|            HStack(spacing: 0) {
16|76a69f|                // Branch
17|c00d22|                StatusBarItem(text: git.currentBranch, icon: "arrow.triangle.branch", theme: theme) {
18|dd8c9a|                    showGitSheet = true
19|4e2d32|                }
20|adc83b|
21|dbdce5|                // Pull button with behind count
22|87e91c|                StatusBarItem(text: git.behindCount > 0 ? String(git.behindCount) : "", icon: "arrow.down.to.line", theme: theme) {
23|9d1e31|                    guard !git.isLoading else { return }
24|261f83|                    Task { try? await git.pull() }
25|4e2d32|                }
26|adc83b|
27|6ca4da|                // Push button with ahead count
28|b7e247|                StatusBarItem(text: git.aheadCount > 0 ? String(git.aheadCount) : "", icon: "arrow.up.to.line", theme: theme) {
29|9d1e31|                    guard !git.isLoading else { return }
30|5a13c0|                    Task { try? await git.push() }
31|4e2d32|                }
32|adc83b|
33|d616a7|                // Stash indicator
34|7ba113|                StatusBarItem(text: git.stashes.isEmpty ? "" : String(git.stashes.count), icon: "archivebox", theme: theme) {
35|dd8c9a|                    showGitSheet = true
36|4e2d32|                }
37|adc83b|
38|46aca8|                StatusBarItem(text: "0", icon: "xmark.circle.fill", theme: theme) {
39|fae617|                    // Future: Show problems
40|4e2d32|                }
41|adc83b|
42|42f43a|                StatusBarItem(text: "0", icon: "exclamationmark.triangle.fill", theme: theme) {
43|2e7a16|                    // Future: Show warnings
44|4e2d32|                }
45|a7dc16|            }
46|adc83b|
47|1e6289|            Spacer()
48|adc83b|
49|bddcf7|            // Right side items
50|3b7550|            HStack(spacing: 0) {
51|47e72a|                // Multi-cursor indicator
52|5cb325|                if editorCore.multiCursorState.isMultiCursor {
53|290831|                    StatusBarItem(
54|a52c7c|                        text: "\(editorCore.multiCursorState.cursors.count) cursors",
55|766f89|                        icon: "text.cursor",
56|5db55c|                        theme: theme
57|db2f4e|                    ) {
58|d38430|                        editorCore.escapeMultiCursor()
59|c9717a|                    }
60|4e2d32|                }
61|adc83b|
62|f98b36|                // Cursor Position
63|406945|                StatusBarItem(text: "Ln \(editorCore.cursorPosition.line + 1), Col \(editorCore.cursorPosition.column + 1)", theme: theme) {
64|7e7955|                    editorCore.showGoToLine = true
65|4e2d32|                }
66|adc83b|
67|501c8e|                // Indentation
68|120be6|                StatusBarItem(text: "Spaces: 4", theme: theme) {
69|6a9baf|                    // Future: Change indentation
70|4e2d32|                }
71|adc83b|
72|df648b|                // Encoding
73|385ef9|                StatusBarItem(text: "UTF-8", theme: theme) {
74|aeba50|                    // Future: Change encoding
75|4e2d32|                }
76|adc83b|
77|23f466|                // EOL
78|9f392e|                StatusBarItem(text: "LF", theme: theme) {
79|1a1292|                    // Future: Change EOL
80|4e2d32|                }
81|adc83b|
82|6363b5|                // Language
83|43ec96|                if let tab = editorCore.activeTab {
84|2472c1|                    StatusBarItem(text: tab.language.displayName, theme: theme) {
85|e37065|                        // Future: Change Language Mode
86|c9717a|                    }
87|adc83b|
88|68a512|                    // Feedback / Notification bell
89|41755f|                    StatusBarItem(text: "", icon: "bell", theme: theme) {
90|26b1e3|                        // Future: Notifications
91|c9717a|                    }
92|4e2d32|                }
93|a7dc16|            }
94|5f3077|        }
95|7e0317|        .padding(.horizontal, 4)
96|b52c03|        .frame(height: 22)
97|de948c|        .background(theme.statusBarBackground)
98|eaaf2f|        .foregroundColor(theme.statusBarForeground)
99|0b2af4|        .font(.system(size: 11))
100|e7af34|        .sheet(isPresented: $showGitSheet) {
101|0b599a|            GitQuickActionsView()
102|5f3077|        }
103|27e597|    }
104|b31277|}
105|adc83b|
106|c96c97|struct StatusBarItem: View {
107|3b73c8|    var text: String
108|40fef6|    var icon: String? = nil
109|af9da8|    var theme: Theme
110|e0b4f1|    var action: () -> Void
111|adc83b|
112|6d2ac2|    @State private var isHovering = false
113|adc83b|
114|504e43|    var body: some View {
115|6f04d8|        Button(action: action) {
116|37f526|            HStack(spacing: 4) {
117|80e25a|                if let icon = icon {
118|9372a4|                    Image(systemName: icon)
119|b3f5ca|                        .font(.system(size: 10))
120|4e2d32|                }
121|68c672|                if !text.isEmpty {
122|769fe1|                    Text(text)
123|4e2d32|                }
124|a7dc16|            }
125|ac06c9|            .padding(.horizontal, 8)
126|45eea2|            .frame(maxHeight: .infinity)
127|be707c|            .background(isHovering ? Color.white.opacity(0.12) : Color.clear)
128|68d57d|            .contentShape(Rectangle())
129|5f3077|        }
130|bd8b70|        .buttonStyle(.plain)
131|ca4aa4|        .onHover { hovering in
132|0675b0|            isHovering = hovering
133|5f3077|        }
134|27e597|    }
135|b31277|}
136|adc83b|


Now let me check how the branch is read during refresh:



---

## 🔧 TOOL RESULTS

[read_file]
snapshot: 868512a70fb4
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitQuickActionsView.swift (lines 1-272 of 272)
────────────────────────────────────────
1|d755ba|import SwiftUI
2|adc83b|
3|47c9a4|/// Quick actions sheet wired to GitManager for Pull/Push + Stash operations.
4|826f92|struct GitQuickActionsView: View {
5|ad7e4e|    @ObservedObject private var git = GitManager.shared
6|08e45e|    @Environment(\.dismiss) private var dismiss
7|adc83b|
8|c0a7dc|    @State private var stashMessage: String = ""
9|b4687f|    
10|7de1e6|    /// Computed property for whether there are uncommitted changes
11|fc39b6|    private var hasUncommittedChanges: Bool {
12|e82e3d|        !git.stagedChanges.isEmpty || !git.unstagedChanges.isEmpty || !git.untrackedFiles.isEmpty
13|27e597|    }
14|adc83b|
15|504e43|    var body: some View {
16|0c7ea9|        NavigationView {
17|3e697a|            VStack(spacing: 12) {
18|3dd44c|                pullPushSection
19|858961|                statusSection
20|a94e41|                stashSection
21|a02350|                Spacer()
22|a7dc16|            }
23|043773|            .padding(.top, 12)
24|a8872a|            .navigationTitle("Git")
25|83a489|            .navigationBarTitleDisplayMode(.inline)
26|806036|            .toolbar {
27|64bf59|                ToolbarItem(placement: .topBarLeading) {
28|735f6c|                    Button("Close") { dismiss() }
29|4e2d32|                }
30|d6567f|                ToolbarItem(placement: .topBarTrailing) {
31|5e695f|                    Button {
32|4850da|                        Task { await git.refresh() }
33|83be2c|                    } label: {
34|84a28b|                        Image(systemName: "arrow.clockwise")
35|c9717a|                    }
36|a9569d|                    .disabled(git.isLoading)
37|4e2d32|                }
38|a7dc16|            }
39|02a406|            .overlay {
40|3d6f44|                if git.isLoading {
41|ac3ac4|                    ProgressView()
42|efd428|                        .scaleEffect(1.2)
43|4e2d32|                }
44|a7dc16|            }
45|5f3077|        }
46|2bd24e|        .onAppear {
47|a7c6bf|            Task { await git.refresh() }
48|5f3077|        }
49|27e597|    }
50|b4687f|    
51|5d7f8c|    // MARK: - Pull/Push Section
52|b4687f|    
53|ab06c2|    @ViewBuilder
54|2f77e5|    private var pullPushSection: some View {
55|8c28e9|        HStack(spacing: 12) {
56|70c70b|            Button {
57|5c72ed|                Task { try? await git.pull() }
58|d8abfb|            } label: {
59|fe8ceb|                Label("Pull", systemImage: "arrow.down.to.line")
60|6d5e9c|                    .frame(maxWidth: .infinity)
61|a7dc16|            }
62|fe3986|            .buttonStyle(.bordered)
63|644732|            .disabled(git.isLoading)
64|adc83b|
65|70c70b|            Button {
66|119fb9|                Task { try? await git.push() }
67|d8abfb|            } label: {
68|023d73|                Label("Push", systemImage: "arrow.up.to.line")
69|6d5e9c|                    .frame(maxWidth: .infinity)
70|a7dc16|            }
71|a68f66|            .buttonStyle(.borderedProminent)
72|644732|            .disabled(git.isLoading)
73|5f3077|        }
74|215d84|        .padding(.horizontal)
75|27e597|    }
76|b4687f|    
77|258809|    // MARK: - Status Section
78|b4687f|    
79|ab06c2|    @ViewBuilder
80|b9bc7c|    private var statusSection: some View {
81|98d0f7|        VStack(alignment: .leading, spacing: 8) {
82|637a7e|            Text("STATUS")
83|916793|                .font(.caption)
84|4e212a|                .foregroundStyle(.secondary)
85|adc83b|
86|6b85db|            ScrollView {
87|675fcc|                statusContent
88|a7dc16|            }
89|53ba65|            .frame(maxHeight: 160)
90|508ae7|            .background(Color(UIColor.secondarySystemBackground))
91|e5fd5c|            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
92|5f3077|        }
93|215d84|        .padding(.horizontal)
94|27e597|    }
95|b4687f|    
96|ab06c2|    @ViewBuilder
97|781ca2|    private var statusContent: some View {
98|478d8c|        VStack(alignment: .leading, spacing: 4) {
99|843c77|            branchInfoRow
100|667235|            aheadBehindRow
101|e744dc|            Divider()
102|d8946a|            changesContent
103|5f3077|        }
104|a98e10|        .font(.system(.footnote, design: .monospaced))
105|e6b16b|        .frame(maxWidth: .infinity, alignment: .leading)
106|a37586|        .padding(10)
107|27e597|    }
108|b4687f|    
109|ab06c2|    @ViewBuilder
110|326c61|    private var branchInfoRow: some View {
111|642308|        HStack {
112|7ae026|            Image(systemName: "arrow.triangle.branch")
113|c6ab37|            Text("On branch \(git.currentBranch)")
114|9b6b1c|                .fontWeight(.medium)
115|5f3077|        }
116|27e597|    }
117|b4687f|    
118|ab06c2|    @ViewBuilder
119|cbf44f|    private var aheadBehindRow: some View {
120|39fd6f|        if git.aheadCount > 0 || git.behindCount > 0 {
121|f49fd2|            HStack {
122|2621bf|                if git.aheadCount > 0 {
123|ce3eb0|                    Text("↑\(git.aheadCount) ahead")
124|4e165b|                        .foregroundColor(.orange)
125|4e2d32|                }
126|c053af|                if git.behindCount > 0 {
127|268f5f|                    Text("↓\(git.behindCount) behind")
128|4139e8|                        .foregroundColor(.blue)
129|4e2d32|                }
130|a7dc16|            }
131|5f3077|        }
132|27e597|    }
133|b4687f|    
134|ab06c2|    @ViewBuilder
135|a9d6a5|    private var changesContent: some View {
136|4387ed|        if git.stagedChanges.isEmpty && git.unstagedChanges.isEmpty {
137|da949f|            Text("Nothing to commit, working tree clean")
138|831eae|                .foregroundColor(.secondary)
139|b31999|        } else {
140|48cc9b|            stagedChangesView
141|ecbed9|            unstagedChangesView
142|5f3077|        }
143|27e597|    }
144|b4687f|    
145|ab06c2|    @ViewBuilder
146|689e6e|    private var stagedChangesView: some View {
147|f8757e|        if !git.stagedChanges.isEmpty {
148|3ba17e|            Text("Changes to be committed:")
149|d4f168|                .foregroundColor(.green)
150|c0ad53|            ForEach(git.stagedChanges) { entry in
151|a720d4|                Text("  \(entry.kind.rawValue): \(entry.path)")
152|ffb94f|                    .font(.system(.footnote, design: .monospaced))
153|a7dc16|            }
154|5f3077|        }
155|27e597|    }
156|b4687f|    
157|ab06c2|    @ViewBuilder
158|8b0e41|    private var unstagedChangesView: some View {
159|42e4ff|        if !git.unstagedChanges.isEmpty {
160|d7144a|            Text("Changes not staged for commit:")
161|efc1de|                .foregroundColor(.red)
162|74e905|            ForEach(git.unstagedChanges) { entry in
163|a720d4|                Text("  \(entry.kind.rawValue): \(entry.path)")
164|ffb94f|                    .font(.system(.footnote, design: .monospaced))
165|a7dc16|            }
166|5f3077|        }
167|27e597|    }
168|b4687f|    
169|44c6a3|    // MARK: - Stash Section
170|b4687f|    
171|ab06c2|    @ViewBuilder
172|b9b959|    private var stashSection: some View {
173|98d0f7|        VStack(alignment: .leading, spacing: 8) {
174|47f5d1|            Text("STASH")
175|916793|                .font(.caption)
176|4e212a|                .foregroundStyle(.secondary)
177|adc83b|
178|547b32|            stashInputRow
179|47b10c|            stashListView
180|5f3077|        }
181|215d84|        .padding(.horizontal)
182|27e597|    }
183|b4687f|    
184|ab06c2|    @ViewBuilder
185|1d3d73|    private var stashInputRow: some View {
186|5a4332|        HStack(spacing: 10) {
187|d1de71|            TextField("Message (optional)", text: $stashMessage)
188|9e985f|                .textFieldStyle(.roundedBorder)
189|adc83b|
190|87c1fc|            Button("Save") {
191|0f0930|                Task {
192|2e0daa|                    try? await git.stashPush(message: stashMessage.isEmpty ? nil : stashMessage)
193|8ffc20|                    await MainActor.run { stashMessage = "" }
194|4e2d32|                }
195|a7dc16|            }
196|fe3986|            .buttonStyle(.bordered)
197|ac5bfc|            .disabled(git.isLoading || !hasUncommittedChanges)
198|5f3077|        }
199|27e597|    }
200|b4687f|    
201|ab06c2|    @ViewBuilder
202|60f5b6|    private var stashListView: some View {
203|c5ddd1|        if git.stashes.isEmpty {
204|0b1090|            emptyStashView
205|b31999|        } else {
206|7de0ac|            stashListContent
207|5f3077|        }
208|27e597|    }
209|b4687f|    
210|ab06c2|    @ViewBuilder
211|d70468|    private var emptyStashView: some View {
212|161aca|        Text("No stashes")
213|628ce9|            .font(.footnote)
214|c1fa8a|            .foregroundStyle(.secondary)
215|6572f7|            .frame(maxWidth: .infinity, alignment: .leading)
216|a46278|            .padding(10)
217|508ae7|            .background(Color(UIColor.secondarySystemBackground))
218|e5fd5c|            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
219|27e597|    }
220|b4687f|    
221|ab06c2|    @ViewBuilder
222|153015|    private var stashListContent: some View {
223|5f41cb|        List {
224|924d26|            ForEach(git.stashes) { stash in
225|ac1ee4|                StashRowView(stash: stash, git: git)
226|a7dc16|            }
227|5f3077|        }
228|a4fe26|        .listStyle(.plain)
229|314c72|        .frame(maxHeight: 220)
230|27e597|    }
231|b31277|}
232|adc83b|
233|bb2b69|// MARK: - Stash Row View
234|adc83b|
235|5636ba|struct StashRowView: View {
236|41e9e3|    let stash: GitStashEntry
237|f5d2e5|    @ObservedObject var git: GitManager
238|b4687f|    
239|504e43|    var body: some View {
240|5a4332|        HStack(spacing: 10) {
241|e92c9e|            VStack(alignment: .leading, spacing: 2) {
242|352cf7|                Text("stash@{\(stash.index)}")
243|0d1ec3|                    .font(.system(.caption, design: .monospaced))
244|480d66|                    .foregroundStyle(.secondary)
245|dbe97c|                Text(stash.message)
246|e7cbc8|                    .font(.footnote)
247|e81625|                    .lineLimit(2)
248|a7dc16|            }
249|adc83b|
250|1e6289|            Spacer()
251|adc83b|
252|0a2ed6|            Button("Pop") {
253|a7975d|                Task { try? await git.stashPop(index: stash.index) }
254|a7dc16|            }
255|fe3986|            .buttonStyle(.bordered)
256|644732|            .disabled(git.isLoading)
257|adc83b|
258|2d8ebb|            Button("Drop") {
259|6b3b6f|                Task { try? await git.stashDrop(index: stash.index) }
260|a7dc16|            }
261|fe3986|            .buttonStyle(.bordered)
262|c380ad|            .tint(.red)
263|644732|            .disabled(git.isLoading)
264|5f3077|        }
265|60e15e|        .padding(.vertical, 4)
266|27e597|    }
267|b31277|}
268|adc83b|
269|0eca73|#Preview {
270|f27ac6|    GitQuickActionsView()
271|b31277|}
272|adc83b|


Now I have a complete picture. Let me provide my report.

>>>REPORT
# Git Integration Analysis for VSCodeiPadOS

## 1. Does Branch Switching Actually Work?
**NO, branch switching does NOT work.**

In `GitManager.swift` (line 315-317):
```swift
func checkout(branch: String) async throws {
    throw GitManagerError.sshNotConnected
}
```

The `checkout` function **always throws** `.sshNotConnected`. It is completely unimplemented.

Similarly, all branch management operations just throw:
- `createBranch` (lines 319-321) → throws `.sshNotConnected`
- `deleteBranch` (lines 323-325) → throws `.sshNotConnected`

## 2. Is There Real Git Integration or Is It Mocked/Fake?

**PARTIAL REAL INTEGRATION** - The codebase has genuine git parsing but incomplete operations.

### Real Implementation (NativeGit folder):

**NativeGitReader.swift** (805 lines) - Parses `.git` directory directly:
- Reads `HEAD` file for current branch (lines 50-71)
- Lists branches from `refs/heads/` and `refs/remotes/`
- Parses git index file (staging area)
- Decompresses and reads loose git objects (zlib)
- Parses commits, trees, blobs
- Computes file status by comparing working dir vs index vs HEAD

**NativeGitWriter.swift** (616 lines) - Creates real commits:
- Stages files by updating git index
- Unstages files
- Creates commits (writes tree and commit objects, updates refs)

### Mocked/Stub Service:

**GitService.swift** (lines 9-14) contains comments admitting it's fake:
```swift
/// NOTE: This project does not yet have a real git backend (libgit2 / shell).
/// This service exists to wire FEAT-076/077 UI and provide a single shared state
```
Has hardcoded branches: `["main", "develop", "feature/ui-updates"]`

## 3. Why Would It Always Show "main"?

Multiple reasons:

1. **Default initialization** - `GitManager.swift` line 141:
   ```swift
   @Published var currentBranch: String = "main"
   ```

2. **clearRepository() resets to "main"** - line 184:
   ```swift
   currentBranch = "main"
   ```

3. **No workspace set** - If `setWorkingDirectory()` is never called with a valid git repository URL, the NativeGitReader is never initialized and the branch stays "main"

4. **Refresh does work IF properly initialized** - line 208:
   ```swift
   currentBranch = reader.currentBranch() ?? "HEAD"
   ```

## Git Functionality Status

### ✅ EXISTS & WORKS (via NativeGit):
| Feature | Location |
|---------|----------|
| Read current branch | NativeGitReader.currentBranch() |
| List local branches | NativeGitReader.localBranches() |
| List remote branches | NativeGitReader.remoteBranches() |
| File status detection | NativeGitReader.status() |
| Read recent commits | NativeGitReader.recentCommits() |
| Stage file | NativeGitWriter.stageFile() |
| Stage all | NativeGitWriter.stageAll() |
| Unstage file | NativeGitWriter.unstageFile() |
| Create commit | NativeGitWriter.commit() |
| Build diffs | GitManager.diffWorkingCopyToHEAD() |

### ❌ MISSING (throws `.sshNotConnected`):
| Feature | GitManager.swift line |
|---------|----------------------|
| checkout (switch branch) | 315-317 |
| createBranch | 319-321 |
| deleteBranch | 323-325 |
| pull | 327-329 |
| push | 331-333 |
| stashPush | 335-337 |
| stashPop | 339-341 |
| stashDrop | 343-345 |
| discard | 347-349 |
| discardAll | 351-353 |
| discardChanges | 355-357 |
| fetch | 359-361 |

### Exists But Not Wired Up:
**SSHGitClient.swift** (452 lines) - Full SSH git client implementation that could run git commands on remote servers. Has implementations for all operations (checkout, push, pull, etc.) but is not connected to GitManager.

## Root Cause Summary

The app shows "main" because:
1. Default value is "main"
2. Branch switching is completely stubbed out (throws error)
3. The native git reader CAN read the real branch, but only if a workspace with a .git folder is properly loaded
4. Network operations (push/pull/fetch) require SSH which isn't connected

To fix branch switching, either:
1. Wire up SSHGitClient for remote operations
2. Implement pure-native checkout by updating `.git/HEAD` and restoring files from tree (complex)
>>>END
