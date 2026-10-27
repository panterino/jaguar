#!/bin/sh
# Último paso de la mudanza a Cloudflare: las tres direcciones viejas de
# Firebase Hosting redirigen a jaguarcode.org y app.jaguarcode.org (301). El
# navegador conserva lo que va después del #, así que los enlaces y QR ya
# compartidos siguen abriendo el programa. Corre solo cuando las direcciones
# nuevas ya funcionan.
set -e
cd "$(dirname "$0")/.."
firebase deploy --only hosting --config firebase.redirect.json --project jaguarapp-50a15
