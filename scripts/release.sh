#!/bin/bash
# Arma dist/AwayLock-<versión>.zip, listo para subir a un Release de GitHub.
# La versión sale de Resources/Info.plist (CFBundleShortVersionString).
set -euo pipefail
cd "$(dirname "$0")/.."

./build.sh

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Resources/Info.plist)
mkdir -p dist
ZIP="dist/AwayLock-$VERSION.zip"
rm -f "$ZIP"
# ditto arma el zip como el Finder y conserva la firma; sin metadatos de iCloud ni del Finder.
ditto -c -k --norsrc --noextattr --keepParent build/AwayLock.app "$ZIP"

echo "Listo: $ZIP"
shasum -a 256 "$ZIP"
