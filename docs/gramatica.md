# Qué pseudocódigo entiende Jaguar

Jaguar sigue el **perfil flexible de PSeInt**: un `.psc` hecho en la sala de
cómputo debe correr igual en Jaguar, y al revés. No distingue mayúsculas ni
acentos (`Según` = `SEGUN` = `segun`). El `;` al final es opcional.

## Estructura

```
// Las funciones pueden ir antes o después del algoritmo.
Funcion resultado <- Doble(x)
    resultado <- x * 2
FinFuncion

SubProceso Intercambiar(a Por Referencia, b Por Referencia)
    aux <- a
    a <- b
    b <- aux
FinSubProceso

Algoritmo ejemplo          // o: Proceso ejemplo ... FinProceso
    Escribir Doble(21)
FinAlgoritmo
```

## Instrucciones

| Instrucción | Ejemplo |
|---|---|
| Definir | `Definir n, m Como Entero` (Entero, Real/Numero, Logico, Caracter/Texto/Cadena) |
| Asignar | `x <- 5` (también `=` y `:=`) |
| Escribir | `Escribir "Total: ", x` · `Escribir Sin Saltar "..."` (sinónimos: Imprimir, Mostrar) |
| Leer | `Leer a, b` |
| Dimension | `Dimension a[10], m[3, 4]` (índices desde 1) |
| Si | `Si cond Entonces ... SiNo ... FinSi` |
| Segun | `Segun x Hacer  1: ...  2, 3: ...  De Otro Modo: ...  FinSegun` |
| Mientras | `Mientras cond Hacer ... FinMientras` |
| Repetir | `Repetir ... Hasta Que cond` o `... Mientras Que cond` |
| Para | `Para i <- 1 Hasta 10 Con Paso 2 Hacer ... FinPara` |
| Para Cada | `Para Cada x de arreglo Hacer ... FinPara` |
| Esperar | `Esperar Tecla` · `Esperar 2 Segundos` · `Esperar 500 Milisegundos` |
| Limpiar | `Borrar Pantalla` / `Limpiar Pantalla` |

`FinSi`, `FinPara`, etc. también se aceptan con espacio: `Fin Si`.

## Operadores (de menor a mayor precedencia)

| | |
|---|---|
| `O`  `\|`  `\|\|` | o lógico |
| `Y`  `&`  `&&` | y lógico |
| `NO`  `~`  `!` | negación |
| `=` `==` `<>` `!=` `<` `>` `<=` `>=` | comparación |
| `+` `-` | suma (también une textos), resta |
| `*` `/` `MOD` `%` | multiplicación, división, residuo |
| `-` | signo |
| `^` | potencia |

## Funciones internas

`Raiz`/`RC`, `Abs`, `Ln`, `Exp`, `Sen`, `Cos`, `Tan`, `ASen`, `ACos`, `ATan`,
`Trunc`, `Redon`, `Azar(n)`, `Aleatorio(a, b)`, `Longitud`, `Mayusculas`,
`Minusculas`, `Subcadena(s, desde, hasta)`, `Concatenar`, `ConvertirANumero`,
`ConvertirATexto`, y la constante `PI`.

## Decisiones

- **Variables sin `Definir`** se permiten (como en el perfil flexible).
  Si se definen, el tipo se respeta: guardar `2.5` en un `Entero` es error.
- **Usar una variable sin valor** es error, con sugerencia de cómo dárselo.
- **Cada función tiene sus propias variables**; no hay variables globales.
  Los arreglos siempre se comparten con la función que los recibe.
- **`Para` sin `Con Paso`** cuenta hacia atrás si el inicio es mayor que el fin.
- **Límites** para no congelar la app ni el calificador: número máximo de pasos
  (configurable) y 200 llamadas anidadas.

## Lo que todavía no hace

- Perfil estricto (Definir obligatorio, `;` obligatorio, índices desde 0).
- Validar contra los ejemplos que trae PSeInt y tareas reales de alumnos.

## Sintaxis de DFD

Para quien viene de DFD, Jaguar también entiende su forma de escribir. Al
guardar, el pseudocódigo queda en notación de PSeInt.

| DFD | Se guarda como |
|---|---|
| `x ← 5` | `x <- 5` |
| `'Hola'` | `"Hola"` |
| `.V.` `.F.` | `Verdadero` `Falso` |
| `a != b` | `a <> b` |
| `AND` `OR` `NOT` | `Y` `O` `NO` |
| `a XOR b`, `a XNOR b` | `a <> b`, `a = b` |
| `a NAND b`, `a NOR b` | `NO (a Y b)`, `NO (a O b)` |
| `SQRT` `ABS` `LEN` `ROUND` `TRUNC` `RANDOM` | `Raiz` `Abs` `Longitud` `Redon` `Trunc` `Azar` |
| `SIN` `COS` `TAN` `ASIN` `ACOS` `ATAN` `LN` `EXP` | `Sen` `Cos` `Tan` `ASen` `ACos` `ATan` `Ln` `Exp` |
| `LOG(x)` | `Ln(x) / Ln(10)` |
| `SINH`, `COSH`, `TANH` | su fórmula con `Exp` |
| `SUBSTRING(t, inicio, cuantos)` | `Subcadena(t, inicio, inicio + cuantos - 1)` |
| `V(3)` | `V[3]` (si `V` se creó con `Dimension`) |

También se aceptan `≠`, `≤` y `≥`.
