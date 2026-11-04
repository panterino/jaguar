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
# Si cambiaste el intérprete, corre sus pruebas en el repositorio jaguar_core.
cd apps/jaguar && flutter analyze && flutter test
cd firebase-tests && npm test        # si cambiaste firestore.rules
```

Los commits llevan un mensaje corto, de una línea y sin descripción:
"Agregado icono de app", "Se agregó panel de pruebas", "Corregido error al
guardar".

## Desarrollar el intérprete junto con la app

`jaguar_core` vive en [su propio repositorio](https://github.com/panterino/jaguar_core) y la app lo toma por git, con una etiqueta (`ref` en `apps/jaguar/pubspec.yaml`). Para cambiar los dos a la vez, clona `jaguar_core` junto a este repositorio y crea `apps/jaguar/pubspec_overrides.yaml` (no se versiona):

```yaml
dependency_overrides:
  jaguar_core:
    path: ../../../jaguar_core
```

Cuando el cambio del intérprete esté listo, se publica una versión nueva con su etiqueta y se actualiza el `ref` de la app.
