# Play Store

Lo que hay que pegar en la consola de Google Play. El paquete se arma con:

```sh
cd apps/jaguar
flutter build appbundle --release --obfuscate --split-debug-info=build/simbolos
```

Sale en `build/app/outputs/bundle/release/app-release.aab`, firmado con la
llave de subida. La primera vez Google pregunta si administra la llave de
firma de la app: decir que sí (Play App Signing) y subir este `.aab`. La
carpeta `build/simbolos` sirve para leer los errores ofuscados; conviene
guardarla junto a cada versión.

## Ficha

**Nombre** (30): Jaguar: pseudocódigo y diagramas

**Descripción corta** (80): Aprende lógica de programación con pseudocódigo PSeInt y diagramas como en DFD.

**Descripción completa:**

Jaguar es para aprender lógica de programación desde el celular, como en la
sala de cómputo pero sin depender de ella.

- Escribe pseudocódigo compatible con PSeInt y ejecútalo, sin internet.
- Dibuja diagramas de flujo como en DFD y conviértelos en pseudocódigo, o al
  revés.
- Haz la prueba de escritorio: Jaguar llena la tabla de variables paso a paso,
  o la llenas tú y te dice en qué acertaste.
- Escribe el planteamiento (entrada, proceso y salida) antes de programar.
- Practica con retos del programa de Cultura Digital, con pistas.
- Si tu profesor usa Jaguar, únete a su clase con un código y entrega tus
  ejercicios.
- Abre y guarda archivos .psc, o mándalos por WhatsApp o correo.

Sin anuncios y sin pedir datos personales. Jaguar es software libre (AGPL) y
lo hace Panterino, un proyecto educativo de México.

**Categoría:** Educación
**Correo de contacto:** (el mismo del aviso de privacidad)
**Política de privacidad:** https://jaguar-edu.web.app/privacidad.html

Capturas: las de `tool/capturas` sirven de base (código, diagrama, consola,
prueba de escritorio, retos), sacadas a 1080×2400.

## Público objetivo y contenido

- **Edades:** 13 a 15, 16 a 17 y 18 o más. No marcar menores de 13: eso mete
  la app al programa de Familias, con más requisitos, y no es nuestro
  público.
- **Anuncios:** no tiene.
- **Clasificación de contenido:** cuestionario de IARC, categoría
  "Referencia, noticias o educación". Hay contenido creado por usuarios
  (programas publicados en la comunidad) que se puede reportar; no hay chat
  ni mensajes entre usuarios.
- **Acceso a la app:** todo funciona sin cuenta. Para revisar las clases,
  crear una cuenta de profesor de prueba y dejar el correo y la contraseña
  en el formulario.

## Seguridad de los datos

Respuestas para el formulario, según el aviso de privacidad:

| Dato | ¿Se recopila? | Para qué | ¿Opcional? |
| --- | --- | --- | --- |
| Correo (solo profesores) | Sí | Cuenta | Sí |
| IDs de usuario | Sí | Cuenta y funciones de la app | Sí |
| Otro contenido generado por el usuario (programas, entregas, publicaciones) | Sí | Funciones de la app | Sí |
| Nombre (alias o nombre en una clase) | Sí | Funciones de la app | Sí |
| Ubicación, contactos, fotos, actividad, identificadores del dispositivo | No | | |

- No se comparte con terceros. Firebase actúa como proveedor de servicios.
- Los datos viajan cifrados.
- Se pueden borrar: en la app (Tu cuenta → Borrar mi cuenta). Para la URL de
  borrado que pide Google, usar la del aviso de privacidad; la sección "Tus
  derechos" explica cómo hacerlo.

## Antes de la primera versión pública

- Crear la cuenta de desarrollador de Google Play (pago único) y la app con
  el paquete `com.panterino.jaguar`.
- Probar primero en la pista de pruebas internas con el piloto.
