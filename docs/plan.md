# Hoja de ruta

## Por qué existe

En la prepa la lógica se enseña con PSeInt y DFD en la sala de cómputo, y lo
que haces ahí se queda ahí: no hay PSeInt en el celular, en casa a veces no
hay computadora y pasar archivos entre la sala, la USB y el teléfono es un lío.
Del otro lado, los profesores revisan a mano decenas de archivos o pasan
lugar por lugar a ver si el programa corre.

Jaguar quiere arreglar las dos cosas: que el alumno pueda llevarse su trabajo
a donde sea, y que revisar ejercicios no le cueste horas al profesor.

Algunas reglas que me puse:

- Lo básico funciona sin internet y sin cuenta.
- Gratis para estudiantes.
- Compatible con lo que ya se usa en el salón (`.psc`, la sintaxis de PSeInt
  y la de DFD).
- IA al final: primero algoritmos que se puedan probar. Los errores, los
  casos de prueba y la revisión de ejercicios no usan IA.
- Código y contenido abiertos.

## Cómo está armado

El intérprete (`packages/jaguar_core`) no depende de Flutter. Lo mismo corre
la app, las pruebas de los ejercicios y la línea de comandos. La app
(`apps/jaguar`) es Flutter y sale para web, Android y escritorio. Las clases y
la comunidad usan Firebase (ver [nube.md](nube.md)).

## Ya está

- Intérprete compatible con PSeInt (perfil flexible) y con la sintaxis de DFD.
- Editor con colores, autocompletado, cierre de bloques, errores mientras
  escribes, buscar y reemplazar, y las operaciones de línea de siempre.
- Diagramas de flujo: se ven a partir del código y también se puede programar
  dibujando, como en DFD.
- Paso a paso con tabla de variables, "ejecutar hasta aquí" y evaluador.
- Ejercicios con pruebas, pestaña de Pruebas y pantalla de "verificado" para
  mostrársela al profesor.
- El profesor escribe su solución y Jaguar genera los casos de prueba solo.
- Modos Básico y Completo.
- Clases en línea: código para unirse, tareas, entregas y tabla de avance.
- Comunidad: publicar programas y ejercicios, "me sirvió", reportar.
- Web publicada en https://jaguar-edu.web.app
- Cuentas en línea activadas (anónima para alumnos, correo para profesores),
  con "olvidé mi contraseña" y borrar la cuenta.
- APK de prueba en Firebase App Distribution, firmado con la llave de subida
  que después servirá para Play Store.

## Lo que sigue

El orden sale de [investigacion.md](investigacion.md). Ya están la prueba de
escritorio, el planteamiento, los retos del primer nivel, el modo sin
conexión, el APK ligero y el aviso de privacidad. Las rúbricas y listas de
cotejo las lleva el profesor; Jaguar se queda como herramienta general.

1. Poner el correo de contacto en el aviso de privacidad.
2. Probarlo con uno o dos profesores de verdad, en su clase. Antes de eso,
   platicar con ellos (abajo están las preguntas).
3. Subir a Play Store, primero en pruebas internas (ver
   [play-store.md](play-store.md)).
4. Retos del segundo nivel: arreglos, funciones y cadenas.

Después: tutoriales por enlace, directorio de la red de apoyo, calificar por
lotes y detectar copias.

Pendientes de DFD: los símbolos exactos de cada objeto, abrir archivos `.dfd`,
exportar el diagrama a PDF y los arreglos que DFD crea sin `Dimension`.

## Preguntas para los profesores

1. ¿Con qué enseñan lógica: PSeInt, DFD, otra cosa?
2. ¿Cómo les entregan las prácticas y cómo las revisan?
3. ¿Cuánto les toma calificar una práctica de todo el grupo?
4. ¿Qué tanto se copian los alumnos y cómo se dan cuenta?
5. ¿Sus alumnos tienen computadora en casa? ¿Celular?
6. ¿Piden el diagrama antes que el código, después, o los dos?
7. ¿Probarían Jaguar con un grupo el próximo semestre?

## Lo que aprendí de la competencia

La app más usada para practicar PSeInt en el celular tiene más de un millón
de descargas. Lo que la gente le agradece: que funciona sin internet, la
barra de símbolos sobre el teclado y que trae ejemplos. Lo que le reclaman:
los anuncios, que "Borrar Pantalla" no funciona, que con muchos `Si`
anidados uno se pierde porque no hay líneas de sangría, y que los archivos
se guardan donde no se pueden encontrar. Tampoco tiene diagramas.

Jaguar no tiene anuncios, marca la sangría, guarda donde tú eliges y manda el
`.psc` por WhatsApp. Lo que todavía nos falta y ella sí tiene: un modo
estricto (obliga a `Definir`) y una referencia de sintaxis dentro de la app.

## Limpieza

- Cambiar o borrar el usuario de MongoDB que quedó en
  `panterino/jaguar-server/src/keys.js` (repo viejo).
- Archivar los repos viejos de `panterino` y `JaguarEducation`.
- Publicar en la página de Facebook la historia del regreso.
