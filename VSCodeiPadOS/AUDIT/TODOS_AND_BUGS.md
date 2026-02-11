# 🐛 TODOs, FIXMEs, and Known Bugs

## 🔴 CRITICAL BUGS (From bugs.md)

These 3 bugs are documented but NOT FIXED:

### Bug 1: Shift+Arrow Selection Broken
**File:** Unknown (editor related)
**Issue:** Shift+arrow key selection doesn't work properly
**Impact:** Core editing functionality broken

### Bug 2: Cursor Position After Paste
**File:** Editor code
**Issue:** Cursor jumps to wrong position after pasting
**Impact:** Editing workflow disrupted

### Bug 3: Undo/Redo Stack Issues
**File:** Editor code
**Issue:** Undo doesn't always work correctly
**Impact:** Can lose work

---

## 📝 TODOs in Code

### TreeSitterLanguages.swift (30 TODOs)
All related to uncommenting language imports as they're added:

```swift
// Line 10+: "Uncomment these imports as TreeSitter packages are added"
// TODO: TreeSitterCppRunestone
// TODO: TreeSitterJavaRunestone  
// TODO: TreeSitterRubyRunestone
// TODO: TreeSitterPHPRunestone
// TODO: TreeSitterMarkdownRunestone
// TODO: TreeSitterYAMLRunestone
// TODO: TreeSitterDockerfileRunestone
// TODO: TreeSitterSQLRunestone
// TODO: TreeSitterGraphQLRunestone
// ... etc
```

**Action:** These are placeholders. Add TreeSitter packages as needed.

---

### NativeGitWriter.swift
**Line 296:** `// TODO: Wire this to GitManager`

**Action:** Connect NativeGitWriter to GitManager.commit() method.

---

### SSHManager.swift
**Line 5:** `// Stub SSH Manager - TODO: Implement with SwiftNIO SSH`

**Action:** Major implementation needed. See SSH_STATUS.md.

---

## ⚠️ FIXMEs in Code

### ContentView.swift
**Various lines:** Several FIXME comments about:
- State management complexity
- View extraction needed
- Performance concerns with large files

---

## 🔧 HACKs in Code

### SyntaxHighlightingTextView.swift
**Line ~1700:** Workaround for UITextView selection issues
**Line ~2100:** Hack for handling special characters

---

## 📋 Feature Gaps to Address

| Gap | Priority | Effort |
|-----|----------|--------|
| SSH not implemented | HIGH | 1-2 weeks |
| Git write operations stub | HIGH | 3-5 days |
| Pack file reading (large repos) | MEDIUM | 1 week |
| LSP support | LOW | Complex |
| On-device Python | LOW | Experimental |

---

## 🧪 Tests Needed

### Existing Tests (4 files)
- `ErrorParserTests.swift` ✅
- `NodeRunnerTests.swift` ✅
- `RemoteExecutionTests.swift` ✅
- `SearchIntegrationTests.swift` ✅

### Tests Missing
- [ ] Git operations (NativeGitReader)
- [ ] Theme switching
- [ ] Editor operations (cut/copy/paste)
- [ ] File operations (create/delete/rename)
- [ ] Syntax highlighting accuracy

---

## 📖 Documentation Outdated

### README.md
**Issues:**
- References non-existent files (BACKLOG.md, PROGRESS.md, AGENTS.md)
- Wrong xcodeproj name mentioned
- Setup instructions may be outdated

**Action:** Rewrite after cleanup.

---

## 🎯 Suggested Priority Order

### Week 1: Fix Critical Bugs
1. Fix Shift+Arrow selection
2. Fix cursor after paste
3. Fix undo/redo

### Week 2: Enable Git Writes
1. Wire NativeGitWriter to GitManager
2. Test local commits
3. Stage/unstage operations

### Week 3: SSH Foundation
1. Add SwiftNIO SSH package
2. Implement basic connection
3. Test with a server

### Week 4: Polish
1. Clean up code per this audit
2. Update documentation
3. Full test pass with FULL_FEATURE_TEST_PLAN.md
