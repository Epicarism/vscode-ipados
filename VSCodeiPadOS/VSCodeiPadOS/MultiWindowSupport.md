# Multi-Window Support for iPadOS 26+

## Overview

VS Code for iPadOS now supports full multi-window functionality, enabling users to:
- Open multiple editor windows simultaneously
- Drag files to create new windows
- Restore window state after app termination
- Optimize for Stage Manager

## Architecture

### Key Components

1. **SceneDelegate.swift** - Manages individual window scenes
   - Handles scene lifecycle (connect, disconnect, foreground, background)
   - Creates EditorCore instance per window
   - Implements state restoration
   - Updates window titles

2. **WindowStateManager.swift** - Centralized state management
   - Persists window states to UserDefaults
   - Manages window IDs and sessions
   - Creates new windows via `requestNewWindow()`
   - Captures and restores EditorCore state

3. **AppDelegate.swift** - Scene configuration
   - Configures scenes based on user activity
   - Distinguishes between file windows and workspace windows
   - Handles window cleanup on scene destruction
   - Optimizes for Stage Manager

4. **FileDragModifier.swift** - Drag & drop support
   - Enables dragging tabs to create new windows
   - Enables dragging files from file tree
   - Creates NSUserActivity for handoff

## Usage

### Creating New Windows

**Via Menu:**
```
File → New Window (⌘+⌥+N)
```

**Via Drag & Drop:**
- Drag a tab from the tab bar to the screen edge
- Drag a file from the file tree to the screen edge

**Programmatically:**
```swift
WindowStateManager.shared.requestNewWindow(
    with: fileURL,
    workspacePath: path
)
```

### State Restoration

Window state is automatically saved and restored:
- Open tabs and their content
- Active tab selection
- Cursor positions
- Sidebar state
- Unsaved changes

State is persisted:
- When scene goes to background
- When scene disconnects
- Before app termination

### Window Titles

Window titles automatically update to show:
- Active file name (e.g., "main.swift")
- Unsaved indicator (●) for modified files
- Workspace name when no file is active

Format: `[●] filename - VS Code`

## Implementation Details

### Scene Lifecycle

```
App Launch
    ↓
didFinishLaunchingWithOptions
    ↓
configurationForConnecting (determines scene type)
    ↓
willConnectTo (SceneDelegate)
    ↓
- Create EditorCore instance
- Restore state if available
- Handle file URL if opening file
- Update window title
    ↓
sceneDidBecomeActive (set as active window)
    ↓
[User interacts with window]
    ↓
sceneWillEnterForeground (restore state)
sceneDidEnterBackground (save state)
sceneDidDisconnect (cleanup and save)
```

### State Flow

```
User opens file in window
    ↓
EditorCore.openFile(from: url)
    ↓
WindowStateManager.captureState(from: editorCore, windowId: id)
    ↓
Save to UserDefaults
    ↓
App terminates
    ↓
App relaunches
    ↓
stateRestorationActivity (returns NSUserActivity)
    ↓
Scene scene(_:willConnectTo:options:)
    ↓
WindowStateManager.restoreState(to: editorCore, windowId: id)
    ↓
User sees restored window state
```

### Drag & Drop Flow

```
User starts dragging tab/file
    ↓
onDrag handler creates NSItemProvider
    ↓
Provider contains:
  - File URL (as NSString)
  - NSUserActivity with window info
    ↓
User drags to screen edge
    ↓
iPadOS creates new scene
    ↓
AppDelegate.configurationForConnecting
    ↓
Detects file/workspace in user activity
    ↓
Returns appropriate scene configuration
    ↓
SceneDelegate.willConnectTo
    ↓
Opens file in new window
```

## Stage Manager Optimization

The app is optimized for Stage Manager on iPadOS 16+:

1. **Scene Resizing** - Windows properly resize and adapt
2. **Window Titles** - Displayed in window switcher and stage thumbnails
3. **State Persistence** - Each window maintains its state independently
4. **Resource Management** - Each scene has its own EditorCore instance

## File Structure

```
VSCodeiPadOS/
├── App/
│   ├── AppDelegate.swift          # Scene configuration
│   └── VSCodeiPadOSApp.swift      # Main app entry
├── Services/
│   ├── WindowStateManager.swift   # State persistence
│   └── EditorCore.swift           # Per-window state
├── Utils/
│   └── FileDragModifier.swift     # Drag & drop
├── SceneDelegate.swift            # Window lifecycle
└── Info.plist                     # Scene manifest
```

## Configuration

### Info.plist

The following entries enable multi-window support:

```xml
<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
    <key>UISceneConfigurations</key>
    <dict>
        <key>UIWindowSceneSessionRoleApplication</key>
        <array>
            <dict>
                <key>UISceneConfigurationName</key>
                <string>Default Configuration</string>
                <key>UISceneDelegateClassName</key>
                <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
            </dict>
        </array>
    </dict>
</dict>
```

## Testing Checklist

- [ ] Create new window via menu (File → New Window)
- [ ] Create new window via keyboard shortcut (⌘+⌥+N)
- [ ] Drag tab to screen edge to create new window
- [ ] Drag file from file tree to create new window
- [ ] Open multiple windows with different files
- [ ] Verify window titles update correctly
- [ ] Verify unsaved indicator (●) appears
- [ ] Close window and verify state is saved
- [ ] Terminate app and relaunch
- [ ] Verify all windows restore with correct state
- [ ] Test with Stage Manager enabled
- [ ] Test window resizing in Stage Manager
- [ ] Test window switching in App Exposé

## Known Limitations

1. Maximum windows limited by iPadOS system limits (typically 4-6)
2. Window state stored in UserDefaults (not suitable for very large files)
3. Unsaved file content stored in memory (use with caution for large files)

## Future Enhancements

- [ ] Workspace-based windows (different folders in different windows)
- [ ] Window grouping and tabs within windows
- [ ] Enhanced drag & drop (drag between windows)
- [ ] Window layout presets
- [ ] iCloud sync for window state across devices
