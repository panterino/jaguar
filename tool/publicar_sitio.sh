#!/bin/sh
# Publica la página de presentación (carpeta sitio/, jaguarcode.org) y el
# redireccionador de www en Cloudflare. Es HTML suelto, no hay que compilar
# nada, pero las guías y las páginas de retos se generan (tool/guias_html.dart
# y apps/jaguar/tool/retos_html.dart, que también arma el sitemap). Primera vez:
#   npx wrangler login
set -e
cd "$(dirname "$0")/.."
dart run tool/guias_html.dart
(cd apps/jaguar && dart run tool/retos_html.dart)
(cd cloudflare/landing && npx --yes wrangler@4 deploy)
(cd cloudflare/www && npx --yes wrangler@4 deploy)
