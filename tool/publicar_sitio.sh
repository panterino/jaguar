#!/bin/sh
# Publica la página de presentación (carpeta sitio/). Es HTML suelto, no hay
# que compilar nada.
set -e
cd "$(dirname "$0")/.."
firebase deploy --only hosting:sitio --project jaguarapp-50a15
