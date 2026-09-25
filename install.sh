#!/bin/bash
# Compila, instala AwayLock en /Applications y lo reinicia.
set -euo pipefail
cd "$(dirname "$0")"

./build.sh

pkill -x AwayLock 2>/dev/null && sleep 1 || true
rm -rf /Applications/AwayLock.app
cp -R build/AwayLock.app /Applications/
open /Applications/AwayLock.app

echo "Instalado en /Applications/AwayLock.app"
