#!/bin/bash
# Compila y arma build/AwayLock.app (firmado ad hoc, para uso propio).
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP=build/AwayLock.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/AwayLock "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
codesign --force --sign - "$APP"

echo "Listo: $APP"
