import '../challenges/challenges.dart';
import 'lessons.dart';

/// Level 0: the first program, built with blocks. It is optional: the
/// recommended path starts at level 1, and the Ruta never waits for this one.
final nivel0 = RouteLevel(
  id: 'nivel-0',
  number: 0,
  optional: true,
  title: 'Bloques',
  description: 'Arma programas con piezas que encajan. Es opcional: puedes empezar por el Nivel 1.',
  groups: [
    RouteGroup('Primeros bloques', 'Arma un programa pieza por pieza.', [
      const LessonStep(lessonBlocks),
      for (final challenge in blockChallenges) ChallengeStep(challenge),
    ]),
  ],
);
