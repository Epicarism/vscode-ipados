# SWE Communication Log

## Last Updated: March 17, 2026 - 3:25 AM GMT+1

---

## 🟢 Current Status: BUILD SUCCEEDED (0 errors, 0 warnings)

### Latest Commits (newest first):
- `02e50cf` fix: HoverInfoView theme-aware colors, WelcomeView dynamic version, placeholder URL safety
- `98233cd` fix: Encoding/EOL settings now applied to saves, notification badge visibility
- `7ca080f` fix: GitView merge conflict UI, SearchView polish, RemoteExplorer improvements, editor cleanup
- `395463f` feat: Git merge conflicts, debug output wiring, status bar encoding, output panel polish
- `2a1d260` fix: SearchView theme, DebugView UX, ThemeManager 40+ colors, TerminalView concurrency
- `2a49012` feat: Watch expression eval, breakpoint sync, terminal auto-scroll, multi-encoding files
- `af43fc1` feat: Wire up Cmd+Z/Cmd+Shift+Z undo/redo keyboard shortcuts

---

## ✅ Issues RESOLVED Since Last Doc Update:

### Undo Stack (was: "polluted by highlighting changes")
- ✅ All 3 highlighting paths now use textStorage.beginEditing/endEditing
- ✅ applyHighlightingAsync (5k-10k chars), applyVisibleRangeHighlighting (10k+), applySyntaxHighlighting (small)
- ✅ Zero instances of `textView.attributedText =` in production code

### Encoding/EOL (was: "settings not applied to saves")
- ✅ StatusBar encoding picker now calls EditorCore.setActiveTabEncoding()
- ✅ StatusBar EOL picker now calls EditorCore.convertActiveTabEOL()
- ✅ EOL conversion normalizes CRLF/CR to LF then converts to target
- ✅ stringEncodingFromName() helper for all 8 supported encodings

### ExtensionsView Theme (was: "12+ hardcoded system colors")
- ✅ Complete theme overhaul - all 3 structs now use ThemeManager
- ✅ 39 Color(theme.xxx) references, 0 Color(UIColor...) references
- ✅ Search bar, filters, rows, detail view all theme-aware

### Merge Conflicts (was: "No merge conflict handling")
- ✅ GitView: merge conflict banner, conflict section, resolution UI (ours/theirs/manual)
- ✅ Notification observer for .gitMergeConflictsDetected

### HoverInfoView (was: "hardcoded dark-only color")
- ✅ Replaced with theme.editorBackground via ThemeManager

### WelcomeView (was: "placeholder URLs break Safari")
- ✅ Documentation/Release Notes links now safely log instead of opening broken URLs
- ✅ Dynamic version from Bundle.main instead of hardcoded "v1.0.0"

### Notification Badge (was: "invisible in dark mode")
- ✅ Changed from Color(.systemBackground) to .white for badge text

---

## 🔍 Remaining Open Issues:

### Critical:
- SSH private key auth broken (passes key as password - needs NIOSSHPrivateKey impl)
- Host key validation disabled (MITM risk - needs known_hosts support)

### High:
- SFTP upload limited to 100KB (base64 over SSH)
- Terminal only supports one SSH session (singleton SSHManager)
- AIAssistantView has 25+ hardcoded system colors (worst remaining theme offender)

### Medium:
- Debug step controls are simulated stubs in local mode (remote mode works)
- Exception breakpoints not connected to debugger
- Breakpoint conditions always nil (no UI to set conditions)
- Remote debugger onOutput callback not wired
- SearchView.SearchResultLine.matches array always empty (highlighted preview doesn't work)
- ~150 instances of .foregroundColor(.secondary) across views
- ~80 instances of Color(UIColor...) across views

### Low:
- TypeScript falls back to JavaScript TreeSitter grammar
- No TreeSitter for Ruby, PHP, Kotlin, C/C++, SQL
- ContentView IDEWelcomeView layout overflow on narrow screens
- DemoFileRow missing VoiceOver accessibility actions

---

## 📝 Notes for Other SWE:

### Build:
- **Target:** `iPad Pro 13-inch (M5)` simulator
- **Scheme:** `VSCodeiPadOS`

### Architecture:
- `EditorCore` is `@MainActor` - all published property access safe from SwiftUI views
- `SSHManager` is singleton with `@unchecked Sendable` - wrap Published mutations in MainActor
- `SSHConnectionStore` now uses Keychain for credentials (migration handled automatically)
- Port forwarding uses NIO ServerBootstrap + directTCPIP SSH channels
- `Tab.fileEncoding` stores detected encoding as UInt (String.Encoding.rawValue)
- `AppLogger`: use `.editor`, `.git`, `.ssh`, `.ai`, `.fileSystem` etc. (NO `.app`)
- `Notification+Names.swift` is the single source for all notification names
- `Theme` struct has: editorBackground, editorForeground, selection, cursor, lineNumber, lineNumberActive, currentLineHighlight, sidebarBackground, sidebarForeground, sidebarSectionHeader, sidebarSelection, activityBarBackground/Foreground/Selection, tabBarBackground, tabActive/InactiveBackground/Foreground, statusBarBackground/Foreground, keyword, string, number, comment, function, type, variable, bracketPair1-6, indentGuide/Active

### Files I'm Currently Working On:
- Breakpoint conditions UI
- Debug output wiring
- AIAssistantView theme compliance
- Continuing theme cleanup across remaining views

### Commit Convention:
- `fix:` for bug fixes
- `feat:` for new features  
- `refactor:` for code cleanup
- `docs:` for documentation
