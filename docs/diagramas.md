# Diagramas de flujo y DFD

En las escuelas normalmente se enseña primero el diagrama de flujo (con DFD) y
después el pseudocódigo (con PSeInt). Jaguar sirve para las dos etapas y para
pasar de una a la otra.

## Un programa, dos vistas

El diagrama no es un dibujo aparte: es otra forma de ver el mismo programa.
Lo que cambias en el código aparece en el diagrama y al revés, y se guarda
como un `.psc` normal. La vista se elige en la barra de arriba: pseudocódigo,
diagrama o los dos lado a lado.

Cuando editas desde el diagrama, Jaguar cambia solo las líneas de ese bloque,
así que los comentarios y el formato que tenía el alumno no se pierden. Los
diagramas son estructurados (como en DFD y PSeInt): los bloques se insertan
sobre una flecha y no hay flechas libres, por eso cualquier diagrama se puede
convertir en pseudocódigo válido.

## Lo que se tomó de DFD

Revisé el manual de referencia de FreeDFD 1.1 y la idea es que quien viene de
DFD se sienta en casa:

- Se dibuja igual: eliges un objeto de la paleta y lo pones sobre una flecha
  (aquí la flecha tiene un ＋). Doble clic edita, Supr borra.
- Los objetos son los de DFD (Asignación, Lectura, Salida, Decisión, Ciclo
  Mientras, Ciclo Para y Llamada) más Repetir y Según de PSeInt. El Ciclo
  Para pide contador, valor inicial, valor final e incremento.
- La sintaxis de DFD funciona en el código y en los diálogos: textos con
  comilla simple, `←`, `.V.` y `.F.`, `!=`, `AND OR NOT XOR NAND NOR XNOR`,
  funciones como `SQRT`, `LEN` o `SUBSTRING`, y arreglos con paréntesis. El
  pseudocódigo siempre se guarda en notación de PSeInt; lo que no existe en
  PSeInt (por ejemplo `LOG` o `SINH`) se escribe como fórmula.
- El diagrama se puede mostrar en notación PSeInt o DFD (`x <- a Y b` o
  `x ← a AND b`).
- Las teclas del depurador: F9 ejecuta, F7 avanza un paso, F4 ejecuta hasta
  donde está el cursor. También hay Pausar, un evaluador de expresiones y la
  tabla de variables, que marca las que acaban de cambiar.

Una diferencia a propósito: en DFD un objeto de asignación puede tener hasta
tres asignaciones; en Jaguar cada una es un bloque.

## Pendiente

- La forma exacta de los símbolos de DFD. No encontré capturas confiables y
  no quise inventarlas; hoy Lectura y Salida tienen la misma figura y se
  distinguen por color.
- Abrir archivos `.dfd`. El formato no está documentado; hacen falta archivos
  reales para ver si se pueden leer.
- Los arreglos que DFD crea sin `Dimension`.
- Ángulos en grados (PSeInt usa radianes).
- Exportar a PDF (hoy se guarda como imagen PNG).

## Cómo está hecho

En `jaguar_core`:

- `flowchart.dart` calcula la posición de cada bloque a partir del programa ya
  analizado. Es pura geometría, así que se prueba sin Flutter y sirve igual
  para la pantalla y para exportar.
- `editing.dart` inserta, reemplaza y borra bloques editando solo sus líneas.
  El parser guarda dónde termina cada bloque y dónde están `SiNo` y los casos
  de `Según` para poder hacerlo.
- `format.dart` escribe las expresiones en notación PSeInt o DFD.

En la app, `diagram/` dibuja el diagrama, maneja la paleta y los diálogos de
cada objeto.
