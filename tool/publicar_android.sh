#!/bin/sh
# Sube un APK de prueba a Firebase App Distribution.
#   tool/publicar_android.sh "Notas de la versión"
# Solo ARM (todos los celulares reales) y ofuscado: unos 35 MB en vez de 57.
# Para Play Store: flutter build appbundle con las mismas opciones.
set -e
cd "$(dirname "$0")/../apps/jaguar"
flutter build apk --release --target-platform android-arm,android-arm64 \
  --obfuscate --split-debug-info=build/simbolos
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:860170749647:android:f854ea9492fb07131d19ba --project jaguarapp-50a15 \
  --release-notes "${1:-Versión de prueba}"
