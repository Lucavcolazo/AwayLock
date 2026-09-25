#!/bin/bash
# Compila y arma build/AwayLock.app (firmado ad hoc, para uso propio).
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=build/AwayLock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp .build/release/AwayLock "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
codesign --force --sign - "$APP"

echo "Listo: $APP"
