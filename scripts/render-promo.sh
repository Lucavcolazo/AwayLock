#!/bin/bash
# Genera dist/awaylock-promo.mp4 (1920×1080, 60 fps, 15 s) a partir de promo/.
# Levanta un servidor local solo mientras renderiza.
set -euo pipefail
cd "$(dirname "$0")/.."

python3 -m http.server 4174 --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER=$!
trap 'kill $SERVER 2>/dev/null' EXIT
sleep 1

mkdir -p dist
swift scripts/render-promo.swift dist/awaylock-promo.mp4
