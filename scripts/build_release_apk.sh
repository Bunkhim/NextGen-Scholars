#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f android/keystore.properties ]; then
  echo "ERROR: android/keystore.properties missing."
  echo "Copy android/keystore.properties.example to android/keystore.properties and fill in the values."
  exit 1
fi

flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/app-symbols \
  --tree-shake-icons

echo ""
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "Symbols (keep for crash deobfuscation, NOT for the security team): build/app-symbols"
