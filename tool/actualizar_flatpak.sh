#!/bin/sh
# Pone en el manifiesto de Flatpak la versión nueva: la dirección del paquete de
# Linux de la publicación, su suma de verificación y la entrada en el metainfo.
#   tool/actualizar_flatpak.sh 0.8.2
# La publicación v0.8.2 ya debe existir en GitHub con JaguarCode-linux-x64.tar.gz.
set -e
[ -n "$1" ] || { echo "Uso: tool/actualizar_flatpak.sh VERSION"; exit 1; }
raiz="$(cd "$(dirname "$0")/.." && pwd)"
cd "$raiz/flatpak"
tmp="$(mktemp -d)"
curl -fsSL -o "$tmp/linux.tar.gz" "https://github.com/panterino/jaguar/releases/download/v$1/JaguarCode-linux-x64.tar.gz"
suma="$(shasum -a 256 "$tmp/linux.tar.gz" | cut -d' ' -f1)"
rm -rf "$tmp"
python3 - "$1" "$suma" <<'PY'
import re, sys, datetime
version, suma = sys.argv[1], sys.argv[2]
m = open('org.jaguarcode.JaguarCode.yml').read()
m = re.sub(r'releases/download/v[^/]+/', f'releases/download/v{version}/', m)
m = re.sub(r'sha256: [0-9a-f]{64}', f'sha256: {suma}', m)
open('org.jaguarcode.JaguarCode.yml', 'w').write(m)
x = open('org.jaguarcode.JaguarCode.metainfo.xml').read()
if f'version="{version}"' not in x:
    hoy = datetime.date.today().isoformat()
    x = x.replace('<releases>', f'<releases>\n    <release version="{version}" date="{hoy}"/>', 1)
open('org.jaguarcode.JaguarCode.metainfo.xml', 'w').write(x)
PY
echo "Manifiesto actualizado a $1 ($suma)"
