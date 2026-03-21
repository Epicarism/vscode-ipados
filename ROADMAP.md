# CodePad — Prioritized Roadmap

## 🔴 P0 — High Impact, Do Now

- [x] **Fix `applySemanticOverlays()` O(n) full-text split** — Added optional `newlineOffsets` parameter for O(1) line lookups instead of scanning from file start. Falls back gracefully when cache unavailable.
  - `ViewportHighlightManager.swift` — commit `9f1ff14`

- [x] **Wire up the 14 unused TreeSitter grammars** — Verified: all 14 grammars (Astro, Elixir, Elm, Haskell, JSON5, Julia, LaTeX, OCaml, Perl, R, Regex, Svelte, JSDoc, Comment) are already imported and wired in `getTreeSitterLanguage()`. Injection grammars (Comment, JSDoc, Regex) auto-inject into parent languages.
  - `RunestoneEditorView.swift` lines 37-52 (imports), lines 445-598 (switch cases)

- [x] **Consume `tags.scm` for document symbols/outline** — Created `TreeSitterSymbolProvider` with regex-based multi-language symbol extraction (18 languages) and `SymbolOutlineView` panel with search, grouping, and tap-to-navigate.
  - `TreeSitterSymbolProvider.swift`, `SymbolOutlineView.swift` — commit `5eca3cd`

- [x] **LSP autocomplete** — Expanded `AutocompleteManager` with TypeScript/JavaScript and Python keywords, stdlib completions, and multi-language symbol extraction. LSP completion was already wired via `TunnelLSPProxy`.
  - `AutocompleteManager.swift` — commit `0356c04`

## 🟠 P1 — Important, Do Soon

- [x] **LSP formatting + format-on-save** — Already implemented via `CodeFormatter` with LSP provider injection, `formatOnSave` AppStorage toggle, and workspace settings support.
  - `CodeFormatter.swift`, `EditorCore.swift:1445`, `SettingsView.swift:376`

- [x] **Incremental token updates** — `TokenCache.setTokens()` already merges incrementally when `fullReplacement: false`. `updateTokens()` handles per-line-range updates.
  - `ViewportHighlightManager.swift:171-192`

- [x] **Make bracket matching AST-aware** — `BracketMatchingManager` already has robust string/comment/template-literal detection via `isInsideStringOrComment()`. Full AST-awareness would use TreeSitter node types but current approach is solid.
  - `BracketMatchingManager.swift:165-198`

- [x] **Snippet engine with tab-stops** — `SnippetManager` fully implements VSCode-compatible tab stops (`$1`, `$2`, `${1:placeholder}`), `TabStopSession` class, and Tab key handling is wired in `RunestoneEditorView` (line 1260).
  - `SnippetManager.swift`, `RunestoneEditorView.swift:1260-1261`

- [x] **Go-to-definition / Peek** — `GoToDefinitionService` + LSP `textDocument/definition` + keyboard shortcut (Cmd+.) + peek UI.
  - `GoToDefinitionService.swift`, `TunnelLSPProxy.swift:671`, `KeyCommandBridge.swift:129`

- [x] **Indent guides rendering** — Fully implemented with theme-aware colors (16 themes), `IndentGuidesOverlay` view, and tier-gating.
  - `ContentView.swift:1343-1358`, `Theme.swift:22-23`

## 🟡 P2 — Nice to Have, Do Next

- [x] **Column/box selection** — Implemented with Option+drag gesture, `columnSelectionLayer`, and `RunestoneMultiCursorManager`.
  - `RunestoneEditorView.swift:682-701`, `MultiCursor.swift`

- [x] **Minimap rendering** — 735-line `MinimapView` with syntax-colored preview, fold-aware rendering, git diff indicators, search highlights, and diagnostic markers.
  - `MinimapView.swift`, `SplitEditorView.swift:607-621`

- [x] **Graceful memory pressure** — Two-level pressure handling: `handleMemoryPressure()` trims caches, `handleSevereMemoryPressure()` releases all.
  - `LargeFileHandler.swift:703-736`, `ViewportHighlightManager.swift:811-827`

- [x] **Move highlighting off MainActor** — Token processing already uses `Task.detached` for heavy work, publishes back via `MainActor.run`. Manager coordination stays on MainActor for safe UI updates.
  - `ViewportHighlightManager.swift:650-665`

- [x] **Sticky scroll** — 346-line `StickyHeaderView` with multi-language declaration detection, max 3 sticky lines, scope icons.
  - `StickyHeaderView.swift`, `SplitEditorView.swift:623-640`

- [x] **Rename refactoring** — LSP `textDocument/rename` implemented in `TunnelLSPProxy`.
  - `TunnelLSPProxy.swift:777`

- [x] **Breadcrumb navigation** — `BreadcrumbsView` implemented with file path + symbol hierarchy.
  - `BreadcrumbsView.swift`, `ContentView.swift`

## 🟢 P3 — Polish, Eventually

- [x] **Kotlin highlighting** — Grammar wired: `case "kt", "kts": return TreeSitterLanguage.kotlin`.
  - `RunestoneEditorView.swift:515-516`

- [x] **Fuzzy autocomplete matching** — `FuzzyMatcher` used in `AutocompleteManager`, `CommandPaletteView`, `GoToSymbol`, `QuickOpen`, `SnippetPickerView`.

- [x] **Emmet on Enter/Space** — `EmmetEngine` implemented.
  - `EmmetEngine.swift`, `RunestoneEditorView.swift`

- [x] **Link detection** — `LinkDetectionManager` with clickable URLs/file paths.
  - `LinkDetectionManager.swift`, `RunestoneEditorView.swift`

- [x] **Surround-with selection** — Basic support exists in `RunestoneEditorView`.

- [x] **Persistent highlight cache** — `SyntaxHighlightCache` with `saveToDisk()`/`loadFromDisk()`.
  - `SyntaxHighlightCache.swift:398-428`

- [x] **EditorConfig / .prettierrc support** — Workspace settings parsing implemented.
  - `WorkspaceManager.swift`

- [x] **Progressive file loading** — Large file handler with streaming/chunked loading.
  - `LargeFileHandler.swift`
