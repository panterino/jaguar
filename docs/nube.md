# La nube

Jaguar funciona sin internet y sin cuenta. La nube solo hace falta para lo
que involucra a más de una persona: clases, tareas, entregas y la comunidad.
Si no hay conexión, esas opciones avisan que no hay conexión y lo demás sigue
funcionando.

Usamos Firebase, en el proyecto `jaguarapp-50a15` (plan gratuito, sin tarjeta y
sin plan de pago), para las clases, la comunidad y las cuentas. La app **no usa
los SDK de Firebase**: habla con Authentication y Firestore por sus API REST,
en Dart puro (`lib/src/cloud/firebase_rest.dart`), y por eso es igual en Android,
iOS, Mac, Windows, Linux y la web, y no lleva código nativo de Google (lo que
piden tiendas como F-Droid). La interfaz es `CloudBackend`
(`lib/src/cloud/cloud_backend.dart`): `RestBackend` es la que se usa y
`MemoryBackend` la de las pruebas. Si algún día hay que cambiar de servicio, solo
se escribe otra implementación.

La web se sirve desde Cloudflare: la app en
https://app.jaguarcode.org y la página de presentación en
https://jaguarcode.org. Las direcciones viejas de Firebase
(`jaguar-edu.web.app`, `pseudocodigo-jaguar.web.app` y `jaguarapp-50a15.web.app`)
redirigen a las nuevas conservando lo que va después del `#`, para que los
enlaces ya compartidos sigan abriendo. En Firebase Authentication, los dominios
`jaguarcode.org` y `app.jaguarcode.org` deben estar en Dominios autorizados.

## Cuentas

Los alumnos y quienes aprenden por su cuenta entran solo con un alias, con una
cuenta anónima que vive en su dispositivo. Los profesores usan correo y
contraseña, para no perder sus clases si cambian de computadora. Hay que
activar los dos métodos en la consola, en Authentication → Sign-in method.

## Datos

- `users/{uid}`: alias, rol y las clases a las que se unió. Solo lo ve su dueño.
- `classes/{id}` y `classCodes/{código}`: la clase y su código para unirse. Los
  códigos no se pueden listar; solo se encuentran si ya los conoces, y los nuevos
  tienen 8 caracteres (`JAG-K7Q4M2XP`) para que no se puedan encontrar probando
  (los primeros eran de 4 y siguen sirviendo). La clase tiene `open`: el
  profesor la cierra y nadie nuevo se une; quien ya estaba sigue.
- `classes/{id}/members`: el nombre de cada alumno. Cada alumno ve solo el
  suyo; el profesor ve a todos.
- `classes/{id}/assignments/{id}`: la tarea, solo con las pruebas **visibles** y
  `hiddenCount` (cuántas ocultas hay). `classes/{id}/hiddenCases/{id}`: las
  pruebas ocultas, que solo lee el profesor.
- `classes/{id}/assignments/{id}/submissions/{uid}`: la entrega de cada alumno
  (su programa y cuántas pruebas dice que pasó). La escribe el alumno y la ve el
  profesor.
- `publications`: lo que se comparte en la comunidad, con `useful` (me sirvió)
  y `reports` (reportes, que solo se leen desde la consola).
- `supportOffers`: la red de apoyo. Solo lectura; las ofertas se dan de alta a
  mano después de revisarlas.
- `mensajes`: lo que mandan desde el formulario de la página de presentación.
  Cualquiera puede escribir uno; nadie los puede leer fuera de la consola.

Todo esto lo hacen cumplir las reglas de `firestore.rules`, que tienen sus
propias pruebas en `firebase-tests/`.

La solución del profesor nunca sube: se queda en su equipo.

### Por qué las calificaciones no se pueden falsificar (sin servidor)

No hay Cloud Functions ni servidor propio: serían de pago. Las calificaciones se
protegen así:

- Lo que dice una entrega (`passed`, `total`) lo escribe el alumno, así que **no se
  cree**. La app del profesor corre el programa de cada alumno otra vez contra
  todas las pruebas, las ocultas incluidas, y muestra ese resultado
  (`lib/src/cloud/regrade.dart`). Un 3 de 3 inventado aparece como lo que es.
- Las pruebas ocultas viven en `hiddenCases`, que solo lee el profesor: el
  alumno no puede programar «para el ejemplo» ni leerlas directo del servidor.
  Su «Probar» corre las visibles; las ocultas las revisa el profesor.
- Una tarea hecha con la primera versión de la app, con las pruebas ocultas a la
  vista, se corrige sola cuando el profesor abre su clase.

Lo que no se puede evitar sin servidor: nadie impide que alguien con la clave
pública gaste la cuota gratuita del día (50 mil lecturas y 20 mil escrituras).
Si pasa, la parte en línea se detiene hasta el día siguiente y lo demás sigue
funcionando; la app lo avisa («llegó hoy a su límite gratuito»). Tampoco se pueden
limitar los envíos del formulario de la página.

Cuánto aguanta la cuota gratuita (cálculo aproximado, no medido): una clase de 40
alumnos que hace una tarea gasta unas 500 lecturas y 200 escrituras. La cuota de
escrituras (20 mil al día) es la que se acaba primero, a unas 100 clases al día.
Por eso «Probar» no manda nada si el resultado y el programa son los mismos, ni si
solo cambió el texto en los últimos 20 segundos (`Cloud.minSendGap`). Las reglas
que comprueban que eres de la clase también cuentan como una lectura por escritura.

Moderar: una publicación que se marca `status: moderado` en la consola ya no la
puede volver a publicar su autor.

## Probar sin tocar producción

```sh
cd firebase-tests && npm install && npm test     # las reglas, contra el emulador
tool/probar_nube.sh                              # el cliente REST contra los emuladores

firebase emulators:start --only firestore,auth
cd apps/jaguar && flutter run -d chrome --dart-define=JAGUAR_EMULATORS=true
```

## Publicar

```sh
firebase deploy --only firestore --project jaguarapp-50a15   # reglas e índices
tool/publicar_web.sh                                          # la app web
tool/publicar_sitio.sh                                        # la página de presentación
tool/publicar_android.sh "Notas de la versión"                # APK a App Distribution
```

El hosting manda `Cache-Control: no-cache`, para que el navegador revise si hay
versión nueva en cada visita. Sin eso, después de actualizar se quedaba con
archivos viejos.
