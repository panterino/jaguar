#!/bin/sh
# Genera los binarios para descargar en dist/ (carpeta que no se versiona).
#   tool/empaquetar.sh android   APK firmado con la llave de subida (ARM de 32 y 64 bits)
#   tool/empaquetar.sh macos     DMG sin notarizar (hace falta un Mac)
#   tool/empaquetar.sh todo      los dos
# Linux y Windows no se pueden compilar desde un Mac: los arma .github/workflows/escritorio.yml.
# Los nombres no llevan versión para que https://github.com/panterino/jaguar/releases/latest/download/<nombre>
# sea siempre la última.
set -e
raiz="$(cd "$(dirname "$0")/.." && pwd)"
dist="$raiz/dist"
cd "$raiz/apps/jaguar"
mkdir -p "$dist"

apk() {
  flutter build apk --release --target-platform android-arm,android-arm64 \
    --obfuscate --split-debug-info=build/simbolos
  cp build/app/outputs/flutter-apk/app-release.apk "$dist/JaguarCode-android.apk"
  echo "APK: $dist/JaguarCode-android.apk"
}

macos() {
  flutter build macos --release
  app="build/macos/Build/Products/Release/Jaguar Code.app"
  # Firma ad hoc: sin ella, en los Mac con chip de Apple la app ni siquiera abre.
  codesign --force --deep --sign - "$app"
  tmp="$(mktemp -d)"
  cp -R "$app" "$tmp/"
  ln -s /Applications "$tmp/Applications"
  rm -f "$dist/JaguarCode-macos.dmg"
  hdiutil create -volname "Jaguar Code" -srcfolder "$tmp" -ov -format UDZO "$dist/JaguarCode-macos.dmg" >/dev/null
  rm -rf "$tmp"
  echo "DMG: $dist/JaguarCode-macos.dmg"
}

case "${1:-todo}" in
  android) apk ;;
  macos) macos ;;
  todo) apk; macos ;;
  *) echo "Uso: tool/empaquetar.sh android|macos|todo"; exit 1 ;;
esac
(cd "$dist" && shasum -a 256 JaguarCode-* > SHA256SUMS.txt && cat SHA256SUMS.txt)
