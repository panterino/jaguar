# Jaguar Code en Snap Store y Flathub

Estado: archivos listos, sin publicar. Los dos son gratis.

## Snap Store (nombre `jaguar-code`, publicador angeloflowers)

Archivos: `snap/snapcraft.yaml`, `snap/gui/`, y el trabajo `snap` de `.github/workflows/escritorio.yml`.

Una sola vez, en una terminal con `snapcraft` instalado (en Linux, o `brew install snapcraft` en Mac):

1. `snapcraft login` con la cuenta de angeloflowers.
2. `snapcraft register jaguar-code` para reservar el nombre.
3. Crear la credencial para el repositorio:
   `snapcraft export-login --snaps jaguar-code --channels beta --acls package_access,package_push,package_release credenciales.txt`
4. En GitHub, Settings, Secrets and variables, Actions, crear el secreto `SNAPCRAFT_STORE_CREDENTIALS` con el contenido de `credenciales.txt`, y borrar el archivo.

Desde entonces, cada publicación (release) de GitHub compila el snap, lo adjunta como `JaguarCode-linux-x64.snap` y lo sube al canal `beta`. Mientras sea versión de prueba, se queda en `beta`; para pasarlo a estable: `snapcraft release jaguar-code <revisión> stable`.

Para probar sin publicar: Actions, Escritorio, Run workflow (deja la etiqueta vacía); el snap queda como artefacto.

Lo que no se ha probado: el primer build del snap. Si falla, se corrige con el registro de Actions.

## Flathub (`org.jaguarcode.JaguarCode`)

Archivos: `flatpak/` (manifiesto, metainfo, escritorio, ícono) y `tool/actualizar_flatpak.sh`.

- El identificador sale del dominio `jaguarcode.org`. Flathub lo verifica con un archivo en `https://jaguarcode.org/.well-known/org.flathub.VerifiedApps.txt`; el contenido (un código) lo da Flathub al aceptar la solicitud, y se agrega en `sitio/.well-known/`.
- Las capturas del metainfo están en `sitio/tiendas/` y salen con el despliegue de la landing.
- El manifiesto usa el `tar.gz` de Linux de la publicación. Para cada versión: `tool/actualizar_flatpak.sh X.Y.Z`.
- Para probar que compila: Actions, Flatpak, Run workflow. Hay que revisar que `runtime-version` (hoy 50) sea una versión vigente de GNOME en Flathub.
- Para enviarlo: bifurcar `github.com/flathub/flathub`, rama `new-pr`, copiar el manifiesto y los archivos de `flatpak/`, y abrir la solicitud. Un revisor la aprueba, a veces tarda semanas.

Limitaciones conocidas:
- El selector de archivos de la app usa `zenity`. El snap lo incluye; el Flatpak no, así que abrir y guardar archivos `.psc` puede fallar ahí hasta resolverlo.
- `--filesystem=home` es un permiso amplio y los revisores pueden pedir quitarlo.
- En Linux no están las clases ni la comunidad (Firebase no tiene versión para Linux).
