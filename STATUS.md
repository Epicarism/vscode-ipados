# VSCode iPadOS — Project Status

**Last Updated:** 2026-03-16 01:53 UTC  
**Updated By:** Claude (Coordinator Agent)  
**Branch:** main (39 ahead of origin, needs rebase)

## 🔴 Critical Issues

| # | Issue | Status | Owner |
|---|-------|--------|-------|
| 1 | No `.gitignore` — 1.9GB build dir may be committed | 🔧 Fixing now | coordinator |
| 2 | Missing `PrivacyInfo.xcprivacy` — required for App Store since Spring 2024 | 🔧 Fixing now | coordinator |
| 3 | Tests exist (212) but no test target in Xcode project — can't run | ⚠️ Needs Xcode GUI | manual |
| 4 | Branch diverged from origin — needs `git pull --rebase` | ⚠️ Needs manual | manual |
| 5 | LICENSE says Proprietary but README says MIT — conflict | 🔧 Fixing now | coordinator |

## 🟡 High Priority Bugs

| # | Issue | File(s) | Status |
|---|-------|---------|--------|
| 1 | Duplicate file icon/color logic (inconsistent across 5 files) | FileItem, FileHelpers, FileIcons, FileManager+Extensions, ThemeManager | 🔧 Fixing now |
| 2 | Orphaned duplicate files cluttering project | RunnerSelector.existing.swift, RunestoneThemeAdapter 2.swift | 🔧 Fixing now |
| 3 | Workspace `replaceAll()` is destructive — no undo, no confirmation | FindViewModel.swift | 🔧 Fixing now |
| 4 | Security-scoped access bookkeeping may leak | EditorCore.swift | 🔧 Fixing now |
| 5 | `FileManager+Extension.swift` force unwrap on documents dir | FileManager+Extension.swift | 🔧 Fixing now |
| 6 | Duplicate FileManager extension files (singular vs plural) | FileManager+Extension(s).swift | 🔧 Fixing now |
| 7 | Debug `print()` statements throughout codebase | Multiple | 🔧 Fixing now |
| 8 | Empty catch blocks | Multiple | 🔧 Fixing now |

## 🟢 Features In Progress

| Feature | Completion | Notes |
|---------|------------|-------|
| Native Git | 70% | NativeGitReader done, GitView.swift missing, write ops missing |
| Runestone Editor | 95% | Code complete, packages need manual Xcode SPM add |
| On-Device LLM (Nanbeige) | 80% | Template fix done, debug logging in progress |
| Multi-Window / Stage Manager | ✅ 100% | Complete and tested |
| Keyboard Shortcuts | ✅ 100% | Complete, documented |
| Syntax Highlighting | ✅ 100% | 20+ languages via Tree-sitter |
| Theme System | ✅ 100% | 19 built-in themes |
| SSH/SFTP | 5% | All stubs, feature-flagged off |
| iCloud Sync | 0% | Feature-flagged off |
| Debugger | 0% | Feature-flagged off |
| Extension System | 30% | Basic framework exists |

## 🏗️ Architecture

```
App (SwiftUI) → ContentView → Views/ (Editor, Panels, Sidebar)
                             → Services/ (EditorCore, GitManager, AIManager, etc.)
                             → Models/ (Tab, Theme, FileItem, EditorState, etc.)
```

## 📋 Production Readiness Checklist

- [ ] .gitignore added
- [ ] PrivacyInfo.xcprivacy added
- [ ] Debug prints removed or gated behind flags
- [ ] Force unwraps replaced with safe alternatives
- [ ] Duplicate code consolidated
- [ ] Orphaned files removed
- [ ] All 26 TODOs triaged (fix or document)
- [ ] Test targets added to Xcode project
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] App icon finalized
- [ ] Launch screen configured
- [ ] Error handling audit
- [ ] Memory leak audit
- [ ] Accessibility audit (VoiceOver)
- [ ] Git rebase with origin
- [ ] License conflict resolved

## 📞 Communication

Other SWEs: Please update this file or create PRs. Check BACKLOG.md for tasks to pick up.
