import 'package:jaguar_core/jaguar_core.dart';

import 'challenges.dart';

/// Level 3: data. Arrays, searching, strings, matrices and sorting.
const challengesNivel3 = <Challenge>[
  Challenge(
    subject: 'Arreglos',
    topic: 'Arreglos y recorridos',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-01',
      title: 'Reto 25 · Al revés',
      statement:
          'Pide 5 números y muéstralos en orden inverso, uno por renglón.\n\nSi escriben 1, 2, 3, 4 y 5, el programa muestra:\n5\n4\n3\n2\n1',
      cases: [
        TestCase(inputs: ['1', '2', '3', '4', '5'], expected: '5\n4\n3\n2\n1'),
        TestCase(inputs: ['10', '20', '30', '40', '50'], expected: '50\n40\n30\n20\n10'),
        TestCase(inputs: ['7', '7', '0', '-2', '3'], expected: '3\n-2\n0\n7\n7', hidden: true),
      ],
    ),
    hints: [
      'Guarda los números en un arreglo de 5 casillas: Dimension a[5].',
      'Un Para de 1 a 5 lee cada casilla con Leer a[i]. Otro Para, de 5 a 1 con Paso -1, las muestra.',
      'Dimension a[5]\nPara i <- 1 Hasta 5 Hacer\n    Leer a[i]\nFinPara\nPara i <- 5 Hasta 1 Con Paso -1 Hacer\n    Escribir a[i]\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Arreglos',
    topic: 'Acumuladores con arreglos',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-02',
      title: 'Reto 26 · Suma y promedio',
      statement:
          'Pide cuántos números van a escribir (n) y luego los n números. Muestra su suma y su promedio.\n\nSi escriben 3, 4, 6 y 8, el programa muestra:\nSuma: 18\nPromedio: 6',
      cases: [
        TestCase(inputs: ['3', '4', '6', '8'], expected: 'Suma: 18\nPromedio: 6'),
        TestCase(inputs: ['2', '5', '10'], expected: 'Suma: 15\nPromedio: 7.5'),
        TestCase(inputs: ['1', '9'], expected: 'Suma: 9\nPromedio: 9', hidden: true),
        TestCase(inputs: ['4', '1', '2', '3', '4'], expected: 'Suma: 10\nPromedio: 2.5', hidden: true),
      ],
    ),
    hints: [
      'El arreglo puede tener el tamaño que escribió la persona: Dimension a[n].',
      'Lee los n números con un Para y suma cada uno en un acumulador que empieza en 0.',
      'El promedio es la suma entre n.',
      'Leer n\nDimension a[n]\nsuma <- 0\nPara i <- 1 Hasta n Hacer\n    Leer a[i]\n    suma <- suma + a[i]\nFinPara\nEscribir "Suma: ", suma\nEscribir "Promedio: ", suma / n',
    ],
  ),
  Challenge(
    subject: 'Arreglos',
    topic: 'Contadores con arreglos',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-03',
      title: 'Reto 27 · Cuántos pares',
      statement:
          'Pide cuántos números van a escribir (n) y luego los n números. Muestra cuántos son pares (el 0 también es par).\n\nSi escriben 5, 1, 2, 3, 4 y 6, el programa muestra:\nPares: 3',
      cases: [
        TestCase(inputs: ['5', '1', '2', '3', '4', '6'], expected: 'Pares: 3'),
        TestCase(inputs: ['4', '2', '4', '6', '8'], expected: 'Pares: 4'),
        TestCase(inputs: ['3', '1', '3', '5'], expected: 'Pares: 0', hidden: true),
        TestCase(inputs: ['1', '0'], expected: 'Pares: 1', hidden: true),
      ],
    ),
    hints: [
      'Un contador empieza en 0 y sube cada vez que encuentras un número par.',
      'Un número es par cuando su residuo entre 2 es 0: a[i] MOD 2 = 0.',
      'Recorre el arreglo con un Para y usa un Si dentro del ciclo.',
    ],
  ),
  Challenge(
    subject: 'Buscar y comparar',
    topic: 'Mayor de una lista',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-04',
      title: 'Reto 28 · El mayor y su posición',
      statement:
          'Pide cuántos números van a escribir (n) y luego los n números. Muestra el mayor y en qué posición está. Si el mayor se repite, muestra la primera posición.\n\nSi escriben 4, 3, 7, 9 y 2, el programa muestra:\nMayor: 9 en la posición 3',
      cases: [
        TestCase(inputs: ['4', '3', '7', '9', '2'], expected: 'Mayor: 9 en la posición 3'),
        TestCase(inputs: ['3', '5', '1', '2'], expected: 'Mayor: 5 en la posición 1'),
        TestCase(inputs: ['3', '-4', '-2', '-9'], expected: 'Mayor: -2 en la posición 2', hidden: true),
        TestCase(inputs: ['3', '6', '6', '1'], expected: 'Mayor: 6 en la posición 1', hidden: true),
        TestCase(inputs: ['1', '5'], expected: 'Mayor: 5 en la posición 1', hidden: true),
      ],
    ),
    hints: [
      'Guarda el mayor y también su posición; empieza con la casilla 1.',
      'Empezar el mayor en 0 falla con números negativos: empieza con a[1].',
      'Cambia el mayor solo si el nuevo es estrictamente mayor (>): así se queda con la primera posición.',
      'Cuidado con n = 1: Para i <- 2 Hasta 1 cuenta hacia atrás. Agrega Con Paso 1 para que no se ejecute ninguna vez.',
      'mayor <- a[1]\npos <- 1\nPara i <- 2 Hasta n Hacer\n    Si a[i] > mayor Entonces\n        mayor <- a[i]\n        pos <- i\n    FinSi\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Buscar y comparar',
    topic: 'Búsqueda en un arreglo',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-05',
      title: 'Reto 29 · Buscar un número',
      statement:
          'Pide cuántos números van a escribir (n), luego los n números y al final el número que se busca. Muestra Está en la posición p (la primera donde aparece) o No está.\n\nSi escriben 4, 5, 8, 3, 9 y se busca el 3, el programa muestra:\nEstá en la posición 3',
      cases: [
        TestCase(inputs: ['4', '5', '8', '3', '9', '3'], expected: 'Está en la posición 3'),
        TestCase(inputs: ['3', '1', '2', '3', '7'], expected: 'No está'),
        TestCase(inputs: ['3', '4', '4', '4', '4'], expected: 'Está en la posición 1', hidden: true),
        TestCase(inputs: ['2', '1', '2', '2'], expected: 'Está en la posición 2', hidden: true),
      ],
    ),
    hints: [
      'Usa una variable pos que empieza en 0, que significa "todavía no lo encontré".',
      'Si a[i] es el buscado y pos sigue en 0, guarda i: así te quedas con la primera aparición.',
      'Al final, si pos sigue en 0, no estaba.',
    ],
  ),
  Challenge(
    subject: 'Buscar y comparar',
    topic: 'Mínimo y máximo',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-06',
      title: 'Reto 30 · Menor y mayor',
      statement:
          'Pide cuántos números van a escribir (n) y luego los n números. Muestra el menor y el mayor.\n\nSi escriben 4, 3, 7, 9 y 2, el programa muestra:\nMenor: 2\nMayor: 9',
      cases: [
        TestCase(inputs: ['4', '3', '7', '9', '2'], expected: 'Menor: 2\nMayor: 9'),
        TestCase(inputs: ['3', '5', '1', '2'], expected: 'Menor: 1\nMayor: 5'),
        TestCase(inputs: ['1', '4'], expected: 'Menor: 4\nMayor: 4', hidden: true),
        TestCase(inputs: ['3', '-4', '-2', '-9'], expected: 'Menor: -9\nMayor: -2', hidden: true),
      ],
    ),
    hints: [
      'Lleva dos variables, menor y mayor, y empieza las dos con a[1].',
      'Recorre desde la casilla 2 y actualiza cada una cuando encuentres uno más chico o más grande.',
      'Con un solo número (n = 1) el menor y el mayor son el mismo. Cuidado: Para i <- 2 Hasta 1 cuenta hacia atrás; agrega Con Paso 1 para que no se ejecute.',
    ],
  ),
  Challenge(
    subject: 'Textos',
    topic: 'Recorrer un texto',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-07',
      title: 'Reto 31 · Contar vocales',
      statement:
          'Pide una palabra en minúsculas y sin acentos y di cuántas vocales (a, e, i, o, u) tiene.\n\nSi escriben jaguar, el programa muestra:\nVocales: 3',
      cases: [
        TestCase(inputs: ['jaguar'], expected: 'Vocales: 3'),
        TestCase(inputs: ['sol'], expected: 'Vocales: 1'),
        TestCase(inputs: ['xyz'], expected: 'Vocales: 0', hidden: true),
        TestCase(inputs: ['aeiou'], expected: 'Vocales: 5', hidden: true),
      ],
    ),
    hints: [
      'Recorre la palabra letra por letra: Subcadena(palabra, i, i) da la letra i.',
      'Dentro del ciclo, un Si con O revisa si la letra es a, e, i, o o u.',
      'Un contador empieza en 0 y sube con cada vocal.',
    ],
  ),
  Challenge(
    subject: 'Textos',
    topic: 'Comparar letras de un texto',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-08',
      title: 'Reto 32 · Palíndromo',
      statement:
          'Pide una palabra en minúsculas y di si es un palíndromo: se lee igual de izquierda a derecha que de derecha a izquierda.\n\nSi escriben reconocer, el programa muestra:\nEs palíndromo',
      cases: [
        TestCase(inputs: ['reconocer'], expected: 'Es palíndromo'),
        TestCase(inputs: ['jaguar'], expected: 'No es palíndromo'),
        TestCase(inputs: ['a'], expected: 'Es palíndromo', hidden: true),
        TestCase(inputs: ['ab'], expected: 'No es palíndromo', hidden: true),
        TestCase(inputs: ['anitalavalatina'], expected: 'Es palíndromo', hidden: true),
      ],
    ),
    hints: [
      'Compara la letra i con la letra que está a la misma distancia del final: Longitud(palabra) - i + 1.',
      'Si encuentras una pareja distinta, ya no es palíndromo. Usa una variable que empieza en Verdadero y se vuelve Falso.',
      'Basta recorrer la palabra completa: no hace falta parar a la mitad.',
    ],
  ),
  Challenge(
    subject: 'Textos',
    topic: 'Construir un texto',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-09',
      title: 'Reto 33 · Texto al revés',
      statement: 'Pide un texto y muéstralo escrito al revés.\n\nSi escriben hola, el programa muestra:\naloh',
      cases: [
        TestCase(inputs: ['hola'], expected: 'aloh'),
        TestCase(inputs: ['jaguar'], expected: 'raugaj'),
        TestCase(inputs: ['a'], expected: 'a', hidden: true),
        TestCase(inputs: ['ana y luis'], expected: 'siul y ana', hidden: true),
      ],
    ),
    hints: [
      'Empieza con un texto vacío: al <- "" y ve pegándole letras.',
      'Recorre de la última letra a la primera: Para i <- Longitud(texto) Hasta 1 Con Paso -1.',
      'Cada vuelta suma la letra i: al <- al + Subcadena(texto, i, i).',
    ],
  ),
  Challenge(
    subject: 'Matrices',
    topic: 'Matrices y recorridos',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-10',
      title: 'Reto 34 · Suma por filas',
      statement:
          'Pide 6 números y guárdalos en una matriz de 2 filas y 3 columnas, llenándola fila por fila. Muestra la suma de cada fila.\n\nSi escriben 1, 2, 3, 4, 5 y 6, el programa muestra:\nFila 1: 6\nFila 2: 15',
      cases: [
        TestCase(inputs: ['1', '2', '3', '4', '5', '6'], expected: 'Fila 1: 6\nFila 2: 15'),
        TestCase(inputs: ['5', '5', '5', '1', '1', '1'], expected: 'Fila 1: 15\nFila 2: 3'),
        TestCase(inputs: ['-1', '1', '0', '10', '20', '30'], expected: 'Fila 1: 0\nFila 2: 60', hidden: true),
      ],
    ),
    hints: [
      'Dimension m[2, 3] crea 2 filas y 3 columnas.',
      'Dos ciclos anidados leen: el de afuera recorre las filas y el de adentro las columnas.',
      'La suma de cada fila empieza en 0 al inicio de cada fila, no una sola vez.',
      'Para i <- 1 Hasta 2 Hacer\n    suma <- 0\n    Para j <- 1 Hasta 3 Hacer\n        suma <- suma + m[i, j]\n    FinPara\n    Escribir "Fila ", i, ": ", suma\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Ordenar',
    topic: 'Ordenamiento burbuja',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-11',
      title: 'Reto 35 · Ordenar de menor a mayor',
      statement:
          'Pide cuántos números van a escribir (n) y luego los n números. Muéstralos ordenados de menor a mayor, uno por renglón.\n\nSi escriben 4, 3, 1, 4 y 2, el programa muestra:\n1\n2\n3\n4',
      cases: [
        TestCase(inputs: ['4', '3', '1', '4', '2'], expected: '1\n2\n3\n4'),
        TestCase(inputs: ['3', '9', '5', '7'], expected: '5\n7\n9'),
        TestCase(inputs: ['1', '8'], expected: '8', hidden: true),
        TestCase(inputs: ['4', '2', '2', '1', '1'], expected: '1\n1\n2\n2', hidden: true),
      ],
    ),
    hints: [
      'El ordenamiento burbuja compara cada casilla con la siguiente y las intercambia si están al revés.',
      'Repite esa pasada n - 1 veces: un Para de afuera para las pasadas y uno de adentro para las parejas.',
      'Para intercambiar usa una variable auxiliar, como en la lección.',
      'Con n = 1 no hay nada que comparar: un Para de 1 hasta 0 contaría hacia atrás, así que agrega Con Paso 1 en los dos ciclos.',
      'Para pasada <- 1 Hasta n - 1 Hacer\n    Para i <- 1 Hasta n - 1 Hacer\n        Si a[i] > a[i + 1] Entonces\n            aux <- a[i]\n            a[i] <- a[i + 1]\n            a[i + 1] <- aux\n        FinSi\n    FinPara\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Matrices',
    topic: 'Diagonal de una matriz',
    level: 3,
    exercise: Exercise(
      id: 'reto-3-12',
      title: 'Reto 36 · Suma de la diagonal',
      statement:
          'Pide 9 números y guárdalos en una matriz de 3 filas y 3 columnas, llenándola fila por fila. Muestra la suma de su diagonal (de la esquina de arriba a la izquierda a la de abajo a la derecha).\n\nSi escriben 1, 2, 3, 4, 5, 6, 7, 8 y 9, el programa muestra:\nDiagonal: 15',
      cases: [
        TestCase(inputs: ['1', '2', '3', '4', '5', '6', '7', '8', '9'], expected: 'Diagonal: 15'),
        TestCase(inputs: ['1', '0', '0', '0', '1', '0', '0', '0', '1'], expected: 'Diagonal: 3'),
        TestCase(inputs: ['-1', '2', '2', '2', '-5', '2', '2', '2', '-9'], expected: 'Diagonal: -15', hidden: true),
        TestCase(inputs: ['9', '9', '9', '9', '9', '9', '9', '9', '9'], expected: 'Diagonal: 27', hidden: true),
      ],
    ),
    hints: [
      'Llena la matriz con dos ciclos anidados y Leer m[i, j].',
      'La diagonal son las casillas donde la fila y la columna son iguales: m[1, 1], m[2, 2] y m[3, 3].',
      'No necesitas dos ciclos para sumarla: un solo Para con m[i, i] basta.',
    ],
  ),
];
