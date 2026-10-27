import '../challenges/challenges_nivel3.dart';
import 'lessons.dart';
import 'lessons_nivel3.dart';

/// Level 3: data. Arrays, searching, strings, matrices and sorting.
final nivel3 = RouteLevel(
  id: 'nivel-3',
  number: 3,
  title: 'Datos',
  description: 'Guarda muchos valores, búscalos, recorre textos y ordénalos.',
  groups: [
    RouteGroup('Arreglos', 'Guarda muchos valores bajo un solo nombre.', [
      const LessonStep(lessonArrays),
      ChallengeStep(challengesNivel3[0]),
      ChallengeStep(challengesNivel3[1]),
      ChallengeStep(challengesNivel3[2]),
    ]),
    RouteGroup('Buscar y comparar', 'Encuentra el mayor, el menor y una posición.', [
      const LessonStep(lessonSearching),
      ChallengeStep(challengesNivel3[3]),
      ChallengeStep(challengesNivel3[4]),
      ChallengeStep(challengesNivel3[5]),
    ]),
    RouteGroup('Textos por dentro', 'Recorre un texto letra por letra.', [
      const LessonStep(lessonStrings),
      ChallengeStep(challengesNivel3[6]),
      ChallengeStep(challengesNivel3[7]),
      ChallengeStep(challengesNivel3[8]),
    ]),
    RouteGroup('Matrices y ordenar', 'Tablas con filas y columnas, y ordenar valores.', [
      const LessonStep(lessonMatricesSorting),
      ChallengeStep(challengesNivel3[9]),
      ChallengeStep(challengesNivel3[10]),
      ChallengeStep(challengesNivel3[11]),
    ]),
  ],
);
