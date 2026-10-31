#!/usr/bin/env bash
set -euo pipefail

# Find Xcode Developer Directory
if [ -d "/Applications/Xcode-beta.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
    export PATH="/Applications/Xcode-beta.app/Contents/Developer/usr/bin:$PATH"
elif [ -d "/Applications/Xcode.app/Contents/Developer" ]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
    export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"
fi

echo "==> Using Xcode: $(xcodebuild -version | head -n 1)"
echo "==> Regenerating Xcode project with xcodegen..."
xcodegen generate

echo "==> Building iMuseWatch for watchOS Simulator..."
xcodebuild -project iMuseWatch.xcodeproj \
    -scheme iMuseWatch \
    -destination "generic/platform=watchOS Simulator" \
    build \
    CODE_SIGNING_ALLOWED=NO

echo "==> Running Unit Tests on watchOS Simulator..."
xcodebuild -project iMuseWatch.xcodeproj \
    -scheme iMuseWatch \
    -destination "platform=watchOS Simulator,name=Apple Watch Series 12 (46mm)" \
    test \
    CODE_SIGNING_ALLOWED=NO

echo "==> iMuseWatch build and tests completed successfully! 🎉"
