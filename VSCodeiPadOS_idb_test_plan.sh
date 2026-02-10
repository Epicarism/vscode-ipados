#!/bin/bash

# VSCodeiPadOS idb UI Testing Script
# This script tests the main UI navigation elements

set -e

echo "========================================"
echo "VSCodeiPadOS idb UI Navigation Test"
echo "========================================"

# Configuration
BUNDLE_ID="com.vscode.ipados"  # Update with actual bundle ID
DEVICE_ID=""  # Leave empty to use default booted simulator

# Step 1: Find booted iPad simulator
echo "\n[1] Finding booted iPad simulator..."
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(xcrun simctl list devices | grep "iPad" | grep "Booted" | head -1 | sed 's/.*\([A-F0-9]\{8\}-[A-F0-9]\{4\}-[A-F0-9]\{4\}-[A-F0-9]\{4\}-[A-F0-9]\{12\}\).*/\1/' | tr -d ' ') || true
    if [ -z "$DEVICE_ID" ]; then
        echo "ERROR: No booted iPad simulator found!"
        echo "Please boot an iPad simulator first:"
        echo "  xcrun simctl boot 'iPad Pro (12.9-inch) (6th generation)'"
        exit 1
    fi
fi
echo "Found device: $DEVICE_ID"

# Step 2: Launch the app
echo "\n[2] Launching VSCodeiPadOS app..."
idb launch $BUNDLE_ID
sleep 3  # Wait for app to fully launch

# Step 3: Take initial screenshot to determine coordinates
echo "\n[3] Taking initial screenshot..."
idb screenshot --output initial_screenshot.png
echo "Screenshot saved to: initial_screenshot.png"
echo "\nIMPORTANT: Open this screenshot to find exact coordinates!"

# Step 4: Test File Tree Sidebar
echo "\n========================================"
echo "[4] Testing File Tree Sidebar"
echo "========================================"

# 4a. Tap on Activity Bar Explorer icon (left side)
echo "\n[4a] Tapping Activity Bar Explorer icon..."
# Coordinates will need to be adjusted based on screenshot
# Typical iPad Pro 12.9" coordinates (left side of screen)
ACTIVITY_BAR_X=25
ACTIVITY_BAR_EXPLORER_Y=100
idb ui tap $ACTIVITY_BAR_X $ACTIVITY_BAR_EXPLORER_Y
sleep 1
idb screenshot --output sidebar_explorer.png
echo "Saved: sidebar_explorer.png"

# 4b. Try to expand a folder in file tree
echo "\n[4b] Attempting to expand folder in file tree..."
# File tree is typically in the sidebar area (left-center)
FOLDER_CHEVRON_X=100  # Adjust based on screenshot
FOLDER_CHEVRON_Y=200  # First folder row
idb ui tap $FOLDER_CHEVRON_X $FOLDER_CHEVRON_Y
sleep 1
idb screenshot --output folder_expanded.png
echo "Saved: folder_expanded.png"

# Step 5: Test Tab Bar
echo "\n========================================"
echo "[5] Testing Tab Bar"
echo "========================================"

# 5a. Tap on first tab (top area)
echo "\n[5a] Tapping first tab..."
TAB_BAR_Y=50  # Top of screen below status bar
FIRST_TAB_X=100
idb ui tap $FIRST_TAB_X $TAB_BAR_Y
sleep 1
idb screenshot --output tab1_selected.png
echo "Saved: tab1_selected.png"

# 5b. Try tapping a second tab (if exists)
echo "\n[5b] Tapping second tab..."
SECOND_TAB_X=260
idb ui tap $SECOND_TAB_X $TAB_BAR_Y
sleep 1
idb screenshot --output tab2_selected.png
echo "Saved: tab2_selected.png"

# Step 6: Test Panel/Terminal Area
echo "\n========================================"
echo "[6] Testing Panel/Terminal Area"
echo "========================================"

# 6a. Toggle terminal (try keyboard shortcut via notification or menu)
echo "\n[6a] Attempting to toggle terminal..."
echo "Note: Terminal toggle requires keyboard shortcut Cmd+J or Cmd+`"
echo "This may not work via idb tap - may need to use idb text"

# Try tapping in terminal area if visible
PANEL_TOGGLE_Y=700  # Bottom area of screen
PANEL_X=500
idb ui tap $PANEL_X $PANEL_TOGGLE_Y
sleep 1
idb screenshot --output panel_attempt.png
echo "Saved: panel_attempt.png"

# Step 7: Test Status Bar
echo "\n========================================"
echo "[7] Testing Status Bar"
echo "========================================"

# 7a. Tap on status bar items (bottom of screen)
echo "\n[7a] Tapping status bar cursor position..."
STATUS_BAR_Y=1020  # Bottom of iPad Pro 12.9"
STATUS_BAR_CENTER_X=512
idb ui tap $STATUS_BAR_CENTER_X $STATUS_BAR_Y
sleep 1
idb screenshot --output statusbar_tap.png
echo "Saved: statusbar_tap.png"

# 7b. Tap git branch indicator (left side of status bar)
echo "\n[7b] Tapping git branch indicator..."
STATUS_BAR_LEFT_X=100
idb ui tap $STATUS_BAR_LEFT_X $STATUS_BAR_Y
sleep 1
idb screenshot --output statusbar_git.png
echo "Saved: statusbar_git.png"

# Step 8: Test Command Palette (if accessible)
echo "\n========================================"
echo "[8] Testing Command Palette Access"
echo "========================================"
echo "Note: Command Palette requires Cmd+Shift+P"
echo "This may not work via simple tap commands"

# Final screenshot
echo "\n[9] Taking final screenshot..."
idb screenshot --output final_state.png
echo "Saved: final_state.png"

echo "\n========================================"
echo "Test Complete!"
echo "========================================"
echo "\nGenerated screenshots:"
echo "  - initial_screenshot.png"
echo "  - sidebar_explorer.png"
echo "  - folder_expanded.png"
echo "  - tab1_selected.png"
echo "  - tab2_selected.png"
echo "  - panel_attempt.png"
echo "  - statusbar_tap.png"
echo "  - statusbar_git.png"
echo "  - final_state.png"
echo "\nIMPORTANT NOTES:"
echo "1. Coordinates are approximate - adjust based on actual screenshot"
echo "2. iPad Pro 12.9" resolution: 1024x1366 (portrait) or 1366x1024 (landscape)"
echo "3. Use 'idb screenshot' before each tap to verify coordinates"
echo "4. Some features require keyboard shortcuts (Cmd+B, Cmd+J, Cmd+Shift+P)"
echo "5. Check accessibility identifiers in code for more reliable testing"
