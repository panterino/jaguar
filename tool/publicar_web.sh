#!/bin/sh
# Publica la web desde un build limpio. Un build con caché viejo dejó una vez
# a la web sin Firebase (sin clases ni comunidad), así que se revisa al final.
set -e
cd "$(dirname "$0")/../apps/jaguar"
flutter clean
flutter build web --release --pwa-strategy=none --no-web-resources-cdn
grep -q gstatic build/web/main.dart.js || { echo "El build no trae Firebase; no se publica."; exit 1; }
cd ../..
firebase deploy --only hosting:app --project jaguarapp-50a15
