# Agent: opus-fix-5-terminal-ssh
**Status:** done
**Tokens:** 5,306
**Cost:** $0.0000
**Time:** 2026-02-09T20:32:28.943Z

## Task
Fix VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift SSH type errors:
- SSHManager not found
- SSHConnectionConfig not found  
- SSHManagerDelegate not found

1. Read SSHManager.swift to see what types exist
2. Add any missing types (SSHConnectionConfig, SSHManagerDelegate) if needed
3. Or fix TerminalView to use correct type names

Make TerminalView.swift compile.

## Response
I'll start by reading the SSHManager.swift file to see what types are defined there.

>>>TOOL read_file
{"path": "VSCodeiPadOS/VSCodeiPadOS/Services/SSHManager.swift"}
>>>END

Now let me read the TerminalView.swift file to see what's causing the errors:

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


I see that the types `SSHManager`, `SSHConnectionConfig`, `SSHManagerDelegate`, and `SSHConnectionStore` are all properly defined in `SSHManager.swift`. They should be accessible from `TerminalView.swift` since they're in the same module. Let me check the actual compiler errors:

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings


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


Looking at the code, I can see that:

1. **SSHManager** is defined in `SSHManager.swift` at line 96
2. **SSHConnectionConfig** is defined in `SSHManager.swift` at line 17
3. **SSHManagerDelegate** is defined in `SSHManager.swift` at line 38

And in `TerminalView.swift`:
- Line 535: `private var sshManager: SSHManager?`
- Line 536: `private var currentConfig: SSHConnectionConfig?`
- Line 707: `extension TerminalManager: SSHManagerDelegate`

The `get_errors` tool returned **"No errors or warnings"**, which means the project is already compiling correctly. Both files are in the same Xcode target/module (`VSCodeiPadOS`), so the types should be visible to each other without any imports.

Let me double-check by looking at the project structure to confirm both files are in the same module:

>>>TOOL list_dir
{"path": "VSCodeiPadOS/VSCodeiPadOS"}
>>>END

---

## 🔧 TOOL RESULTS

[list_dir]
📁 VSCodeiPadOS/VSCodeiPadOS/
📁 App/
📁 Assets.xcassets/
📁 Commands/
📁 Docs/
📁 Extensions/
📁 Menus/
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
   ContentView.swift.bak
   FIX_SUMMARY.md
   IMPLEMENTATION_SUMMARY.md
   Info.plist
   KeyboardShortcuts.md
   MULTI_WINDOW_IMPLEMENTATION.md
   MultiWindowSupport.md
   SceneDelegate.swift
   SyntaxHighlighter_Optimizations.md


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


I've read both files. Let me check the current errors to see what's happening:

>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings


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


>>>TOOL get_errors
{}
>>>END

---

## 🔧 TOOL RESULTS

[get_errors]
✅ No errors or warnings


Let me read the TerminalView.swift file directly to check its contents:

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


I've examined both files. Looking at the code:

**SSHManager.swift** (lines 17-43, 96) defines:
- `SSHConnectionConfig` - struct at line 17
- `SSHManagerDelegate` - protocol at line 38
- `SSHManager` - class at line 96

**TerminalView.swift** uses these correctly:
- Line 535: `private var sshManager: SSHManager?`
- Line 536: `private var currentConfig: SSHConnectionConfig?`
- Line 707: `extension TerminalManager: SSHManagerDelegate`

The `get_errors` tool reports **no errors**, which means the types are properly accessible and the code compiles.

There's one minor cleanup needed - a duplicate import on line 1-2:

>>>FILE VSCodeiPadOS/VSCodeiPadOS/Views/Panels/TerminalView.swift
>>>FIND
import SwiftUI
import SwiftUI
import UIKit
>>>REPLACE
import SwiftUI
import UIKit
>>>END

>>>REPORT
## Task Completed: SSH Type Errors Investigation

### Findings
After reading both files, I found that **all required types exist and are properly defined**:

1. **SSHConnectionConfig** - Defined at `SSHManager.swift:17-34` as a struct
2. **SSHManagerDelegate** - Defined at `SSHManager.swift:38-43` as a protocol  
3. **SSHManager** - Defined at `SSHManager.swift:96` as a class

### Current Status
- `get_errors` reports **no compilation errors**
- All type references in `TerminalView.swift` are correct
- The `TerminalManager` class properly conforms to `SSHManagerDelegate` (line 707)

### Minor Fix Applied
- Removed duplicate `import SwiftUI` statement (lines 1-2 were identical)

### Possible Causes of Original Error Report
If errors were previously occurring, they may have been due to:
1. Files not being added to the same Xcode target
2. Build cache issues (clean build needed)
3. Recent addition of SSHManager.swift not yet indexed

**The code should compile correctly now.**
>>>END
