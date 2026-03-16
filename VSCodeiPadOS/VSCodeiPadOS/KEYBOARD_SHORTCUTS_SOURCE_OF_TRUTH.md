# Keyboard Shortcuts - Single Source of Truth

**IMPORTANT: This document defines where ALL keyboard shortcuts are implemented.**

## Architecture

There is NO `Menus/` folder. Keyboard shortcuts are defined in **three places**:

1. **`VSCodeiPadOSApp.swift`** — SwiftUI `.commands{}` block using `CommandGroup` + `.keyboardShortcut()`. These are menu-level commands available app-wide.
2. **`KeyCommandBridge.swift`** — UIKit `UIKeyCommand` bridge for iPadOS hardware keyboard support. Provides shortcuts via `override var keyCommands` on a view controller.
3. **`SyntaxHighlightingTextView.swift`** — Editor-specific UIKit `UIKeyCommand` shortcuts. Only active when the text editor has focus. Defined via `override var keyCommands` on the text view.

> **NOTE:** Some shortcuts may overlap across sources (e.g., ⌘/ for Toggle Comment appears in both VSCodeiPadOSApp.swift and SyntaxHighlightingTextView.swift). This is intentional — the UIKit `UIKeyCommand` versions ensure hardware keyboard support on iPadOS, while the SwiftUI `.keyboardShortcut()` versions cover the macOS menu bar and iPadOS command palette.

---

## Source 1: VSCodeiPadOSApp.swift

Location: `App/VSCodeiPadOSApp.swift` — inside the `@main` struct's `commands:` parameter.

### File Commands (CommandGroup: .newItem / after: .newItem)

| Shortcut | Action |
|----------|--------|
| ⌘N | New File |
| ⌘⌥N | New Window |
| ⌘S | Save |
| ⌘⌥S | Save All |
| ⌘W | Close Editor |

### Edit Commands (CommandGroup: after: .pasteboard)

| Shortcut | Action |
|----------|--------|
| ⌘F | Find |
| ⌘⌥H | Find and Replace |
| ⌘⌥↑ | Add Cursor Above (or Move Line Up) |
| ⌘⌥↓ | Add Cursor Below (or Move Line Down) |
| ⌘/ | Toggle Comment |

### View Commands (CommandGroup: replacing: .sidebar / after: .sidebar)

| Shortcut | Action |
|----------|--------|
| ⌘+ | Zoom In |
| ⌘- | Zoom Out |
| ⌘⇧B | Toggle Sidebar (likely) |
| ⌘⇧D | Toggle Debug Console (likely) |
| ⌘⇧R | Toggle Related (likely) |

### Navigation Commands

| Shortcut | Action |
|----------|--------|
| ⌘P | Go to File (Quick Open) |
| ⌘⇧O | Go to Symbol |
| ⌃G | Go to Line |
| ⌘↵ | Execute / Accept (context-dependent) |
| ⌃[ | Go Back |
| ⌃] | Go Forward |

### Terminal Commands

| Shortcut | Action |
|----------|--------|
| ⌃⇧` | Toggle Terminal |
| ⌘K | Clear Terminal |

### Help Commands (CommandGroup: replacing: .help)

| Shortcut | Action |
|----------|--------|
| ⌘/ | Toggle Comment (see Edit Commands — may be duplicated here) |

---

## Source 2: KeyCommandBridge.swift

Location: `Views/KeyCommandBridge.swift` — UIKit `UIKeyCommand` bridge.

Uses `override var keyCommands: [UIKeyCommand]?` to register hardware keyboard shortcuts for iPadOS. Shortcuts are constructed via `UIKeyCommand(title:action:input:modifierFlags:)`.

> **Note:** The full list of registered key commands in this file needs to be audited. Current implementation constructs commands dynamically — verify all expected shortcuts are present.

---

## Source 3: SyntaxHighlightingTextView.swift

Location: `Views/Editor/SyntaxHighlightingTextView.swift` — Editor-only shortcuts.

Uses `override var keyCommands: [UIKeyCommand]?` to register shortcuts active only when the text view is first responder.

| Shortcut | Action |
|----------|--------|
| Escape | Dismiss Autocomplete / Peek / Suggestion |
| Tab | Accept Autocomplete / Insert Tab |
| ⌘/ | Toggle Comment (also in VSCodeiPadOSApp.swift) |
| ⌥D | Peek Definition |
| ⌘⇧D | (context-dependent) |
| ⌘⇧R | (context-dependent) |

### Edit Menu Actions (when text is selected)

| Action | Description |
|--------|-------------|
| Go to Definition | Navigate to symbol definition |
| Peek Definition | Show definition inline |
| Find All References | Find all usages of symbol |
| Format Document | Format current file |
| Toggle Comment | Toggle line/block comment |

---

## Troubleshooting

### Duplicate Shortcut Warnings
If you see "keyboard shortcut already in use" warnings:
1. Check for overlapping `.keyboardShortcut()` entries in `VSCodeiPadOSApp.swift`
2. Check for overlapping `UIKeyCommand` entries between `KeyCommandBridge.swift` and `SyntaxHighlightingTextView.swift`
3. Some overlap is intentional (UIKit + SwiftUI paths)

### Adding a New Shortcut
1. **App-wide menu command:** Add a `Button` inside the appropriate `CommandGroup` in `VSCodeiPadOSApp.swift` with `.keyboardShortcut()`
2. **iPadOS hardware keyboard (global):** Register in `KeyCommandBridge.swift` via `UIKeyCommand`
3. **Editor-only (when typing):** Register in `SyntaxHighlightingTextView.swift` via `UIKeyCommand`

### Hardcoded Strings → Constants
**TODO:** Many keyboard shortcut key strings (e.g., `"n"`, `"s"`, `"f"`) are hardcoded inline in `VSCodeiPadOSApp.swift`. These should be extracted to named constants for maintainability and to avoid typos.

---

## Symbol Legend
- ⌘ = Command
- ⇧ = Shift  
- ⌥ = Option/Alt
- ⌃ = Control
- ↑↓←→ = Arrow keys
- ↵ = Return/Enter
- ` = Backtick/Tilde

---

## Audit Status

- [ ] Verify full list of KeyCommandBridge.swift registered commands
- [ ] Extract hardcoded shortcut strings to constants
- [ ] Ensure all VS Code parity shortcuts are implemented
- [ ] Remove any true duplicates (unintentional overlaps)
- [ ] Test all shortcuts on iPadOS hardware keyboard
