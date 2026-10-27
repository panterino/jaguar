#!/bin/sh
# Publica la web de la app (app.jaguarcode.org) en Cloudflare desde un build
# limpio. Un build con caché viejo dejó una vez a la web sin Firebase (sin
# clases ni comunidad), así que se revisa al final. Primera vez:
#   npx wrangler login
set -e
cd "$(dirname "$0")/../apps/jaguar"
flutter clean
flutter build web --release --pwa-strategy=none --no-web-resources-cdn
grep -q gstatic build/web/main.dart.js || { echo "El build no trae Firebase; no se publica."; exit 1; }
cd ../../cloudflare/app
npx --yes wrangler@4 deploy
