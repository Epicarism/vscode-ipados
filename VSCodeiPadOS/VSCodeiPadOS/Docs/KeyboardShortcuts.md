# Keyboard Shortcuts - VSCode for iPadOS

This document provides a comprehensive list of keyboard shortcuts available in VSCode for iPadOS, including custom shortcuts adapted for iOS system compatibility.

## Table of Contents

- [File Operations](#file-operations)
- [Navigation](#navigation)
- [Editing](#editing)
- [View](#view)
- [Help](#help)
- [iOS System Conflicts](#ios-system-conflicts)

---

## File Operations

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+N` | New File | Create a new untitled file |
| `Cmd+S` | Save | Save the current file |
| `Cmd+Option+S` | Save All | Save all modified files |
| `Cmd+W` | Close Editor | Close the current editor tab |
| `Cmd+Option+Shift+W` | Close All | Close all editor tabs |

---

## Navigation

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+P` | Quick Open | Go to file by name |
| `Cmd+Shift+P` | Command Palette | Show all available commands |
| `Cmd+G` | Go to Line | Jump to a specific line number |
| `Cmd+Shift+O` | Go to Symbol | Navigate to symbol in current file |
| `F12` | Go to Definition | Jump to definition of symbol |
| `Option+F12` | Peek Definition | Preview definition inline |
| `Ctrl+-` | Go Back | Navigate back in location history |
| `Ctrl+Shift+-` | Go Forward | Navigate forward in location history |
| `Cmd+Shift+]` | Next Editor | Switch to the next editor tab |
| `Cmd+Shift+`[` | Previous Editor | Switch to the previous editor tab |

---

## Editing

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+Option+F` | Find in File | Open search in current file (custom - avoids iOS conflict) |
| `Cmd+Shift+F` | Find in Files | Search across all files in workspace |
| `Cmd+Option+H` | Replace | Open find and replace dialog |
| `F2` | Rename Symbol | Rename symbol under cursor |
| `Cmd+D` | Add Selection to Next Match | Add next occurrence to selection |
| `Cmd+Shift+L` | Select All Occurrences | Select all occurrences of current selection |

---

## View

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+B` | Toggle Sidebar | Show/hide the side bar |
| `Cmd+J` | Toggle Panel | Show/hide the bottom panel |
| `Cmd+`` | Toggle Terminal | Show/hide integrated terminal |
| `Cmd+=` | Zoom In | Increase editor font size |
| `Cmd+-` | Zoom Out | Decrease editor font size |
| `Cmd+Shift+E` | Focus Explorer | Set focus to file explorer |
| `Cmd+Shift+G` | Focus Git | Set focus to source control view |

---

## Help

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Cmd+Shift+A` | AI Assistant | Open AI Assistant panel |
| `Cmd+,` | Settings | Open user settings |

---

## iOS System Conflicts

Due to iOS system-level keyboard shortcuts, certain VSCode shortcuts have been remapped or behave differently on iPadOS:

### System Shortcuts That Override VSCode

| Standard VSCode | iOS Behavior | iPadOS Alternative |
|-----------------|--------------|-------------------|
| `Cmd+O` | Opens iOS file picker | Use `Cmd+P` (Quick Open) or touch the file browser |
| `Cmd+F` | iOS system find | Use `Cmd+Option+F` (custom find) |

### Notes

- **Cmd+O**: On iOS, this shortcut is handled by the system and opens the native iOS file picker/document browser. This is intentional and allows seamless integration with iOS Files app.

- **Cmd+F**: The standard VSCode "Find" shortcut conflicts with iOS system-wide find functionality. A custom shortcut `Cmd+Option+F` is provided instead to access find within files.

- **Custom Shortcuts**: Several shortcuts have been adapted specifically for iPadOS touch and keyboard input patterns while maintaining familiarity with desktop VSCode.

---

## Tips & Tricks

1. **External Keyboards**: For the best experience, use an external keyboard with iPadOS. All shortcuts listed above work with both:
   - Apple Magic Keyboard
   - Apple Smart Keyboard Folio
   - Third-party Bluetooth keyboards

2. **Modifier Keys**: You can customize modifier keys (Caps Lock, Control, Option, Command) in iPadOS Settings > General > Keyboard > Hardware Keyboard.

3. **Command Palette**: Access any command without memorizing shortcuts using `Cmd+Shift+P`.

4. **Key Repeat**: iPadOS supports key repeat for holding down keys, useful for navigation and editing operations.

---

*Last Updated: 2024*
*Version: 1.0.0*