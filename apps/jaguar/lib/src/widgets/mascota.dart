import 'package:flutter/material.dart';

/// The moods of the mascot, one drawing each (`assets/mascota/`). Always the
/// same animal, seated; the feeling is in the eyelids, the mouth and a prop.
enum MascotPose {
  /// Welcome, first time, the plain greeting.
  hola('hola'),

  /// She did it: every test passes.
  lograste('lograste'),

  /// A hint was asked for.
  pensando('pensando'),

  /// An error when running, or something missing.
  uy('uy'),

  /// Failed a few times: almost there.
  animo('animo'),

  /// Empty screens, days without practice.
  dormido('dormido'),

  /// A hint shown, a new topic.
  idea('idea'),

  /// While a program loads or runs.
  programando('programando'),

  /// Guided tours: points at something.
  miraAqui('mira_aqui'),

  /// A whole level done.
  orgulloso('orgulloso'),

  /// A quick tip, an invitation to share.
  guino('guino'),

  /// A playful reminder to practice.
  yHoy('y_hoy'),

  /// The result is not the expected one.
  confundido('confundido'),

  /// Thanks for support, reviews and contributions.
  leEncanta('le_encanta'),

  /// Lessons and explanations.
  estudiando('estudiando'),

  /// Special achievements.
  estrella('estrella'),

  /// Something is not working in the app or the server.
  enfermo('enfermo'),

  /// Cold season and notices.
  frio('frio'),

  /// A lot pending, or a hot day.
  calor('calor'),

  /// A long session: an invitation to rest.
  cansado('cansado');

  const MascotPose(this.file);

  final String file;

  String get asset => 'assets/mascota/$file.webp';
}

/// Just the face, for icons, notices and small places.
enum MascotFace {
  feliz('cara_feliz'),
  risa('cara_risa'),
  sorpresa('cara_sorpresa'),
  triste('cara_triste'),
  serio('cara_serio'),
  guino('cara_guino'),
  enfermo('cara_enfermo'),
  dormido('cara_dormido');

  const MascotFace(this.file);

  final String file;

  String get asset => 'assets/mascota/$file.webp';
}

/// The mascot in one of its [MascotPose]s. Decorative: screen readers skip it.
class Mascota extends StatelessWidget {
  const Mascota({super.key, this.pose = MascotPose.hola, required this.size});

  final MascotPose pose;

  /// The height; the drawings are a little taller than wide.
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset(pose.asset, height: size, width: size * 600 / 621, fit: BoxFit.contain, excludeFromSemantics: true);
}

/// The face of the mascot alone.
class MascotaCara extends StatelessWidget {
  const MascotaCara({super.key, this.face = MascotFace.feliz, required this.size});

  final MascotFace face;

  /// The width.
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset(face.asset, width: size, height: size * 470 / 600, fit: BoxFit.contain, excludeFromSemantics: true);
}
