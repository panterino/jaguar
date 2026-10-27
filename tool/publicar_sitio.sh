#!/bin/sh
# Publica la página de presentación (carpeta sitio/, jaguarcode.org) y el
# redireccionador de www en Cloudflare. Es HTML suelto, no hay que compilar
# nada, pero las guías se generan: dart run tool/guias_html.dart. Primera vez:
#   npx wrangler login
set -e
cd "$(dirname "$0")/.."
dart run tool/guias_html.dart
(cd cloudflare/landing && npx --yes wrangler@4 deploy)
(cd cloudflare/www && npx --yes wrangler@4 deploy)
