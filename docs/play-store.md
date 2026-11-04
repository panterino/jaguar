# Google Play

Todo lo que hace falta para publicar Jaguar Code en Google Play. Los textos y las
imágenes están en `play/`; esto explica dónde va cada cosa en la consola.

La app ya existe en la consola (con algo de avance). Lo primero es revisar que su
nombre de paquete sea `io.github.panterino.jaguar`: el paquete se fija con la primera
subida y no se puede cambiar. Si la app de la consola se creó con otro, hay que crear
otra con este.

## El paquete

```sh
cd apps/jaguar
flutter build appbundle --release --obfuscate --split-debug-info=build/simbolos
```

Sale en `build/app/outputs/bundle/release/app-release.aab` y se firma con la llave de
subida (`android/key.properties`, que apunta a `claves/jaguar-upload.jks`, fuera del repo).
El código de versión sale del número después del `+` en `pubspec.yaml`; Google exige uno
mayor en cada subida.

Verificado en el de la 0.9.2 (24):

- Paquete `io.github.panterino.jaguar`, versión 0.9.2, código 24.
- `minSdk` 24 y `targetSdk` 36: cumple lo que Google pide desde el 31 de agosto de 2026
  (Android 16, API 36).
- Las bibliotecas nativas de 64 bits están alineadas a 16 KB (15 de 15), requisito para apps nuevas.
- Firmado con la llave de subida. Huella del certificado, para compararla en la consola
  (Integridad de la app, Firma de apps, Certificado de la clave de carga):
  - SHA-1: `6B:93:14:49:D0:E8:06:FC:0B:88:D2:72:49:BC:BF:C5:28:5E:B5:80`
  - SHA-256: `7B:4B:58:80:F2:3E:28:B1:BD:AB:45:0F:E5:09:B0:7A:8D:EC:EA:BE:57:D5:3F:10:B1:D9:EC:5E:87:F6:D0:BF`

  Si la app de la consola ya recibió una subida con otra llave, no van a coincidir: en
  ese caso hay que pedir el restablecimiento de la llave de carga en la consola.
- Guardar junto a cada versión los símbolos de Dart (`build/simbolos`), para leer errores
  ofuscados. Los símbolos nativos ya van dentro del paquete.

La primera vez, Google pregunta si administra la llave de firma de la app: decir que sí
(Play App Signing).

## Ficha principal

| Campo | Valor |
| --- | --- |
| Nombre (30) | `play/es-419/titulo.txt` |
| Descripción breve (80) | `play/es-419/descripcion-corta.txt` |
| Descripción completa (4000) | `play/es-419/descripcion-completa.txt` |
| Idioma | Español (Latinoamérica), es-419 |
| Categoría | Educación |
| Correo de contacto | uno que se revise: Google lo muestra y manda ahí los avisos de políticas |
| Sitio web | https://jaguarcode.org |
| Política de privacidad | https://app.jaguarcode.org/privacidad |

La ficha está en español porque la app lo está. Una ficha en inglés sería engañosa; si
más adelante hay versión en inglés de la app, se agrega.

## Imágenes

| Pieza | Archivo | Medida |
| --- | --- | --- |
| Ícono | `play/graficos/icono-512.png` | 512x512 PNG |
| Gráfico de funciones | `play/graficos/grafico-de-funciones-1024x500.png` | 1024x500 PNG sin transparencia |
| Capturas de teléfono (7) | `play/capturas-telefono/` | 1080x1920 |

Las capturas se tomaron de la app 0.9.2, en este orden: código, diagrama, consola,
prueba de escritorio, bloques, Ruta e Inicio. Google pide entre 2 y 8, con el lado largo
a lo más el doble del corto: por eso son 9:16 y no 9:20. Las de tableta (7 y 10 pulgadas)
son opcionales y no están hechas.

## Contenido de la app

En la consola, Política, Contenido de la app.

- **Política de privacidad:** la URL de arriba. Es una página estática, sin JavaScript.
  Antes de enviar, desplegar la web (`tool/publicar_web.sh`): el aviso ganó una sección
  con la cámara y con dónde viven los datos, para que coincida con lo de abajo.
- **Anuncios:** no tiene.
- **Acceso a la app:** casi todo funciona sin cuenta. Las clases del profesor piden una
  cuenta. Elegir "todo o parte requiere acceso" y dar un correo y una contraseña de
  profesor de prueba, que hay que crear en la app (https://app.jaguarcode.org, Clases,
  Entrar) y poner en el formulario, con una nota: "Sin cuenta se puede usar todo salvo
  las clases en línea".
- **ID de publicidad:** no lo usa.
- **Público objetivo:** 13 a 15, 16 a 17 y 18 o más. No marcar menores de 13: mete la app
  al programa de Familias, con más requisitos.
- **Clasificación de contenido (IARC):** categoría "Referencia, noticias o educación".
  Contenido generado por usuarios: sí (la comunidad comparte programas y ejercicios, y
  se pueden reportar). Chat o mensajes entre usuarios: no. Compras: no. Ubicación: no.
- **Aplicaciones de gobierno, finanzas, salud, noticias:** no.
- **Permisos:** `INTERNET` y `CAMERA` (solo para leer el QR de un ejercicio, y está
  declarada como opcional: la app funciona en equipos sin cámara).

### Seguridad de los datos

La app ya no usa los SDK de Firebase: habla con Authentication y Firestore por la red. Los
datos igual viven en Google Firebase, y Google lo trata como proveedor de servicios, no
como "compartir".

| Dato | Se recopila | Para qué | Opcional |
| --- | --- | --- | --- |
| Correo (solo profesores) | Sí | Cuenta | Sí |
| Nombre (alias, o nombre dentro de una clase) | Sí | Funciones de la app | Sí |
| ID de usuario (el anónimo de Firebase) | Sí | Cuenta y funciones de la app | Sí |
| Otro contenido de usuarios (programas, entregas, publicaciones) | Sí | Funciones de la app | Sí |
| Actividad en la app, otras acciones (cuántas líneas se pegaron en una entrega) | Sí | Funciones de la app | Sí |
| Ubicación, contactos, fotos y videos, audio, archivos, compras, identificadores del dispositivo | No | | |

- Los datos no se comparten con terceros.
- Los datos viajan cifrados.
- Se pueden borrar: en la app, Tu cuenta, Borrar mi cuenta. URL para pedirlo: la misma del
  aviso de privacidad (la sección "Tus derechos" lo explica).
- La cámara no cuenta como dato recopilado: la imagen se procesa en el teléfono y no se
  guarda ni se envía.
- La app de Android no mide visitas: Google Analytics solo está en la web, con tu permiso.

## Orden en la consola

1. Crear la versión en Pruebas internas, subir el `.aab`, y poner `play/es-419/novedades.txt`
   en las notas de la versión.
2. Llenar la ficha y las declaraciones de arriba (el panel de la consola dice qué falta).
3. Probar con tu cuenta y con quien se sume en Pruebas internas.
4. Pedir acceso a producción. Las cuentas personales nuevas pueden pedir antes una prueba
   cerrada con testers durante 14 días; tu cuenta, según
   dijiste, no lo pide. Si aparece, es la única parte que cambiaría.
5. Enviar a revisión. Las primeras revisiones tardan varios días.

## Estado de la consola (4 de noviembre de 2026)

La app está en la cuenta de desarrollador **JF Dev MX** (cuenta personal), como el borrador
«Jaguar: Aprende a programar», sin paquete subido todavía. En la misma cuenta hay otra, «Jaguar:
Aprende Facilmente» (`com.panterino.jaguar`, de 2021), que **Google eliminó** y tiene un problema de
políticas; no es esta y conviene saber por qué fue, porque cuenta en el historial de la cuenta.

Hecho en el borrador:

- Ficha principal: nombre, descripciones, ícono, gráfico de funciones y las 7 capturas.
- Política de privacidad, anuncios (no), ID de publicidad (no), apps gubernamentales (no),
  funciones financieras (ninguna) y apps de salud (ninguna).
- Seguridad de los datos: todo respondido y guardado como borrador, falta enviarlo.

Falta, y no lo puede hacer un asistente:

1. **Detalles de acceso:** pide un correo y una contraseña de profesor de prueba (hay que crear la
   cuenta en la app). Hasta que esté, la consola no deja llenar «Público objetivo y contenido», ni
   enviar la seguridad de los datos.
2. **Público objetivo y contenido:** 13 a 15, 16 a 17 y 18 o más.
3. **Clasificación del contenido:** el cuestionario IARC implica aceptar sus condiciones de servicio.
4. **Correo de contacto** de la ficha (obligatorio, y es público) y, si quieres, el sitio web
   https://jaguarcode.org.
5. **El `.aab`:** crear la versión en Pruebas internas y subirlo.
6. Declarar el estado de comerciante antes de febrero de 2027 (solo el dueño de la cuenta).

## Pendiente

- Capturas de tableta y, si se quiere, un video.
- Cambiar `mobile_scanner` por `flutter_zxing` (hace falta para F-Droid, no para Google Play).
