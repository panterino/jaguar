#!/bin/sh
# Genera las capturas del manual dentro de la app (assets/manual/*.webp) a
# partir de la propia app, con las fuentes reales. Requiere cwebp y ImageMagick.
set -e
cd "$(dirname "$0")/.."
out="${TMPDIR:-/tmp}/jaguar-capturas"
rm -rf "$out"; mkdir -p "$out" assets/manual
JAGUAR_CAPTURAS="$out" flutter test test/capturas/capturas_test.dart
for png in "$out"/*.png; do
  name=$(basename "$png" .png)
  width=540; [ "$name" = computadora ] && width=1100
  magick "$png" -resize "${width}x" "$out/$name-r.png"
  cwebp -quiet -q 80 "$out/$name-r.png" -o "assets/manual/$name.webp"
done
# computadora.webp (escritorio) se conserva a mano: en pruebas, los textos sin fuente propia salen como bloques.
echo "Listo: $(ls assets/manual | wc -l | tr -d ' ') imágenes en assets/manual"
