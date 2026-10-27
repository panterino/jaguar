import 'package:jaguar_core/jaguar_core.dart';

/// A practice exercise for people learning on their own. The tests check it
/// like a teacher's exercise; the hints go from an idea to a sketch, never
/// the full answer.
class Challenge {
  const Challenge({
    required this.subject,
    required this.topic,
    required this.exercise,
    required this.hints,
    this.level = 1,
    this.languages = const ['Pseudocódigo'],
    this.author = 'Jaguar',
    this.license = 'CC BY-SA',
  });

  /// The area it belongs to, to group and filter: Variables, Operadores,
  /// Condicionales or Ciclos.
  final String subject;

  /// What it practices, as the SEP program names it (Cultura Digital I,
  /// propósito 8).
  final String topic;

  /// Level of the path, 1 to 5.
  final int level;

  /// The languages it has a version in.
  final List<String> languages;

  /// Who wrote it and under which license it is shared.
  final String author;
  final String license;
  final Exercise exercise;
  final List<String> hints;

  String get id => exercise.id;
}

/// Level 1: one challenge per content of the program, in order.
const challenges = <Challenge>[
  Challenge(
    subject: 'Variables',
    topic: 'Dato y variable',
    exercise: Exercise(
      id: 'reto-1-01',
      title: 'Reto 1 · Saludo',
      statement:
          'Pide el nombre de una persona y salúdala.\n\n'
          'Si escribe Ana, el programa muestra:\nHola, Ana',
      cases: [
        TestCase(inputs: ['Ana'], expected: 'Hola, Ana'),
        TestCase(inputs: ['Luis'], expected: 'Hola, Luis'),
        TestCase(inputs: ['María José'], expected: 'Hola, María José', hidden: true),
      ],
    ),
    hints: [
      'Necesitas una variable para guardar el nombre: Leer la llena.',
      'Escribir puede mostrar un texto entre comillas y una variable juntos: únelos con + o sepáralos con una coma.',
      'Leer nombre\nEscribir "Hola, " + nombre\n(con coma también sirve: Escribir "Hola, ", nombre)',
    ],
  ),
  Challenge(
    subject: 'Operadores',
    topic: 'Operadores aritméticos',
    exercise: Exercise(
      id: 'reto-1-02',
      title: 'Reto 2 · Área del rectángulo',
      statement:
          'Lee la base y la altura de un rectángulo y muestra su área.\n\n'
          'Con base 4 y altura 3, muestra:\nÁrea: 12',
      cases: [
        TestCase(inputs: ['4', '3'], expected: 'Área: 12'),
        TestCase(inputs: ['10', '2.5'], expected: 'Área: 25'),
        TestCase(inputs: ['7', '7'], expected: 'Área: 49', hidden: true),
      ],
    ),
    hints: [
      'El área de un rectángulo es base por altura.',
      'En pseudocódigo la multiplicación se escribe con *.',
      'area <- base * altura',
    ],
  ),
  Challenge(
    subject: 'Operadores',
    topic: 'Constantes y expresiones',
    exercise: Exercise(
      id: 'reto-1-03',
      title: 'Reto 3 · Precio con IVA',
      statement:
          'El IVA es del 16 %. Lee el precio de un producto y muestra cuánto cuesta con IVA.\n\n'
          'Con 100, muestra:\nTotal: 116',
      cases: [
        TestCase(inputs: ['100'], expected: 'Total: 116'),
        TestCase(inputs: ['50'], expected: 'Total: 58'),
        TestCase(inputs: ['12.5'], expected: 'Total: 14.5', hidden: true),
      ],
    ),
    hints: [
      'El 16 % no cambia: guárdalo una vez en una variable (por ejemplo iva <- 0.16) y úsala.',
      'El total es el precio más el 16 % del precio.',
      'total <- precio + precio * iva',
    ],
  ),
  Challenge(
    subject: 'Operadores',
    topic: 'División entera y residuo',
    exercise: Exercise(
      id: 'reto-1-04',
      title: 'Reto 4 · Minutos a horas',
      statement:
          'Lee una cantidad de minutos y muéstrala en horas y minutos.\n\n'
          'Con 125, muestra:\n2 horas y 5 minutos',
      cases: [
        TestCase(inputs: ['125'], expected: '2 horas y 5 minutos'),
        TestCase(inputs: ['185'], expected: '3 horas y 5 minutos'),
        TestCase(inputs: ['59'], expected: '0 horas y 59 minutos', hidden: true),
      ],
    ),
    hints: [
      'Una hora tiene 60 minutos. ¿Cuántas veces cabe 60 en tus minutos? ¿Cuánto sobra?',
      'trunc(x / 60) da las horas completas y x MOD 60 lo que sobra.',
      'horas <- trunc(minutos / 60)\nresto <- minutos MOD 60',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Operadores relacionales y estructura condicional',
    exercise: Exercise(
      id: 'reto-1-05',
      title: 'Reto 5 · ¿Aprobado?',
      statement: 'Lee una calificación del 0 al 10. Si es 6 o más, muestra Aprobado; si no, Reprobado.',
      cases: [
        TestCase(name: 'Nueve', inputs: ['9'], expected: 'Aprobado'),
        TestCase(name: 'Cinco', inputs: ['5'], expected: 'Reprobado'),
        TestCase(name: 'Justo seis', inputs: ['6'], expected: 'Aprobado', hidden: true),
      ],
    ),
    hints: [
      'Hay dos caminos: uno para 6 o más y otro para lo demás. Eso es un Si con SiNo.',
      '"6 o más" se escribe calificacion >= 6. Cuidado con el 6 justo.',
      'Si calificacion >= 6 Entonces\n    Escribir "Aprobado"\nSiNo\n    ...\nFinSi',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Operadores lógicos',
    exercise: Exercise(
      id: 'reto-1-06',
      title: 'Reto 6 · Dentro del rango',
      statement: 'Lee un número. Si está entre 1 y 10 (incluidos), muestra Dentro; si no, Fuera.',
      cases: [
        TestCase(inputs: ['5'], expected: 'Dentro'),
        TestCase(inputs: ['0'], expected: 'Fuera'),
        TestCase(inputs: ['1'], expected: 'Dentro', hidden: true),
        TestCase(inputs: ['10'], expected: 'Dentro', hidden: true),
        TestCase(inputs: ['11'], expected: 'Fuera', hidden: true),
      ],
    ),
    hints: [
      'Tienen que cumplirse dos cosas a la vez: ser mayor o igual a 1 y menor o igual a 10.',
      'Para unir dos condiciones que deben cumplirse las dos se usa Y.',
      'Si n >= 1 Y n <= 10 Entonces',
    ],
  ),
  Challenge(
    subject: 'Condicionales',
    topic: 'Estructura selectiva',
    exercise: Exercise(
      id: 'reto-1-07',
      title: 'Reto 7 · Día de la semana',
      statement:
          'Lee un número del 1 al 7 y muestra el día: 1 es Lunes, 2 Martes… 7 Domingo. '
          'Con cualquier otro número muestra No existe.',
      cases: [
        TestCase(inputs: ['1'], expected: 'Lunes'),
        TestCase(inputs: ['5'], expected: 'Viernes'),
        TestCase(inputs: ['7'], expected: 'Domingo', hidden: true),
        TestCase(inputs: ['0'], expected: 'No existe', hidden: true),
        TestCase(inputs: ['9'], expected: 'No existe', hidden: true),
      ],
    ),
    hints: [
      'Cuando una variable puede tener muchos valores y cada uno hace algo distinto, Segun es más claro que muchos Si.',
      'De Otro Modo atrapa todos los valores que no pusiste.',
      'Segun dia Hacer\n    1: Escribir "Lunes"\n    ...\n    De Otro Modo: Escribir "No existe"\nFinSegun',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Estructura repetitiva: Mientras',
    exercise: Exercise(
      id: 'reto-1-08',
      title: 'Reto 8 · Suma hasta el cero',
      statement:
          'Lee números hasta que escriban 0 y muestra la suma de todos.\n\n'
          'Con 4, 6, 10 y 0, muestra:\nSuma: 20',
      cases: [
        TestCase(inputs: ['4', '6', '10', '0'], expected: 'Suma: 20'),
        TestCase(name: 'Solo cero', inputs: ['0'], expected: 'Suma: 0'),
        TestCase(inputs: ['-5', '5', '3', '0'], expected: 'Suma: 3', hidden: true),
      ],
    ),
    hints: [
      'No sabes cuántos números vendrán: repite mientras el número no sea 0.',
      'Lleva un acumulador que empiece en 0 y súmale cada número.',
      'suma <- 0\nLeer n\nMientras n <> 0 Hacer\n    suma <- suma + n\n    Leer n\nFinMientras',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Estructura repetitiva: Para',
    exercise: Exercise(
      id: 'reto-1-09',
      title: 'Reto 9 · Tabla de multiplicar',
      statement:
          'Lee un número y muestra su tabla del 1 al 10.\n\n'
          'Con 3, muestra:\n3 x 1 = 3\n3 x 2 = 6\n…\n3 x 10 = 30',
      cases: [
        TestCase(
          inputs: ['3'],
          expected:
              '3 x 1 = 3\n3 x 2 = 6\n3 x 3 = 9\n3 x 4 = 12\n3 x 5 = 15\n'
              '3 x 6 = 18\n3 x 7 = 21\n3 x 8 = 24\n3 x 9 = 27\n3 x 10 = 30',
        ),
        TestCase(
          inputs: ['7'],
          expected:
              '7 x 1 = 7\n7 x 2 = 14\n7 x 3 = 21\n7 x 4 = 28\n7 x 5 = 35\n'
              '7 x 6 = 42\n7 x 7 = 49\n7 x 8 = 56\n7 x 9 = 63\n7 x 10 = 70',
          hidden: true,
        ),
      ],
    ),
    hints: [
      'Sabes exactamente cuántas veces se repite: 10. Para eso está Para.',
      'La variable del Para (por ejemplo i) va de 1 a 10; cada vuelta muestra n, " x ", i, " = " y el producto.',
      'Para i <- 1 Hasta 10 Hacer\n    Escribir n, " x ", i, " = ", n * i\nFinPara',
    ],
  ),
  Challenge(
    subject: 'Ciclos',
    topic: 'Estructura repetitiva: Repetir y contador',
    exercise: Exercise(
      id: 'reto-1-10',
      title: 'Reto 10 · Contraseña',
      statement:
          'Pide la contraseña hasta que escriban jaguar y al final di cuántos intentos fueron.\n\n'
          'Si escriben gato, perro y jaguar, muestra:\nEntraste en 3 intentos',
      cases: [
        TestCase(inputs: ['gato', 'perro', 'jaguar'], expected: 'Entraste en 3 intentos'),
        TestCase(inputs: ['hola', 'jaguar'], expected: 'Entraste en 2 intentos'),
        TestCase(inputs: ['a', 'b', 'c', 'd', 'jaguar'], expected: 'Entraste en 5 intentos', hidden: true),
      ],
    ),
    hints: [
      'Siempre se pide al menos una vez: Repetir … Hasta Que revisa la condición al final.',
      'Un contador empieza en 0 y sube de 1 en 1 cada vez que piden la contraseña. Define la clave Como Texto.',
      'intentos <- 0\nRepetir\n    Leer clave\n    intentos <- intentos + 1\nHasta Que clave = "jaguar"',
    ],
  ),
  Challenge(
    subject: 'Textos',
    topic: 'Mayúsculas y unir textos',
    exercise: Exercise(
      id: 'reto-1-11',
      title: 'Reto 11 · Grito',
      statement:
          'Pide una palabra o una frase y muéstrala en mayúsculas, con un signo de admiración al final.\n\n'
          'Si escriben hola, el programa muestra:\nHOLA!',
      cases: [
        TestCase(inputs: ['hola'], expected: 'HOLA!'),
        TestCase(inputs: ['jaguar'], expected: 'JAGUAR!'),
        TestCase(inputs: ['buenos días'], expected: 'BUENOS DÍAS!', hidden: true),
      ],
    ),
    hints: [
      'Hay una función que vuelve mayúsculas todas las letras de un texto: Mayusculas.',
      'Guarda lo que escriben con Leer y muestra Mayusculas(texto) junto con "!". Define el texto Como Texto.',
      'Leer texto\nEscribir Mayusculas(texto) + "!"',
    ],
  ),
  Challenge(
    subject: 'Textos',
    topic: 'Longitud de un texto',
    exercise: Exercise(
      id: 'reto-1-12',
      title: 'Reto 12 · Contar letras',
      statement:
          'Pide una palabra y di cuántas letras tiene.\n\n'
          'Si escriben jaguar, el programa muestra:\nLetras: 6',
      cases: [
        TestCase(inputs: ['jaguar'], expected: 'Letras: 6'),
        TestCase(inputs: ['sol'], expected: 'Letras: 3'),
        TestCase(inputs: ['a'], expected: 'Letras: 1', hidden: true),
      ],
    ),
    hints: [
      'La función Longitud cuenta las letras de un texto.',
      'Guarda la palabra con Leer y muestra "Letras: " junto con Longitud(palabra).',
      'Leer palabra\nEscribir "Letras: ", Longitud(palabra)',
    ],
  ),
];

/// Level 0: three small challenges solved with blocks. They are not part of
/// the twelve of level 1 (nor of their count).
const blockChallenges = <Challenge>[
  Challenge(
    subject: 'Bloques',
    topic: 'Mostrar y leer datos',
    level: 0,
    exercise: Exercise(
      id: 'reto-0-01',
      title: 'Bloques 1 · Eco',
      statement:
          'Arma con bloques un programa que pida una palabra y la muestre dos veces.\n\n'
          'Si escriben hola, el programa muestra:\nhola\nhola',
      cases: [
        TestCase(inputs: ['hola'], expected: 'hola\nhola'),
        TestCase(inputs: ['jaguar'], expected: 'jaguar\njaguar'),
        TestCase(inputs: ['sol'], expected: 'sol\nsol', hidden: true),
      ],
    ),
    hints: [
      'Cambia a la vista Bloques. Con + agregas un bloque: uno para leer y otro para mostrar.',
      'Primero un bloque Lectura con la variable palabra; después dos bloques Salida que muestren palabra.',
      'Leer palabra\nEscribir palabra\nEscribir palabra',
    ],
  ),
  Challenge(
    subject: 'Bloques',
    topic: 'Operaciones con datos',
    level: 0,
    exercise: Exercise(
      id: 'reto-0-02',
      title: 'Bloques 2 · Suma',
      statement:
          'Arma con bloques un programa que pida dos números y muestre su suma.\n\n'
          'Si escriben 2 y 3, el programa muestra:\n5',
      cases: [
        TestCase(inputs: ['2', '3'], expected: '5'),
        TestCase(inputs: ['10', '20'], expected: '30'),
        TestCase(inputs: ['0', '0'], expected: '0', hidden: true),
      ],
    ),
    hints: [
      'Un bloque Lectura puede leer dos variables a la vez: sepáralas con coma.',
      'Lee a y b, y en un bloque Salida muestra a + b.',
      'Leer a, b\nEscribir a + b',
    ],
  ),
  Challenge(
    subject: 'Bloques',
    topic: 'Decisiones',
    level: 0,
    exercise: Exercise(
      id: 'reto-0-03',
      title: 'Bloques 3 · ¿Mayor de edad?',
      statement:
          'Arma con bloques un programa que pida una edad y muestre Mayor si es 18 o más, y Menor si no.\n\n'
          'Si escriben 20, el programa muestra:\nMayor',
      cases: [
        TestCase(inputs: ['20'], expected: 'Mayor'),
        TestCase(inputs: ['10'], expected: 'Menor'),
        TestCase(inputs: ['18'], expected: 'Mayor', hidden: true),
      ],
    ),
    hints: [
      'Agrega un bloque Decisión: lo que va dentro se hace solo si la condición se cumple.',
      'La condición es edad >= 18. En el Sí va Escribir "Mayor"; en el SiNo, Escribir "Menor".',
      'Leer edad\nSi edad >= 18 Entonces\n    Escribir "Mayor"\nSiNo\n    Escribir "Menor"\nFinSi',
    ],
  ),
];

Challenge? challengeById(String id) {
  for (final challenge in [...challenges, ...blockChallenges]) {
    if (challenge.id == id) return challenge;
  }
  return null;
}
