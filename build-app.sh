#!/bin/zsh
set -e
cd "$(dirname "$0")"
swift build -c release
rm -rf DevPorts.app
mkdir -p DevPorts.app/Contents/MacOS DevPorts.app/Contents/Resources
cp AppIcon.icns DevPorts.app/Contents/Resources/AppIcon.icns
cp .build/release/DevPorts DevPorts.app/Contents/MacOS/DevPorts
cat > DevPorts.app/Contents/Info.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>DevPorts</string>
    <key>CFBundleIdentifier</key><string>local.devports</string>
    <key>CFBundleName</key><string>DevPorts</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST
codesign --force --sign - DevPorts.app
echo "Built $(pwd)/DevPorts.app"
