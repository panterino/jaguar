#!/bin/sh
# Agrega Jaguar Code al menú de aplicaciones de tu usuario (no necesita permisos de administrador).
set -e
aqui="$(cd "$(dirname "$0")" && pwd)"
destino="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$destino"
sed "s|@RUTA@|$aqui|g" "$aqui/jaguar-code.desktop" > "$destino/jaguar-code.desktop"
chmod +x "$destino/jaguar-code.desktop"
echo "Listo: busca Jaguar Code en el menú de aplicaciones. No muevas esta carpeta de lugar."
