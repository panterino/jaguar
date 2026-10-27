import 'package:flutter/material.dart';

import '../challenges/challenges.dart';

/// The flowchart shapes a figure question asks about.
enum Figure {
  oval('Óvalo'),
  parallelogram('Paralelogramo'),
  rectangle('Rectángulo'),
  diamond('Rombo');

  const Figure(this.label);

  final String label;
}

/// One question of a lesson. Every question says why the answer is what it is,
/// right or wrong: the explanation is the point, not the score.
sealed class Question {
  const Question({required this.prompt, required this.right, required this.wrong});

  final String prompt;

  /// Shown after a right answer.
  final String right;

  /// Shown after a wrong one: says what the answer is and why.
  final String wrong;
}

/// Pick one of the options; the prompt may come with a program.
class ChoiceQuestion extends Question {
  const ChoiceQuestion({
    required super.prompt,
    required super.right,
    required super.wrong,
    required this.options,
    required this.answer,
    this.code,
    this.mono = false,
    this.output,
    this.inputs = const [],
  });

  final List<String> options;

  /// Index of the right option.
  final int answer;
  final String? code;

  /// The options are code: show them in the code font.
  final bool mono;

  /// What [code] shows when it runs (checked by a test against the
  /// interpreter, so a lesson can never teach a wrong result).
  final String? output;
  final List<String> inputs;
}

/// Pick the flowchart shape for something.
class FigureQuestion extends Question {
  const FigureQuestion({required super.prompt, required super.right, required super.wrong, required this.answer});

  final Figure answer;
}

/// Put the lines of a program in order.
class OrderQuestion extends Question {
  const OrderQuestion({
    required super.prompt,
    required super.right,
    required super.wrong,
    required this.lines,
    this.inputs = const [],
  });

  /// In the right order. They must all be different.
  final List<String> lines;

  /// Data for running the finished program in tests.
  final List<String> inputs;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.questions,
  });

  final String id;
  final String title;
  final String summary;
  final IconData icon;
  final List<Question> questions;
}

/// A step of the path: a lesson to play or a challenge to solve.
sealed class RouteStep {
  const RouteStep();

  String get id;
  String get title;
}

class LessonStep extends RouteStep {
  const LessonStep(this.lesson);

  final Lesson lesson;

  @override
  String get id => lesson.id;
  @override
  String get title => lesson.title;
}

class ChallengeStep extends RouteStep {
  const ChallengeStep(this.challenge);

  final Challenge challenge;

  @override
  String get id => challenge.id;
  @override
  String get title => challenge.exercise.title.replaceFirst(RegExp(r'^Reto \d+ · '), '');
}

/// A group of the path, like a unit: a few lessons and the challenges they
/// prepare.
class RouteGroup {
  const RouteGroup(this.title, this.description, this.steps);

  final String title;

  /// One line saying what the group is for.
  final String description;
  final List<RouteStep> steps;
}

const lessonFirstProgram = Lesson(
  id: 'leccion-primer-programa',
  title: 'Tu primer programa',
  summary: 'Muestra un saludo y pide tu nombre',
  icon: Icons.play_circle_outline,
  questions: [
    ChoiceQuestion(
      prompt: '¿Con qué palabras empieza y termina un programa?',
      options: ['Algoritmo … FinAlgoritmo', 'Inicio … Fin', 'Programa … Listo', 'Abrir … Cerrar'],
      answer: 0,
      mono: true,
      right: 'Todo programa va entre Algoritmo y FinAlgoritmo.',
      wrong: 'Se escribe Algoritmo (con un nombre) al empezar y FinAlgoritmo al terminar.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'Escribir "Hola"',
      options: ['Hola', '"Hola"', 'Escribir', 'Nada'],
      answer: 0,
      output: 'Hola',
      right: 'Escribir muestra el texto, sin las comillas.',
      wrong: 'Las comillas solo marcan dónde empieza y termina el texto: lo que se muestra es Hola.',
    ),
    ChoiceQuestion(
      prompt: 'Completa la instrucción para pedir un dato.',
      code: '___ nombre',
      options: ['Leer', 'Escribir', 'Si', 'Fin'],
      answer: 0,
      mono: true,
      right: 'Leer pide un dato y lo guarda en la variable nombre.',
      wrong: 'Para pedir un dato se usa Leer; Escribir sirve al revés: para mostrar.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué es una variable?',
      options: [
        'Una caja con nombre donde se guarda un valor',
        'Una instrucción que repite pasos',
        'Un tipo de error',
        'Un comentario del programa',
      ],
      answer: 0,
      right: 'Eso es: nombre guarda lo que escribe la persona, y puedes usarlo después.',
      wrong: 'Una variable es una caja con nombre donde se guarda un valor para usarlo más tarde.',
    ),
    OrderQuestion(
      prompt: 'Ordena el programa para que salude por su nombre.',
      lines: ['Algoritmo saludo', '    Leer nombre', '    Escribir "Hola, " + nombre', 'FinAlgoritmo'],
      inputs: ['Ana'],
      right: 'Primero se pide el nombre y después se usa para saludar.',
      wrong: 'Hay que leer el nombre antes de usarlo, y todo va entre Algoritmo y FinAlgoritmo.',
    ),
  ],
);

const lessonOperations = Lesson(
  id: 'leccion-operaciones',
  title: 'Operaciones',
  summary: 'Suma, multiplica y junta textos',
  icon: Icons.calculate_outlined,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'a <- 4\nb <- 3\nEscribir a * b',
      options: ['7', '12', '43', '1'],
      answer: 1,
      output: '12',
      right: 'El asterisco multiplica: 4 por 3 son 12.',
      wrong: 'El * multiplica, no suma ni junta: 4 por 3 son 12.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué símbolo guarda un valor en una variable?',
      options: ['<-', '==', '->', ':'],
      answer: 0,
      mono: true,
      right: 'La flecha <- guarda el valor de la derecha en la variable de la izquierda.',
      wrong: 'Se usa la flecha <-: guarda el valor de la derecha en la variable de la izquierda.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa? (MOD es el residuo de dividir)',
      code: 'Escribir 7 MOD 2',
      options: ['3', '1', '0', '3.5'],
      answer: 1,
      output: '1',
      right: '7 entre 2 da 3 y sobra 1: ese residuo es el MOD.',
      wrong: '7 entre 2 da 3 y sobra 1. MOD no da el cociente, da lo que sobra.',
    ),
    ChoiceQuestion(
      prompt: 'Completa para calcular el precio con IVA del 16 %.',
      code: 'total <- precio ___ 1.16',
      options: ['*', '+', '-', '<-'],
      answer: 0,
      mono: true,
      right: 'Multiplicar por 1.16 suma el 16 % de una vez.',
      wrong: 'Se multiplica por 1.16: es el precio más su 16 %, todo en un paso.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'Escribir "Total: " + 5',
      options: ['Total: 5', '"Total: " 5', 'Un error', '5'],
      answer: 0,
      output: 'Total: 5',
      right: 'Con + se une un texto con un número.',
      wrong: 'El + junta el texto con el valor y muestra Total: 5.',
    ),
  ],
);

const lessonFlowcharts = Lesson(
  id: 'leccion-diagramas',
  title: 'Diagramas de flujo',
  summary: 'Qué significa cada figura del diagrama',
  icon: Icons.account_tree_outlined,
  questions: [
    FigureQuestion(
      prompt: '¿Qué figura se usa para leer o escribir datos?',
      answer: Figure.parallelogram,
      right: 'El paralelogramo es para entradas y salidas: Leer y Escribir.',
      wrong: 'Leer y Escribir van en el paralelogramo.',
    ),
    FigureQuestion(
      prompt: '¿Cuál es la figura de una decisión?',
      answer: Figure.diamond,
      right: 'El rombo hace una pregunta y sale por Sí o por No.',
      wrong: 'Las decisiones van en el rombo: tiene una pregunta y dos salidas.',
    ),
    FigureQuestion(
      prompt: '¿Con qué figura empieza y termina un diagrama?',
      answer: Figure.oval,
      right: 'El óvalo marca el inicio y el fin.',
      wrong: 'Un diagrama empieza y termina con un óvalo.',
    ),
    FigureQuestion(
      prompt: '¿Y para un cálculo, como suma <- a + b?',
      answer: Figure.rectangle,
      right: 'Los cálculos y asignaciones van en un rectángulo, el de proceso.',
      wrong: 'Un cálculo es un proceso: va en un rectángulo.',
    ),
    ChoiceQuestion(
      prompt: '¿Cuántas salidas tiene un rombo?',
      options: ['Dos: Sí y No', 'Una', 'Tres', 'Ninguna'],
      answer: 0,
      right: 'Dos: por una sigue si la respuesta es Sí y por la otra si es No.',
      wrong: 'Tiene dos, rotuladas Sí y No: una por cada respuesta posible.',
    ),
  ],
);

const lessonDecisions = Lesson(
  id: 'leccion-decisiones',
  title: 'Decisiones con Si',
  summary: 'Haz que el programa elija un camino',
  icon: Icons.call_split,
  questions: [
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'n <- 5\nSi n > 0 Entonces\n    Escribir "Positivo"\nFinSi',
      options: ['Positivo', 'Negativo', 'Nada', 'Un error'],
      answer: 0,
      output: 'Positivo',
      right: '5 es mayor que 0, así que entra al Si.',
      wrong: '5 > 0 es cierto, entonces se ejecuta lo que está dentro del Si.',
    ),
    ChoiceQuestion(
      prompt: '¿Y este? Fíjate en el valor de n.',
      code: 'n <- -3\nSi n > 0 Entonces\n    Escribir "Positivo"\nFinSi',
      options: ['Positivo', 'Negativo', 'Nada', 'Un error'],
      answer: 2,
      output: '',
      right: 'Sin SiNo y con la condición falsa, el programa sigue sin mostrar nada.',
      wrong: '-3 no es mayor que 0 y no hay SiNo: no se muestra nada.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'Si 5 >= 6 Entonces\n    Escribir "Pasa"\nSiNo\n    Escribir "No pasa"\nFinSi',
      options: ['Pasa', 'No pasa', 'Pasa y No pasa', 'Nada'],
      answer: 1,
      output: 'No pasa',
      right: '5 no es 6 o más: se ejecuta el SiNo.',
      wrong: '5 >= 6 es falso, así que se salta al SiNo y muestra No pasa.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué operador compara si dos valores son diferentes?',
      options: ['<>', '<-', '=>', '!!'],
      answer: 0,
      mono: true,
      right: '<> significa "diferente de".',
      wrong: 'Se usa <>: 3 <> 4 es cierto porque son diferentes.',
    ),
    OrderQuestion(
      prompt: 'Ordena el programa que dice si una calificación aprueba.',
      lines: [
        'Algoritmo aprobado',
        '    Leer calificacion',
        '    Si calificacion >= 6 Entonces',
        '        Escribir "Aprobado"',
        '    SiNo',
        '        Escribir "Reprobado"',
        '    FinSi',
        'FinAlgoritmo',
      ],
      inputs: ['8'],
      right: 'Se lee el dato, se decide con Si … SiNo y se cierra con FinSi.',
      wrong: 'Primero se lee la calificación; luego el Si, con su SiNo, y se cierra con FinSi.',
    ),
  ],
);

const lessonDeskCheck = Lesson(
  id: 'leccion-prueba-escritorio',
  title: 'Prueba de escritorio',
  summary: 'Sigue un programa y anota cada valor',
  icon: Icons.table_chart_outlined,
  questions: [
    ChoiceQuestion(
      prompt: '¿Cuánto vale x al final?',
      code: 'x <- 2\nx <- x + 3\nEscribir x',
      options: ['2', '3', '5', '23'],
      answer: 2,
      output: '5',
      right: 'x empieza en 2 y luego se le suman 3.',
      wrong: 'Primero x vale 2; la segunda línea le suma 3 y queda en 5.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'a <- 1\nb <- 2\na <- b\nEscribir a',
      options: ['1', '2', '3', '12'],
      answer: 1,
      output: '2',
      right: 'a <- b copia el valor de b en a: ahora a vale 2.',
      wrong: 'La línea a <- b copia el valor de b (2) dentro de a, y se pierde el 1.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué se anota en una prueba de escritorio?',
      options: [
        'El valor de cada variable en cada paso',
        'Solo el resultado final',
        'El nombre del programador',
        'Las líneas que no se ejecutan',
      ],
      answer: 0,
      right: 'La tabla va mostrando cómo cambia cada variable.',
      wrong: 'Se anota el valor de cada variable después de cada paso: así se ve dónde cambia.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'n <- 7\nSi n MOD 2 = 0 Entonces\n    Escribir "Par"\nSiNo\n    Escribir "Impar"\nFinSi',
      options: ['Par', 'Impar', 'Los dos', 'Nada'],
      answer: 1,
      output: 'Impar',
      right: '7 MOD 2 es 1, no 0: entra al SiNo.',
      wrong: '7 MOD 2 da 1, y como no es 0 se ejecuta el SiNo: Impar.',
    ),
    ChoiceQuestion(
      prompt: 'Si la regla es «6 o más», ¿qué datos conviene probar?',
      options: ['5, 6 y 7', 'Solo 10', 'Solo 6', 'Solo 0'],
      answer: 0,
      right: 'Los valores de alrededor del límite son donde más se equivoca uno.',
      wrong: 'Conviene probar justo el límite y sus vecinos: 5, 6 y 7.',
    ),
  ],
);

const lessonLoops = Lesson(
  id: 'leccion-ciclos',
  title: 'Repetir pasos',
  summary: 'Repite pasos con Para y Mientras',
  icon: Icons.repeat,
  questions: [
    ChoiceQuestion(
      prompt: 'Sabes que debes repetir algo 10 veces. ¿Qué ciclo usas?',
      options: ['Para', 'Si', 'SiNo', 'Leer'],
      answer: 0,
      mono: true,
      right: 'Cuando sabes cuántas veces, Para es el ciclo.',
      wrong: 'Para repite un número conocido de veces; Si solo decide.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué muestra este programa?',
      code: 'Para i <- 1 Hasta 3 Hacer\n    Escribir i\nFinPara',
      options: ['1, 2, 3', '0, 1, 2', '1, 2', '3'],
      answer: 0,
      output: '1\n2\n3',
      right: 'i empieza en 1 y llega hasta 3, mostrando cada valor.',
      wrong: 'i toma los valores 1, 2 y 3, uno por vuelta.',
    ),
    ChoiceQuestion(
      prompt: '¿Cuánto vale n al final?',
      code: 'n <- 3\nMientras n > 0 Hacer\n    n <- n - 1\nFinMientras\nEscribir n',
      options: ['3', '1', '0', '-1'],
      answer: 2,
      output: '0',
      right: 'n baja de 3 a 0 y entonces la condición deja de cumplirse.',
      wrong: 'n va bajando: 3, 2, 1, 0. Con 0 ya no se cumple n > 0 y el ciclo termina.',
    ),
    ChoiceQuestion(
      prompt: '¿Qué pasa si dentro de un Mientras nada cambia la condición?',
      options: ['Se repite para siempre', 'Se ejecuta una sola vez', 'No se ejecuta', 'Termina solo'],
      answer: 0,
      right: 'Por eso dentro del ciclo debe cambiar algo que lleve a la salida.',
      wrong: 'Sin un cambio que lleve a la salida, la condición siempre se cumple y nunca termina.',
    ),
    OrderQuestion(
      prompt: 'Ordena el programa que suma del 1 al 4.',
      lines: [
        'Algoritmo suma',
        '    suma <- 0',
        '    Para i <- 1 Hasta 4 Hacer',
        '        suma <- suma + i',
        '    FinPara',
        '    Escribir suma',
        'FinAlgoritmo',
      ],
      right: 'La suma empieza en 0, el ciclo la va aumentando y al final se muestra.',
      wrong: 'La suma debe empezar en 0 antes del ciclo, crecer dentro y mostrarse después.',
    ),
  ],
);

const allLessons = [
  lessonFirstProgram,
  lessonOperations,
  lessonFlowcharts,
  lessonDecisions,
  lessonDeskCheck,
  lessonLoops,
];

Lesson? lessonById(String id) {
  for (final lesson in allLessons) {
    if (lesson.id == id) return lesson;
  }
  return null;
}

Challenge _reto(int n) => challenges[n - 1];

/// The path of level 1: lessons that prepare each challenge, in order.
final routeGroups = <RouteGroup>[
  RouteGroup('Primeros pasos', 'Escribe y ejecuta tu primer programa.', [
    const LessonStep(lessonFirstProgram),
    ChallengeStep(_reto(1)),
  ]),
  RouteGroup('Operaciones', 'Haz cuentas con lo que escribe la persona.', [
    const LessonStep(lessonOperations),
    ChallengeStep(_reto(2)),
    ChallengeStep(_reto(3)),
    ChallengeStep(_reto(4)),
  ]),
  RouteGroup('Diagramas y decisiones', 'Dibuja el flujo y haz que el programa elija.', [
    const LessonStep(lessonFlowcharts),
    const LessonStep(lessonDecisions),
    ChallengeStep(_reto(5)),
    ChallengeStep(_reto(6)),
    ChallengeStep(_reto(7)),
  ]),
  RouteGroup('Repetir y comprobar', 'Repite pasos y revisa tu programa a mano.', [
    const LessonStep(lessonDeskCheck),
    const LessonStep(lessonLoops),
    ChallengeStep(_reto(8)),
    ChallengeStep(_reto(9)),
    ChallengeStep(_reto(10)),
  ]),
];

/// Every step of the path, in order.
List<RouteStep> get routeSteps => [for (final group in routeGroups) ...group.steps];

bool isStepDone(RouteStep step, {required Set<String> lessons, required Set<String> challenges}) =>
    step is LessonStep ? lessons.contains(step.id) : challenges.contains(step.id);

/// The first step not done yet; null when the whole path is done.
RouteStep? nextStep({required Set<String> lessons, required Set<String> challenges}) {
  for (final step in routeSteps) {
    if (!isStepDone(step, lessons: lessons, challenges: challenges)) {
      return step;
    }
  }
  return null;
}
