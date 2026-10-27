import 'package:flutter/material.dart';

import 'lessons.dart';

/// The lessons of level 3: data. Arrays, searching, strings and matrices.

const lessonArrays = Lesson(
  id: 'leccion-arreglos',
  title: 'Arreglos',
  summary: 'Guarda muchos valores bajo un solo nombre',
  icon: Icons.view_list_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (a[2] es la casilla número 2 del arreglo a)',
      code: 'Dimension a[3]\na[1] <- 10\na[2] <- 20\na[3] <- 30\nEscribir a[2]',
      options: ['20', '10', '30', '2'],
      answer: 0,
      output: '20',
      right: 'Dimension a[3] crea tres casillas. La casilla 2 guarda 20.',
      wrong: 'Un arreglo guarda varios valores en casillas numeradas. En la casilla 2 se guardó el 20.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (un Para recorre las casillas)',
      code: 'Dimension a[3]\nPara i <- 1 Hasta 3 Hacer\n    a[i] <- i * 2\nFinPara\nEscribir a[1] + a[3]',
      options: ['8', '4', '6', '12'],
      answer: 0,
      output: '8',
      right: 'El Para llena las casillas con 2, 4 y 6. La primera y la tercera suman 2 + 6 = 8.',
      wrong: 'El Para guarda i * 2 en cada casilla: 2, 4 y 6. a[1] + a[3] es 2 + 6 = 8.',
    ),
    ChoiceQuestion(
      prompt: '¿Desde qué número se cuentan las casillas de un arreglo en Jaguar?',
      options: ['Desde 1', 'Desde 0', 'Desde 2', 'Depende del arreglo'],
      answer: 0,
      right: 'En Jaguar la primera casilla es la 1, y la última es la del tamaño: en a[3], la 3.',
      wrong: 'En Jaguar se cuenta desde 1. Un arreglo a[3] tiene las casillas 1, 2 y 3.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para sumar todas las casillas.',
      code:
          'Dimension a[3]\na[1] <- 4\na[2] <- 5\na[3] <- 6\nsuma <- 0\nPara i <- 1 Hasta 3 Hacer\n    suma <- suma + a[___]\nFinPara\nEscribir suma',
      options: ['i', '1', '3', 'a'],
      answer: 0,
      mono: true,
      fillOutput: '15',
      right: 'La i cambia en cada vuelta y visita una casilla distinta.',
      wrong:
          'Si el número es fijo, se suma siempre la misma casilla. Para visitar todas hay que usar la variable del ciclo: i.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error? (el arreglo tiene 3 casillas)',
      lines: [
        'Algoritmo lista',
        'Dimension a[3]',
        'Para i <- 1 Hasta 4 Hacer',
        '    a[i] <- i',
        'FinPara',
        'FinAlgoritmo',
      ],
      errorLine: 2,
      fixed: 'Para i <- 1 Hasta 3 Hacer',
      right: 'El ciclo llega al 4, pero la casilla 4 no existe: el ciclo debe terminar en el tamaño del arreglo.',
      wrong: 'La línea 3: el ciclo llega hasta 4 y el arreglo solo tiene 3 casillas. Debe llegar hasta 3.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (Para Cada visita cada valor sin usar un índice)',
      code:
          'Dimension a[3]\na[1] <- 1\na[2] <- 2\na[3] <- 3\ntotal <- 0\nPara Cada x de a Hacer\n    total <- total + x\nFinPara\nEscribir total',
      options: ['6', '3', '1', '0'],
      answer: 0,
      output: '6',
      right: 'Para Cada toma uno por uno los valores 1, 2 y 3 y los va sumando.',
      wrong: 'Para Cada recorre todos los valores del arreglo: 1 + 2 + 3 = 6.',
    ),
  ],
);

const lessonSearching = Lesson(
  id: 'leccion-buscar',
  title: 'Buscar y comparar',
  summary: 'Encuentra el mayor, una posición o un promedio',
  icon: Icons.search_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (guarda el mayor visto hasta ahora)',
      code:
          'Dimension a[3]\na[1] <- 4\na[2] <- 9\na[3] <- 2\nmayor <- a[1]\nPara i <- 2 Hasta 3 Hacer\n    Si a[i] > mayor Entonces\n        mayor <- a[i]\n    FinSi\nFinPara\nEscribir mayor',
      options: ['9', '4', '2', '15'],
      answer: 0,
      output: '9',
      right: 'Empieza con 4, lo cambia por 9 y el 2 no lo supera.',
      wrong: 'mayor empieza en a[1] = 4. Al ver el 9 lo cambia, y el 2 no es mayor que 9: queda 9.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (también guarda en qué posición estaba)',
      code:
          'Dimension a[3]\na[1] <- 4\na[2] <- 9\na[3] <- 2\nmayor <- a[1]\npos <- 1\nPara i <- 2 Hasta 3 Hacer\n    Si a[i] > mayor Entonces\n        mayor <- a[i]\n        pos <- i\n    FinSi\nFinPara\nEscribir pos',
      options: ['2', '9', '1', '3'],
      answer: 0,
      output: '2',
      right: 'El 9 está en la casilla 2, y es ahí donde pos se actualizó.',
      wrong: 'pos guarda la casilla del mayor: el 9 está en la casilla 2.',
    ),
    ChoiceQuestion(
      prompt: 'Para hallar el mayor de una lista, ¿con qué valor conviene empezar la variable mayor?',
      options: ['Con el primer elemento de la lista', 'Con 0', 'Con -1', 'Con 100'],
      answer: 0,
      right: 'Así funciona aunque todos sean negativos o muy grandes.',
      wrong:
          'Empezar en 0 falla si todos los números son negativos (ninguno supera al 0). Lo seguro es empezar con el primer elemento.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (busca el 3: si está dos veces, se queda con la primera)',
      code:
          'Dimension a[4]\na[1] <- 7\na[2] <- 3\na[3] <- 9\na[4] <- 3\nbuscado <- 3\npos <- 0\nPara i <- 1 Hasta 4 Hacer\n    Si a[i] = buscado Y pos = 0 Entonces\n        pos <- i\n    FinSi\nFinPara\nEscribir pos',
      options: ['2', '4', '0', '3'],
      answer: 0,
      output: '2',
      right: 'pos solo cambia mientras valga 0: se queda con la primera aparición, la casilla 2.',
      wrong: 'pos cambia solo si todavía vale 0, así que se queda con la primera aparición del 3: la casilla 2.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para sacar el promedio de los tres valores.',
      code:
          'Dimension a[3]\na[1] <- 4\na[2] <- 5\na[3] <- 6\nsuma <- 0\nPara i <- 1 Hasta 3 Hacer\n    suma <- suma + a[i]\nFinPara\nEscribir suma / ___',
      options: ['3', 'suma', 'a', '0'],
      answer: 0,
      mono: true,
      fillOutput: '5',
      right: 'El promedio es la suma entre cuántos valores son: 15 / 3 = 5.',
      wrong: 'El promedio es la suma entre la cantidad de valores. Son 3: 15 / 3 = 5.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo mayor',
        'Dimension a[2]',
        'a[1] <- 4',
        'a[2] <- 9',
        'mayor <- a[2',
        'Escribir mayor',
        'FinAlgoritmo',
      ],
      errorLine: 4,
      fixed: 'mayor <- a[2]',
      right: 'Los corchetes se abren y se cierran: a[2].',
      wrong: 'La línea 5: a[2 no cierra el corchete. Debe ser a[2].',
    ),
  ],
);

const lessonStrings = Lesson(
  id: 'leccion-cadenas',
  title: 'Textos por dentro',
  summary: 'Recorre un texto letra por letra',
  icon: Icons.abc_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (Subcadena(texto, 2, 2) toma solo la letra 2)',
      code: 'palabra <- "jaguar"\nEscribir Subcadena(palabra, 2, 2)',
      options: ['a', 'j', 'ag', 'r'],
      answer: 0,
      output: 'a',
      right: 'Las letras se cuentan desde 1: j es la 1 y a es la 2.',
      wrong: 'Subcadena con el mismo número al inicio y al final toma una sola letra: la 2 de jaguar es la a.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (la última letra está en la posición Longitud)',
      code: 'palabra <- "sol"\nEscribir Subcadena(palabra, Longitud(palabra), Longitud(palabra))',
      options: ['l', 's', 'o', '3'],
      answer: 0,
      output: 'l',
      right: 'sol tiene 3 letras y la última es la l.',
      wrong: 'Longitud(palabra) es 3, la posición de la última letra: la l.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (recorre la palabra y cuenta las a)',
      code:
          'palabra <- "casa"\ncuenta <- 0\nPara i <- 1 Hasta Longitud(palabra) Hacer\n    Si Subcadena(palabra, i, i) = "a" Entonces\n        cuenta <- cuenta + 1\n    FinSi\nFinPara\nEscribir cuenta',
      options: ['2', '1', '4', '0'],
      answer: 0,
      output: '2',
      right: 'casa tiene dos letras a (posiciones 2 y 4).',
      wrong: 'El ciclo mira cada letra de casa; las a están en las posiciones 2 y 4: son 2.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (recorre de atrás hacia adelante)',
      code:
          'palabra <- "abc"\ninvertida <- ""\nPara i <- Longitud(palabra) Hasta 1 Con Paso -1 Hacer\n    invertida <- invertida + Subcadena(palabra, i, i)\nFinPara\nEscribir invertida',
      options: ['cba', 'abc', 'bca', 'c'],
      answer: 0,
      output: 'cba',
      right: 'Va de la última letra a la primera y las va juntando: c, luego b, luego a.',
      wrong: 'El ciclo baja de la posición 3 a la 1 y va pegando cada letra: cba.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para mostrar todas las letras de la palabra.',
      code: 'palabra <- "sol"\nPara i <- 1 Hasta ___ Hacer\n    Escribir Sin Saltar Subcadena(palabra, i, i)\nFinPara',
      options: ['Longitud(palabra)', 'palabra', 'Longitud', '0'],
      answer: 0,
      mono: true,
      fillOutput: 'sol',
      right: 'El ciclo debe llegar hasta la última letra, y esa posición es Longitud(palabra).',
      wrong: 'El ciclo debe llegar hasta la última posición del texto: Longitud(palabra).',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo letras',
        'palabra <- "jaguar"',
        'Para i <- 1 Hasta Longitud(palabra) Hacer',
        '    Escribir Subcadena(palabra, i)',
        'FinPara',
        'FinAlgoritmo',
      ],
      errorLine: 3,
      fixed: '    Escribir Subcadena(palabra, i, i)',
      right: 'Subcadena necesita el texto, desde dónde y hasta dónde: Subcadena(palabra, i, i).',
      wrong: 'La línea 4: a Subcadena le falta un dato. Necesita tres: el texto, desde y hasta.',
    ),
  ],
);

const lessonMatricesSorting = Lesson(
  id: 'leccion-matrices-ordenar',
  title: 'Matrices y ordenar',
  summary: 'Tablas con filas y columnas, e intercambiar valores',
  icon: Icons.grid_on_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (m[fila, columna])',
      code: 'Dimension m[2, 2]\nm[1, 1] <- 1\nm[1, 2] <- 2\nm[2, 1] <- 3\nm[2, 2] <- 4\nEscribir m[2, 1]',
      options: ['3', '2', '1', '4'],
      answer: 0,
      output: '3',
      right: 'm[2, 1] es la fila 2, columna 1.',
      wrong: 'Primero va la fila y luego la columna: m[2, 1] es la fila 2, columna 1, donde se guardó el 3.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (dos ciclos recorren filas y columnas)',
      code:
          'Dimension m[2, 2]\nPara i <- 1 Hasta 2 Hacer\n    Para j <- 1 Hasta 2 Hacer\n        m[i, j] <- i * j\n    FinPara\nFinPara\nEscribir m[2, 2]',
      options: ['4', '2', '1', '3'],
      answer: 0,
      output: '4',
      right: 'En la casilla de la fila 2 y la columna 2 se guardó 2 × 2 = 4.',
      wrong: 'Cada casilla guarda fila × columna. En la fila 2, columna 2: 2 × 2 = 4.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (suma la diagonal: las casillas con fila igual a columna)',
      code:
          'Dimension m[3, 3]\nPara i <- 1 Hasta 3 Hacer\n    Para j <- 1 Hasta 3 Hacer\n        m[i, j] <- i + j\n    FinPara\nFinPara\nsuma <- 0\nPara i <- 1 Hasta 3 Hacer\n    suma <- suma + m[i, i]\nFinPara\nEscribir suma',
      options: ['12', '18', '6', '9'],
      answer: 0,
      output: '12',
      right: 'La diagonal tiene m[1,1] = 2, m[2,2] = 4 y m[3,3] = 6: suman 12.',
      wrong: 'En la diagonal la fila y la columna son iguales: 2 + 4 + 6 = 12.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (así se intercambian dos valores)',
      code: 'a <- 5\nb <- 8\naux <- a\na <- b\nb <- aux\nEscribir a, " ", b',
      options: ['8 5', '5 8', '8 8', '5 5'],
      answer: 0,
      output: '8 5',
      right: 'aux guarda el 5 para no perderlo cuando a toma el valor de b.',
      wrong: 'aux guarda el valor de a, a toma el de b y b recupera el de aux: quedan intercambiados, 8 y 5.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para intercambiar a y b sin perder ningún valor.',
      code: 'a <- 5\nb <- 8\naux <- ___\na <- b\nb <- aux\nEscribir a, " ", b',
      options: ['a', 'b', 'aux', '0'],
      answer: 0,
      mono: true,
      fillOutput: '8 5',
      right: 'Hay que guardar el valor de a antes de que se pierda.',
      wrong: 'aux debe guardar el valor de a, porque a es el que se va a sobrescribir en la siguiente línea.',
    ),
    OrderQuestion(
      prompt: 'Ordena las líneas para dejar el menor en a y el mayor en b.',
      lines: [
        'a <- 9',
        'b <- 4',
        'Si a > b Entonces',
        '    aux <- a',
        '    a <- b',
        '    b <- aux',
        'FinSi',
        'Escribir a, " ", b',
      ],
      right: 'Si a es mayor que b, se intercambian. Repetir esto entre vecinos es la base del ordenamiento burbuja.',
      wrong: 'Primero los valores, luego el Si que los intercambia si están al revés y al final se muestran.',
    ),
  ],
);

const lessonsNivel3 = [lessonArrays, lessonSearching, lessonStrings, lessonMatricesSorting];
