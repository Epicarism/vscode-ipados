# Keyboard Shortcuts - Single Source of Truth

**IMPORTANT: This document defines where ALL keyboard shortcuts are implemented.**

## Architecture

Keyboard shortcuts are defined in ONE place only: the `Menus/` folder.

**DO NOT** define duplicate shortcuts in:
- `VSCodeiPadOSApp.swift` (removed inline structs)
- `Commands/AppCommands.swift` (not used in .commands{})
- `Views/Editor/SyntaxHighlightingTextView.swift` (only editor-specific shortcuts like Tab, Escape)
- `Views/Editor/MultiCursorTextView.swift` (inherits from SyntaxHighlightingTextView)

## Source Files (Menus/ folder)

### FileMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌘N | New File |
| ⌘⌥N | New Window |
| ⌘O | Open File |
| ⌘S | Save |
| ⌘⇧S | Save As |
| ⌘⌥S | Save All |
| ⌘W | Close Editor |
| ⌘⌥⇧W | Close All |

### EditMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌘Z | Undo |
| ⌘⇧Z | Redo |
| ⌘X | Cut |
| ⌘C | Copy |
| ⌘V | Paste |
| ⌘F | Find |
| ⌘⇧F | Find in Files |
| ⌘⌥F | Replace |
| ⌘H | Find and Replace |

### SelectionMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌘A | Select All |
| ⌃⇧⌘→ | Expand Selection |
| ⌃⇧⌘← | Shrink Selection |
| ⌥⇧↑ | Copy Line Up |
| ⌥⇧↓ | Copy Line Down |
| ⌥↑ | Move Line Up |
| ⌥↓ | Move Line Down |
| ⌥⌘↑ | Add Cursor Above |
| ⌥⌘↓ | Add Cursor Below |
| ⌥⇧I | Add Cursors to Line Ends |
| ⌘D | Add Next Occurrence |
| ⌘⇧L | Select All Occurrences |

### ViewMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌘⇧P | Command Palette |
| ⌘B | Toggle Sidebar |
| ⌘J | Toggle Panel |
| ⌘⇧E | Show Explorer |
| ⌘⇧F | Show Search |
| ⌃⇧G | Show Source Control |
| ⌘⇧X | Show Extensions |
| ⌘= | Zoom In |
| ⌘- | Zoom Out |

### GoMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌘P | Go to File (Quick Open) |
| ⌘T | Go to Symbol in Workspace |
| ⌘⇧O | Go to Symbol in Editor |
| ⌃⌘↓ | Go to Definition |
| ⇧⌃↓ | Go to References |
| ⌘G | Go to Line |
| ⌃- | Go Back |
| ⌃⇧= | Go Forward |
| ⌘⇧] | Next Editor |
| ⌘⇧[ | Previous Editor |

### TerminalMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⌃` | New Terminal |
| ⌘\ | Split Terminal |
| ⌘K | Clear Terminal |
| ⌘⌥R | Run Active File |
| ⌃⇧R | Run Selected Text |
| ⌘` | Toggle Terminal |

### RunMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| F5 | Start Debugging |
| ⌃F5 | Run Without Debugging |
| ⇧⌃F5 | Stop Debugging |
| ⌘⇧F5 | Restart Debugging |
| F10 | Step Over |
| F11 | Step Into |
| ⇧F11 | Step Out |
| F9 | Toggle Breakpoint |

### HelpMenuCommands.swift
| Shortcut | Action |
|----------|--------|
| ⇧⌘? | Welcome |
| ⌥⌘I | Toggle Developer Tools |

## Editor-Only Shortcuts (SyntaxHighlightingTextView.swift)

These are NOT menu shortcuts - they are UIKeyCommand for the text view only:

| Shortcut | Action |
|----------|--------|
| ⌥D | Peek Definition |
| Tab | Accept Autocomplete / Insert Tab |
| Escape | Dismiss Autocomplete/Peek |
| ⌘⌥[ | Fold Code |
| ⌘⌥] | Unfold Code |
| ⌘⇧A | AI Assistant |

## Troubleshooting Duplicate Warnings

If you see "keyboard shortcut already in use" warnings:

1. Check that `VSCodeiPadOSApp.swift` does NOT define inline menu structs
2. Check that the Menus/ folder files are the ONLY place defining these Commands structs
3. Ensure `AppCommands.swift` is NOT included in `.commands {}` block

## Symbol Legend
- ⌘ = Command
- ⇧ = Shift  
- ⌥ = Option/Alt
- ⌃ = Control
- ↑↓←→ = Arrow keys
