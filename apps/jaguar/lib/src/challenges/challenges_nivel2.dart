import 'package:jaguar_core/jaguar_core.dart';

import 'challenges.dart';

/// Level 2: decisions and loops in depth. Each one has a hidden case on an
/// edge that a nearly right program gets wrong.
const challengesNivel2 = <Challenge>[
  Challenge(
    subject: 'Condicionales',
    topic: 'Condiciones compuestas',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-01',
      title: 'Reto 13 · Año bisiesto',
      statement:
          'Pide un año y di si es bisiesto. Es bisiesto si es múltiplo de 4, pero no de 100, salvo que también sea múltiplo de 400.\n\n'
          'Si escriben 2024, el programa muestra:\nBisiesto',
      cases: [
        TestCase(inputs: ['2024'], expected: 'Bisiesto'),
        TestCase(inputs: ['2023'], expected: 'No bisiesto'),
        TestCase(inputs: ['1900'], expected: 'No bisiesto', hidden: true),
        TestCase(inputs: ['2000'], expected: 'Bisiesto', hidden: true),
      ],
    ),
    hints: [
      'Un número es múltiplo de otro cuando el resto de la división (MOD) es 0.',
      'Junta las condiciones con Y y O, y usa paréntesis para decidir qué se evalúa primero.',
      'Es bisiesto si (año MOD 4 = 0 Y año MOD 100 <> 0) O año MOD 400 = 0.',
      'Si (año MOD 4 = 0 Y año MOD 100 <> 0) O año MOD 400 = 0 Entonces\n    Escribir "Bisiesto"\nSiNo\n    Escribir "No bisiesto"\nFinSi',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Condiciones compuestas',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-02',
      title: 'Reto 14 · El mayor de tres',
      statement:
          'Pide tres números y muestra el mayor.\n\n'
          'Si escriben 3, 7 y 5, el programa muestra:\nMayor: 7',
      cases: [
        TestCase(inputs: ['3', '7', '5'], expected: 'Mayor: 7'),
        TestCase(inputs: ['9', '2', '4'], expected: 'Mayor: 9'),
        TestCase(inputs: ['4', '4', '4'], expected: 'Mayor: 4', hidden: true),
        TestCase(inputs: ['-1', '-5', '-3'], expected: 'Mayor: -1', hidden: true),
      ],
    ),
    hints: [
      'Puedes suponer que el primero es el mayor y comparar con los otros dos.',
      'Guarda el mayor en una variable: empieza con a, y si b es más grande, cámbiala; luego igual con c.',
      'mayor <- a\nSi b > mayor Entonces\n    mayor <- b\nFinSi\n(y lo mismo con c)',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Condiciones anidadas',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-03',
      title: 'Reto 15 · Tipo de triángulo',
      statement:
          'Pide los tres lados de un triángulo y di de qué tipo es: Equilátero si los tres lados son iguales, Isósceles si solo dos lo son, y Escaleno si los tres son distintos.\n\n'
          'Si escriben 3, 3 y 3, el programa muestra:\nEquilátero',
      cases: [
        TestCase(inputs: ['3', '3', '3'], expected: 'Equilátero'),
        TestCase(inputs: ['3', '4', '5'], expected: 'Escaleno'),
        TestCase(inputs: ['2', '2', '3'], expected: 'Isósceles', hidden: true),
        TestCase(inputs: ['3', '2', '3'], expected: 'Isósceles', hidden: true),
      ],
    ),
    hints: [
      'Revisa primero el caso más estricto: los tres iguales.',
      'Después, si dos cualesquiera son iguales (a con b, b con c o a con c), es isósceles. Une las tres con O.',
      'Si a = b Y b = c Entonces ... SiNo Si a = b O b = c O a = c Entonces ... SiNo ... FinSi FinSi',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Segun',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-04',
      title: 'Reto 16 · Calculadora',
      statement:
          'Pide un número, una operación (+, -, * o /) y otro número, y muestra el resultado. Si piden dividir entre 0, muestra: No se puede dividir.\n\n'
          'Si escriben 6, + y 2, el programa muestra:\n8',
      cases: [
        TestCase(inputs: ['6', '+', '2'], expected: '8'),
        TestCase(inputs: ['6', '*', '2'], expected: '12'),
        TestCase(inputs: ['6', '-', '2'], expected: '4', hidden: true),
        TestCase(inputs: ['5', '/', '0'], expected: 'No se puede dividir', hidden: true),
      ],
    ),
    hints: [
      'La operación es un texto: Defínela Como Texto y lee las tres cosas en orden.',
      'Un Segun sobre la operación tiene un caso por cada símbolo: "+", "-", "*" y "/".',
      'En el caso "/", revisa antes si b es 0 con un Si.',
      'Segun op Hacer\n    "+": Escribir a + b\n    "/": Si b = 0 Entonces ... SiNo Escribir a / b FinSi\nFinSegun',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Segun',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-05',
      title: 'Reto 17 · Nombre del mes',
      statement:
          'Pide el número de un mes y muestra su nombre. Si no es de 1 a 12, muestra: Mes inválido.\n\n'
          'Si escriben 3, el programa muestra:\nMarzo',
      cases: [
        TestCase(inputs: ['3'], expected: 'Marzo'),
        TestCase(inputs: ['12'], expected: 'Diciembre'),
        TestCase(inputs: ['1'], expected: 'Enero', hidden: true),
        TestCase(inputs: ['13'], expected: 'Mes inválido', hidden: true),
        TestCase(inputs: ['0'], expected: 'Mes inválido', hidden: true),
      ],
    ),
    hints: [
      'Es un menú de doce casos: un Segun sobre el número del mes.',
      'Cada caso es "número: Escribir nombre". Lo que no coincida va en De Otro Modo.',
      'Segun mes Hacer\n    1: Escribir "Enero"\n    2: Escribir "Febrero"\n    ...\n    De Otro Modo: Escribir "Mes inválido"\nFinSegun',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Mientras con centinela',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-06',
      title: 'Reto 18 · Promedio de calificaciones',
      statement:
          'Pide calificaciones hasta que escriban -1 y muestra su promedio. Si no escribieron ninguna, muestra: Sin datos.\n\n'
          'Si escriben 8, 10 y -1, el programa muestra:\nPromedio: 9',
      cases: [
        TestCase(inputs: ['8', '10', '-1'], expected: 'Promedio: 9'),
        TestCase(inputs: ['6', '7', '-1'], expected: 'Promedio: 6.5'),
        TestCase(inputs: ['-1'], expected: 'Sin datos', hidden: true),
        TestCase(inputs: ['10', '-1'], expected: 'Promedio: 10', hidden: true),
      ],
    ),
    hints: [
      'Necesitas dos acumuladores que empiezan en 0: la suma y cuántas calificaciones van.',
      'Lee la primera antes del Mientras, y vuelve a leer al final de cada vuelta. El -1 no se suma.',
      'Al terminar, si la cuenta sigue en 0 no se puede dividir: muestra Sin datos.',
      'Leer c\nMientras c <> -1 Hacer\n    suma <- suma + c\n    cuenta <- cuenta + 1\n    Leer c\nFinMientras',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Mientras con centinela',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-07',
      title: 'Reto 19 · El mayor de la lista',
      statement:
          'Pide números hasta que escriban 0 y muestra el mayor. Si el primero es 0, muestra: Sin números.\n\n'
          'Si escriben 3, 9, 4 y 0, el programa muestra:\nMayor: 9',
      cases: [
        TestCase(inputs: ['3', '9', '4', '0'], expected: 'Mayor: 9'),
        TestCase(inputs: ['5', '0'], expected: 'Mayor: 5'),
        TestCase(inputs: ['-3', '-1', '-7', '0'], expected: 'Mayor: -1', hidden: true),
        TestCase(inputs: ['0'], expected: 'Sin números', hidden: true),
      ],
    ),
    hints: [
      'Guarda el mayor visto hasta ahora y compáralo con cada número nuevo.',
      '¿Con qué valor empieza el mayor? Si empiezas en 0, los números negativos nunca lo superarían: empieza con el primer número que lean.',
      'Leer n\nSi n = 0 Entonces Escribir "Sin números"\nSiNo mayor <- n; Mientras n <> 0 ...',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Acumuladores',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-08',
      title: 'Reto 20 · Suma de pares',
      statement:
          'Pide un número n y muestra la suma de los números pares del 1 al n.\n\n'
          'Si escriben 10, el programa muestra:\nSuma: 30',
      cases: [
        TestCase(inputs: ['10'], expected: 'Suma: 30'),
        TestCase(inputs: ['7'], expected: 'Suma: 12'),
        TestCase(inputs: ['1'], expected: 'Suma: 0', hidden: true),
        TestCase(inputs: ['2'], expected: 'Suma: 2', hidden: true),
      ],
    ),
    hints: [
      'Un acumulador empieza en 0 y crece dentro del ciclo.',
      'Recorre del 1 al n y suma solo cuando el número es par: i MOD 2 = 0.',
      'suma <- 0\nPara i <- 1 Hasta n Hacer\n    Si i MOD 2 = 0 Entonces\n        suma <- suma + i\n    FinSi\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Acumuladores',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-09',
      title: 'Reto 21 · Factorial',
      statement:
          'Pide un número n y muestra su factorial: el producto de todos los números del 1 al n. El factorial de 0 es 1.\n\n'
          'Si escriben 5, el programa muestra:\nFactorial: 120',
      cases: [
        TestCase(inputs: ['5'], expected: 'Factorial: 120'),
        TestCase(inputs: ['3'], expected: 'Factorial: 6'),
        TestCase(inputs: ['0'], expected: 'Factorial: 1', hidden: true),
        TestCase(inputs: ['10'], expected: 'Factorial: 3628800', hidden: true),
      ],
    ),
    hints: [
      'Es como una suma, pero el acumulador multiplica y se va multiplicando por n, n-1, n-2... hasta 1.',
      'Un acumulador que multiplica empieza en 1, no en 0: con 0 todo daría 0.',
      'Cuidado con n = 0: un Para de 1 hasta 0 cuenta hacia atrás (1 y 0) y daría 0. Un Mientras n > 1 evita ese problema.',
      'factorial <- 1\nMientras n > 1 Hacer\n    factorial <- factorial * n\n    n <- n - 1\nFinMientras',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Para con Paso',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-10',
      title: 'Reto 22 · Cuenta regresiva',
      statement:
          'Pide un número n y muestra la cuenta regresiva desde n hasta 1, un número por renglón, y al final: ¡Despegue!\n\n'
          'Si escriben 3, el programa muestra:\n3\n2\n1\n¡Despegue!',
      cases: [
        TestCase(inputs: ['3'], expected: '3\n2\n1\n¡Despegue!'),
        TestCase(inputs: ['1'], expected: '1\n¡Despegue!'),
        TestCase(inputs: ['0'], expected: '¡Despegue!', hidden: true),
      ],
    ),
    hints: [
      'Para puede contar hacia atrás con Con Paso -1.',
      'Cuenta de n a 1 con Paso -1 y, después del ciclo, muestra el mensaje.',
      'Cuidado con n = 0: el ciclo no debe mostrar nada.',
      'Para i <- n Hasta 1 Con Paso -1 Hacer\n    Escribir i\nFinPara\nEscribir "¡Despegue!"',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Ciclos anidados',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-11',
      title: 'Reto 23 · Cuadro de asteriscos',
      statement:
          'Pide un número n y dibuja un cuadro de n renglones con n asteriscos cada uno.\n\n'
          'Si escriben 3, el programa muestra:\n***\n***\n***',
      cases: [
        TestCase(inputs: ['3'], expected: '***\n***\n***'),
        TestCase(inputs: ['2'], expected: '**\n**'),
        TestCase(inputs: ['1'], expected: '*', hidden: true),
        TestCase(inputs: ['4'], expected: '****\n****\n****\n****', hidden: true),
      ],
    ),
    hints: [
      'Un ciclo de afuera para los renglones y uno de adentro para los asteriscos de cada renglón.',
      'Escribir Sin Saltar deja el cursor en el mismo renglón; un Escribir "" al terminar cada renglón baja al siguiente.',
      'Para i <- 1 Hasta n Hacer\n    Para j <- 1 Hasta n Hacer\n        Escribir Sin Saltar "*"\n    FinPara\n    Escribir ""\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Ciclos anidados',
    level: 2,
    exercise: Exercise(
      id: 'reto-2-12',
      title: 'Reto 24 · Escalera',
      statement:
          'Pide un número n y dibuja una escalera de n renglones: el primero con un asterisco, el segundo con dos, y así hasta n.\n\n'
          'Si escriben 4, el programa muestra:\n*\n**\n***\n****',
      cases: [
        TestCase(inputs: ['4'], expected: '*\n**\n***\n****'),
        TestCase(inputs: ['2'], expected: '*\n**'),
        TestCase(inputs: ['1'], expected: '*', hidden: true),
        TestCase(inputs: ['5'], expected: '*\n**\n***\n****\n*****', hidden: true),
      ],
    ),
    hints: [
      'Es casi igual al cuadro, pero cada renglón tiene un asterisco más que el anterior.',
      'El ciclo de adentro no llega hasta n: llega hasta el número de renglón en que va (i).',
      'Para i <- 1 Hasta n Hacer\n    Para j <- 1 Hasta i Hacer\n        Escribir Sin Saltar "*"\n    FinPara\n    Escribir ""\nFinPara',
    ],
  ),
];
