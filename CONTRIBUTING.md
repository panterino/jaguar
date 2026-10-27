# Cómo trabajamos

Usamos gitflow:

- `main` tiene solo versiones publicadas, cada una con su etiqueta (`v0.2.0`).
  Lo que se despliega en https://app.jaguarcode.org sale de aquí.
- `develop` es donde se junta el trabajo del día a día.
- `feature/<algo>` sale de `develop` y regresa a `develop` con un pull request.
  Ejemplo: `feature/retos-nivel-1`.
- `release/<versión>` sale de `develop` cuando hay que preparar una versión
  (subir el número en `pubspec.yaml` y en `about_screen.dart`, últimos
  arreglos). Se junta en `main`, se etiqueta y se regresa a `develop`.
- `hotfix/<algo>` sale de `main` para un arreglo urgente en producción, y se
  junta en `main` y en `develop`.

Antes de abrir un pull request:

```sh
cd packages/jaguar_core && dart analyze && dart test
cd apps/jaguar && flutter analyze && flutter test
cd firebase-tests && npm test        # si cambiaste firestore.rules
```

Los commits llevan un mensaje corto, de una línea y sin descripción:
"Agregado icono de app", "Se agregó panel de pruebas", "Corregido error al
guardar".
