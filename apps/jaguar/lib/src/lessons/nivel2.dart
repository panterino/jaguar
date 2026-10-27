import '../challenges/challenges_nivel2.dart';
import 'lessons.dart';
import 'lessons_nivel2.dart';

/// Level 2: conditions, menus and loops in depth.
final nivel2 = RouteLevel(
  id: 'nivel-2',
  number: 2,
  title: 'Decisiones y ciclos',
  description: 'Combina condiciones, arma menús y repite con contadores y acumuladores.',
  groups: [
    RouteGroup('Condiciones compuestas', 'Junta condiciones con Y, O y NO.', [
      const LessonStep(lessonCompoundConditions),
      ChallengeStep(challengesNivel2[0]),
      ChallengeStep(challengesNivel2[1]),
      ChallengeStep(challengesNivel2[2]),
    ]),
    RouteGroup('Menús con Según', 'Elige entre muchos casos.', [
      const LessonStep(lessonSegun),
      ChallengeStep(challengesNivel2[3]),
      ChallengeStep(challengesNivel2[4]),
    ]),
    RouteGroup('Repetir hasta que digan basta', 'Lee datos hasta un valor que marca el final.', [
      const LessonStep(lessonSentinel),
      ChallengeStep(challengesNivel2[5]),
      ChallengeStep(challengesNivel2[6]),
    ]),
    RouteGroup('Contadores y acumuladores', 'Suma, cuenta y multiplica con Para.', [
      const LessonStep(lessonLoopsDeep),
      ChallengeStep(challengesNivel2[7]),
      ChallengeStep(challengesNivel2[8]),
      ChallengeStep(challengesNivel2[9]),
    ]),
    RouteGroup('Ciclos dentro de ciclos', 'Dibuja tablas y figuras.', [
      const LessonStep(lessonNestedLoops),
      ChallengeStep(challengesNivel2[10]),
      ChallengeStep(challengesNivel2[11]),
    ]),
  ],
);
