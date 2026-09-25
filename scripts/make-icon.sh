#!/bin/bash
# Genera Resources/AppIcon.icns y docs/icon.png a partir de scripts/icon.swift.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

swift scripts/icon.swift "$WORK/icon-1024.png"

ICONSET="$WORK/AppIcon.iconset"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
    sips -z $size $size "$WORK/icon-1024.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    double=$((size * 2))
    sips -z $double $double "$WORK/icon-1024.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns

mkdir -p docs
sips -z 256 256 "$WORK/icon-1024.png" --out docs/icon.png >/dev/null

echo "Listo: Resources/AppIcon.icns y docs/icon.png"
