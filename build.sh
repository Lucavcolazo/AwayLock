#!/bin/bash
# Compila y arma build/AwayLock.app universal (chip Apple e Intel), firmado ad hoc.
set -euo pipefail
cd "$(dirname "$0")"

ARCHS=(--arch arm64 --arch x86_64)
swift build -c release "${ARCHS[@]}"
BIN="$(swift build -c release "${ARCHS[@]}" --show-bin-path)/AwayLock"

# Se arma y firma fuera del proyecto: si la carpeta está en iCloud Drive (por ejemplo
# en el Escritorio), iCloud le agrega metadatos a la app y codesign se niega a firmarla.
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
APP="$STAGE/AwayLock.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
xattr -cr "$APP"
codesign --force --sign - "$APP"

rm -rf build/AwayLock.app
mkdir -p build
ditto --norsrc --noextattr "$APP" build/AwayLock.app

echo "Listo: build/AwayLock.app"
