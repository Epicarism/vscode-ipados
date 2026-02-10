#!/bin/bash

# VSCodeiPadOS Editor Typing Test
# Tests: Launch app, tap editor, type code, test undo

set -e

echo "========================================"
echo "VSCodeiPadOS Editor Typing Test"
echo "========================================"

# Configuration
BUNDLE_ID="com.vscodeipad.VSCodeiPadOS"  # Correct bundle ID from project.pbxproj
OUTPUT_DIR="/tmp"

# Step 1: Get UDID
echo "\n[1] Getting iPad simulator UDID..."
UDID=$(idb list-targets | grep -i "ipad" | head -1 | awk '{print $1}')
if [ -z "$UDID" ]; then
    echo "ERROR: No iPad simulator found!"
    echo "Try: idb list-targets"
    exit 1
fi
echo "Found UDID: $UDID"

# Step 2: Launch the app
echo "\n[2] Launching VSCodeiPadOS app..."
idb launch --udid $UDID $BUNDLE_ID
sleep 3  # Wait for app to fully launch
echo "App launched!"

# Step 3: Take initial screenshot
echo "\n[3] Taking initial screenshot..."
idb screenshot --udid $UDID $OUTPUT_DIR/test2_initial.png
echo "Saved: $OUTPUT_DIR/test2_initial.png"

# Step 4: Tap on editor area (center of screen)
# iPad Pro 12.9" landscape: 1366x1024
# Editor area is roughly center-right (sidebar takes ~280px on left)
echo "\n[4] Tapping on editor area at (500, 400)..."
idb ui tap --udid $UDID 500 400
sleep 1
echo "Tapped editor area"

# Step 5: Type code
echo "\n[5] Typing code..."
idb ui text --udid $UDID 'func test() { print("hello") }'
sleep 1
echo "Typed: func test() { print(\"hello\") }"

# Step 6: Take screenshot after typing
echo "\n[6] Taking screenshot after typing..."
idb screenshot --udid $UDID $OUTPUT_DIR/test2_typed.png
echo "Saved: $OUTPUT_DIR/test2_typed.png"

# Step 7: Test undo with Cmd+Z
echo "\n[7] Testing undo (Cmd+Z)..."
# idb key event for Cmd+Z
idb ui key --udid $UDID 6 --modifier 1  # 6 = z key, modifier 1 = command
sleep 1
echo "Sent Cmd+Z"

# Step 8: Screenshot after undo
echo "\n[8] Taking screenshot after undo..."
idb screenshot --udid $UDID $OUTPUT_DIR/test2_undo.png
echo "Saved: $OUTPUT_DIR/test2_undo.png"

echo "\n========================================"
echo "Test Complete!"
echo "========================================"
echo "\nScreenshots saved to:"
echo "  - $OUTPUT_DIR/test2_initial.png"
echo "  - $OUTPUT_DIR/test2_typed.png"
echo "  - $OUTPUT_DIR/test2_undo.png"
echo "\nPlease examine screenshots to verify:"
echo "  1. App launched correctly"
echo "  2. Code was typed in editor"
echo "  3. Undo removed the text"
