# Agent: audit-git-terminal-debug
**Status:** done
**Tokens:** 5,279
**Cost:** $0.0000
**Time:** 2026-02-09T22:20:45.961Z

## Task
Audit Git, Terminal, Debug. Read GitManager.swift, GitView.swift, TerminalView.swift, DebugView.swift, DebugManager.swift. Check if operations are real or mock. Report exactly what's WORKING vs STUB vs MISSING for each.

## Response
I'll audit the Git, Terminal, and Debug functionality by reading each specified file. Let me start:

>>>TOOL read_file
{"path": "vscode-ipados/Managers/GitManager.swift"}
>>>END

Now let me read GitView.swift:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/GitView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 1-505 of 505)
────────────────────────────────────────
1: import SwiftUI
2: 
3: // MARK: - Git View (Source Control Panel)
4: 
5: struct GitView: View {
6:     @ObservedObject private var gitManager = GitManager.shared
7:     @EnvironmentObject var editorCore: EditorCore
8:     @State private var commitMessage = ""
9:     @State private var selectedEntry: GitStatusEntry?
10:     @State private var showBranchPicker = false
11:     
12:     var body: some View {
13:         VStack(alignment: .leading, spacing: 0) {
14:             // Header
15:             HStack {
16:                 Text("SOURCE CONTROL")
17:                     .font(.system(size: 11, weight: .semibold))
18:                     .foregroundColor(.secondary)
19:                 Spacer()
20:                 
21:                 if gitManager.isLoading {
22:                     ProgressView()
23:                         .scaleEffect(0.6)
24:                 }
25:                 
26:                 Button(action: refreshGit) {
27:                     Image(systemName: "arrow.clockwise")
28:                         .font(.system(size: 12))
29:                 }
30:                 .buttonStyle(.plain)
31:                 .disabled(gitManager.isLoading)
32:             }
33:             .padding(.horizontal, 12)
34:             .padding(.vertical, 8)
35:             
36:             Divider()
37:             
38:             // Branch selector
39:             HStack {
40:                 Image(systemName: "arrow.triangle.branch")
41:                     .font(.system(size: 11))
42:                     .foregroundColor(.secondary)
43:                 
44:                 Button(action: { showBranchPicker = true }) {
45:                     HStack(spacing: 4) {
46:                         Text(gitManager.currentBranch)
47:                             .font(.system(size: 12, weight: .medium))
48:                         Image(systemName: "chevron.down")
49:                             .font(.system(size: 9))
50:                     }
51:                 }
52:                 .buttonStyle(.plain)
53:                 
54:                 Spacer()
55:                 
56:                 // Sync status
57:                 if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
58:                     HStack(spacing: 4) {
59:                         if gitManager.aheadCount > 0 {
60:                             HStack(spacing: 2) {
61:                                 Image(systemName: "arrow.up")
62:                                 Text("\(gitManager.aheadCount)")
63:                             }
64:                             .font(.system(size: 10))
65:                             .foregroundColor(.orange)
66:                         }
67:                         if gitManager.behindCount > 0 {
68:                             HStack(spacing: 2) {
69:                                 Image(systemName: "arrow.down")
70:                                 Text("\(gitManager.behindCount)")
71:                             }
72:                             .font(.system(size: 10))
73:                             .foregroundColor(.blue)
74:                         }
75:                     }
76:                 }
77:             }
78:             .padding(.horizontal, 12)
79:             .padding(.vertical, 6)
80:             .background(Color(UIColor.secondarySystemBackground))
81:             
82:             Divider()
83:             
84:             // Commit input
85:             VStack(spacing: 8) {
86:                 TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
87:                     .textFieldStyle(.roundedBorder)
88:                     .font(.system(size: 12))
89:                 
90:                 HStack(spacing: 8) {
91:                     Button(action: commitChanges) {
92:                         HStack {
93:                             Image(systemName: "checkmark")
94:                             Text("Commit")
95:                         }
96:                         .frame(maxWidth: .infinity)
97:                         .padding(.vertical, 6)
98:                         .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
99:                         .foregroundColor(.white)
100:                         .cornerRadius(6)
101:                     }
102:                     .disabled(!canCommit)
103:                     .buttonStyle(.plain)
104:                     
105:                     Menu {
106:                         Button(action: { Task { try? await gitManager.stageAll() } }) {
107:                             Label("Stage All", systemImage: "plus.circle")
108:                         }
109:                         Button(action: commitAndPush) {
110:                             Label("Commit & Push", systemImage: "arrow.up.circle")
111:                         }
112:                     } label: {
113:                         Image(systemName: "ellipsis.circle")
114:                             .font(.system(size: 16))
115:                     }
116:                     .buttonStyle(.plain)
117:                 }
118:             }
119:             .padding(12)
120:             
121:             Divider()
122:             
123:             // Changes list
124:             ScrollView {
125:                 VStack(alignment: .leading, spacing: 4) {
126:                     // Staged changes
127:                     if !gitManager.stagedChanges.isEmpty {
128:                         sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
129:                         ForEach(gitManager.stagedChanges) { entry in
130:                             changeRow(entry, isStaged: true)
131:                         }
132:                     }
133:                     
134:                     // Unstaged changes
135:                     if !gitManager.unstagedChanges.isEmpty {
136:                         sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
137:                         ForEach(gitManager.unstagedChanges) { entry in
138:                             changeRow(entry, isStaged: false)
139:                         }
140:                     }
141:                     
142:                     // No changes
143:                     if gitManager.stagedChanges.isEmpty && gitManager.unstagedChanges.isEmpty {
144:                         VStack(spacing: 8) {
145:                             Image(systemName: "checkmark.circle")
146:                                 .font(.system(size: 24))
147:                                 .foregroundColor(.green)
148:                             Text("No changes")
149:                                 .font(.system(size: 12))
150:                                 .foregroundColor(.secondary)
151:                         }
152:                         .frame(maxWidth: .infinity)
153:                         .padding(.vertical, 20)
154:                     }
155:                     
156:                     // Recent commits
157:                     if !gitManager.recentCommits.isEmpty {
158:                         Divider()
159:                             .padding(.vertical, 8)
160:                         
161:                         sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
162:                         ForEach(gitManager.recentCommits.prefix(5)) { commit in
163:                             commitRow(commit)
164:                         }
165:                     }
166:                 }
167:                 .padding(.horizontal, 8)
168:                 .padding(.bottom, 8)
169:             }
170:             
171:             Spacer(minLength: 0)
172:             
173:             // Error display
174:             if let error = gitManager.error {
175:                 HStack {
176:                     Image(systemName: "exclamationmark.triangle")
177:                         .foregroundColor(.red)
178:                     Text(error)
179:                         .font(.system(size: 10))
180:                         .foregroundColor(.red)
181:                         .lineLimit(2)
182:                 }
183:                 .padding(8)
184:                 .background(Color.red.opacity(0.1))
185:                 .cornerRadius(6)
186:                 .padding(.horizontal, 12)
187:             }
188:             
189:             Divider()
190:             
191:             // Bottom actions
192:             HStack(spacing: 12) {
193:                 Button(action: pullChanges) {
194:                     HStack(spacing: 4) {
195:                         Image(systemName: "arrow.down.circle")
196:                         Text("Pull")
197:                         if gitManager.behindCount > 0 {
198:                             Text("(\(gitManager.behindCount))")
199:                                 .foregroundColor(.blue)
200:                         }
201:                     }
202:                 }
203:                 .font(.system(size: 11))
204:                 .buttonStyle(.plain)
205:                 
206:                 Button(action: pushChanges) {
207:                     HStack(spacing: 4) {
208:                         Image(systemName: "arrow.up.circle")
209:                         Text("Push")
210:                         if gitManager.aheadCount > 0 {
211:                             Text("(\(gitManager.aheadCount))")
212:                                 .foregroundColor(.orange)
213:                         }
214:                     }
215:                 }
216:                 .font(.system(size: 11))
217:                 .buttonStyle(.plain)
218:                 
219:                 Button(action: fetchChanges) {
220:                     Image(systemName: "arrow.triangle.2.circlepath")
221:                 }
222:                 .font(.system(size: 11))
223:                 .buttonStyle(.plain)
224:                 
225:                 Spacer()
226:             }
227:             .padding(12)
228:         }
229:         .background(Color(UIColor.systemBackground))
230:         .sheet(isPresented: $showBranchPicker) {
231:             BranchPickerSheet(gitManager: gitManager)
232:         }
233:     }
234:     
235:     private var canCommit: Bool {
236:         !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
237:     }
238:     
239:     private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
240:         HStack {
241:             Text(title)
242:                 .font(.system(size: 11, weight: .semibold))
243:                 .foregroundColor(.secondary)
244:             Text("\(count)")
245:                 .font(.system(size: 10))
246:                 .foregroundColor(color)
247:                 .padding(.horizontal, 6)
248:                 .padding(.vertical, 2)
249:                 .background(color.opacity(0.2))
250:                 .cornerRadius(8)
251:             Spacer()
252:         }
253:         .padding(.vertical, 4)
254:     }
255:     
256:     private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
257:         HStack(spacing: 8) {
258:             // Status indicator
259:             Text(entry.kind.rawValue.prefix(1).uppercased())
260:                 .font(.system(size: 10, weight: .bold, design: .monospaced))
261:                 .foregroundColor(entry.kind.color)
262:                 .frame(width: 16)
263:             
264:             // File name
265:             Text(entry.path.components(separatedBy: "/").last ?? entry.path)
266:                 .font(.system(size: 12))
267:                 .lineLimit(1)
268:             
269:             Spacer()
270:             
271:             // Stage/unstage button
272:             if isStaged {
273:                 Button(action: { unstageFile(entry.path) }) {
274:                     Image(systemName: "minus")
275:                         .font(.system(size: 10))
276:                         .foregroundColor(.red)
277:                 }
278:                 .buttonStyle(.plain)
279:             } else {
280:                 Button(action: { stageFile(entry.path) }) {
281:                     Image(systemName: "plus")
282:                         .font(.system(size: 10))
283:                         .foregroundColor(.green)
284:                 }
285:                 .buttonStyle(.plain)
286:             }
287:         }
288:         .padding(.vertical, 4)
289:         .padding(.horizontal, 8)
290:         .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
291:         .cornerRadius(4)
292:         .onTapGesture {
293:             selectedEntry = entry
294:         }
295:         .contextMenu {
296:             if isStaged {
297:                 Button(action: { unstageFile(entry.path) }) {
298:                     Label("Unstage Changes", systemImage: "minus.circle")
299:                 }
300:             } else {
301:                 Button(action: { stageFile(entry.path) }) {
302:                     Label("Stage Changes", systemImage: "plus.circle")
303:                 }
304:             }
305:             
306:             if !isStaged && entry.kind != .untracked {
307:                 Button(role: .destructive, action: {
308:                     Task { try? await gitManager.discardChanges(file: entry.path) }
309:                 }) {
310:                     Label("Discard Changes", systemImage: "trash")
311:                 }
312:             }
313:             
314:             Divider()
315:             
316:             Button(action: {
317:                 let url = URL(fileURLWithPath: entry.path)
318:                 editorCore.openFile(from: url)
319:             }) {
320:                 Label("Open File", systemImage: "doc.text")
321:             }
322:             
323:             Button(action: {
324:                 UIPasteboard.general.string = entry.path
325:             }) {
326:                 Label("Copy Path", systemImage: "doc.on.doc")
327:             }
328:         }
329:     }
330:     
331:     private func commitRow(_ commit: GitCommit) -> some View {
332:         VStack(alignment: .leading, spacing: 2) {
333:             HStack {
334:                 Text(commit.shortSHA)
335:                     .font(.system(size: 10, design: .monospaced))
336:                     .foregroundColor(.accentColor)
337:                 
338:                 Text(commit.message)
339:                     .font(.system(size: 11))
340:                     .lineLimit(1)
341:             }
342:             
343:             HStack {
344:                 Text(commit.author)
345:                     .font(.system(size: 10))
346:                     .foregroundColor(.secondary)
347:                 
348:                 Text("•")
349:                     .foregroundColor(.secondary)
350:                 
351:                 Text(commit.date, style: .relative)
352:                     .font(.system(size: 10))
353:                     .foregroundColor(.secondary)
354:             }
355:         }
356:         .padding(.vertical, 4)
357:         .padding(.horizontal, 8)
358:     }
359:     
360:     // MARK: - Actions
361:     
362:     private func refreshGit() {
363:         Task { await gitManager.refresh() }
364:     }
365:     
366:     private func stageFile(_ path: String) {
367:         Task { try? await gitManager.stage(file: path) }
368:     }
369:     
370:     private func unstageFile(_ path: String) {
371:         Task { try? await gitManager.unstage(file: path) }
372:     }
373:     
374:     private func commitChanges() {
375:         guard canCommit else { return }
376:         Task {
377:             try? await gitManager.commit(message: commitMessage)
378:             await MainActor.run { commitMessage = "" }
379:         }
380:     }
381:     
382:     private func commitAndPush() {
383:         guard canCommit else { return }
384:         Task {
385:             try? await gitManager.commit(message: commitMessage)
386:             await MainActor.run { commitMessage = "" }
387:             try? await gitManager.push()
388:         }
389:     }
390:     
391:     private func pullChanges() {
392:         Task { try? await gitManager.pull() }
393:     }
394:     
395:     private func pushChanges() {
396:         Task { try? await gitManager.push() }
397:     }
398:     
399:     private func fetchChanges() {
400:         Task { try? await gitManager.fetch() }
401:     }
402: }
403: 
404: // MARK: - Branch Picker Sheet
405: 
406: struct BranchPickerSheet: View {
407:     @ObservedObject var gitManager: GitManager
408:     @Environment(\.dismiss) private var dismiss
409:     @State private var newBranchName = ""
410:     @State private var showCreateBranch = false
411:     
412:     var localBranches: [GitBranch] {
413:         gitManager.branches.filter { !$0.isRemote }
414:     }
415:     
416:     var remoteBranches: [GitBranch] {
417:         gitManager.branches.filter { $0.isRemote }
418:     }
419:     
420:     var body: some View {
421:         NavigationView {
422:             List {
423:                 // Create new branch
424:                 Section {
425:                     if showCreateBranch {
426:                         HStack {
427:                             TextField("New branch name", text: $newBranchName)
428:                                 .textFieldStyle(.roundedBorder)
429:                             
430:                             Button("Create") {
431:                                 createBranch()
432:                             }
433:                             .disabled(newBranchName.isEmpty)
434:                         }
435:                     } else {
436:                         Button(action: { showCreateBranch = true }) {
437:                             Label("Create New Branch", systemImage: "plus.circle")
438:                         }
439:                     }
440:                 }
441:                 
442:                 // Local branches
443:                 Section("Local Branches") {
444:                     ForEach(localBranches) { branch in
445:                         Button(action: { checkout(branch.name) }) {
446:                             HStack {
447:                                 if branch.isCurrent {
448:                                     Image(systemName: "checkmark")
449:                                         .foregroundColor(.accentColor)
450:                                 }
451:                                 Text(branch.name)
452:                                     .foregroundColor(branch.isCurrent ? .accentColor : .primary)
453:                                 Spacer()
454:                             }
455:                         }
456:                         .buttonStyle(.plain)
457:                     }
458:                 }
459:                 
460:                 // Remote branches
461:                 if !remoteBranches.isEmpty {
462:                     Section("Remote Branches") {
463:                         ForEach(remoteBranches) { branch in
464:                             Button(action: { checkout(branch.name) }) {
465:                                 HStack {
466:                                     Text(branch.name)
467:                                         .foregroundColor(.secondary)
468:                                     Spacer()
469:                                 }
470:                             }
471:                             .buttonStyle(.plain)
472:                         }
473:                     }
474:                 }
475:             }
476:             .navigationTitle("Branches")
477:             .navigationBarTitleDisplayMode(.inline)
478:             .toolbar {
479:                 ToolbarItem(placement: .navigationBarTrailing) {
480:                     Button("Done") { dismiss() }
481:                 }
482:             }
483:         }
484:     }
485:     
486:     private func checkout(_ branch: String) {
487:         Task {
488:             try? await gitManager.checkout(branch: branch)
489:             await MainActor.run { dismiss() }
490:         }
491:     }
492:     
493:     private func createBranch() {
494:         guard !newBranchName.isEmpty else { return }
495:         Task {
496:             try? await gitManager.createBranch(name: newBranchName)
497:             await MainActor.run {
498:                 newBranchName = ""
499:                 showCreateBranch = false
500:                 dismiss()
501:             }
502:         }
503:     }
504: }
505: 


Now let me read TerminalView.swift:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift (lines 1-981 of 981)
────────────────────────────────────────
1: import SwiftUI
2: import SwiftUI
3: import UIKit
4: import Network
5: import Foundation
6: 
7: // MARK: - Terminal View (Main Container)
8: 
9: struct TerminalView: View {
10:     @StateObject private var workspace = TerminalWorkspace.shared
11:     @ObservedObject private var themeManager = ThemeManager.shared
12:     @State private var showConnectionSheet = false
13: 
14:     var body: some View {
15:         VStack(spacing: 0) {
16:             // MARK: Top Toolbar
17:             HStack(spacing: 10) {
18:                 Text("TERMINAL")
19:                     .font(.caption)
20:                     .fontWeight(.bold)
21:                     .foregroundColor(themeManager.currentTheme.tabActiveForeground)
22:                     .padding(.horizontal, 8)
23: 
24:                 Spacer()
25: 
26:                 HStack(spacing: 12) {
27:                     Button(action: { workspace.addTab() }) {
28:                         Image(systemName: "plus")
29:                     }
30:                     .help("New Terminal")
31: 
32:                     Button(action: { workspace.toggleSplitActiveTab() }) {
33:                         Image(systemName: "square.split.2x1")
34:                     }
35:                     .disabled(workspace.tabs.isEmpty)
36:                     .help("Split Terminal")
37: 
38:                     Button(action: copyActiveTerminalToClipboard) {
39:                         Image(systemName: "doc.on.doc")
40:                     }
41:                     .disabled(workspace.activePane == nil)
42:                     .help("Copy Terminal Output")
43: 
44:                     Button(action: pasteClipboardToActiveTerminal) {
45:                         Image(systemName: "doc.on.clipboard")
46:                     }
47:                     .disabled(workspace.activePane == nil)
48:                     .help("Paste")
49: 
50:                     Button(action: { workspace.activePane?.clear() }) {
51:                         Image(systemName: "trash")
52:                     }
53:                     .disabled(workspace.activePane == nil)
54:                     .help("Clear Terminal")
55: 
56:                     Button(action: { workspace.killActive() }) {
57:                         Image(systemName: "xmark")
58:                     }
59:                     .disabled(workspace.activePane == nil)
60:                     .help("Kill Terminal")
61: 
62:                     Button(action: { showConnectionSheet = true }) {
63:                         Image(systemName: "network")
64:                     }
65:                     .disabled(workspace.activePane == nil)
66:                     .help("SSH Connect")
67:                 }
68:                 .font(.caption)
69:                 .foregroundColor(themeManager.currentTheme.editorForeground)
70:             }
71:             .padding(8)
72:             .background(themeManager.currentTheme.editorBackground)
73:             .overlay(
74:                 Rectangle()
75:                     .frame(height: 1)
76:                     .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.2)),
77:                 alignment: .bottom
78:             )
79: 
80:             // MARK: Tab Strip
81:             ScrollView(.horizontal, showsIndicators: false) {
82:                 HStack(spacing: 6) {
83:                     ForEach(workspace.tabs) { tab in
84:                         if let primary = tab.panes.first {
85:                             TerminalTabButtonView(
86:                                 terminal: primary,
87:                                 isActive: workspace.activeTabId == tab.id,
88:                                 onSelect: { workspace.activeTabId = tab.id },
89:                                 onClose: { workspace.closeTab(id: tab.id) },
90:                                 onRename: { workspace.activeTabId = tab.id },
91:                                 onSplit: { workspace.activeTabId = tab.id; workspace.toggleSplitActiveTab() }
92:                             )
93:                         }
94:                     }
95: 
96:                     Button(action: { workspace.addTab() }) {
97:                         Image(systemName: "plus")
98:                             .font(.caption)
99:                             .padding(.horizontal, 10)
100:                             .padding(.vertical, 6)
101:                             .background(
102:                                 RoundedRectangle(cornerRadius: 6)
103:                                     .fill(themeManager.currentTheme.editorForeground.opacity(0.08))
104:                             )
105:                     }
106:                     .buttonStyle(.plain)
107:                     .help("New Terminal")
108:                 }
109:                 .padding(.horizontal, 8)
110:                 .padding(.vertical, 6)
111:             }
112:             .background(themeManager.currentTheme.editorBackground)
113:             .overlay(
114:                 Rectangle()
115:                     .frame(height: 1)
116:                     .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.12)),
117:                 alignment: .bottom
118:             )
119: 
120:             // MARK: Terminal Content
121:             Group {
122:                 if let tab = workspace.activeTab {
123:                     if tab.panes.count <= 1, let terminal = tab.panes.first {
124:                         SingleTerminalView(
125:                             terminal: terminal,
126:                             isActive: true,
127:                             onActivate: { workspace.setActivePane(terminal.id, in: tab.id) },
128:                             onKill: { workspace.killActive() }
129:                         )
130:                     } else {
131:                         HStack(spacing: 0) {
132:                             ForEach(tab.panes) { pane in
133:                                 SingleTerminalView(
134:                                     terminal: pane,
135:                                     isActive: tab.activePaneId == pane.id,
136:                                     onActivate: { workspace.setActivePane(pane.id, in: tab.id) },
137:                                     onKill: { workspace.killActive() }
138:                                 )
139:                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
140: 
141:                                 if pane.id != tab.panes.last?.id {
142:                                     Divider()
143:                                         .background(themeManager.currentTheme.editorForeground.opacity(0.2))
144:                                 }
145:                             }
146:                         }
147:                     }
148:                 } else {
149:                     VStack(spacing: 12) {
150:                         Text("No Open Terminals")
151:                             .foregroundColor(themeManager.currentTheme.editorForeground.opacity(0.5))
152:                         Button("Create New Terminal") {
153:                             workspace.addTab()
154:                         }
155:                     }
156:                     .frame(maxWidth: .infinity, maxHeight: .infinity)
157:                     .background(themeManager.currentTheme.editorBackground)
158:                 }
159:             }
160:         }
161:         .background(themeManager.currentTheme.editorBackground)
162:         .sheet(isPresented: $showConnectionSheet) {
163:             if let active = workspace.activePane {
164:                 SSHConnectionView(terminal: active, isPresented: $showConnectionSheet)
165:             }
166:         }
167:     }
168: 
169:     private func copyActiveTerminalToClipboard() {
170:         guard let terminal = workspace.activePane else { return }
171:         let text = terminal.output.map(\.text).joined(separator: "\n")
172:         UIPasteboard.general.string = text
173:     }
174: 
175:     private func pasteClipboardToActiveTerminal() {
176:         guard let terminal = workspace.activePane else { return }
177:         guard let clip = UIPasteboard.general.string, !clip.isEmpty else { return }
178:         terminal.draftCommand.append(contentsOf: clip)
179:     }
180: }
181: 
182: struct TerminalTabButtonView: View {
183:     @ObservedObject var terminal: TerminalManager
184:     var isActive: Bool
185:     var onSelect: () -> Void
186:     var onClose: () -> Void
187:     var onRename: () -> Void
188:     var onSplit: () -> Void
189: 
190:     @ObservedObject private var themeManager = ThemeManager.shared
191:     @State private var showRenameAlert = false
192: 
193:     var body: some View {
194:         Button(action: onSelect) {
195:             HStack(spacing: 6) {
196:                 Image(systemName: "terminal")
197:                     .font(.caption2)
198: 
199:                 Text(terminal.title.isEmpty ? "Terminal" : terminal.title)
200:                     .font(.caption)
201:                     .lineLimit(1)
202:                     .frame(maxWidth: 200, alignment: .leading)
203: 
204:                 Button(action: onClose) {
205:                     Image(systemName: "xmark")
206:                         .font(.caption2)
207:                 }
208:                 .buttonStyle(.plain)
209:             }
210:             .padding(.horizontal, 10)
211:             .padding(.vertical, 6)
212:             .background(
213:                 RoundedRectangle(cornerRadius: 6)
214:                     .fill(isActive ? themeManager.currentTheme.editorForeground.opacity(0.15) : themeManager.currentTheme.editorForeground.opacity(0.08))
215:             )
216:             .overlay(
217:                 RoundedRectangle(cornerRadius: 6)
218:                     .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.5) : .clear, lineWidth: 1)
219:             )
220:         }
221:         .buttonStyle(.plain)
222:         .contextMenu {
223:             Button(action: {
224:                 showRenameAlert = true
225:             }) {
226:                 Label("Rename Terminal", systemImage: "pencil")
227:             }
228: 
229:             Button(action: {
230:                 onSplit()
231:             }) {
232:                 Label("Split Terminal", systemImage: "square.split.2x1")
233:             }
234: 
235:             Divider()
236: 
237:             Button(action: {
238:                 onClose()
239:             }) {
240:                 Label("Close Terminal", systemImage: "xmark")
241:                     .foregroundColor(.red)
242:             }
243:         }
244:         .alert("Rename Terminal", isPresented: $showRenameAlert) {
245:             TextField("Terminal Name", text: $terminal.title)
246:             Button("OK", role: .cancel) { }
247:         }
248:     }
249: }
250: 
251: // MARK: - Single Terminal View
252: 
253: struct SingleTerminalView: View {
254:     @ObservedObject var terminal: TerminalManager
255:     var isActive: Bool
256:     var onActivate: () -> Void
257:     var onKill: () -> Void
258: 
259:     @ObservedObject private var themeManager = ThemeManager.shared
260:     @FocusState private var isInputFocused: Bool
261: 
262:     var body: some View {
263:         VStack(spacing: 0) {
264:             // Terminal Output
265:             ScrollViewReader { proxy in
266:                 ScrollView {
267:                     VStack(alignment: .leading, spacing: 2) {
268:                         ForEach(terminal.output) { line in
269:                             TerminalLineView(line: line)
270:                                 .id(line.id)
271:                         }
272:                     }
273:                     .frame(maxWidth: .infinity, alignment: .leading)
274:                     .padding(8)
275:                 }
276:                 .onChange(of: terminal.output.count) { _ in
277:                     withAnimation(.easeOut(duration: 0.1)) {
278:                         proxy.scrollTo(terminal.output.last?.id, anchor: .bottom)
279:                     }
280:                 }
281:             }
282:             .contentShape(Rectangle())
283:             .contextMenu {
284:                 Button(action: {
285:                     let text = terminal.output.map(\.text).joined(separator: "\n")
286:                     UIPasteboard.general.string = text
287:                 }) {
288:                     Label("Copy", systemImage: "doc.on.doc")
289:                 }
290: 
291:                 Button(action: {
292:                     if let clip = UIPasteboard.general.string, !clip.isEmpty {
293:                         terminal.draftCommand.append(contentsOf: clip)
294:                     }
295:                 }) {
296:                     Label("Paste", systemImage: "doc.on.clipboard")
297:                 }
298: 
299:                 Divider()
300: 
301:                 Button(action: {
302:                     terminal.clear()
303:                 }) {
304:                     Label("Clear Terminal", systemImage: "trash")
305:                 }
306: 
307:                 Divider()
308: 
309:                 Button(action: {
310:                     onKill()
311:                 }) {
312:                     Label("Kill Terminal", systemImage: "xmark.circle")
313:                         .foregroundColor(.red)
314:                 }
315:             }
316:             .onTapGesture {
317:                 onActivate()
318:                 isInputFocused = true
319:             }
320: 
321:             // Input Area
322:             HStack(spacing: 0) {
323:                 Text(terminal.promptString)
324:                     .font(.system(.body, design: .monospaced))
325:                     .foregroundColor(themeManager.currentTheme.type)
326:                     .padding(.leading, 8)
327: 
328:                 TextField("", text: $terminal.draftCommand)
329:                     .font(.system(.body, design: .monospaced))
330:                     .foregroundColor(themeManager.currentTheme.editorForeground)
331:                     .accentColor(themeManager.currentTheme.cursor)
332:                     .autocapitalization(.none)
333:                     .disableAutocorrection(true)
334:                     .focused($isInputFocused)
335:                     .onSubmit { executeCommand() }
336:                     .padding(8)
337:             }
338:             .background(themeManager.currentTheme.editorBackground)
339: 
340:             // Mobile Helper Bar (optional)
341:             if isInputFocused {
342:                 HStack(spacing: 12) {
343:                     Button("Tab") { terminal.sendTab() }
344:                     Button("Esc") { /* handle esc */ }
345:                     Button("Ctrl+C") { terminal.sendInterrupt() }
346:                         .foregroundColor(.red)
347:                     Spacer()
348:                     Button("ls") { terminal.draftCommand = "ls -la" }
349:                     Button("git status") { terminal.draftCommand = "git status" }
350:                 }
351:                 .font(.caption)
352:                 .padding(.horizontal)
353:                 .padding(.vertical, 6)
354:                 .background(themeManager.currentTheme.editorForeground.opacity(0.1))
355:             }
356:         }
357:         .background(themeManager.currentTheme.editorBackground)
358:         .overlay(
359:             RoundedRectangle(cornerRadius: 0)
360:                 .stroke(isActive ? themeManager.currentTheme.tabActiveForeground.opacity(0.35) : .clear, lineWidth: 1)
361:         )
362:         .onAppear {
363:             if isActive {
364:                 isInputFocused = true
365:             }
366:         }
367:     }
368: 
369:     private func executeCommand() {
370:         let command = terminal.draftCommand.trimmingCharacters(in: .whitespacesAndNewlines)
371:         guard !command.isEmpty else { return }
372:         terminal.executeCommand(command)
373:         terminal.draftCommand = ""
374:     }
375: }
376: 
377: struct TerminalLineView: View {
378:     let line: TerminalLine
379:     @ObservedObject private var themeManager = ThemeManager.shared
380:     
381:     var body: some View {
382:         if line.isANSI {
383:             ANSIText(line.text)
384:         } else {
385:             Text(line.text)
386:                 .font(.system(.body, design: .monospaced))
387:                 .foregroundColor(colorForType(line.type))
388:                 .textSelection(.enabled)
389:         }
390:     }
391:     
392:     func colorForType(_ type: LineType) -> Color {
393:         switch type {
394:         case .command: return themeManager.currentTheme.editorForeground
395:         case .output: return themeManager.currentTheme.editorForeground.opacity(0.9)
396:         case .error: return Color.red // Could use theme error color if available
397:         case .system: return themeManager.currentTheme.comment
398:         case .prompt: return themeManager.currentTheme.type
399:         }
400:     }
401: }
402: 
403: // MARK: - Terminal Workspace Manager
404: 
405: struct TerminalTab: Identifiable, Equatable {
406:     let id: UUID
407:     var panes: [TerminalManager]
408:     var activePaneId: UUID
409: 
410:     init(panes: [TerminalManager]) {
411:         self.id = UUID()
412:         self.panes = panes
413:         self.activePaneId = panes.first?.id ?? UUID()
414:     }
415: 
416:     var title: String {
417:         panes.first?.title ?? "Terminal"
418:     }
419: 
420:     static func == (lhs: TerminalTab, rhs: TerminalTab) -> Bool {
421:         lhs.id == rhs.id
422:     }
423: }
424: 
425: class TerminalWorkspace: ObservableObject {
426:     static let shared = TerminalWorkspace()
427: 
428:     @Published var tabs: [TerminalTab] = []
429:     @Published var activeTabId: UUID?
430: 
431:     var activeTabIndex: Int? {
432:         guard let id = activeTabId else { return nil }
433:         return tabs.firstIndex(where: { $0.id == id })
434:     }
435: 
436:     var activeTab: TerminalTab? {
437:         guard let idx = activeTabIndex else { return nil }
438:         return tabs[idx]
439:     }
440: 
441:     var activePane: TerminalManager? {
442:         guard let tab = activeTab else { return nil }
443:         return tab.panes.first(where: { $0.id == tab.activePaneId }) ?? tab.panes.first
444:     }
445: 
446:     init() {
447:         addTab() // start with one
448:     }
449: 
450:     func addTab() {
451:         let term = TerminalManager()
452:         term.title = "Terminal \(tabs.count + 1)"
453:         let tab = TerminalTab(panes: [term])
454:         tabs.append(tab)
455:         activeTabId = tab.id
456:     }
457: 
458:     func closeTab(id: UUID) {
459:         guard let idx = tabs.firstIndex(where: { $0.id == id }) else { return }
460:         for pane in tabs[idx].panes {
461:             pane.disconnect()
462:         }
463:         tabs.remove(at: idx)
464:         if activeTabId == id {
465:             activeTabId = tabs.last?.id
466:         }
467:     }
468: 
469:     func setActivePane(_ paneId: UUID, in tabId: UUID) {
470:         guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
471:         tabs[tabIndex].activePaneId = paneId
472:     }
473: 
474:     func toggleSplitActiveTab() {
475:         guard let tabId = activeTabId else { return }
476:         guard let idx = tabs.firstIndex(where: { $0.id == tabId }) else { return }
477: 
478:         if tabs[idx].panes.count <= 1 {
479:             // Split: add a second pane (max 2 panes for now)
480:             let newPane = TerminalManager()
481:             newPane.title = "Terminal \(tabs.count).2"
482:             tabs[idx].panes.append(newPane)
483:             tabs[idx].activePaneId = newPane.id
484:         } else {
485:             // Unsplit: remove all panes except the first
486:             let extraPanes = tabs[idx].panes.dropFirst()
487:             for pane in extraPanes {
488:                 pane.disconnect()
489:             }
490:             tabs[idx].panes = Array(tabs[idx].panes.prefix(1))
491:             tabs[idx].activePaneId = tabs[idx].panes.first?.id ?? tabs[idx].activePaneId
492:         }
493:     }
494: 
495:     func killActive() {
496:         guard let tabId = activeTabId else { return }
497:         guard let tabIndex = tabs.firstIndex(where: { $0.id == tabId }) else { return }
498: 
499:         let paneId = tabs[tabIndex].activePaneId
500:         if tabs[tabIndex].panes.count > 1 {
501:             // If split, kill the active pane only.
502:             if let paneIndex = tabs[tabIndex].panes.firstIndex(where: { $0.id == paneId }) {
503:                 tabs[tabIndex].panes[paneIndex].disconnect()
504:                 tabs[tabIndex].panes.remove(at: paneIndex)
505:             }
506:             tabs[tabIndex].activePaneId = tabs[tabIndex].panes.first?.id ?? tabs[tabIndex].activePaneId
507: 
508:             if tabs[tabIndex].panes.isEmpty {
509:                 closeTab(id: tabId)
510:             }
511:         } else {
512:             // If not split, kill the tab.
513:             closeTab(id: tabId)
514:         }
515:     }
516: }
517: 
518: // MARK: - Terminal Manager
519: 
520: class TerminalManager: ObservableObject, Identifiable {
521:     let id = UUID()
522:     @Published var title: String = "Terminal"
523:     
524:     @Published var output: [TerminalLine] = [
525:         TerminalLine(text: "VSCode iPadOS Terminal v2.0", type: .system),
526:         TerminalLine(text: "Type 'help' for commands or connect via SSH (SwiftNIO).", type: .system),
527:         TerminalLine(text: "", type: .output)
528:     ]
529:     @Published var isConnected = false
530:     @Published var isConnecting = false
531:     @Published var connectionStatus = "Not connected"
532:     @Published var promptString = "$ "
533:     @Published var draftCommand: String = ""
534:     
535:     private var sshManager: SSHManager?
536:     private var currentConfig: SSHConnectionConfig?
537:     private var commandHistory: [String] = []
538:     private var historyIndex = 0
539:     
540:     func clear() {
541:         output = []
542:     }
543:     
544:     func connect(to config: SSHConnectionConfig) {
545:         currentConfig = config
546:         isConnecting = true
547:         connectionStatus = "Connecting to \(config.host)..."
548:         title = "\(config.username)@\(config.host)"
549:         
550:         appendOutput("Connecting to \(config.username)@\(config.host):\(config.port)...", type: .system)
551:         appendOutput("Using SwiftNIO SSH (real SSH protocol)", type: .system)
552:         
553:         sshManager = SSHManager()
554:         sshManager?.delegate = self
555:         sshManager?.connect(config: config) { [weak self] result in
556:             switch result {
557:             case .success:
558:                 // Connection successful - delegate will handle UI update
559:                 SSHConnectionStore.shared.updateLastUsed(config)
560:             case .failure(let error):
561:                 self?.appendOutput("Connection failed: \(error.localizedDescription)", type: .error)
562:                 self?.isConnecting = false
563:                 self?.connectionStatus = "Connection failed"
564:             }
565:         }
566:     }
567:     
568:     // Legacy connect method for backward compatibility
569:     func connect(to connection: SSHConnection) {
570:         let authMethod: SSHConnectionConfig.SSHAuthMethod
571:         if let privateKey = connection.privateKey, !privateKey.isEmpty {
572:             authMethod = .privateKey(key: privateKey, passphrase: nil)
573:         } else {
574:             authMethod = .password(connection.password ?? "")
575:         }
576:         
577:         let config = SSHConnectionConfig(
578:             name: "\(connection.username)@\(connection.host)",
579:             host: connection.host,
580:             port: connection.port,
581:             username: connection.username,
582:             authMethod: authMethod
583:         )
584:         connect(to: config)
585:     }
586:     
587:     func disconnect() {
588:         sshManager?.disconnect()
589:         sshManager = nil
590:         isConnected = false
591:         isConnecting = false
592:         connectionStatus = "Disconnected"
593:         promptString = "$ "
594:         title = "Terminal (Disconnected)"
595:         appendOutput("Disconnected from server.", type: .system)
596:     }
597:     
598:     func executeCommand(_ command: String) {
599:         commandHistory.append(command)
600:         historyIndex = commandHistory.count
601:         
602:         if isConnected {
603:             // Don't echo command - server will echo it back
604:             sshManager?.send(command: command)
605:         } else {
606:             appendOutput(promptString + command, type: .command)
607:             processLocalCommand(command)
608:         }
609:     }
610:     
611:     func sendInterrupt() {
612:         if isConnected {
613:             sshManager?.sendInterrupt()
614:         }
615:         appendOutput("^C", type: .system)
616:     }
617:     
618:     func sendTab() {
619:         if isConnected {
620:             sshManager?.sendTab()
621:         }
622:     }
623:     
624:     func sendEscape() {
625:         sshManager?.sendEscape()
626:     }
627:     
628:     func previousCommand() -> String? {
629:         guard !commandHistory.isEmpty else { return nil }
630:         historyIndex = max(0, historyIndex - 1)
631:         return commandHistory[historyIndex]
632:     }
633:     
634:     func nextCommand() -> String? {
635:         guard !commandHistory.isEmpty else { return nil }
636:         historyIndex = min(commandHistory.count, historyIndex + 1)
637:         if historyIndex >= commandHistory.count {
638:             return ""
639:         }
640:         return commandHistory[historyIndex]
641:     }
642:     
643:     private func processLocalCommand(_ command: String) {
644:         let parts = command.split(separator: " ", maxSplits: 1)
645:         guard let cmd = parts.first?.lowercased() else { return }
646:         
647:         switch cmd {
648:         case "help":
649:             appendOutput("""
650:             Local Commands:
651:               help              - Show this help
652:               clear             - Clear terminal
653:               echo <text>       - Echo text
654:               date              - Show current date
655:               whoami            - Show current user
656:               history           - Show command history
657:               ssh               - Show SSH connection info
658:             
659:             Connect via SSH using the network button in toolbar.
660:             Real SSH protocol powered by SwiftNIO SSH.
661:             """, type: .output)
662:             
663:         case "clear":
664:             clear()
665:             
666:         case "echo":
667:             let text = parts.count > 1 ? String(parts[1]) : ""
668:             appendOutput(text, type: .output)
669:             
670:         case "date":
671:             appendOutput(Date().description, type: .output)
672:             
673:         case "whoami":
674:             appendOutput("ipad-user", type: .output)
675:             
676:         case "history":
677:             for (index, cmd) in commandHistory.enumerated() {
678:                 appendOutput("  \(index + 1)  \(cmd)", type: .output)
679:             }
680:             
681:         case "ssh":
682:             appendOutput("""
683:             SSH Status: \(isConnected ? "Connected" : "Not connected")
684:             Implementation: SwiftNIO SSH (apple/swift-nio-ssh)
685:             Features: Password auth, Key auth, PTY support, Shell sessions
686:             """, type: .output)
687:             
688:         default:
689:             appendOutput("\(cmd): command not found (local mode)", type: .error)
690:         }
691:     }
692:     
693:     func appendOutput(_ text: String, type: LineType, isANSI: Bool = false) {
694:         DispatchQueue.main.async {
695:             // Split multi-line output into separate lines
696:             let lines = text.components(separatedBy: .newlines)
697:             for line in lines {
698:                 if !line.isEmpty || lines.count == 1 {
699:                     self.output.append(TerminalLine(text: line, type: type, isANSI: isANSI || line.contains("\u{1B}")))
700:                 }
701:             }
702:         }
703:     }
704: }
705: 
706: // MARK: - SSH Manager Delegate
707: extension TerminalManager: SSHManagerDelegate {
708:     func sshManagerDidConnect(_ manager: SSHManager) {
709:         DispatchQueue.main.async {
710:             self.isConnected = true
711:             self.isConnecting = false
712:             self.connectionStatus = "Connected"
713:             self.promptString = "" // Shell will provide prompt
714:             self.appendOutput("Connected successfully via SwiftNIO SSH!", type: .system)
715:         }
716:     }
717:     
718:     func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?) {
719:         DispatchQueue.main.async {
720:             self.isConnected = false
721:             self.isConnecting = false
722:             self.connectionStatus = "Disconnected"
723:             self.promptString = "$ "
724:             if let error = error {
725:                 self.appendOutput("Connection lost: \(error.localizedDescription)", type: .error)
726:             }
727:         }
728:     }
729:     
730:     func sshManager(_ manager: SSHManager, didReceiveOutput text: String) {
731:         appendOutput(text, type: .output)
732:     }
733:     
734:     func sshManager(_ manager: SSHManager, didReceiveError text: String) {
735:         appendOutput(text, type: .error)
736:     }
737: }
738: 
739: // MARK: - SSH Connection View (Enhanced with Saved Connections)
740: 
741: struct SSHConnectionView: View {
742:     @ObservedObject var terminal: TerminalManager
743:     @Binding var isPresented: Bool
744:     @ObservedObject private var connectionStore = SSHConnectionStore.shared
745:     @ObservedObject private var themeManager = ThemeManager.shared
746:     
747:     @State private var connectionName = ""
748:     @State private var host = ""
749:     @State private var port = "22"
750:     @State private var username = ""
751:     @State private var password = ""
752:     @State private var useKey = false
753:     @State private var privateKey = ""
754:     @State private var keyPassphrase = ""
755:     @State private var saveConnection = true
756:     @State private var showSavedConnections = true
757:     @State private var errorMessage: String?
758:     
759:     var body: some View {
760:         NavigationView {
761:             Form {
762:                 // Saved Connections Section
763:                 if !connectionStore.savedConnections.isEmpty {
764:                     Section(header: Text("Saved Connections")) {
765:                         ForEach(connectionStore.savedConnections) { config in
766:                             Button(action: { connectToSaved(config) }) {
767:                                 HStack {
768:                                     VStack(alignment: .leading, spacing: 2) {
769:                                         Text(config.name)
770:                                             .font(.headline)
771:                                             .foregroundColor(themeManager.currentTheme.editorForeground)
772:                                         Text("\(config.username)@\(config.host):\(config.port)")
773:                                             .font(.caption)
774:                                             .foregroundColor(themeManager.currentTheme.comment)
775:                                     }
776:                                     Spacer()
777:                                     if case .privateKey = config.authMethod {
778:                                         Image(systemName: "key.fill")
779:                                             .foregroundColor(.orange)
780:                                     } else {
781:                                         Image(systemName: "lock.fill")
782:                                             .foregroundColor(.blue)
783:                                     }
784:                                 }
785:                             }
786:                             .swipeActions(edge: .trailing, allowsFullSwipe: true) {
787:                                 Button(role: .destructive) {
788:                                     connectionStore.delete(config)
789:                                 } label: {
790:                                     Label("Delete", systemImage: "trash")
791:                                 }
792:                             }
793:                         }
794:                     }
795:                 }
796:                 
797:                 // New Connection Section
798:                 Section(header: Text("New Connection")) {
799:                     TextField("Connection Name (optional)", text: $connectionName)
800:                         .autocapitalization(.none)
801:                     
802:                     TextField("Host", text: $host)
803:                         .autocapitalization(.none)
804:                         .disableAutocorrection(true)
805:                         .keyboardType(.URL)
806:                     
807:                     TextField("Port", text: $port)
808:                         .keyboardType(.numberPad)
809:                     
810:                     TextField("Username", text: $username)
811:                         .autocapitalization(.none)
812:                         .disableAutocorrection(true)
813:                 }
814:                 
815:                 Section(header: Text("Authentication")) {
816:                     Picker("Method", selection: $useKey) {
817:                         Text("Password").tag(false)
818:                         Text("SSH Key").tag(true)
819:                     }
820:                     .pickerStyle(.segmented)
821:                     
822:                     if useKey {
823:                         VStack(alignment: .leading, spacing: 8) {
824:                             Text("Private Key (PEM format)")
825:                                 .font(.caption)
826:                                 .foregroundColor(themeManager.currentTheme.comment)
827:                             
828:                             TextEditor(text: $privateKey)
829:                                 .font(.system(.caption, design: .monospaced))
830:                                 .frame(height: 120)
831:                                 .overlay(
832:                                     RoundedRectangle(cornerRadius: 8)
833:                                         .stroke(themeManager.currentTheme.editorForeground.opacity(0.2), lineWidth: 1)
834:                                 )
835:                             
836:                             SecureField("Key Passphrase (if encrypted)", text: $keyPassphrase)
837:                         }
838:                     } else {
839:                         SecureField("Password", text: $password)
840:                     }
841:                 }
842:                 
843:                 Section {
844:                     Toggle("Save Connection", isOn: $saveConnection)
845:                 }
846:                 
847:                 if let error = errorMessage {
848:                     Section {
849:                         Text(error)
850:                             .foregroundColor(.red)
851:                             .font(.caption)
852:                     }
853:                 }
854:                 
855:                 Section {
856:                     Button(action: connect) {
857:                         HStack {
858:                             Spacer()
859:                             if terminal.isConnecting {
860:                                 ProgressView()
861:                                     .progressViewStyle(CircularProgressViewStyle())
862:                                 Text("Connecting...")
863:                             } else {
864:                                 Image(systemName: "network")
865:                                 Text("Connect")
866:                             }
867:                             Spacer()
868:                         }
869:                     }
870:                     .disabled(host.isEmpty || username.isEmpty || terminal.isConnecting)
871:                 }
872:             }
873:             .navigationTitle("SSH Connection")
874:             .toolbar {
875:                 ToolbarItem(placement: .cancellationAction) {
876:                     Button("Cancel") { isPresented = false }
877:                 }
878:             }
879:         }
880:     }
881:     
882:     private func connectToSaved(_ config: SSHConnectionConfig) {
883:         terminal.connect(to: config)
884:         isPresented = false
885:     }
886:     
887:     private func connect() {
888:         errorMessage = nil
889:         
890:         let authMethod: SSHConnectionConfig.SSHAuthMethod
891:         if useKey {
892:             guard !privateKey.isEmpty else {
893:                 errorMessage = "Please enter your private key"
894:                 return
895:             }
896:             authMethod = .privateKey(key: privateKey, passphrase: keyPassphrase.isEmpty ? nil : keyPassphrase)
897:         } else {
898:             guard !password.isEmpty else {
899:                 errorMessage = "Please enter your password"
900:                 return
901:             }
902:             authMethod = .password(password)
903:         }
904:         
905:         let name = connectionName.isEmpty ? "\(username)@\(host)" : connectionName
906:         
907:         let config = SSHConnectionConfig(
908:             name: name,
909:             host: host,
910:             port: Int(port) ?? 22,
911:             username: username,
912:             authMethod: authMethod
913:         )
914:         
915:         if saveConnection {
916:             connectionStore.save(config)
917:         }
918:         
919:         terminal.connect(to: config)
920:         isPresented = false
921:     }
922: }
923: 
924: // MARK: - Models & Helpers (Legacy support)
925: 
926: struct SSHConnection {
927:     let host: String
928:     let port: Int
929:     let username: String
930:     let password: String?
931:     let privateKey: String?
932: }
933: 
934: struct TerminalLine: Identifiable {
935:     let id = UUID()
936:     let text: String
937:     let type: LineType
938:     var isANSI: Bool = false
939: }
940: 
941: enum LineType {
942:     case command
943:     case output
944:     case error
945:     case system
946:     case prompt
947: }
948: 
949: struct ANSIText: View {
950:     let text: String
951:     @ObservedObject private var themeManager = ThemeManager.shared
952:     
953:     init(_ text: String) {
954:         self.text = text
955:     }
956:     
957:     var body: some View {
958:         Text(stripANSI(text))
959:             .font(.system(.body, design: .monospaced))
960:             .foregroundColor(themeManager.currentTheme.editorForeground)
961:             .textSelection(.enabled)
962:     }
963:     
964:     private func stripANSI(_ text: String) -> String {
965:         let pattern = "\u{1B}\\[[0-9;]*[a-zA-Z]"
966:         guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
967:         let range = NSRange(text.startIndex..., in: text)
968:         return regex.stringByReplacingMatches(in: text, range: range, withTemplate: "")
969:     }
970: }
971: 
972: // MARK: - SSH Client Implementation
973: // Real SSH implementation is now in Services/SSHManager.swift
974: // Uses SwiftNIO SSH (apple/swift-nio-ssh) for proper SSH protocol support
975: // Features:
976: // - Password authentication
977: // - SSH key authentication (Ed25519, ECDSA)
978: // - PTY allocation for interactive shells
979: // - Proper channel management
980: // - Terminal resize support
981: 


Good, I got TerminalView.swift. Now let me find GitView.swift:

>>>TOOL search
{"query": "GitView.swift", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "GitView.swift"


Let me search for Git views and Debug files:

>>>TOOL search
{"query": "struct GitView", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "struct GitView"


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views"}
>>>END

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


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   AIAssistantView.swift.backup
   AIAssistantView.swift.bak
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GitView.swift.broken
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SearchView.swift.broken
   SettingsView.swift
   TerminalView.swift
   TerminalView.swift.bak
   TestView.swift
   TimelineView.swift


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 1-505 of 505)
────────────────────────────────────────
1: import SwiftUI
2: 
3: // MARK: - Git View (Source Control Panel)
4: 
5: struct GitView: View {
6:     @ObservedObject private var gitManager = GitManager.shared
7:     @EnvironmentObject var editorCore: EditorCore
8:     @State private var commitMessage = ""
9:     @State private var selectedEntry: GitStatusEntry?
10:     @State private var showBranchPicker = false
11:     
12:     var body: some View {
13:         VStack(alignment: .leading, spacing: 0) {
14:             // Header
15:             HStack {
16:                 Text("SOURCE CONTROL")
17:                     .font(.system(size: 11, weight: .semibold))
18:                     .foregroundColor(.secondary)
19:                 Spacer()
20:                 
21:                 if gitManager.isLoading {
22:                     ProgressView()
23:                         .scaleEffect(0.6)
24:                 }
25:                 
26:                 Button(action: refreshGit) {
27:                     Image(systemName: "arrow.clockwise")
28:                         .font(.system(size: 12))
29:                 }
30:                 .buttonStyle(.plain)
31:                 .disabled(gitManager.isLoading)
32:             }
33:             .padding(.horizontal, 12)
34:             .padding(.vertical, 8)
35:             
36:             Divider()
37:             
38:             // Branch selector
39:             HStack {
40:                 Image(systemName: "arrow.triangle.branch")
41:                     .font(.system(size: 11))
42:                     .foregroundColor(.secondary)
43:                 
44:                 Button(action: { showBranchPicker = true }) {
45:                     HStack(spacing: 4) {
46:                         Text(gitManager.currentBranch)
47:                             .font(.system(size: 12, weight: .medium))
48:                         Image(systemName: "chevron.down")
49:                             .font(.system(size: 9))
50:                     }
51:                 }
52:                 .buttonStyle(.plain)
53:                 
54:                 Spacer()
55:                 
56:                 // Sync status
57:                 if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
58:                     HStack(spacing: 4) {
59:                         if gitManager.aheadCount > 0 {
60:                             HStack(spacing: 2) {
61:                                 Image(systemName: "arrow.up")
62:                                 Text("\(gitManager.aheadCount)")
63:                             }
64:                             .font(.system(size: 10))
65:                             .foregroundColor(.orange)
66:                         }
67:                         if gitManager.behindCount > 0 {
68:                             HStack(spacing: 2) {
69:                                 Image(systemName: "arrow.down")
70:                                 Text("\(gitManager.behindCount)")
71:                             }
72:                             .font(.system(size: 10))
73:                             .foregroundColor(.blue)
74:                         }
75:                     }
76:                 }
77:             }
78:             .padding(.horizontal, 12)
79:             .padding(.vertical, 6)
80:             .background(Color(UIColor.secondarySystemBackground))
81:             
82:             Divider()
83:             
84:             // Commit input
85:             VStack(spacing: 8) {
86:                 TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
87:                     .textFieldStyle(.roundedBorder)
88:                     .font(.system(size: 12))
89:                 
90:                 HStack(spacing: 8) {
91:                     Button(action: commitChanges) {
92:                         HStack {
93:                             Image(systemName: "checkmark")
94:                             Text("Commit")
95:                         }
96:                         .frame(maxWidth: .infinity)
97:                         .padding(.vertical, 6)
98:                         .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
99:                         .foregroundColor(.white)
100:                         .cornerRadius(6)
101:                     }
102:                     .disabled(!canCommit)
103:                     .buttonStyle(.plain)
104:                     
105:                     Menu {
106:                         Button(action: { Task { try? await gitManager.stageAll() } }) {
107:                             Label("Stage All", systemImage: "plus.circle")
108:                         }
109:                         Button(action: commitAndPush) {
110:                             Label("Commit & Push", systemImage: "arrow.up.circle")
111:                         }
112:                     } label: {
113:                         Image(systemName: "ellipsis.circle")
114:                             .font(.system(size: 16))
115:                     }
116:                     .buttonStyle(.plain)
117:                 }
118:             }
119:             .padding(12)
120:             
121:             Divider()
122:             
123:             // Changes list
124:             ScrollView {
125:                 VStack(alignment: .leading, spacing: 4) {
126:                     // Staged changes
127:                     if !gitManager.stagedChanges.isEmpty {
128:                         sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
129:                         ForEach(gitManager.stagedChanges) { entry in
130:                             changeRow(entry, isStaged: true)
131:                         }
132:                     }
133:                     
134:                     // Unstaged changes
135:                     if !gitManager.unstagedChanges.isEmpty {
136:                         sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
137:                         ForEach(gitManager.unstagedChanges) { entry in
138:                             changeRow(entry, isStaged: false)
139:                         }
140:                     }
141:                     
142:                     // No changes
143:                     if gitManager.stagedChanges.isEmpty && gitManager.unstagedChanges.isEmpty {
144:                         VStack(spacing: 8) {
145:                             Image(systemName: "checkmark.circle")
146:                                 .font(.system(size: 24))
147:                                 .foregroundColor(.green)
148:                             Text("No changes")
149:                                 .font(.system(size: 12))
150:                                 .foregroundColor(.secondary)
151:                         }
152:                         .frame(maxWidth: .infinity)
153:                         .padding(.vertical, 20)
154:                     }
155:                     
156:                     // Recent commits
157:                     if !gitManager.recentCommits.isEmpty {
158:                         Divider()
159:                             .padding(.vertical, 8)
160:                         
161:                         sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
162:                         ForEach(gitManager.recentCommits.prefix(5)) { commit in
163:                             commitRow(commit)
164:                         }
165:                     }
166:                 }
167:                 .padding(.horizontal, 8)
168:                 .padding(.bottom, 8)
169:             }
170:             
171:             Spacer(minLength: 0)
172:             
173:             // Error display
174:             if let error = gitManager.error {
175:                 HStack {
176:                     Image(systemName: "exclamationmark.triangle")
177:                         .foregroundColor(.red)
178:                     Text(error)
179:                         .font(.system(size: 10))
180:                         .foregroundColor(.red)
181:                         .lineLimit(2)
182:                 }
183:                 .padding(8)
184:                 .background(Color.red.opacity(0.1))
185:                 .cornerRadius(6)
186:                 .padding(.horizontal, 12)
187:             }
188:             
189:             Divider()
190:             
191:             // Bottom actions
192:             HStack(spacing: 12) {
193:                 Button(action: pullChanges) {
194:                     HStack(spacing: 4) {
195:                         Image(systemName: "arrow.down.circle")
196:                         Text("Pull")
197:                         if gitManager.behindCount > 0 {
198:                             Text("(\(gitManager.behindCount))")
199:                                 .foregroundColor(.blue)
200:                         }
201:                     }
202:                 }
203:                 .font(.system(size: 11))
204:                 .buttonStyle(.plain)
205:                 
206:                 Button(action: pushChanges) {
207:                     HStack(spacing: 4) {
208:                         Image(systemName: "arrow.up.circle")
209:                         Text("Push")
210:                         if gitManager.aheadCount > 0 {
211:                             Text("(\(gitManager.aheadCount))")
212:                                 .foregroundColor(.orange)
213:                         }
214:                     }
215:                 }
216:                 .font(.system(size: 11))
217:                 .buttonStyle(.plain)
218:                 
219:                 Button(action: fetchChanges) {
220:                     Image(systemName: "arrow.triangle.2.circlepath")
221:                 }
222:                 .font(.system(size: 11))
223:                 .buttonStyle(.plain)
224:                 
225:                 Spacer()
226:             }
227:             .padding(12)
228:         }
229:         .background(Color(UIColor.systemBackground))
230:         .sheet(isPresented: $showBranchPicker) {
231:             BranchPickerSheet(gitManager: gitManager)
232:         }
233:     }
234:     
235:     private var canCommit: Bool {
236:         !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
237:     }
238:     
239:     private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
240:         HStack {
241:             Text(title)
242:                 .font(.system(size: 11, weight: .semibold))
243:                 .foregroundColor(.secondary)
244:             Text("\(count)")
245:                 .font(.system(size: 10))
246:                 .foregroundColor(color)
247:                 .padding(.horizontal, 6)
248:                 .padding(.vertical, 2)
249:                 .background(color.opacity(0.2))
250:                 .cornerRadius(8)
251:             Spacer()
252:         }
253:         .padding(.vertical, 4)
254:     }
255:     
256:     private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
257:         HStack(spacing: 8) {
258:             // Status indicator
259:             Text(entry.kind.rawValue.prefix(1).uppercased())
260:                 .font(.system(size: 10, weight: .bold, design: .monospaced))
261:                 .foregroundColor(entry.kind.color)
262:                 .frame(width: 16)
263:             
264:             // File name
265:             Text(entry.path.components(separatedBy: "/").last ?? entry.path)
266:                 .font(.system(size: 12))
267:                 .lineLimit(1)
268:             
269:             Spacer()
270:             
271:             // Stage/unstage button
272:             if isStaged {
273:                 Button(action: { unstageFile(entry.path) }) {
274:                     Image(systemName: "minus")
275:                         .font(.system(size: 10))
276:                         .foregroundColor(.red)
277:                 }
278:                 .buttonStyle(.plain)
279:             } else {
280:                 Button(action: { stageFile(entry.path) }) {
281:                     Image(systemName: "plus")
282:                         .font(.system(size: 10))
283:                         .foregroundColor(.green)
284:                 }
285:                 .buttonStyle(.plain)
286:             }
287:         }
288:         .padding(.vertical, 4)
289:         .padding(.horizontal, 8)
290:         .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
291:         .cornerRadius(4)
292:         .onTapGesture {
293:             selectedEntry = entry
294:         }
295:         .contextMenu {
296:             if isStaged {
297:                 Button(action: { unstageFile(entry.path) }) {
298:                     Label("Unstage Changes", systemImage: "minus.circle")
299:                 }
300:             } else {
301:                 Button(action: { stageFile(entry.path) }) {
302:                     Label("Stage Changes", systemImage: "plus.circle")
303:                 }
304:             }
305:             
306:             if !isStaged && entry.kind != .untracked {
307:                 Button(role: .destructive, action: {
308:                     Task { try? await gitManager.discardChanges(file: entry.path) }
309:                 }) {
310:                     Label("Discard Changes", systemImage: "trash")
311:                 }
312:             }
313:             
314:             Divider()
315:             
316:             Button(action: {
317:                 let url = URL(fileURLWithPath: entry.path)
318:                 editorCore.openFile(from: url)
319:             }) {
320:                 Label("Open File", systemImage: "doc.text")
321:             }
322:             
323:             Button(action: {
324:                 UIPasteboard.general.string = entry.path
325:             }) {
326:                 Label("Copy Path", systemImage: "doc.on.doc")
327:             }
328:         }
329:     }
330:     
331:     private func commitRow(_ commit: GitCommit) -> some View {
332:         VStack(alignment: .leading, spacing: 2) {
333:             HStack {
334:                 Text(commit.shortSHA)
335:                     .font(.system(size: 10, design: .monospaced))
336:                     .foregroundColor(.accentColor)
337:                 
338:                 Text(commit.message)
339:                     .font(.system(size: 11))
340:                     .lineLimit(1)
341:             }
342:             
343:             HStack {
344:                 Text(commit.author)
345:                     .font(.system(size: 10))
346:                     .foregroundColor(.secondary)
347:                 
348:                 Text("•")
349:                     .foregroundColor(.secondary)
350:                 
351:                 Text(commit.date, style: .relative)
352:                     .font(.system(size: 10))
353:                     .foregroundColor(.secondary)
354:             }
355:         }
356:         .padding(.vertical, 4)
357:         .padding(.horizontal, 8)
358:     }
359:     
360:     // MARK: - Actions
361:     
362:     private func refreshGit() {
363:         Task { await gitManager.refresh() }
364:     }
365:     
366:     private func stageFile(_ path: String) {
367:         Task { try? await gitManager.stage(file: path) }
368:     }
369:     
370:     private func unstageFile(_ path: String) {
371:         Task { try? await gitManager.unstage(file: path) }
372:     }
373:     
374:     private func commitChanges() {
375:         guard canCommit else { return }
376:         Task {
377:             try? await gitManager.commit(message: commitMessage)
378:             await MainActor.run { commitMessage = "" }
379:         }
380:     }
381:     
382:     private func commitAndPush() {
383:         guard canCommit else { return }
384:         Task {
385:             try? await gitManager.commit(message: commitMessage)
386:             await MainActor.run { commitMessage = "" }
387:             try? await gitManager.push()
388:         }
389:     }
390:     
391:     private func pullChanges() {
392:         Task { try? await gitManager.pull() }
393:     }
394:     
395:     private func pushChanges() {
396:         Task { try? await gitManager.push() }
397:     }
398:     
399:     private func fetchChanges() {
400:         Task { try? await gitManager.fetch() }
401:     }
402: }
403: 
404: // MARK: - Branch Picker Sheet
405: 
406: struct BranchPickerSheet: View {
407:     @ObservedObject var gitManager: GitManager
408:     @Environment(\.dismiss) private var dismiss
409:     @State private var newBranchName = ""
410:     @State private var showCreateBranch = false
411:     
412:     var localBranches: [GitBranch] {
413:         gitManager.branches.filter { !$0.isRemote }
414:     }
415:     
416:     var remoteBranches: [GitBranch] {
417:         gitManager.branches.filter { $0.isRemote }
418:     }
419:     
420:     var body: some View {
421:         NavigationView {
422:             List {
423:                 // Create new branch
424:                 Section {
425:                     if showCreateBranch {
426:                         HStack {
427:                             TextField("New branch name", text: $newBranchName)
428:                                 .textFieldStyle(.roundedBorder)
429:                             
430:                             Button("Create") {
431:                                 createBranch()
432:                             }
433:                             .disabled(newBranchName.isEmpty)
434:                         }
435:                     } else {
436:                         Button(action: { showCreateBranch = true }) {
437:                             Label("Create New Branch", systemImage: "plus.circle")
438:                         }
439:                     }
440:                 }
441:                 
442:                 // Local branches
443:                 Section("Local Branches") {
444:                     ForEach(localBranches) { branch in
445:                         Button(action: { checkout(branch.name) }) {
446:                             HStack {
447:                                 if branch.isCurrent {
448:                                     Image(systemName: "checkmark")
449:                                         .foregroundColor(.accentColor)
450:                                 }
451:                                 Text(branch.name)
452:                                     .foregroundColor(branch.isCurrent ? .accentColor : .primary)
453:                                 Spacer()
454:                             }
455:                         }
456:                         .buttonStyle(.plain)
457:                     }
458:                 }
459:                 
460:                 // Remote branches
461:                 if !remoteBranches.isEmpty {
462:                     Section("Remote Branches") {
463:                         ForEach(remoteBranches) { branch in
464:                             Button(action: { checkout(branch.name) }) {
465:                                 HStack {
466:                                     Text(branch.name)
467:                                         .foregroundColor(.secondary)
468:                                     Spacer()
469:                                 }
470:                             }
471:                             .buttonStyle(.plain)
472:                         }
473:                     }
474:                 }
475:             }
476:             .navigationTitle("Branches")
477:             .navigationBarTitleDisplayMode(.inline)
478:             .toolbar {
479:                 ToolbarItem(placement: .navigationBarTrailing) {
480:                     Button("Done") { dismiss() }
481:                 }
482:             }
483:         }
484:     }
485:     
486:     private func checkout(_ branch: String) {
487:         Task {
488:             try? await gitManager.checkout(branch: branch)
489:             await MainActor.run { dismiss() }
490:         }
491:     }
492:     
493:     private func createBranch() {
494:         guard !newBranchName.isEmpty else { return }
495:         Task {
496:             try? await gitManager.createBranch(name: newBranchName)
497:             await MainActor.run {
498:                 newBranchName = ""
499:                 showCreateBranch = false
500:                 dismiss()
501:             }
502:         }
503:     }
504: }
505: 


Now let me read DebugView.swift:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/DebugView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/DebugView.swift (lines 1-233 of 233)
────────────────────────────────────────
1: import SwiftUI
2: 
3: struct DebugView: View {
4:     @State private var variables: [DebugVariable] = [
5:         DebugVariable(name: "local", value: "", children: [
6:             DebugVariable(name: "this", value: "Object"),
7:             DebugVariable(name: "index", value: "0"),
8:             DebugVariable(name: "items", value: "Array(5)", children: [
9:                 DebugVariable(name: "[0]", value: "Item"),
10:                 DebugVariable(name: "[1]", value: "Item"),
11:                 DebugVariable(name: "length", value: "2")
12:             ])
13:         ]),
14:         DebugVariable(name: "global", value: "", children: [
15:             DebugVariable(name: "window", value: "Window")
16:         ])
17:     ]
18:     
19:     @State private var watchExpressions: [WatchExpression] = []
20:     @State private var newWatchExpression: String = ""
21:     @State private var isAddingWatch: Bool = false
22:     
23:     // Expanded states for sections
24:     @State private var isVariablesExpanded: Bool = true
25:     @State private var isWatchExpanded: Bool = true
26:     
27:     var body: some View {
28:         VStack(spacing: 0) {
29:             // Header
30:             HStack {
31:                 Text("RUN AND DEBUG")
32:                     .font(.caption)
33:                     .fontWeight(.bold)
34:                     .foregroundColor(.secondary)
35:                 Spacer()
36:                 Button(action: {}) {
37:                     Image(systemName: "play.fill")
38:                         .font(.system(size: 10))
39:                         .foregroundColor(.green)
40:                         .padding(4)
41:                         .background(Color.green.opacity(0.1))
42:                         .cornerRadius(4)
43:                 }
44:                 .buttonStyle(PlainButtonStyle())
45:                 
46:                 Button(action: {}) {
47:                     Image(systemName: "ellipsis")
48:                         .font(.system(size: 12))
49:                         .foregroundColor(.secondary)
50:                 }
51:                 .buttonStyle(PlainButtonStyle())
52:                 .padding(.leading, 8)
53:             }
54:             .padding(.horizontal)
55:             .padding(.vertical, 8)
56:             .background(Color(UIColor.secondarySystemBackground))
57:             
58:             ScrollView {
59:                 VStack(spacing: 0) {
60:                     // Variables Section
61:                     DisclosureGroup(isExpanded: $isVariablesExpanded) {
62:                         VStack(alignment: .leading, spacing: 0) {
63:                             ForEach(variables) { variable in
64:                                 VariableRow(variable: variable)
65:                             }
66:                         }
67:                         .padding(.leading, 4)
68:                     } label: {
69:                         SectionHeader(title: "VARIABLES")
70:                     }
71:                     .padding(.horizontal, 8)
72:                     .padding(.top, 4)
73:                     
74:                     Divider()
75:                         .padding(.vertical, 4)
76:                     
77:                     // Watch Section
78:                     DisclosureGroup(isExpanded: $isWatchExpanded) {
79:                         VStack(alignment: .leading, spacing: 0) {
80:                             if watchExpressions.isEmpty && !isAddingWatch {
81:                                 Text("No watch expressions")
82:                                     .font(.caption)
83:                                     .foregroundColor(.secondary)
84:                                     .padding(.vertical, 4)
85:                                     .padding(.leading, 12)
86:                             }
87:                             
88:                             ForEach(watchExpressions) { watch in
89:                                 HStack {
90:                                     Image(systemName: "eye")
91:                                         .font(.caption2)
92:                                         .foregroundColor(.secondary)
93:                                     Text(watch.expression)
94:                                         .font(.system(size: 12, design: .monospaced))
95:                                         .foregroundColor(.primary)
96:                                     Text(":")
97:                                         .font(.system(size: 12, design: .monospaced))
98:                                         .foregroundColor(.secondary)
99:                                     Spacer()
100:                                     Text(watch.value)
101:                                         .font(.system(size: 12, design: .monospaced))
102:                                         .foregroundColor(.secondary)
103:                                 }
104:                                 .padding(.vertical, 4)
105:                                 .padding(.leading, 12)
106:                             }
107:                             
108:                             if isAddingWatch {
109:                                 HStack {
110:                                     Image(systemName: "eye")
111:                                         .font(.caption2)
112:                                         .foregroundColor(.secondary)
113:                                     TextField("Expression...", text: $newWatchExpression, onCommit: {
114:                                         if !newWatchExpression.isEmpty {
115:                                             watchExpressions.append(WatchExpression(expression: newWatchExpression, value: "undefined"))
116:                                             newWatchExpression = ""
117:                                         }
118:                                         isAddingWatch = false
119:                                     })
120:                                     .textFieldStyle(PlainTextFieldStyle())
121:                                     .font(.system(size: 12, design: .monospaced))
122:                                     .padding(4)
123:                                     .background(Color(UIColor.systemGray6))
124:                                     .cornerRadius(4)
125:                                 }
126:                                 .padding(.vertical, 4)
127:                                 .padding(.leading, 12)
128:                             }
129:                             
130:                             Button(action: { 
131:                                 isAddingWatch = true
132:                             }) {
133:                                 HStack {
134:                                     Image(systemName: "plus")
135:                                     Text("Add Expression")
136:                                 }
137:                                 .font(.caption)
138:                                 .foregroundColor(.blue)
139:                                 .padding(.vertical, 4)
140:                                 .padding(.leading, 12)
141:                             }
142:                             .opacity(isAddingWatch ? 0 : 1)
143:                         }
144:                     } label: {
145:                         HStack {
146:                             SectionHeader(title: "WATCH")
147:                             Spacer()
148:                             Button(action: { isAddingWatch = true }) {
149:                                 Image(systemName: "plus")
150:                                     .font(.caption)
151:                                     .foregroundColor(.secondary)
152:                             }
153:                             .buttonStyle(PlainButtonStyle())
154:                             .opacity(isWatchExpanded ? 1 : 0)
155:                         }
156:                     }
157:                     .padding(.horizontal, 8)
158:                 }
159:             }
160:         }
161:         .background(Color(UIColor.systemBackground))
162:     }
163: }
164: 
165: struct SectionHeader: View {
166:     let title: String
167:     var body: some View {
168:         Text(title)
169:             .font(.system(size: 11, weight: .bold))
170:             .foregroundColor(.secondary)
171:             .padding(.vertical, 4)
172:     }
173: }
174: 
175: struct VariableRow: View {
176:     let variable: DebugVariable
177:     @State private var isExpanded: Bool = false
178:     
179:     var body: some View {
180:         VStack(alignment: .leading, spacing: 0) {
181:             HStack(alignment: .top, spacing: 4) {
182:                 if let children = variable.children, !children.isEmpty {
183:                     Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
184:                         .font(.system(size: 10, weight: .bold))
185:                         .frame(width: 16, height: 16)
186:                         .contentShape(Rectangle())
187:                         .onTapGesture {
188:                             withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
189:                         }
190:                         .foregroundColor(.secondary)
191:                 } else {
192:                     Spacer().frame(width: 16)
193:                 }
194:                 
195:                 HStack(alignment: .firstTextBaseline, spacing: 4) {
196:                     Text(variable.name)
197:                         .font(.system(size: 12, design: .monospaced))
198:                         .foregroundColor(Color.blue.opacity(0.8))
199:                     Text(":")
200:                         .font(.system(size: 12, design: .monospaced))
201:                         .foregroundColor(.secondary)
202:                     Text(variable.value)
203:                         .font(.system(size: 12, design: .monospaced))
204:                         .foregroundColor(Color.orange.opacity(0.8))
205:                         .lineLimit(1)
206:                 }
207:                 Spacer()
208:             }
209:             .padding(.vertical, 2)
210:             
211:             if isExpanded, let children = variable.children {
212:                 ForEach(children) { child in
213:                     VariableRow(variable: child)
214:                         .padding(.leading, 16)
215:                 }
216:             }
217:         }
218:     }
219: }
220: 
221: struct DebugVariable: Identifiable {
222:     let id = UUID()
223:     let name: String
224:     let value: String
225:     var children: [DebugVariable]?
226: }
227: 
228: struct WatchExpression: Identifiable {
229:     let id = UUID()
230:     let expression: String
231:     let value: String
232: }
233: 


Now let me read GitView.swift explicitly:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 1-505 of 505)
────────────────────────────────────────
1: import SwiftUI
2: 
3: // MARK: - Git View (Source Control Panel)
4: 
5: struct GitView: View {
6:     @ObservedObject private var gitManager = GitManager.shared
7:     @EnvironmentObject var editorCore: EditorCore
8:     @State private var commitMessage = ""
9:     @State private var selectedEntry: GitStatusEntry?
10:     @State private var showBranchPicker = false
11:     
12:     var body: some View {
13:         VStack(alignment: .leading, spacing: 0) {
14:             // Header
15:             HStack {
16:                 Text("SOURCE CONTROL")
17:                     .font(.system(size: 11, weight: .semibold))
18:                     .foregroundColor(.secondary)
19:                 Spacer()
20:                 
21:                 if gitManager.isLoading {
22:                     ProgressView()
23:                         .scaleEffect(0.6)
24:                 }
25:                 
26:                 Button(action: refreshGit) {
27:                     Image(systemName: "arrow.clockwise")
28:                         .font(.system(size: 12))
29:                 }
30:                 .buttonStyle(.plain)
31:                 .disabled(gitManager.isLoading)
32:             }
33:             .padding(.horizontal, 12)
34:             .padding(.vertical, 8)
35:             
36:             Divider()
37:             
38:             // Branch selector
39:             HStack {
40:                 Image(systemName: "arrow.triangle.branch")
41:                     .font(.system(size: 11))
42:                     .foregroundColor(.secondary)
43:                 
44:                 Button(action: { showBranchPicker = true }) {
45:                     HStack(spacing: 4) {
46:                         Text(gitManager.currentBranch)
47:                             .font(.system(size: 12, weight: .medium))
48:                         Image(systemName: "chevron.down")
49:                             .font(.system(size: 9))
50:                     }
51:                 }
52:                 .buttonStyle(.plain)
53:                 
54:                 Spacer()
55:                 
56:                 // Sync status
57:                 if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
58:                     HStack(spacing: 4) {
59:                         if gitManager.aheadCount > 0 {
60:                             HStack(spacing: 2) {
61:                                 Image(systemName: "arrow.up")
62:                                 Text("\(gitManager.aheadCount)")
63:                             }
64:                             .font(.system(size: 10))
65:                             .foregroundColor(.orange)
66:                         }
67:                         if gitManager.behindCount > 0 {
68:                             HStack(spacing: 2) {
69:                                 Image(systemName: "arrow.down")
70:                                 Text("\(gitManager.behindCount)")
71:                             }
72:                             .font(.system(size: 10))
73:                             .foregroundColor(.blue)
74:                         }
75:                     }
76:                 }
77:             }
78:             .padding(.horizontal, 12)
79:             .padding(.vertical, 6)
80:             .background(Color(UIColor.secondarySystemBackground))
81:             
82:             Divider()
83:             
84:             // Commit input
85:             VStack(spacing: 8) {
86:                 TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
87:                     .textFieldStyle(.roundedBorder)
88:                     .font(.system(size: 12))
89:                 
90:                 HStack(spacing: 8) {
91:                     Button(action: commitChanges) {
92:                         HStack {
93:                             Image(systemName: "checkmark")
94:                             Text("Commit")
95:                         }
96:                         .frame(maxWidth: .infinity)
97:                         .padding(.vertical, 6)
98:                         .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
99:                         .foregroundColor(.white)
100:                         .cornerRadius(6)
101:                     }
102:                     .disabled(!canCommit)
103:                     .buttonStyle(.plain)
104:                     
105:                     Menu {
106:                         Button(action: { Task { try? await gitManager.stageAll() } }) {
107:                             Label("Stage All", systemImage: "plus.circle")
108:                         }
109:                         Button(action: commitAndPush) {
110:                             Label("Commit & Push", systemImage: "arrow.up.circle")
111:                         }
112:                     } label: {
113:                         Image(systemName: "ellipsis.circle")
114:                             .font(.system(size: 16))
115:                     }
116:                     .buttonStyle(.plain)
117:                 }
118:             }
119:             .padding(12)
120:             
121:             Divider()
122:             
123:             // Changes list
124:             ScrollView {
125:                 VStack(alignment: .leading, spacing: 4) {
126:                     // Staged changes
127:                     if !gitManager.stagedChanges.isEmpty {
128:                         sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
129:                         ForEach(gitManager.stagedChanges) { entry in
130:                             changeRow(entry, isStaged: true)
131:                         }
132:                     }
133:                     
134:                     // Unstaged changes
135:                     if !gitManager.unstagedChanges.isEmpty {
136:                         sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
137:                         ForEach(gitManager.unstagedChanges) { entry in
138:                             changeRow(entry, isStaged: false)
139:                         }
140:                     }
141:                     
142:                     // No changes
143:                     if gitManager.stagedChanges.isEmpty && gitManager.unstagedChanges.isEmpty {
144:                         VStack(spacing: 8) {
145:                             Image(systemName: "checkmark.circle")
146:                                 .font(.system(size: 24))
147:                                 .foregroundColor(.green)
148:                             Text("No changes")
149:                                 .font(.system(size: 12))
150:                                 .foregroundColor(.secondary)
151:                         }
152:                         .frame(maxWidth: .infinity)
153:                         .padding(.vertical, 20)
154:                     }
155:                     
156:                     // Recent commits
157:                     if !gitManager.recentCommits.isEmpty {
158:                         Divider()
159:                             .padding(.vertical, 8)
160:                         
161:                         sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
162:                         ForEach(gitManager.recentCommits.prefix(5)) { commit in
163:                             commitRow(commit)
164:                         }
165:                     }
166:                 }
167:                 .padding(.horizontal, 8)
168:                 .padding(.bottom, 8)
169:             }
170:             
171:             Spacer(minLength: 0)
172:             
173:             // Error display
174:             if let error = gitManager.error {
175:                 HStack {
176:                     Image(systemName: "exclamationmark.triangle")
177:                         .foregroundColor(.red)
178:                     Text(error)
179:                         .font(.system(size: 10))
180:                         .foregroundColor(.red)
181:                         .lineLimit(2)
182:                 }
183:                 .padding(8)
184:                 .background(Color.red.opacity(0.1))
185:                 .cornerRadius(6)
186:                 .padding(.horizontal, 12)
187:             }
188:             
189:             Divider()
190:             
191:             // Bottom actions
192:             HStack(spacing: 12) {
193:                 Button(action: pullChanges) {
194:                     HStack(spacing: 4) {
195:                         Image(systemName: "arrow.down.circle")
196:                         Text("Pull")
197:                         if gitManager.behindCount > 0 {
198:                             Text("(\(gitManager.behindCount))")
199:                                 .foregroundColor(.blue)
200:                         }
201:                     }
202:                 }
203:                 .font(.system(size: 11))
204:                 .buttonStyle(.plain)
205:                 
206:                 Button(action: pushChanges) {
207:                     HStack(spacing: 4) {
208:                         Image(systemName: "arrow.up.circle")
209:                         Text("Push")
210:                         if gitManager.aheadCount > 0 {
211:                             Text("(\(gitManager.aheadCount))")
212:                                 .foregroundColor(.orange)
213:                         }
214:                     }
215:                 }
216:                 .font(.system(size: 11))
217:                 .buttonStyle(.plain)
218:                 
219:                 Button(action: fetchChanges) {
220:                     Image(systemName: "arrow.triangle.2.circlepath")
221:                 }
222:                 .font(.system(size: 11))
223:                 .buttonStyle(.plain)
224:                 
225:                 Spacer()
226:             }
227:             .padding(12)
228:         }
229:         .background(Color(UIColor.systemBackground))
230:         .sheet(isPresented: $showBranchPicker) {
231:             BranchPickerSheet(gitManager: gitManager)
232:         }
233:     }
234:     
235:     private var canCommit: Bool {
236:         !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
237:     }
238:     
239:     private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
240:         HStack {
241:             Text(title)
242:                 .font(.system(size: 11, weight: .semibold))
243:                 .foregroundColor(.secondary)
244:             Text("\(count)")
245:                 .font(.system(size: 10))
246:                 .foregroundColor(color)
247:                 .padding(.horizontal, 6)
248:                 .padding(.vertical, 2)
249:                 .background(color.opacity(0.2))
250:                 .cornerRadius(8)
251:             Spacer()
252:         }
253:         .padding(.vertical, 4)
254:     }
255:     
256:     private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
257:         HStack(spacing: 8) {
258:             // Status indicator
259:             Text(entry.kind.rawValue.prefix(1).uppercased())
260:                 .font(.system(size: 10, weight: .bold, design: .monospaced))
261:                 .foregroundColor(entry.kind.color)
262:                 .frame(width: 16)
263:             
264:             // File name
265:             Text(entry.path.components(separatedBy: "/").last ?? entry.path)
266:                 .font(.system(size: 12))
267:                 .lineLimit(1)
268:             
269:             Spacer()
270:             
271:             // Stage/unstage button
272:             if isStaged {
273:                 Button(action: { unstageFile(entry.path) }) {
274:                     Image(systemName: "minus")
275:                         .font(.system(size: 10))
276:                         .foregroundColor(.red)
277:                 }
278:                 .buttonStyle(.plain)
279:             } else {
280:                 Button(action: { stageFile(entry.path) }) {
281:                     Image(systemName: "plus")
282:                         .font(.system(size: 10))
283:                         .foregroundColor(.green)
284:                 }
285:                 .buttonStyle(.plain)
286:             }
287:         }
288:         .padding(.vertical, 4)
289:         .padding(.horizontal, 8)
290:         .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
291:         .cornerRadius(4)
292:         .onTapGesture {
293:             selectedEntry = entry
294:         }
295:         .contextMenu {
296:             if isStaged {
297:                 Button(action: { unstageFile(entry.path) }) {
298:                     Label("Unstage Changes", systemImage: "minus.circle")
299:                 }
300:             } else {
301:                 Button(action: { stageFile(entry.path) }) {
302:                     Label("Stage Changes", systemImage: "plus.circle")
303:                 }
304:             }
305:             
306:             if !isStaged && entry.kind != .untracked {
307:                 Button(role: .destructive, action: {
308:                     Task { try? await gitManager.discardChanges(file: entry.path) }
309:                 }) {
310:                     Label("Discard Changes", systemImage: "trash")
311:                 }
312:             }
313:             
314:             Divider()
315:             
316:             Button(action: {
317:                 let url = URL(fileURLWithPath: entry.path)
318:                 editorCore.openFile(from: url)
319:             }) {
320:                 Label("Open File", systemImage: "doc.text")
321:             }
322:             
323:             Button(action: {
324:                 UIPasteboard.general.string = entry.path
325:             }) {
326:                 Label("Copy Path", systemImage: "doc.on.doc")
327:             }
328:         }
329:     }
330:     
331:     private func commitRow(_ commit: GitCommit) -> some View {
332:         VStack(alignment: .leading, spacing: 2) {
333:             HStack {
334:                 Text(commit.shortSHA)
335:                     .font(.system(size: 10, design: .monospaced))
336:                     .foregroundColor(.accentColor)
337:                 
338:                 Text(commit.message)
339:                     .font(.system(size: 11))
340:                     .lineLimit(1)
341:             }
342:             
343:             HStack {
344:                 Text(commit.author)
345:                     .font(.system(size: 10))
346:                     .foregroundColor(.secondary)
347:                 
348:                 Text("•")
349:                     .foregroundColor(.secondary)
350:                 
351:                 Text(commit.date, style: .relative)
352:                     .font(.system(size: 10))
353:                     .foregroundColor(.secondary)
354:             }
355:         }
356:         .padding(.vertical, 4)
357:         .padding(.horizontal, 8)
358:     }
359:     
360:     // MARK: - Actions
361:     
362:     private func refreshGit() {
363:         Task { await gitManager.refresh() }
364:     }
365:     
366:     private func stageFile(_ path: String) {
367:         Task { try? await gitManager.stage(file: path) }
368:     }
369:     
370:     private func unstageFile(_ path: String) {
371:         Task { try? await gitManager.unstage(file: path) }
372:     }
373:     
374:     private func commitChanges() {
375:         guard canCommit else { return }
376:         Task {
377:             try? await gitManager.commit(message: commitMessage)
378:             await MainActor.run { commitMessage = "" }
379:         }
380:     }
381:     
382:     private func commitAndPush() {
383:         guard canCommit else { return }
384:         Task {
385:             try? await gitManager.commit(message: commitMessage)
386:             await MainActor.run { commitMessage = "" }
387:             try? await gitManager.push()
388:         }
389:     }
390:     
391:     private func pullChanges() {
392:         Task { try? await gitManager.pull() }
393:     }
394:     
395:     private func pushChanges() {
396:         Task { try? await gitManager.push() }
397:     }
398:     
399:     private func fetchChanges() {
400:         Task { try? await gitManager.fetch() }
401:     }
402: }
403: 
404: // MARK: - Branch Picker Sheet
405: 
406: struct BranchPickerSheet: View {
407:     @ObservedObject var gitManager: GitManager
408:     @Environment(\.dismiss) private var dismiss
409:     @State private var newBranchName = ""
410:     @State private var showCreateBranch = false
411:     
412:     var localBranches: [GitBranch] {
413:         gitManager.branches.filter { !$0.isRemote }
414:     }
415:     
416:     var remoteBranches: [GitBranch] {
417:         gitManager.branches.filter { $0.isRemote }
418:     }
419:     
420:     var body: some View {
421:         NavigationView {
422:             List {
423:                 // Create new branch
424:                 Section {
425:                     if showCreateBranch {
426:                         HStack {
427:                             TextField("New branch name", text: $newBranchName)
428:                                 .textFieldStyle(.roundedBorder)
429:                             
430:                             Button("Create") {
431:                                 createBranch()
432:                             }
433:                             .disabled(newBranchName.isEmpty)
434:                         }
435:                     } else {
436:                         Button(action: { showCreateBranch = true }) {
437:                             Label("Create New Branch", systemImage: "plus.circle")
438:                         }
439:                     }
440:                 }
441:                 
442:                 // Local branches
443:                 Section("Local Branches") {
444:                     ForEach(localBranches) { branch in
445:                         Button(action: { checkout(branch.name) }) {
446:                             HStack {
447:                                 if branch.isCurrent {
448:                                     Image(systemName: "checkmark")
449:                                         .foregroundColor(.accentColor)
450:                                 }
451:                                 Text(branch.name)
452:                                     .foregroundColor(branch.isCurrent ? .accentColor : .primary)
453:                                 Spacer()
454:                             }
455:                         }
456:                         .buttonStyle(.plain)
457:                     }
458:                 }
459:                 
460:                 // Remote branches
461:                 if !remoteBranches.isEmpty {
462:                     Section("Remote Branches") {
463:                         ForEach(remoteBranches) { branch in
464:                             Button(action: { checkout(branch.name) }) {
465:                                 HStack {
466:                                     Text(branch.name)
467:                                         .foregroundColor(.secondary)
468:                                     Spacer()
469:                                 }
470:                             }
471:                             .buttonStyle(.plain)
472:                         }
473:                     }
474:                 }
475:             }
476:             .navigationTitle("Branches")
477:             .navigationBarTitleDisplayMode(.inline)
478:             .toolbar {
479:                 ToolbarItem(placement: .navigationBarTrailing) {
480:                     Button("Done") { dismiss() }
481:                 }
482:             }
483:         }
484:     }
485:     
486:     private func checkout(_ branch: String) {
487:         Task {
488:             try? await gitManager.checkout(branch: branch)
489:             await MainActor.run { dismiss() }
490:         }
491:     }
492:     
493:     private func createBranch() {
494:         guard !newBranchName.isEmpty else { return }
495:         Task {
496:             try? await gitManager.createBranch(name: newBranchName)
497:             await MainActor.run {
498:                 newBranchName = ""
499:                 showCreateBranch = false
500:                 dismiss()
501:             }
502:         }
503:     }
504: }
505: 


Now let me find and read DebugManager.swift:

>>>TOOL search
{"query": "class DebugManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "class DebugManager"


>>>TOOL search
{"query": "DebugManager", "glob": "**/*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
No matches found for "DebugManager"


Let me search for debug-related files:

>>>TOOL search
{"query": "Debug", "glob": "**/*Manager*.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[search]
Found 10 matches:
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:218: // MARK: - Debug Session
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:220: func startActiveDebugSession() {
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:225: startDebugSession(using: cfg)
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:228: func startDebugSession(using config: LaunchConfig) {
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:234: // For now, this wires into the existing UI-only DebugManager.
VSCodeiPadOS/VSCodeiPadOS/Services/LaunchManager.swift:235: DebugManager.shared.play()
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:8: /// for the Debug sidebar and breakpoint gutter markers.
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:10: final class DebugManager: ObservableObject {
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:11: static let shared = DebugManager()
VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift:308: // MARK: - Debug controls (UI only)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift (lines 1-393 of 393)
────────────────────────────────────────
1: import Foundation
2: import SwiftUI
3: import Foundation
4: 
5: /// UI-only debug state manager.
6: ///
7: /// This does not perform real debugging yet; it only provides observable state
8: /// for the Debug sidebar and breakpoint gutter markers.
9: @MainActor
10: final class DebugManager: ObservableObject {
11:     static let shared = DebugManager()
12: 
13:     enum SessionState: String {
14:         case stopped
15:         case running
16:         case paused
17: 
18:         var displayName: String {
19:             switch self {
20:             case .stopped: return "Stopped"
21:             case .running: return "Running"
22:             case .paused: return "Paused"
23:             }
24:         }
25: 
26:         var canStep: Bool { self == .paused }
27:         var canPlay: Bool { self != .running }
28:         var canStop: Bool { self != .stopped }
29:     }
30: 
31:     struct StackFrame: Identifiable, Hashable {
32:         let id = UUID()
33:         var function: String
34:         var file: String
35:         var line: Int
36:     }
37: 
38:     struct Breakpoint: Identifiable, Hashable {
39:         /// Stable id for list diffing.
40:         var id: String { "\(file)::\(line)" }
41: 
42:         /// File identifier (typically URL path, otherwise fileName).
43:         var file: String
44: 
45:         /// Line index as used by the editor UI (often 0-based).
46:         var line: Int
47: 
48:         /// Convenience for displaying in UI (1-based).
49:         var displayLine: Int { line + 1 }
50: 
51:         /// UI only for now; there is no real debugger yet.
52:         var isEnabled: Bool = true
53:     }
54: 
55:     struct Variable: Identifiable, Hashable {
56:         let id = UUID()
57:         var name: String
58:         var value: String
59:         var type: String
60:         var children: [Variable] = []
61:         
62:         /// Returns children as optional for OutlineGroup compatibility
63:         var optionalChildren: [Variable]? {
64:             children.isEmpty ? nil : children
65:         }
66:     }
67: 
68:     struct WatchExpression: Identifiable, Hashable {
69:         let id = UUID()
70:         var expression: String
71:         var value: String
72:     }
73: 
74:     struct ConsoleEntry: Identifiable, Hashable {
75:         let id = UUID()
76:         var message: String
77:         var kind: Kind
78:         var timestamp: Date = Date()
79:         
80:         enum Kind: String, Hashable {
81:             case input
82:             case output
83:             case error
84:             case warning
85:             case info
86:             case system
87:         }
88:         
89:         var prefix: String {
90:             switch kind {
91:             case .input: return ">"
92:             case .output: return "<"
93:             case .error: return "!"
94:             case .warning: return "⚠"
95:             case .info: return "i"
96:             case .system: return "•"
97:             }
98:         }
99:         
100:         var text: String {
101:             message
102:         }
103:     }
104: 
105:     // MARK: - Published state
106: 
107:     @Published var state: SessionState = .stopped
108: 
109:     /// Breakpoints by file identifier (typically URL path, otherwise fileName).
110:     @Published private(set) var breakpointsByFile: [String: Set<Int>] = [:]
111: 
112:     @Published var watchExpressions: [WatchExpression] = []
113:     @Published var variables: [Variable] = []
114:     @Published var callStack: [StackFrame] = []
115:     @Published var selectedFrameId: StackFrame.ID?
116:     @Published var consoleEntries: [ConsoleEntry] = []
117: 
118:     // MARK: - Convenience views of state (for UI plumbing)
119: 
120:     var allBreakpoints: [Breakpoint] {
121:         breakpointsByFile
122:             .flatMap { (file, lines) in
123:                 lines.map { Breakpoint(file: file, line: $0) }
124:             }
125:             .sorted {
126:                 if $0.file == $1.file { return $0.line < $1.line }
127:                 return $0.file < $1.file
128:             }
129:     }
130: 
131:     private init() {
132:         // Seed some UI data so the panels aren’t empty.
133:         watchExpressions = [
134:             WatchExpression(expression: "counter", value: "0"),
135:             WatchExpression(expression: "user.name", value: "\"Taylor\""),
136:         ]
137:     }
138:     
139:     // MARK: - Console Methods
140:     
141:     func submitConsole(input: String) {
142:         consoleEntries.append(ConsoleEntry(message: "> \(input)", kind: .input))
143:         // Simulate response
144:         consoleEntries.append(ConsoleEntry(message: "undefined", kind: .output))
145:     }
146:     
147:     func copyConsoleToClipboard() {
148:         let text = consoleEntries.map { $0.message }.joined(separator: "\n")
149:         UIPasteboard.general.string = text
150:     }
151:     
152:     func clearConsole() {
153:         consoleEntries.removeAll()
154:     }
155: 
156:     // MARK: - Breakpoints
157: 
158:     private func canonicalFileId(_ file: String) -> String {
159:         // Many call sites use URL.absoluteString; convert file:// URLs to paths so we
160:         // don't end up with duplicate breakpoint buckets for the same file.
161:         if let url = URL(string: file), url.isFileURL {
162:             return url.path
163:         }
164:         return file
165:     }
166: 
167:     /// Normalizes UI-provided line indices.
168:     ///
169:     /// The editor UI typically uses 0-based indices for line iteration. We clamp
170:     /// to a minimum of 0 to avoid negative values.
171:     private func canonicalLine(_ line: Int) -> Int {
172:         max(0, line)
173:     }
174: 
175:     func hasBreakpoint(file: String, line: Int) -> Bool {
176:         let fileId = canonicalFileId(file)
177:         let line = canonicalLine(line)
178:         return breakpointsByFile[fileId]?.contains(line) == true
179:     }
180: 
181:     func toggleBreakpoint(file: String, line: Int) {
182:         let fileId = canonicalFileId(file)
183:         let line = canonicalLine(line)
184: 
185:         // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
186:         var dict = breakpointsByFile
187:         var set = dict[fileId] ?? []
188: 
189:         if set.contains(line) {
190:             set.remove(line)
191:         } else {
192:             set.insert(line)
193:         }
194: 
195:         if set.isEmpty {
196:             dict.removeValue(forKey: fileId)
197:         } else {
198:             dict[fileId] = set
199:         }
200: 
201:         breakpointsByFile = dict
202:     }
203: 
204:     func setBreakpoint(file: String, line: Int, isEnabled: Bool) {
205:         // UI-only model currently treats "enabled" as "present/absent".
206:         // (Real debugger integration can extend this to store disabled breakpoints.)
207:         if isEnabled {
208:             if !hasBreakpoint(file: file, line: line) {
209:                 toggleBreakpoint(file: file, line: line)
210:             }
211:         } else {
212:             removeBreakpoint(file: file, line: line)
213:         }
214:     }
215: 
216:     func removeBreakpoint(file: String, line: Int) {
217:         let fileId = canonicalFileId(file)
218:         let line = canonicalLine(line)
219: 
220:         var dict = breakpointsByFile
221:         guard var set = dict[fileId] else { return }
222: 
223:         set.remove(line)
224:         if set.isEmpty {
225:             dict.removeValue(forKey: fileId)
226:         } else {
227:             dict[fileId] = set
228:         }
229:         breakpointsByFile = dict
230:     }
231: 
232:     func breakpoints(in file: String) -> [Breakpoint] {
233:         let fileId = canonicalFileId(file)
234:         let lines = breakpointsByFile[fileId] ?? []
235:         return lines.sorted().map { Breakpoint(file: fileId, line: $0) }
236:     }
237: 
238:     // MARK: - Watch expressions
239: 
240:     @discardableResult
241:     func addWatchExpression(_ expression: String, initialValue: String = "—") -> WatchExpression? {
242:         let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
243:         guard !trimmed.isEmpty else { return nil }
244: 
245:         // Avoid duplicates by expression text.
246:         if watchExpressions.contains(where: { $0.expression == trimmed }) {
247:             return watchExpressions.first(where: { $0.expression == trimmed })
248:         }
249: 
250:         let watch = WatchExpression(expression: trimmed, value: initialValue)
251:         var watches = watchExpressions
252:         watches.append(watch)
253:         watchExpressions = watches
254:         return watch
255:     }
256: 
257:     func removeWatchExpression(id: WatchExpression.ID) {
258:         var watches = watchExpressions
259:         watches.removeAll { $0.id == id }
260:         watchExpressions = watches
261:     }
262: 
263:     func updateWatchExpression(id: WatchExpression.ID, expression: String) {
264:         let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
265:         guard !trimmed.isEmpty else { return }
266:         guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }
267: 
268:         var watches = watchExpressions
269:         watches[idx].expression = trimmed
270:         watchExpressions = watches
271:     }
272: 
273:     func setWatchValue(id: WatchExpression.ID, value: String) {
274:         guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }
275:         var watches = watchExpressions
276:         watches[idx].value = value
277:         watchExpressions = watches
278:     }
279: 
280:     // MARK: - Variables
281: 
282:     func setVariables(_ newVariables: [Variable]) {
283:         variables = newVariables
284:     }
285: 
286:     func clearVariables() {
287:         variables = []
288:     }
289: 
290:     /// Updates the first variable matching `name` at the root level.
291:     func setRootVariableValue(name: String, value: String) {
292:         guard let idx = variables.firstIndex(where: { $0.name == name }) else { return }
293:         var vars = variables
294:         vars[idx].value = value
295:         variables = vars
296:     }
297: 
298:     func allBreakpointsSorted() -> [(file: String, line: Int)] {
299:         // Keep existing return type because the current UI code uses it.
300:         breakpointsByFile
301:             .flatMap { (file, lines) in lines.map { (file: file, line: $0) } }
302:             .sorted {
303:                 if $0.file == $1.file { return $0.line < $1.line }
304:                 return $0.file < $1.file
305:             }
306:     }
307: 
308:     // MARK: - Debug controls (UI only)
309: 
310:     func play() {
311:         // If paused, resume; if stopped, start a simulated session.
312:         if state == .stopped {
313:             callStack = [
314:                 StackFrame(function: "main()", file: "App.swift", line: 12),
315:                 StackFrame(function: "run()", file: "Runner.swift", line: 48),
316:                 StackFrame(function: "doWork()", file: "Worker.swift", line: 103)
317:             ]
318:             selectedFrameId = callStack.first?.id
319: 
320:             variables = [
321:                 Variable(name: "counter", value: "0", type: "Int"),
322:                 Variable(
323:                     name: "user",
324:                     value: "User(…)",
325:                     type: "User",
326:                     children: [
327:                         Variable(name: "id", value: "42", type: "Int"),
328:                         Variable(name: "name", value: "\"Taylor\"", type: "String")
329:                     ]
330:                 )
331:             ]
332:         }
333: 
334:         state = .running
335: 
336:         // Auto-pause quickly so step buttons make sense in the UI.
337:         DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
338:             Task { @MainActor in
339:                 guard let self else { return }
340:                 if self.state == .running { self.state = .paused }
341:             }
342:         }
343:     }
344: 
345:     func stop() {
346:         state = .stopped
347:         callStack = []
348:         variables = []
349:         selectedFrameId = nil
350:     }
351: 
352:     func stepOver() {
353:         guard state.canStep else { return }
354:         advanceTopFrameLine(by: 1)
355:     }
356: 
357:     func stepInto() {
358:         guard state.canStep else { return }
359:         advanceTopFrameLine(by: 1)
360:         // Pretend we stepped into a function.
361:         if let top = callStack.first {
362:             var cs = callStack
363:             cs.insert(StackFrame(function: "helper()", file: top.file, line: top.line), at: 0)
364:             callStack = cs
365:             selectedFrameId = callStack.first?.id
366:         }
367:     }
368: 
369:     private func advanceTopFrameLine(by delta: Int) {
370:         guard !callStack.isEmpty else { return }
371: 
372:         // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
373:         var cs = callStack
374:         cs[0].line += delta
375:         callStack = cs
376: 
377:         // Make the demo watch expression change a bit.
378:         if let idx = watchExpressions.firstIndex(where: { $0.expression == "counter" }) {
379:             var watches = watchExpressions
380:             let n = Int(watches[idx].value) ?? 0
381:             watches[idx].value = "\(n + delta)"
382:             watchExpressions = watches
383:         }
384: 
385:         if let varIdx = variables.firstIndex(where: { $0.name == "counter" }) {
386:             var vars = variables
387:             let n = Int(vars[varIdx].value) ?? 0
388:             vars[varIdx].value = "\(n + delta)"
389:             variables = vars
390:         }
391:     }
392: }
393: 


Now let me read GitView.swift:

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift (lines 1-505 of 505)
────────────────────────────────────────
1: import SwiftUI
2: 
3: // MARK: - Git View (Source Control Panel)
4: 
5: struct GitView: View {
6:     @ObservedObject private var gitManager = GitManager.shared
7:     @EnvironmentObject var editorCore: EditorCore
8:     @State private var commitMessage = ""
9:     @State private var selectedEntry: GitStatusEntry?
10:     @State private var showBranchPicker = false
11:     
12:     var body: some View {
13:         VStack(alignment: .leading, spacing: 0) {
14:             // Header
15:             HStack {
16:                 Text("SOURCE CONTROL")
17:                     .font(.system(size: 11, weight: .semibold))
18:                     .foregroundColor(.secondary)
19:                 Spacer()
20:                 
21:                 if gitManager.isLoading {
22:                     ProgressView()
23:                         .scaleEffect(0.6)
24:                 }
25:                 
26:                 Button(action: refreshGit) {
27:                     Image(systemName: "arrow.clockwise")
28:                         .font(.system(size: 12))
29:                 }
30:                 .buttonStyle(.plain)
31:                 .disabled(gitManager.isLoading)
32:             }
33:             .padding(.horizontal, 12)
34:             .padding(.vertical, 8)
35:             
36:             Divider()
37:             
38:             // Branch selector
39:             HStack {
40:                 Image(systemName: "arrow.triangle.branch")
41:                     .font(.system(size: 11))
42:                     .foregroundColor(.secondary)
43:                 
44:                 Button(action: { showBranchPicker = true }) {
45:                     HStack(spacing: 4) {
46:                         Text(gitManager.currentBranch)
47:                             .font(.system(size: 12, weight: .medium))
48:                         Image(systemName: "chevron.down")
49:                             .font(.system(size: 9))
50:                     }
51:                 }
52:                 .buttonStyle(.plain)
53:                 
54:                 Spacer()
55:                 
56:                 // Sync status
57:                 if gitManager.aheadCount > 0 || gitManager.behindCount > 0 {
58:                     HStack(spacing: 4) {
59:                         if gitManager.aheadCount > 0 {
60:                             HStack(spacing: 2) {
61:                                 Image(systemName: "arrow.up")
62:                                 Text("\(gitManager.aheadCount)")
63:                             }
64:                             .font(.system(size: 10))
65:                             .foregroundColor(.orange)
66:                         }
67:                         if gitManager.behindCount > 0 {
68:                             HStack(spacing: 2) {
69:                                 Image(systemName: "arrow.down")
70:                                 Text("\(gitManager.behindCount)")
71:                             }
72:                             .font(.system(size: 10))
73:                             .foregroundColor(.blue)
74:                         }
75:                     }
76:                 }
77:             }
78:             .padding(.horizontal, 12)
79:             .padding(.vertical, 6)
80:             .background(Color(UIColor.secondarySystemBackground))
81:             
82:             Divider()
83:             
84:             // Commit input
85:             VStack(spacing: 8) {
86:                 TextField("Message (press ⌘Enter to commit)", text: $commitMessage)
87:                     .textFieldStyle(.roundedBorder)
88:                     .font(.system(size: 12))
89:                 
90:                 HStack(spacing: 8) {
91:                     Button(action: commitChanges) {
92:                         HStack {
93:                             Image(systemName: "checkmark")
94:                             Text("Commit")
95:                         }
96:                         .frame(maxWidth: .infinity)
97:                         .padding(.vertical, 6)
98:                         .background(canCommit ? Color.accentColor : Color.gray.opacity(0.3))
99:                         .foregroundColor(.white)
100:                         .cornerRadius(6)
101:                     }
102:                     .disabled(!canCommit)
103:                     .buttonStyle(.plain)
104:                     
105:                     Menu {
106:                         Button(action: { Task { try? await gitManager.stageAll() } }) {
107:                             Label("Stage All", systemImage: "plus.circle")
108:                         }
109:                         Button(action: commitAndPush) {
110:                             Label("Commit & Push", systemImage: "arrow.up.circle")
111:                         }
112:                     } label: {
113:                         Image(systemName: "ellipsis.circle")
114:                             .font(.system(size: 16))
115:                     }
116:                     .buttonStyle(.plain)
117:                 }
118:             }
119:             .padding(12)
120:             
121:             Divider()
122:             
123:             // Changes list
124:             ScrollView {
125:                 VStack(alignment: .leading, spacing: 4) {
126:                     // Staged changes
127:                     if !gitManager.stagedChanges.isEmpty {
128:                         sectionHeader("Staged Changes", count: gitManager.stagedChanges.count, color: .green)
129:                         ForEach(gitManager.stagedChanges) { entry in
130:                             changeRow(entry, isStaged: true)
131:                         }
132:                     }
133:                     
134:                     // Unstaged changes
135:                     if !gitManager.unstagedChanges.isEmpty {
136:                         sectionHeader("Changes", count: gitManager.unstagedChanges.count, color: .orange)
137:                         ForEach(gitManager.unstagedChanges) { entry in
138:                             changeRow(entry, isStaged: false)
139:                         }
140:                     }
141:                     
142:                     // No changes
143:                     if gitManager.stagedChanges.isEmpty && gitManager.unstagedChanges.isEmpty {
144:                         VStack(spacing: 8) {
145:                             Image(systemName: "checkmark.circle")
146:                                 .font(.system(size: 24))
147:                                 .foregroundColor(.green)
148:                             Text("No changes")
149:                                 .font(.system(size: 12))
150:                                 .foregroundColor(.secondary)
151:                         }
152:                         .frame(maxWidth: .infinity)
153:                         .padding(.vertical, 20)
154:                     }
155:                     
156:                     // Recent commits
157:                     if !gitManager.recentCommits.isEmpty {
158:                         Divider()
159:                             .padding(.vertical, 8)
160:                         
161:                         sectionHeader("Recent Commits", count: gitManager.recentCommits.count, color: .secondary)
162:                         ForEach(gitManager.recentCommits.prefix(5)) { commit in
163:                             commitRow(commit)
164:                         }
165:                     }
166:                 }
167:                 .padding(.horizontal, 8)
168:                 .padding(.bottom, 8)
169:             }
170:             
171:             Spacer(minLength: 0)
172:             
173:             // Error display
174:             if let error = gitManager.error {
175:                 HStack {
176:                     Image(systemName: "exclamationmark.triangle")
177:                         .foregroundColor(.red)
178:                     Text(error)
179:                         .font(.system(size: 10))
180:                         .foregroundColor(.red)
181:                         .lineLimit(2)
182:                 }
183:                 .padding(8)
184:                 .background(Color.red.opacity(0.1))
185:                 .cornerRadius(6)
186:                 .padding(.horizontal, 12)
187:             }
188:             
189:             Divider()
190:             
191:             // Bottom actions
192:             HStack(spacing: 12) {
193:                 Button(action: pullChanges) {
194:                     HStack(spacing: 4) {
195:                         Image(systemName: "arrow.down.circle")
196:                         Text("Pull")
197:                         if gitManager.behindCount > 0 {
198:                             Text("(\(gitManager.behindCount))")
199:                                 .foregroundColor(.blue)
200:                         }
201:                     }
202:                 }
203:                 .font(.system(size: 11))
204:                 .buttonStyle(.plain)
205:                 
206:                 Button(action: pushChanges) {
207:                     HStack(spacing: 4) {
208:                         Image(systemName: "arrow.up.circle")
209:                         Text("Push")
210:                         if gitManager.aheadCount > 0 {
211:                             Text("(\(gitManager.aheadCount))")
212:                                 .foregroundColor(.orange)
213:                         }
214:                     }
215:                 }
216:                 .font(.system(size: 11))
217:                 .buttonStyle(.plain)
218:                 
219:                 Button(action: fetchChanges) {
220:                     Image(systemName: "arrow.triangle.2.circlepath")
221:                 }
222:                 .font(.system(size: 11))
223:                 .buttonStyle(.plain)
224:                 
225:                 Spacer()
226:             }
227:             .padding(12)
228:         }
229:         .background(Color(UIColor.systemBackground))
230:         .sheet(isPresented: $showBranchPicker) {
231:             BranchPickerSheet(gitManager: gitManager)
232:         }
233:     }
234:     
235:     private var canCommit: Bool {
236:         !commitMessage.isEmpty && !gitManager.stagedChanges.isEmpty
237:     }
238:     
239:     private func sectionHeader(_ title: String, count: Int, color: Color) -> some View {
240:         HStack {
241:             Text(title)
242:                 .font(.system(size: 11, weight: .semibold))
243:                 .foregroundColor(.secondary)
244:             Text("\(count)")
245:                 .font(.system(size: 10))
246:                 .foregroundColor(color)
247:                 .padding(.horizontal, 6)
248:                 .padding(.vertical, 2)
249:                 .background(color.opacity(0.2))
250:                 .cornerRadius(8)
251:             Spacer()
252:         }
253:         .padding(.vertical, 4)
254:     }
255:     
256:     private func changeRow(_ entry: GitStatusEntry, isStaged: Bool) -> some View {
257:         HStack(spacing: 8) {
258:             // Status indicator
259:             Text(entry.kind.rawValue.prefix(1).uppercased())
260:                 .font(.system(size: 10, weight: .bold, design: .monospaced))
261:                 .foregroundColor(entry.kind.color)
262:                 .frame(width: 16)
263:             
264:             // File name
265:             Text(entry.path.components(separatedBy: "/").last ?? entry.path)
266:                 .font(.system(size: 12))
267:                 .lineLimit(1)
268:             
269:             Spacer()
270:             
271:             // Stage/unstage button
272:             if isStaged {
273:                 Button(action: { unstageFile(entry.path) }) {
274:                     Image(systemName: "minus")
275:                         .font(.system(size: 10))
276:                         .foregroundColor(.red)
277:                 }
278:                 .buttonStyle(.plain)
279:             } else {
280:                 Button(action: { stageFile(entry.path) }) {
281:                     Image(systemName: "plus")
282:                         .font(.system(size: 10))
283:                         .foregroundColor(.green)
284:                 }
285:                 .buttonStyle(.plain)
286:             }
287:         }
288:         .padding(.vertical, 4)
289:         .padding(.horizontal, 8)
290:         .background(selectedEntry?.id == entry.id ? Color.accentColor.opacity(0.2) : Color.clear)
291:         .cornerRadius(4)
292:         .onTapGesture {
293:             selectedEntry = entry
294:         }
295:         .contextMenu {
296:             if isStaged {
297:                 Button(action: { unstageFile(entry.path) }) {
298:                     Label("Unstage Changes", systemImage: "minus.circle")
299:                 }
300:             } else {
301:                 Button(action: { stageFile(entry.path) }) {
302:                     Label("Stage Changes", systemImage: "plus.circle")
303:                 }
304:             }
305:             
306:             if !isStaged && entry.kind != .untracked {
307:                 Button(role: .destructive, action: {
308:                     Task { try? await gitManager.discardChanges(file: entry.path) }
309:                 }) {
310:                     Label("Discard Changes", systemImage: "trash")
311:                 }
312:             }
313:             
314:             Divider()
315:             
316:             Button(action: {
317:                 let url = URL(fileURLWithPath: entry.path)
318:                 editorCore.openFile(from: url)
319:             }) {
320:                 Label("Open File", systemImage: "doc.text")
321:             }
322:             
323:             Button(action: {
324:                 UIPasteboard.general.string = entry.path
325:             }) {
326:                 Label("Copy Path", systemImage: "doc.on.doc")
327:             }
328:         }
329:     }
330:     
331:     private func commitRow(_ commit: GitCommit) -> some View {
332:         VStack(alignment: .leading, spacing: 2) {
333:             HStack {
334:                 Text(commit.shortSHA)
335:                     .font(.system(size: 10, design: .monospaced))
336:                     .foregroundColor(.accentColor)
337:                 
338:                 Text(commit.message)
339:                     .font(.system(size: 11))
340:                     .lineLimit(1)
341:             }
342:             
343:             HStack {
344:                 Text(commit.author)
345:                     .font(.system(size: 10))
346:                     .foregroundColor(.secondary)
347:                 
348:                 Text("•")
349:                     .foregroundColor(.secondary)
350:                 
351:                 Text(commit.date, style: .relative)
352:                     .font(.system(size: 10))
353:                     .foregroundColor(.secondary)
354:             }
355:         }
356:         .padding(.vertical, 4)
357:         .padding(.horizontal, 8)
358:     }
359:     
360:     // MARK: - Actions
361:     
362:     private func refreshGit() {
363:         Task { await gitManager.refresh() }
364:     }
365:     
366:     private func stageFile(_ path: String) {
367:         Task { try? await gitManager.stage(file: path) }
368:     }
369:     
370:     private func unstageFile(_ path: String) {
371:         Task { try? await gitManager.unstage(file: path) }
372:     }
373:     
374:     private func commitChanges() {
375:         guard canCommit else { return }
376:         Task {
377:             try? await gitManager.commit(message: commitMessage)
378:             await MainActor.run { commitMessage = "" }
379:         }
380:     }
381:     
382:     private func commitAndPush() {
383:         guard canCommit else { return }
384:         Task {
385:             try? await gitManager.commit(message: commitMessage)
386:             await MainActor.run { commitMessage = "" }
387:             try? await gitManager.push()
388:         }
389:     }
390:     
391:     private func pullChanges() {
392:         Task { try? await gitManager.pull() }
393:     }
394:     
395:     private func pushChanges() {
396:         Task { try? await gitManager.push() }
397:     }
398:     
399:     private func fetchChanges() {
400:         Task { try? await gitManager.fetch() }
401:     }
402: }
403: 
404: // MARK: - Branch Picker Sheet
405: 
406: struct BranchPickerSheet: View {
407:     @ObservedObject var gitManager: GitManager
408:     @Environment(\.dismiss) private var dismiss
409:     @State private var newBranchName = ""
410:     @State private var showCreateBranch = false
411:     
412:     var localBranches: [GitBranch] {
413:         gitManager.branches.filter { !$0.isRemote }
414:     }
415:     
416:     var remoteBranches: [GitBranch] {
417:         gitManager.branches.filter { $0.isRemote }
418:     }
419:     
420:     var body: some View {
421:         NavigationView {
422:             List {
423:                 // Create new branch
424:                 Section {
425:                     if showCreateBranch {
426:                         HStack {
427:                             TextField("New branch name", text: $newBranchName)
428:                                 .textFieldStyle(.roundedBorder)
429:                             
430:                             Button("Create") {
431:                                 createBranch()
432:                             }
433:                             .disabled(newBranchName.isEmpty)
434:                         }
435:                     } else {
436:                         Button(action: { showCreateBranch = true }) {
437:                             Label("Create New Branch", systemImage: "plus.circle")
438:                         }
439:                     }
440:                 }
441:                 
442:                 // Local branches
443:                 Section("Local Branches") {
444:                     ForEach(localBranches) { branch in
445:                         Button(action: { checkout(branch.name) }) {
446:                             HStack {
447:                                 if branch.isCurrent {
448:                                     Image(systemName: "checkmark")
449:                                         .foregroundColor(.accentColor)
450:                                 }
451:                                 Text(branch.name)
452:                                     .foregroundColor(branch.isCurrent ? .accentColor : .primary)
453:                                 Spacer()
454:                             }
455:                         }
456:                         .buttonStyle(.plain)
457:                     }
458:                 }
459:                 
460:                 // Remote branches
461:                 if !remoteBranches.isEmpty {
462:                     Section("Remote Branches") {
463:                         ForEach(remoteBranches) { branch in
464:                             Button(action: { checkout(branch.name) }) {
465:                                 HStack {
466:                                     Text(branch.name)
467:                                         .foregroundColor(.secondary)
468:                                     Spacer()
469:                                 }
470:                             }
471:                             .buttonStyle(.plain)
472:                         }
473:                     }
474:                 }
475:             }
476:             .navigationTitle("Branches")
477:             .navigationBarTitleDisplayMode(.inline)
478:             .toolbar {
479:                 ToolbarItem(placement: .navigationBarTrailing) {
480:                     Button("Done") { dismiss() }
481:                 }
482:             }
483:         }
484:     }
485:     
486:     private func checkout(_ branch: String) {
487:         Task {
488:             try? await gitManager.checkout(branch: branch)
489:             await MainActor.run { dismiss() }
490:         }
491:     }
492:     
493:     private func createBranch() {
494:         guard !newBranchName.isEmpty else { return }
495:         Task {
496:             try? await gitManager.createBranch(name: newBranchName)
497:             await MainActor.run {
498:                 newBranchName = ""
499:                 showCreateBranch = false
500:                 dismiss()
501:             }
502:         }
503:     }
504: }
505: 


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift (lines 1-393 of 393)
────────────────────────────────────────
1: import Foundation
2: import SwiftUI
3: import Foundation
4: 
5: /// UI-only debug state manager.
6: ///
7: /// This does not perform real debugging yet; it only provides observable state
8: /// for the Debug sidebar and breakpoint gutter markers.
9: @MainActor
10: final class DebugManager: ObservableObject {
11:     static let shared = DebugManager()
12: 
13:     enum SessionState: String {
14:         case stopped
15:         case running
16:         case paused
17: 
18:         var displayName: String {
19:             switch self {
20:             case .stopped: return "Stopped"
21:             case .running: return "Running"
22:             case .paused: return "Paused"
23:             }
24:         }
25: 
26:         var canStep: Bool { self == .paused }
27:         var canPlay: Bool { self != .running }
28:         var canStop: Bool { self != .stopped }
29:     }
30: 
31:     struct StackFrame: Identifiable, Hashable {
32:         let id = UUID()
33:         var function: String
34:         var file: String
35:         var line: Int
36:     }
37: 
38:     struct Breakpoint: Identifiable, Hashable {
39:         /// Stable id for list diffing.
40:         var id: String { "\(file)::\(line)" }
41: 
42:         /// File identifier (typically URL path, otherwise fileName).
43:         var file: String
44: 
45:         /// Line index as used by the editor UI (often 0-based).
46:         var line: Int
47: 
48:         /// Convenience for displaying in UI (1-based).
49:         var displayLine: Int { line + 1 }
50: 
51:         /// UI only for now; there is no real debugger yet.
52:         var isEnabled: Bool = true
53:     }
54: 
55:     struct Variable: Identifiable, Hashable {
56:         let id = UUID()
57:         var name: String
58:         var value: String
59:         var type: String
60:         var children: [Variable] = []
61:         
62:         /// Returns children as optional for OutlineGroup compatibility
63:         var optionalChildren: [Variable]? {
64:             children.isEmpty ? nil : children
65:         }
66:     }
67: 
68:     struct WatchExpression: Identifiable, Hashable {
69:         let id = UUID()
70:         var expression: String
71:         var value: String
72:     }
73: 
74:     struct ConsoleEntry: Identifiable, Hashable {
75:         let id = UUID()
76:         var message: String
77:         var kind: Kind
78:         var timestamp: Date = Date()
79:         
80:         enum Kind: String, Hashable {
81:             case input
82:             case output
83:             case error
84:             case warning
85:             case info
86:             case system
87:         }
88:         
89:         var prefix: String {
90:             switch kind {
91:             case .input: return ">"
92:             case .output: return "<"
93:             case .error: return "!"
94:             case .warning: return "⚠"
95:             case .info: return "i"
96:             case .system: return "•"
97:             }
98:         }
99:         
100:         var text: String {
101:             message
102:         }
103:     }
104: 
105:     // MARK: - Published state
106: 
107:     @Published var state: SessionState = .stopped
108: 
109:     /// Breakpoints by file identifier (typically URL path, otherwise fileName).
110:     @Published private(set) var breakpointsByFile: [String: Set<Int>] = [:]
111: 
112:     @Published var watchExpressions: [WatchExpression] = []
113:     @Published var variables: [Variable] = []
114:     @Published var callStack: [StackFrame] = []
115:     @Published var selectedFrameId: StackFrame.ID?
116:     @Published var consoleEntries: [ConsoleEntry] = []
117: 
118:     // MARK: - Convenience views of state (for UI plumbing)
119: 
120:     var allBreakpoints: [Breakpoint] {
121:         breakpointsByFile
122:             .flatMap { (file, lines) in
123:                 lines.map { Breakpoint(file: file, line: $0) }
124:             }
125:             .sorted {
126:                 if $0.file == $1.file { return $0.line < $1.line }
127:                 return $0.file < $1.file
128:             }
129:     }
130: 
131:     private init() {
132:         // Seed some UI data so the panels aren’t empty.
133:         watchExpressions = [
134:             WatchExpression(expression: "counter", value: "0"),
135:             WatchExpression(expression: "user.name", value: "\"Taylor\""),
136:         ]
137:     }
138:     
139:     // MARK: - Console Methods
140:     
141:     func submitConsole(input: String) {
142:         consoleEntries.append(ConsoleEntry(message: "> \(input)", kind: .input))
143:         // Simulate response
144:         consoleEntries.append(ConsoleEntry(message: "undefined", kind: .output))
145:     }
146:     
147:     func copyConsoleToClipboard() {
148:         let text = consoleEntries.map { $0.message }.joined(separator: "\n")
149:         UIPasteboard.general.string = text
150:     }
151:     
152:     func clearConsole() {
153:         consoleEntries.removeAll()
154:     }
155: 
156:     // MARK: - Breakpoints
157: 
158:     private func canonicalFileId(_ file: String) -> String {
159:         // Many call sites use URL.absoluteString; convert file:// URLs to paths so we
160:         // don't end up with duplicate breakpoint buckets for the same file.
161:         if let url = URL(string: file), url.isFileURL {
162:             return url.path
163:         }
164:         return file
165:     }
166: 
167:     /// Normalizes UI-provided line indices.
168:     ///
169:     /// The editor UI typically uses 0-based indices for line iteration. We clamp
170:     /// to a minimum of 0 to avoid negative values.
171:     private func canonicalLine(_ line: Int) -> Int {
172:         max(0, line)
173:     }
174: 
175:     func hasBreakpoint(file: String, line: Int) -> Bool {
176:         let fileId = canonicalFileId(file)
177:         let line = canonicalLine(line)
178:         return breakpointsByFile[fileId]?.contains(line) == true
179:     }
180: 
181:     func toggleBreakpoint(file: String, line: Int) {
182:         let fileId = canonicalFileId(file)
183:         let line = canonicalLine(line)
184: 
185:         // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
186:         var dict = breakpointsByFile
187:         var set = dict[fileId] ?? []
188: 
189:         if set.contains(line) {
190:             set.remove(line)
191:         } else {
192:             set.insert(line)
193:         }
194: 
195:         if set.isEmpty {
196:             dict.removeValue(forKey: fileId)
197:         } else {
198:             dict[fileId] = set
199:         }
200: 
201:         breakpointsByFile = dict
202:     }
203: 
204:     func setBreakpoint(file: String, line: Int, isEnabled: Bool) {
205:         // UI-only model currently treats "enabled" as "present/absent".
206:         // (Real debugger integration can extend this to store disabled breakpoints.)
207:         if isEnabled {
208:             if !hasBreakpoint(file: file, line: line) {
209:                 toggleBreakpoint(file: file, line: line)
210:             }
211:         } else {
212:             removeBreakpoint(file: file, line: line)
213:         }
214:     }
215: 
216:     func removeBreakpoint(file: String, line: Int) {
217:         let fileId = canonicalFileId(file)
218:         let line = canonicalLine(line)
219: 
220:         var dict = breakpointsByFile
221:         guard var set = dict[fileId] else { return }
222: 
223:         set.remove(line)
224:         if set.isEmpty {
225:             dict.removeValue(forKey: fileId)
226:         } else {
227:             dict[fileId] = set
228:         }
229:         breakpointsByFile = dict
230:     }
231: 
232:     func breakpoints(in file: String) -> [Breakpoint] {
233:         let fileId = canonicalFileId(file)
234:         let lines = breakpointsByFile[fileId] ?? []
235:         return lines.sorted().map { Breakpoint(file: fileId, line: $0) }
236:     }
237: 
238:     // MARK: - Watch expressions
239: 
240:     @discardableResult
241:     func addWatchExpression(_ expression: String, initialValue: String = "—") -> WatchExpression? {
242:         let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
243:         guard !trimmed.isEmpty else { return nil }
244: 
245:         // Avoid duplicates by expression text.
246:         if watchExpressions.contains(where: { $0.expression == trimmed }) {
247:             return watchExpressions.first(where: { $0.expression == trimmed })
248:         }
249: 
250:         let watch = WatchExpression(expression: trimmed, value: initialValue)
251:         var watches = watchExpressions
252:         watches.append(watch)
253:         watchExpressions = watches
254:         return watch
255:     }
256: 
257:     func removeWatchExpression(id: WatchExpression.ID) {
258:         var watches = watchExpressions
259:         watches.removeAll { $0.id == id }
260:         watchExpressions = watches
261:     }
262: 
263:     func updateWatchExpression(id: WatchExpression.ID, expression: String) {
264:         let trimmed = expression.trimmingCharacters(in: .whitespacesAndNewlines)
265:         guard !trimmed.isEmpty else { return }
266:         guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }
267: 
268:         var watches = watchExpressions
269:         watches[idx].expression = trimmed
270:         watchExpressions = watches
271:     }
272: 
273:     func setWatchValue(id: WatchExpression.ID, value: String) {
274:         guard let idx = watchExpressions.firstIndex(where: { $0.id == id }) else { return }
275:         var watches = watchExpressions
276:         watches[idx].value = value
277:         watchExpressions = watches
278:     }
279: 
280:     // MARK: - Variables
281: 
282:     func setVariables(_ newVariables: [Variable]) {
283:         variables = newVariables
284:     }
285: 
286:     func clearVariables() {
287:         variables = []
288:     }
289: 
290:     /// Updates the first variable matching `name` at the root level.
291:     func setRootVariableValue(name: String, value: String) {
292:         guard let idx = variables.firstIndex(where: { $0.name == name }) else { return }
293:         var vars = variables
294:         vars[idx].value = value
295:         variables = vars
296:     }
297: 
298:     func allBreakpointsSorted() -> [(file: String, line: Int)] {
299:         // Keep existing return type because the current UI code uses it.
300:         breakpointsByFile
301:             .flatMap { (file, lines) in lines.map { (file: file, line: $0) } }
302:             .sorted {
303:                 if $0.file == $1.file { return $0.line < $1.line }
304:                 return $0.file < $1.file
305:             }
306:     }
307: 
308:     // MARK: - Debug controls (UI only)
309: 
310:     func play() {
311:         // If paused, resume; if stopped, start a simulated session.
312:         if state == .stopped {
313:             callStack = [
314:                 StackFrame(function: "main()", file: "App.swift", line: 12),
315:                 StackFrame(function: "run()", file: "Runner.swift", line: 48),
316:                 StackFrame(function: "doWork()", file: "Worker.swift", line: 103)
317:             ]
318:             selectedFrameId = callStack.first?.id
319: 
320:             variables = [
321:                 Variable(name: "counter", value: "0", type: "Int"),
322:                 Variable(
323:                     name: "user",
324:                     value: "User(…)",
325:                     type: "User",
326:                     children: [
327:                         Variable(name: "id", value: "42", type: "Int"),
328:                         Variable(name: "name", value: "\"Taylor\"", type: "String")
329:                     ]
330:                 )
331:             ]
332:         }
333: 
334:         state = .running
335: 
336:         // Auto-pause quickly so step buttons make sense in the UI.
337:         DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
338:             Task { @MainActor in
339:                 guard let self else { return }
340:                 if self.state == .running { self.state = .paused }
341:             }
342:         }
343:     }
344: 
345:     func stop() {
346:         state = .stopped
347:         callStack = []
348:         variables = []
349:         selectedFrameId = nil
350:     }
351: 
352:     func stepOver() {
353:         guard state.canStep else { return }
354:         advanceTopFrameLine(by: 1)
355:     }
356: 
357:     func stepInto() {
358:         guard state.canStep else { return }
359:         advanceTopFrameLine(by: 1)
360:         // Pretend we stepped into a function.
361:         if let top = callStack.first {
362:             var cs = callStack
363:             cs.insert(StackFrame(function: "helper()", file: top.file, line: top.line), at: 0)
364:             callStack = cs
365:             selectedFrameId = callStack.first?.id
366:         }
367:     }
368: 
369:     private func advanceTopFrameLine(by delta: Int) {
370:         guard !callStack.isEmpty else { return }
371: 
372:         // IMPORTANT: mutate via a copy so @Published emits reliably for collection changes.
373:         var cs = callStack
374:         cs[0].line += delta
375:         callStack = cs
376: 
377:         // Make the demo watch expression change a bit.
378:         if let idx = watchExpressions.firstIndex(where: { $0.expression == "counter" }) {
379:             var watches = watchExpressions
380:             let n = Int(watches[idx].value) ?? 0
381:             watches[idx].value = "\(n + delta)"
382:             watchExpressions = watches
383:         }
384: 
385:         if let varIdx = variables.firstIndex(where: { $0.name == "counter" }) {
386:             var vars = variables
387:             let n = Int(vars[varIdx].value) ?? 0
388:             vars[varIdx].value = "\(n + delta)"
389:             variables = vars
390:         }
391:     }
392: }
393: 


>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS/Views/Panels"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/Views/Panels/
   AIAssistantView.swift
   AIAssistantView.swift.backup
   AIAssistantView.swift.bak
   DebugConsoleView.swift
   DebugView.swift
   GitQuickActionsView.swift
   GitView.swift
   GitView.swift.broken
   GoToLineView.swift
   MarkdownPreviewView.swift
   MarkdownPreviewWrapper.swift
   OutlineView.swift
   OutputView.swift
   PanelView.swift
   ProblemsView.swift
   RunnerWarningView.swift
   SearchView.swift
   SearchView.swift.broken
   SettingsView.swift
   TerminalView.swift
   TerminalView.swift.bak
   TestView.swift
   TimelineView.swift
(cached)


>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift"}
>>>END

---

## 🔧 TOOL RESULTS

[read_file]
File: VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift (lines 1-233 of 233)
────────────────────────────────────────
1: //
2: //  SSHManager.swift
3: //  VSCodeiPadOS
4: //
5: //  Stub SSH Manager - TODO: Implement with SwiftNIO SSH
6: //  Add package: https://github.com/apple/swift-nio-ssh
7: //
8: 
9: import Foundation
10: import SwiftUI
11: 
12: // MARK: - SSH Connection Model
13: 
14: struct SSHConnectionConfig: Codable, Identifiable, Equatable {
15:     var id: UUID = UUID()
16:     var name: String
17:     var host: String
18:     var port: Int
19:     var username: String
20:     var authMethod: SSHAuthMethod
21:     var lastUsed: Date?
22:     
23:     enum SSHAuthMethod: Codable, Equatable {
24:         case password(String)
25:         case privateKey(key: String, passphrase: String?)
26:     }
27:     
28:     static func == (lhs: SSHConnectionConfig, rhs: SSHConnectionConfig) -> Bool {
29:         lhs.id == rhs.id
30:     }
31: }
32: 
33: // MARK: - SSH Manager Delegate Protocol
34: 
35: protocol SSHManagerDelegate: AnyObject {
36:     func sshManagerDidConnect(_ manager: SSHManager)
37:     func sshManagerDidDisconnect(_ manager: SSHManager, error: Error?)
38:     func sshManager(_ manager: SSHManager, didReceiveOutput text: String)
39:     func sshManager(_ manager: SSHManager, didReceiveError text: String)
40: }
41: 
42: // MARK: - SSH Client Errors
43: 
44: enum SSHClientError: Error, LocalizedError {
45:     case connectionFailed(String)
46:     case authenticationFailed
47:     case channelCreationFailed
48:     case invalidChannelType
49:     case notConnected
50:     case timeout
51:     case invalidPrivateKey
52:     case commandExecutionFailed(String)
53:     case notImplemented
54:     
55:     var errorDescription: String? {
56:         switch self {
57:         case .connectionFailed(let reason): return "Connection failed: \(reason)"
58:         case .authenticationFailed: return "Authentication failed"
59:         case .channelCreationFailed: return "Failed to create SSH channel"
60:         case .invalidChannelType: return "Invalid channel type"
61:         case .notConnected: return "Not connected to server"
62:         case .timeout: return "Connection timed out"
63:         case .invalidPrivateKey: return "Invalid private key format"
64:         case .commandExecutionFailed(let reason): return "Command execution failed: \(reason)"
65:         case .notImplemented: return "SSH not yet implemented - add SwiftNIO SSH package"
66:         }
67:     }
68: }
69: 
70: // MARK: - Command Output Types
71: 
72: /// Real-time output events from SSH command execution
73: enum SSHCommandOutput {
74:     case stdout(String)
75:     case stderr(String)
76:     case exit(Int)
77:     case error(Error)
78:     case timeout
79: }
80: 
81: /// Result of a completed SSH command
82: struct SSHCommandResult {
83:     let stdout: String
84:     let stderr: String
85:     let exitCode: Int
86:     let isTimedOut: Bool
87:     
88:     var isSuccess: Bool {
89:         return exitCode == 0 && !isTimedOut
90:     }
91: }
92: 
93: // MARK: - SSH Manager (Stub Implementation)
94: 
95: class SSHManager {
96:     weak var delegate: SSHManagerDelegate?
97:     
98:     private(set) var isConnected: Bool = false
99:     private(set) var currentConfig: SSHConnectionConfig?
100:     
101:     init() {}
102:     
103:     // MARK: - Connection Methods
104:     
105:     /// Connect with async/await
106:     func connect(config: SSHConnectionConfig) async throws {
107:         // TODO: Implement with SwiftNIO SSH
108:         throw SSHClientError.notImplemented
109:     }
110:     
111:     /// Connect with completion handler (for compatibility)
112:     func connect(config: SSHConnectionConfig, completion: @escaping (Result<Void, Error>) -> Void) {
113:         // TODO: Implement with SwiftNIO SSH
114:         completion(.failure(SSHClientError.notImplemented))
115:     }
116:     
117:     func disconnect() {
118:         isConnected = false
119:         currentConfig = nil
120:         delegate?.sshManagerDidDisconnect(self, error: nil)
121:     }
122:     
123:     // MARK: - Command Execution
124:     
125:     func executeCommand(_ command: String, timeout: TimeInterval = 30) async throws -> SSHCommandResult {
126:         // TODO: Implement with SwiftNIO SSH
127:         throw SSHClientError.notImplemented
128:     }
129:     
130:     func executeCommand(_ command: String, onOutput: @escaping (SSHCommandOutput) -> Void) async throws {
131:         // TODO: Implement with SwiftNIO SSH
132:         throw SSHClientError.notImplemented
133:     }
134:     
135:     // MARK: - Interactive Shell
136:     
137:     func startInteractiveShell() async throws {
138:         // TODO: Implement with SwiftNIO SSH
139:         throw SSHClientError.notImplemented
140:     }
141:     
142:     func sendInput(_ text: String) async throws {
143:         // TODO: Implement with SwiftNIO SSH
144:         throw SSHClientError.notImplemented
145:     }
146:     
147:     /// Send a command to the shell
148:     func send(command: String) {
149:         // TODO: Implement with SwiftNIO SSH
150:         delegate?.sshManager(self, didReceiveError: "SSH not implemented")
151:     }
152:     
153:     /// Send interrupt signal (Ctrl+C)
154:     func sendInterrupt() {
155:         // TODO: Implement with SwiftNIO SSH
156:     }
157:     
158:     /// Send tab for auto-completion
159:     func sendTab() {
160:         // TODO: Implement with SwiftNIO SSH
161:     }
162:     
163:     /// Send escape key
164:     func sendEscape() {
165:         // TODO: Implement with SwiftNIO SSH
166:     }
167:     
168:     func resizeTerminal(cols: Int, rows: Int) async throws {
169:         // TODO: Implement with SwiftNIO SSH
170:     }
171:     
172:     func closeShell() {
173:         // TODO: Implement with SwiftNIO SSH
174:     }
175:     
176:     deinit {
177:         disconnect()
178:     }
179: }
180: 
181: // MARK: - SSH Connection Store (Persistence)
182: 
183: class SSHConnectionStore: ObservableObject {
184:     static let shared = SSHConnectionStore()
185:     
186:     @Published var savedConnections: [SSHConnectionConfig] = []
187:     
188:     private let userDefaults = UserDefaults.standard
189:     private let storageKey = "ssh_saved_connections"
190:     
191:     init() {
192:         loadConnections()
193:     }
194:     
195:     func save(_ connection: SSHConnectionConfig) {
196:         var config = connection
197:         config.lastUsed = Date()
198:         
199:         if let index = savedConnections.firstIndex(where: { $0.id == config.id }) {
200:             savedConnections[index] = config
201:         } else {
202:             savedConnections.append(config)
203:         }
204:         
205:         persistConnections()
206:     }
207:     
208:     func delete(_ connection: SSHConnectionConfig) {
209:         savedConnections.removeAll { $0.id == connection.id }
210:         persistConnections()
211:     }
212:     
213:     func updateLastUsed(_ connection: SSHConnectionConfig) {
214:         if let index = savedConnections.firstIndex(where: { $0.id == connection.id }) {
215:             savedConnections[index].lastUsed = Date()
216:             persistConnections()
217:         }
218:     }
219:     
220:     private func loadConnections() {
221:         guard let data = userDefaults.data(forKey: storageKey),
222:               let connections = try? JSONDecoder().decode([SSHConnectionConfig].self, from: data) else {
223:             return
224:         }
225:         savedConnections = connections.sorted { ($0.lastUsed ?? .distantPast) > ($1.lastUsed ?? .distantPast) }
226:     }
227:     
228:     private func persistConnections() {
229:         guard let data = try? JSONEncoder().encode(savedConnections) else { return }
230:         userDefaults.set(data, forKey: storageKey)
231:     }
232: }
233: 


Now I have all the information needed. Let me compile my report.

>>>REPORT
# Git, Terminal, Debug Audit Results

## 📁 Files Examined:
1. `VSCodeiPadOS/VSCodeiPadOS/Services/GitManager.swift` (266 lines)
2. `VSCodeiPadOS/VSCodeiPadOS/Views/Panels/GitView.swift` (505 lines)
3. `VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift` (981 lines)
4. `VSCodeiPadOS/VSCodeiPadOS/Views/Panels/DebugView.swift` (233 lines)
5. `VSCodeiPadOS/VSCodeiPadOS/Services/DebugManager.swift` (393 lines)
6. `VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift` (233 lines)

---

## 🔴 GIT - 100% STUB

**GitManager.swift** (line 5 comment: "Minimal Git Manager - stub implementation")

| Operation | Status | Evidence |
|-----------|--------|----------|
| `refresh()` | STUB | Line 188-195: Only sets error message, no real git calls |
| `stage(file:)` | STUB | Line 197-198: `throw GitManagerError.sshNotConnected` |
| `stageAll()` | STUB | Line 201-202: throws |
| `unstage(file:)` | STUB | Line 205-206: throws |
| `commit(message:)` | STUB | Line 209-210: throws |
| `checkout(branch:)` | STUB | Line 213-214: throws |
| `createBranch(name:)` | STUB | Line 217-218: throws |
| `deleteBranch(name:)` | STUB | Line 220-221: throws |
| `pull()` | STUB | Line 225-226: throws |
| `push()` | STUB | Line 229-230: throws |
| `fetch()` | STUB | Line 257-258: throws |
| `stash*()` | STUB | Lines 233-243: all throw |
| `discard*()` | STUB | Lines 245-254: all throw |

**GitView.swift**: UI is COMPLETE (505 lines of working SwiftUI), but all operations fail because GitManager is stub.

---

## 🟡 TERMINAL - PARTIAL (Local works, SSH stub)

**TerminalView.swift + TerminalManager (embedded)**

### WORKING:
| Feature | Evidence |
|---------|----------|
| Local `help` command | Lines 648-661: Returns help text |
| Local `clear` command | Lines 663-664: Clears output |
| Local `echo` command | Lines 666-668: Echoes text |
| Local `date` command | Lines 670-671: Shows date |
| Local `whoami` command | Lines 673-674: Returns "ipad-user" |
| Local `history` command | Lines 676-679: Shows command history |
| Tab management | Lines 450-515: addTab, closeTab, split working |
| Copy/Paste | Lines 169-179: Clipboard operations |

### STUB (SSHManager.swift line 5: "Stub SSH Manager"):
| Feature | Evidence |
|---------|----------|
| `connect()` async | Line 106-108: `throw SSHClientError.notImplemented` |
| `connect()` callback | Line 112-115: returns `.failure(notImplemented)` |
| `executeCommand()` | Line 125-127: throws |
| `startInteractiveShell()` | Line 137-139: throws |
| `send(command:)` | Line 148-151: calls delegate with error |
| `sendInterrupt()` | Line 154-156: empty body |
| `sendTab()` | Line 159-161: empty body |

### WORKING (non-SSH):
| Feature | Evidence |
|---------|----------|
| SSHConnectionStore.save() | Lines 195-206: Persists to UserDefaults |
| SSHConnectionStore.load() | Lines 220-226: Loads from UserDefaults |

---

## 🔴 DEBUG - UI SIMULATION ONLY

**DebugManager.swift** (lines 5-8: "UI-only debug state manager... does not perform real debugging yet")

### WORKING (UI State Only):
| Feature | Evidence |
|---------|----------|
| `toggleBreakpoint()` | Lines 181-202: Manages breakpoint Set per file |
| `hasBreakpoint()` | Lines 175-179: Checks if breakpoint exists |
| `addWatchExpression()` | Lines 240-255: Adds to array, avoids duplicates |
| `removeWatchExpression()` | Lines 257-261: Removes from array |

### STUB/SIMULATION:
| Feature | Status | Evidence |
|---------|--------|----------|
| `play()` | SIMULATION | Lines 310-343: Creates FAKE call stack and variables |
| `stop()` | SIMULATION | Lines 345-350: Just clears fake state |
| `stepOver()` | SIMULATION | Lines 352-355: Just increments line number in fake data |
| `stepInto()` | SIMULATION | Lines 357-367: Inserts fake "helper()" frame |
| `submitConsole()` | SIMULATION | Lines 141-145: Always returns "undefined" |

**DebugView.swift**: Uses HARDCODED static data (lines 4-17), not even connected to DebugManager's fake data.

---

## SUMMARY

| Module | UI | Backend | Real Operations |
|--------|-----|---------|-----------------|
| **Git** | ✅ Complete | ❌ 100% Stub | ❌ None |
| **Terminal** | ✅ Complete | 🟡 Partial | ✅ Local commands only |
| **Debug** | ✅ Complete | ❌ Simulation | ❌ None |

### MISSING for Real Functionality:
1. **Git**: Needs SwiftNIO SSH integration to run git commands on remote server
2. **Terminal SSH**: Needs SwiftNIO SSH package implementation (referenced at line 6-7 of SSHManager.swift)
3. **Debug**: Needs actual debugger integration (DAP protocol or native debugger attachment)
>>>END
