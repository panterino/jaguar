# La nube

Jaguar funciona sin internet y sin cuenta. La nube solo hace falta para lo
que involucra a más de una persona: clases, tareas, entregas y la comunidad.
Si no hay conexión (o en Windows y Linux, que todavía no están configurados),
esas opciones simplemente no aparecen.

Usamos Firebase, en el proyecto `jaguarapp-50a15` (plan gratuito). La web se
sirve en https://jaguar-edu.web.app y la dirección vieja
(`jaguarapp-50a15.web.app`) redirige ahí. Cuando haya dominio propio se
conecta en Hosting.

## Cuentas

Los alumnos y quienes aprenden por su cuenta entran solo con un alias, con una
cuenta anónima que vive en su dispositivo. Los profesores usan correo y
contraseña, para no perder sus clases si cambian de computadora. Hay que
activar los dos métodos en la consola, en Authentication → Sign-in method.

## Datos

- `users/{uid}`: alias, rol y las clases a las que se unió. Solo lo ve su dueño.
- `classes/{id}` y `classCodes/{código}`: la clase y su código para unirse. Los
  códigos no se pueden listar; solo se encuentran si ya los conoces.
- `classes/{id}/members`: el nombre de cada alumno. Cada alumno ve solo el
  suyo; el profesor ve a todos.
- `classes/{id}/assignments/{id}/submissions/{uid}`: la entrega de cada alumno
  (su programa y cuántas pruebas pasó). La escribe el alumno y la ve el
  profesor.
- `publications`: lo que se comparte en la comunidad, con `useful` (me sirvió)
  y `reports` (reportes, que solo se leen desde la consola).
- `supportOffers`: la red de apoyo. Solo lectura; las ofertas se dan de alta a
  mano después de revisarlas.

Todo esto lo hacen cumplir las reglas de `firestore.rules`, que tienen sus
propias pruebas en `firebase-tests/`.

La solución del profesor nunca sube: se queda en su equipo.

## Probar sin tocar producción

```sh
cd firebase-tests && npm install && npm test     # las reglas, contra el emulador

firebase emulators:start --only firestore,auth
cd apps/jaguar && flutter run -d chrome --dart-define=JAGUAR_EMULATORS=true
```

## Publicar

```sh
firebase deploy --only firestore                 # reglas e índices
cd apps/jaguar && flutter build web --release --pwa-strategy=none
cd ../.. && firebase deploy --only hosting
```

El hosting manda `Cache-Control: no-cache`, para que el navegador revise si hay
versión nueva en cada visita. Sin eso, después de actualizar se quedaba con
archivos viejos.
