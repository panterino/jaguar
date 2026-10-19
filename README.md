# Jaguar

Jaguar es una app para aprender lógica de programación: diagramas de flujo
como en DFD, pseudocódigo como en PSeInt, ejercicios que se revisan solos y
clases en línea para profesores y alumnos. Corre en el navegador, en Android
y en escritorio, y lo básico funciona sin internet y sin cuenta.

Pruébala en https://jaguar-edu.web.app

## Un poco de historia

Jaguar empezó en 2019, en la prepa, como el proyecto de Panterino: queríamos
un "Duolingo de programación" para quien no tuviera computadora, internet o
dinero para cursos. Lo intentamos varias veces hasta 2021 y nunca pasamos de
la pantalla de login. En 2026 lo retomé con otra idea: en vez de inventar un
lenguaje nuevo, usar lo que ya se enseña en las escuelas (PSeInt y DFD) y
hacer que funcione en cualquier equipo.

## Qué hay aquí

```
packages/jaguar_core   el intérprete, en Dart puro (sin Flutter)
apps/jaguar            la app en Flutter
firestore.rules        reglas de la base de datos (clases y comunidad)
firebase-tests/        pruebas de esas reglas contra el emulador
docs/                  notas de diseño y la hoja de ruta
```

## Correrla

```sh
cd apps/jaguar
flutter run -d chrome          # o -d macos, o con un Android conectado
flutter test
```

Para trabajar con la nube sin tocar producción:

```sh
firebase emulators:start --only firestore,auth
cd apps/jaguar && flutter run -d chrome --dart-define=JAGUAR_EMULATORS=true
```

Publicar la web:

```sh
tool/publicar_web.sh
```

Mandar un APK de prueba a App Distribution:

```sh
tool/publicar_android.sh "Notas de la versión"
```

El APK se firma con la llave de subida si existe `android/key.properties`
(no está en el repo). Sin ese archivo se firma con la llave de depuración,
que sirve para probar pero no para Play Store.

La página de presentación está en `sitio/`: es un solo HTML, sin
compilar. Se publica con `tool/publicar_sitio.sh`.

## El intérprete solo

```sh
cd packages/jaguar_core
dart test
dart run bin/jaguar.dart example/hola.psc
```

```dart
import 'package:jaguar_core/jaguar_core.dart';

final result = await runProgram(source, inputs: ['5']);
print(result.ok ? result.output : result.error!.format(source));
```

## Notas

- [Hoja de ruta](docs/plan.md)
- [Cómo funciona para alumnos y profesores](docs/producto.md)
- [Diagramas de flujo y compatibilidad con DFD](docs/diagramas.md)
- [La nube (Firebase)](docs/nube.md)
- [Qué pseudocódigo entiende Jaguar](docs/gramatica.md)

## Licencia

El código es AGPL-3.0 (ver `LICENSE`): puedes usarlo y modificarlo, y si
ofreces una versión modificada como servicio, tus cambios también se publican.
Lo que la gente comparte en la comunidad de Jaguar queda bajo CC BY-SA.

Hecho por Angel Flores, para Panterino.
