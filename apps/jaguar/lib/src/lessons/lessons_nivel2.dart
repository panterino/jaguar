import 'package:flutter/material.dart';

import 'lessons.dart';

/// The lessons of level 2: decisions and loops in depth.

const lessonCompoundConditions = Lesson(
  id: 'leccion-condiciones-compuestas',
  title: 'Condiciones compuestas',
  summary: 'Combina condiciones con Y, O y NO',
  icon: Icons.call_split_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (Y exige que se cumplan las dos condiciones)',
      code:
          'edad <- 15\nSi edad >= 12 Y edad <= 17 Entonces\n    Escribir "Adolescente"\nSiNo\n    Escribir "Otro"\nFinSi',
      options: ['Adolescente', 'Otro', 'Un error', 'Nada'],
      answer: 0,
      output: 'Adolescente',
      right: 'Con Y deben cumplirse las dos: 15 es mayor o igual que 12 y menor o igual que 17.',
      wrong: 'Con Y deben cumplirse las dos condiciones. 15 cumple edad >= 12 y también edad <= 17: sale Adolescente.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (O basta con que se cumpla una)',
      code: 'n <- 5\nSi n < 0 O n > 3 Entonces\n    Escribir "Fuera"\nSiNo\n    Escribir "Dentro"\nFinSi',
      options: ['Fuera', 'Dentro', 'Fuera y Dentro', 'Un error'],
      answer: 0,
      output: 'Fuera',
      right: 'n < 0 no se cumple, pero n > 3 sí. Con O basta una, así que entra al Si.',
      wrong: 'Con O basta con que una condición se cumpla. 5 no es menor que 0, pero sí es mayor que 3: sale Fuera.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (NO cambia verdadero por falso)',
      code: 'lleno <- Falso\nSi NO lleno Entonces\n    Escribir "Hay lugar"\nFinSi',
      options: ['Hay lugar', 'Nada', 'lleno', 'Un error'],
      answer: 0,
      output: 'Hay lugar',
      right: 'lleno es Falso, y NO lo vuelve Verdadero: entra al Si.',
      wrong: 'NO invierte la condición: lleno vale Falso, así que NO lleno es Verdadero y se muestra Hay lugar.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para que el 15 salga Fuera del rango de 1 a 10.',
      code: 'n <- 15\nSi n >= 1 ___ n <= 10 Entonces\n    Escribir "Dentro"\nSiNo\n    Escribir "Fuera"\nFinSi',
      options: ['Y', 'O', 'NO', '+'],
      answer: 0,
      mono: true,
      fillOutput: 'Fuera',
      right: 'Para estar dentro del rango hay que cumplir las dos: mayor que 1 Y menor que 10.',
      wrong: 'Con O, el 15 sería "Dentro" porque cumple n >= 1. Para un rango se necesitan las dos condiciones: Y.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo rango',
        'Leer n',
        'Si n >= 1 Y <= 10 Entonces',
        '    Escribir "Dentro"',
        'FinSi',
        'FinAlgoritmo',
      ],
      inputs: ['5'],
      errorLine: 2,
      fixed: 'Si n >= 1 Y n <= 10 Entonces',
      right: 'Cada lado de la Y es una condición completa: falta repetir n antes de <= 10.',
      wrong: 'La línea 3: <= 10 no es una condición completa. Cada lado de Y necesita su variable: n <= 10.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (un Si dentro de otro Si)',
      code:
          'n <- 8\nSi n > 0 Entonces\n    Si n MOD 2 = 0 Entonces\n        Escribir "Positivo par"\n    SiNo\n        Escribir "Positivo impar"\n    FinSi\nSiNo\n    Escribir "No positivo"\nFinSi',
      options: ['Positivo par', 'Positivo impar', 'No positivo', 'Nada'],
      answer: 0,
      output: 'Positivo par',
      right: 'Primero entra por n > 0 y, ya adentro, el segundo Si ve que 8 es par.',
      wrong: '8 es mayor que 0, así que entra al primer Si; adentro, 8 MOD 2 es 0, es par: Positivo par.',
    ),
  ],
);

const lessonSegun = Lesson(
  id: 'leccion-segun',
  title: 'Menús con Según',
  summary: 'Elige entre varios casos con Segun',
  icon: Icons.list_alt_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code:
          'opcion <- 2\nSegun opcion Hacer\n    1: Escribir "Sumar"\n    2: Escribir "Restar"\n    De Otro Modo: Escribir "Otra"\nFinSegun',
      options: ['Restar', 'Sumar', 'Otra', 'Sumar y Restar'],
      answer: 0,
      output: 'Restar',
      right: 'Segun compara opcion con cada caso y ejecuta solo el que coincide: el 2.',
      wrong: 'opcion vale 2, y el caso 2 es Restar. Segun ejecuta solo el caso que coincide.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (De Otro Modo recoge lo que no coincide)',
      code:
          'opcion <- 9\nSegun opcion Hacer\n    1: Escribir "Sumar"\n    2: Escribir "Restar"\n    De Otro Modo: Escribir "Otra"\nFinSegun',
      options: ['Otra', 'Sumar', 'Restar', 'Nada'],
      answer: 0,
      output: 'Otra',
      right: 'El 9 no es ningún caso, así que se ejecuta De Otro Modo.',
      wrong: 'El 9 no coincide con el 1 ni con el 2: entra De Otro Modo, que muestra Otra.',
    ),
    ChoiceQuestion(
      prompt: '¿Para qué sirve De Otro Modo en un Segun?',
      options: [
        'Para lo que no coincide con ningún caso',
        'Para repetir el Segun',
        'Para terminar el programa',
        'Para el primer caso',
      ],
      answer: 0,
      right: 'Es el "en cualquier otro caso": ideal para avisar de una opción que no existe.',
      wrong: 'De Otro Modo se ejecuta cuando ningún caso coincide. Sirve para avisar de una opción que no existe.',
    ),
    ChoiceQuestion(
      prompt: 'Completa la palabra que abre el menú.',
      code: 'dia <- 3\n___ dia Hacer\n    1: Escribir "Lunes"\n    3: Escribir "Miércoles"\nFinSegun',
      options: ['Segun', 'Si', 'Mientras', 'Para'],
      answer: 0,
      mono: true,
      fillOutput: 'Miércoles',
      right: 'Segun elige entre varios casos del mismo dato.',
      wrong: 'Se abre con Segun y se cierra con FinSegun. Si, Mientras y Para son otras estructuras.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo menu',
        'Leer opcion',
        'Segun opcion Hacer',
        '    1 Escribir "Hola"',
        '    2: Escribir "Adiós"',
        'FinSegun',
        'FinAlgoritmo',
      ],
      inputs: ['1'],
      errorLine: 3,
      fixed: '    1: Escribir "Hola"',
      right: 'Cada caso lleva dos puntos después del valor: 1:',
      wrong: 'La línea 4: al caso le faltan los dos puntos. Debe ser 1: Escribir "Hola".',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (no hay caso para el 5 ni De Otro Modo)',
      code: 'n <- 5\nSegun n Hacer\n    1: Escribir "Uno"\nFinSegun\nEscribir "Fin"',
      options: ['Fin', 'Uno', 'Un error', 'Nada'],
      answer: 0,
      output: 'Fin',
      right: 'Si ningún caso coincide y no hay De Otro Modo, el Segun no hace nada y el programa sigue.',
      wrong: 'Sin caso que coincida ni De Otro Modo, el Segun no hace nada; el programa sigue y muestra Fin.',
    ),
  ],
);

const lessonSentinel = Lesson(
  id: 'leccion-centinela',
  title: 'Repetir hasta que digan basta',
  summary: 'Mientras con un valor que marca el final',
  icon: Icons.loop_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'n <- 3\nMientras n > 0 Hacer\n    Escribir n\n    n <- n - 1\nFinMientras',
      options: ['3, 2, 1', '1, 2, 3', '3, 2, 1, 0', 'Nada'],
      answer: 0,
      output: '3\n2\n1',
      right: 'Cada vuelta muestra n y lo baja en uno; cuando n llega a 0, la condición falla y termina.',
      wrong: 'Mientras repite mientras n > 0: muestra 3, 2 y 1. Con n en 0 ya no entra.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (la condición se revisa antes de entrar)',
      code: 'n <- 0\nMientras n > 0 Hacer\n    Escribir "Hola"\nFinMientras\nEscribir "Fin"',
      options: ['Fin', 'Hola y Fin', 'Hola', 'Un error'],
      answer: 0,
      output: 'Fin',
      right: 'Mientras puede no ejecutarse ni una vez: si la condición ya es falsa, se la salta.',
      wrong: 'Mientras revisa la condición antes de cada vuelta. Con n en 0 no entra nunca, así que solo sale Fin.',
    ),
    ChoiceQuestion(
      prompt: 'El programa lee números hasta que escriben 0 (el 0 es el centinela). ¿Qué muestra con 4, 6 y 0?',
      code: 'suma <- 0\nLeer n\nMientras n <> 0 Hacer\n    suma <- suma + n\n    Leer n\nFinMientras\nEscribir suma',
      inputs: ['4', '6', '0'],
      options: ['10', '4', '6', '0'],
      answer: 0,
      output: '10',
      right: 'Suma 4 y 6; al leer el 0, la condición falla y termina sin sumarlo.',
      wrong: 'Suma 4 y 6, y el 0 solo avisa que ya acabaron: no se suma. Sale 10.',
    ),
    ChoiceQuestion(
      prompt: '¿Por qué ese programa tiene un Leer antes del Mientras y otro dentro?',
      options: [
        'El primero da el valor para la condición; el de adentro lee el siguiente',
        'Por si el primero falla',
        'Porque Leer solo funciona dentro de ciclos',
        'No hace falta: sobra uno',
      ],
      answer: 0,
      right: 'Sin el primero, la condición no tendría valor; sin el de adentro, nunca cambiaría y no terminaría.',
      wrong:
          'El primer Leer da el valor que revisa la condición, y el de adentro lo cambia en cada vuelta. Sin él, el ciclo no terminaría.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo cuenta',
        'Leer n',
        'Mientras n > 0 Hacer',
        '    Escribir n',
        '    n <- n - 1',
        'FinSi',
        'FinAlgoritmo',
      ],
      inputs: ['3'],
      errorLine: 5,
      fixed: 'FinMientras',
      right: 'Cada estructura se cierra con su propia palabra: Mientras con FinMientras.',
      wrong: 'La línea 6: un Mientras se cierra con FinMientras, no con FinSi.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para que cuente de 1 a 3.',
      code: 'n <- 1\nMientras n <= 3 Hacer\n    Escribir n\n    n <- n ___ 1\nFinMientras',
      options: ['+', '-', '*', '/'],
      answer: 0,
      mono: true,
      fillOutput: '1\n2\n3',
      right: 'Hay que acercar n al límite: sumar uno en cada vuelta.',
      wrong: 'Con los demás símbolos n nunca pasa de 3 y el ciclo no termina. Para contar hacia arriba se suma: +.',
    ),
  ],
);

const lessonLoopsDeep = Lesson(
  id: 'leccion-ciclos-a-fondo',
  title: 'Contadores y acumuladores',
  summary: 'Para con Paso, sumar y contar',
  icon: Icons.calculate_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (Con Paso salta de dos en dos, de cuatro en cuatro...)',
      code: 'Para i <- 2 Hasta 10 Con Paso 4 Hacer\n    Escribir i\nFinPara',
      options: ['2, 6, 10', '2, 3, 4', '2, 4, 6, 8, 10', '4, 8'],
      answer: 0,
      output: '2\n6\n10',
      right: 'Empieza en 2 y suma 4 cada vuelta: 2, 6 y 10.',
      wrong: 'Con Paso 4 la i avanza de cuatro en cuatro: 2, 6 y 10.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (suma es un acumulador: guarda un total)',
      code: 'suma <- 0\nPara i <- 1 Hasta 4 Hacer\n    suma <- suma + i\nFinPara\nEscribir suma',
      options: ['10', '4', '6', '24'],
      answer: 0,
      output: '10',
      right: 'Acumula 1 + 2 + 3 + 4 = 10. Siempre se empieza el acumulador en 0.',
      wrong: 'En cada vuelta suma i al total: 1 + 2 + 3 + 4 = 10.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (contador cuenta cuántas veces pasa algo)',
      code:
          'contador <- 0\nPara i <- 1 Hasta 10 Hacer\n    Si i MOD 3 = 0 Entonces\n        contador <- contador + 1\n    FinSi\nFinPara\nEscribir contador',
      options: ['3', '10', '9', '1'],
      answer: 0,
      output: '3',
      right: 'Los múltiplos de 3 entre 1 y 10 son 3, 6 y 9: tres veces.',
      wrong: 'El contador sube solo cuando i es múltiplo de 3 (3, 6 y 9): son 3 veces.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (Repetir siempre da al menos una vuelta)',
      code: 'n <- 10\nRepetir\n    Escribir "Hola"\nHasta Que n > 5',
      options: ['Hola', 'Nada', 'Hola, Hola', 'Un error'],
      answer: 0,
      output: 'Hola',
      right: 'Repetir revisa la condición al final: da una vuelta y, como n > 5 ya es cierto, termina.',
      wrong:
          'Repetir revisa la condición después de cada vuelta, así que siempre hace al menos una: sale Hola una vez.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para contar hacia atrás.',
      code: 'Para i <- 3 ___ 1 Con Paso -1 Hacer\n    Escribir i\nFinPara',
      options: ['Hasta', 'Hacer', 'Con', 'En'],
      answer: 0,
      mono: true,
      fillOutput: '3\n2\n1',
      right: 'Para i <- inicio Hasta fin: con Paso -1 baja de uno en uno.',
      wrong: 'Entre el inicio y el fin va la palabra Hasta: Para i <- 3 Hasta 1.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: [
        'Algoritmo sumar',
        'suma <- 0',
        'Para i <- 1 Hasta 4 Hacer',
        '    suma <- suma +',
        'FinPara',
        'Escribir suma',
        'FinAlgoritmo',
      ],
      errorLine: 3,
      fixed: '    suma <- suma + i',
      right: 'A la suma le falta lo que se suma: después del + va la i.',
      wrong: 'La línea 4: el + necesita algo a su derecha. Para acumular, suma <- suma + i.',
    ),
  ],
);

const lessonNestedLoops = Lesson(
  id: 'leccion-ciclos-anidados',
  title: 'Ciclos dentro de ciclos',
  summary: 'Tablas y figuras con ciclos anidados',
  icon: Icons.grid_view_rounded,
  questions: [
    ChoiceQuestion(
      prompt: '¿Cuánto vale veces al final? (el ciclo de adentro se repite completo en cada vuelta del de afuera)',
      code:
          'veces <- 0\nPara i <- 1 Hasta 3 Hacer\n    Para j <- 1 Hasta 2 Hacer\n        veces <- veces + 1\n    FinPara\nFinPara\nEscribir veces',
      options: ['6', '5', '3', '2'],
      answer: 0,
      output: '6',
      right: '3 vueltas de afuera por 2 de adentro: 3 × 2 = 6.',
      wrong: 'Por cada una de las 3 vueltas de afuera, el de adentro da 2: 3 × 2 = 6.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code:
          'Para i <- 1 Hasta 2 Hacer\n    Para j <- 1 Hasta 2 Hacer\n        Escribir i, " x ", j, " = ", i * j\n    FinPara\nFinPara',
      options: [
        '1 x 1 = 1, 1 x 2 = 2, 2 x 1 = 2, 2 x 2 = 4',
        '1 x 1 = 1, 2 x 2 = 4',
        '1 x 1 = 1, 2 x 1 = 2, 1 x 2 = 2, 2 x 2 = 4',
        '1 x 2 = 2, 2 x 2 = 4',
      ],
      answer: 0,
      output: '1 x 1 = 1\n1 x 2 = 2\n2 x 1 = 2\n2 x 2 = 4',
      right: 'La i cambia despacio y la j rápido: con i = 1 recorre j = 1 y 2, y luego pasa a i = 2.',
      wrong:
          'El ciclo de afuera cambia poco a poco: con i = 1 el de adentro da j = 1 y 2; después i = 2 y otra vez j = 1 y 2.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué dibuja este programa? (Escribir Sin Saltar no baja de renglón)',
      code:
          'Para i <- 1 Hasta 3 Hacer\n    Para j <- 1 Hasta i Hacer\n        Escribir Sin Saltar "*"\n    FinPara\n    Escribir ""\nFinPara',
      options: ['*, **, ***', '***, ***, ***', '*, *, *', '***, **, *'],
      answer: 0,
      output: '*\n**\n***',
      right: 'El ciclo de adentro llega hasta i: una estrella en el renglón 1, dos en el 2 y tres en el 3.',
      wrong: 'El de adentro cuenta hasta i, que crece: 1 estrella, luego 2 y luego 3. El Escribir "" baja de renglón.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para dibujar la escalera.',
      code:
          'Para i <- 1 Hasta 3 Hacer\n    Para j <- 1 Hasta ___ Hacer\n        Escribir Sin Saltar "*"\n    FinPara\n    Escribir ""\nFinPara',
      options: ['i', '3', 'j', '1'],
      answer: 0,
      mono: true,
      fillOutput: '*\n**\n***',
      right: 'El límite del ciclo de adentro es i: crece un poco en cada renglón.',
      wrong: 'Con 3 todos los renglones tendrían tres estrellas. Para que crezcan, el límite debe ser i.',
    ),
    FindErrorQuestion(
      prompt: '¿Qué línea tiene el error?',
      lines: ['Algoritmo fila', 'Para j <- 1 Hasta 3 Hacer', '    Escribir Sin Saltar *', 'FinPara', 'FinAlgoritmo'],
      errorLine: 2,
      fixed: '    Escribir Sin Saltar "*"',
      right: 'Un texto va entre comillas: sin ellas, el * parece una multiplicación.',
      wrong: 'La línea 3: el asterisco es un texto y necesita comillas: "*".',
    ),
    ChoiceQuestion(
      prompt:
          'Si el ciclo de afuera da 4 vueltas y el de adentro 5, ¿cuántas veces se ejecuta lo que está dentro del de adentro?',
      options: ['20', '9', '4', '5'],
      answer: 0,
      right: 'Se multiplican: 4 × 5 = 20.',
      wrong: 'En cada una de las 4 vueltas de afuera, el de adentro da 5: 4 × 5 = 20.',
    ),
  ],
);

const lessonsNivel2 = [lessonCompoundConditions, lessonSegun, lessonSentinel, lessonLoopsDeep, lessonNestedLoops];
