#!/bin/sh
# Publica la página de presentación (carpeta sitio/, jaguarcode.org) en
# Cloudflare. Es HTML suelto, no hay que compilar nada. Primera vez:
#   npx wrangler login
set -e
cd "$(dirname "$0")/../cloudflare/landing"
npx --yes wrangler@4 deploy
