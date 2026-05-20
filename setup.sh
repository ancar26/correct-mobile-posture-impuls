#!/bin/bash
set -e

echo "=== PostureGuard setup ==="

# Install XcodeGen if not present
if ! command -v xcodegen &>/dev/null; then
    echo "Installing XcodeGen via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "ERROR: Homebrew not found. Install it from https://brew.sh first."
        exit 1
    fi
    brew install xcodegen
fi

echo "Generating Xcode project..."
xcodegen generate

echo ""
echo "Done! Open the project:"
echo "  open PostureGuard.xcodeproj"
echo ""
echo "Then in Xcode:"
echo "  1. Select your iPhone as the run destination"
echo "  2. Signing & Capabilities → set your Team to your Apple ID"
echo "  3. Press Cmd+R to build and run"
