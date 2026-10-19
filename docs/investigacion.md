# Qué necesitan alumnos y profesores

Notas de octubre de 2026 para decidir qué hacer primero. Junté el programa
oficial, datos del INEGI, lo que dice la investigación sobre enseñar a
programar y las reseñas de la app de la competencia.

## Qué pide el programa

Con la Nueva Escuela Mexicana, la lógica de programación vive en Cultura
Digital I, en primer semestre, con 3 horas a la semana ([DGB, Modelo
Educativo 2025](https://dgb.sep.gob.mx/storage/recursos/2025/09/Funa9XEQmp-MCC_CULTURA-DIGITAL.pdf)).
Son dos de los ocho propósitos del semestre:

- El 7: pasos para resolver un problema (identificarlo, comprenderlo,
  analizar alternativas, escoger una) y usar métodos o diagramas de flujo.
- El 8: dato, información, variables, constantes, expresiones, operadores
  lógicos, relacionales y aritméticos, y estructuras condicionales, selectivas
  y repetitivas.

O sea, el profesor tiene unas cuantas semanas para todo esto, y además le toca
ver hardware, licencias, seguridad digital y ofimática. No tiene tiempo para
revisar programas uno por uno.

El programa de 2023 decía algo que me sirve mucho: que sin internet se puede
probar una solución con pseudocódigo y la corrida de escritorio ([Cultura
Digital I, 2023](https://dgb.sep.gob.mx/storage/recursos/2023/08/LKJkPxM1dk-CULTURA-DIGITAL-I_2C.pdf)).
La prueba de escritorio es justo lo que más se pide en clase y Jaguar todavía
no la hace como tal.

La evaluación que pide la SEP es diagnóstica al inicio y formativa durante el
semestre, con rúbricas, listas de cotejo y bitácoras, y con retroalimentación
puntual al alumno. Una calificación de "pasó 3 de 5 pruebas" no alcanza.

Un detalle bonito: el mismo semestre ve historia del software libre, la GPL y
Creative Commons. Jaguar es AGPL y lo que se comparte es CC BY-SA, así que el
profesor puede usarlo de ejemplo.

## Con qué equipo cuentan

Según la [ENDUTIH 2025](https://www.inegi.org.mx/contenidos/saladeprensa/boletines/2026/endutih/ENDUTIH_25_RR.pdf):

- 97.3 % de quienes usan internet se conecta con el celular, y solo 36.2 %
  con computadora.
- 44.7 % de los hogares tiene computadora. Ese número casi no ha cambiado
  desde 2015.
- En el campo usa internet 75.2 % de la gente, contra un promedio nacional de
  86.1 %.

La mayoría de los alumnos va a usar Jaguar en el celular, muchas veces con
datos limitados. Por eso pesa que el APK mida 57 MB y que la web no funcione
sin conexión.

## Dónde se atoran los alumnos

Lo que más se repite en los estudios:

- Lo difícil no es la sintaxis, es diseñar el algoritmo: entender el
  enunciado, abstraer y poner los pasos en orden ([Redalyc, media técnica en
  informática](https://www.redalyc.org/journal/1942/194274896006/html/);
  [TISE 2012](https://www.tise.cl/volumen8/TISE2012/17.pdf)).
- Los errores sin explicación frustran y hacen que algunos abandonen.
- El pseudocódigo sirve de puente entre los bloques y un lenguaje real, y en
  un grupo de bachillerato técnico llegaron al nivel esperado en menos horas
  que con Java ([SciELO 2025](https://ve.scielo.org/scielo.php?script=sci_arttext&pid=S2542-29872025000200380)).
  Es un grupo de 25, así que lo tomo con cuidado.

Sobre revisar programas en automático ([Messer et al.,
2024](https://arxiv.org/pdf/2306.11722); [ICPEC 2023](https://drops.dagstuhl.de/entities/document/10.4230/OASIcs.ICPEC.2023.7)):
casi todas las herramientas solo dicen si pasó o no pasó; eso motiva, pero no
hay mucha evidencia de que enseñe; y el profesor puede dejar de ver qué está
pasando con sus alumnos. Casi todos los estudios son de universidad, muy pocos
de bachillerato.

## Lo que hace falta en Jaguar, por orden

1. **Prueba de escritorio.** Una tabla con una fila por paso y una columna por
   variable, que se pueda llenar a mano (el alumno predice) o dejar que Jaguar
   la llene, y que se pueda imprimir o mandar. Es lo que el programa pide y lo
   que el profesor ya califica en papel. El paso a paso ya tiene casi todo.
2. **Planteamiento antes del código.** En cada ejercicio, un espacio corto
   para datos de entrada, proceso y salida, y qué se va a comparar. Ataca
   justo donde se atoran: entender el problema.
3. **Retos del primer nivel ligados al programa.** Unos 10, uno por contenido
   del propósito 8 (variables, operadores, Si, Según, Mientras, Para…), para
   que el profesor los pueda asignar tal cual.
4. **Lista de cotejo para el profesor.** Exportar los resultados de una clase
   como tabla (alumno, ejercicio, pruebas que pasan, si usó la estructura
   pedida) para pegarla en su registro. Lo que más le ahorra tiempo.
5. **Ligero y sin conexión.** APK separado por arquitectura (unos 20 MB en vez
   de 57) y la web instalable que funcione sin internet.
6. **Aviso de privacidad.** Antes de probarlo con un grupo. Pedimos alias y,
   a los profesores, correo; hay menores de edad.
7. **Play Store.** La llave de subida ya está.

Lo que no haría todavía: IA para explicar errores, ranking global (la
competencia lo tiene, pero con menores prefiero no) y más funciones de DFD.

## Qué hay que preguntar en el piloto

Además de las preguntas de [plan.md](plan.md): ¿cuántas semanas le dedican de
verdad al propósito 8?, ¿piden prueba de escritorio y cómo la califican?, ¿sus
alumnos pueden instalar un APK o solo usar la web?
