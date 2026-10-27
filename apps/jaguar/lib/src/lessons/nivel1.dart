import 'lessons.dart';

/// Level 1: from the first program to loops, with the lessons that prepare
/// each challenge.
final nivel1 = RouteLevel(
  id: 'nivel-1',
  title: 'Fundamentos',
  description: 'Escribe, calcula, decide y repite: lo básico para programar.',
  groups: [
    RouteGroup('Primeros pasos', 'Escribe y ejecuta tu primer programa.', [
      const LessonStep(lessonFirstProgram),
      ChallengeStep(reto(1)),
    ]),
    RouteGroup('Operaciones', 'Haz cuentas con lo que escribe la persona.', [
      const LessonStep(lessonOperations),
      ChallengeStep(reto(2)),
      ChallengeStep(reto(3)),
      ChallengeStep(reto(4)),
    ]),
    RouteGroup('Diagramas y decisiones', 'Dibuja el flujo y haz que el programa elija.', [
      const LessonStep(lessonFlowcharts),
      const LessonStep(lessonDecisions),
      ChallengeStep(reto(5)),
      ChallengeStep(reto(6)),
      ChallengeStep(reto(7)),
    ]),
    RouteGroup('Repetir y comprobar', 'Repite pasos y revisa tu programa a mano.', [
      const LessonStep(lessonDeskCheck),
      const LessonStep(lessonLoops),
      ChallengeStep(reto(8)),
      ChallengeStep(reto(9)),
      ChallengeStep(reto(10)),
    ]),
  ],
);
