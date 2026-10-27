import '../challenges/challenges.dart';
import 'lessons.dart';
import 'nivel0.dart';
import 'nivel1.dart';

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

/// A unit of the path: a few lessons and the challenges they prepare.
class RouteGroup {
  const RouteGroup(this.title, this.description, this.steps);

  final String title;

  /// One line saying what the group is for.
  final String description;
  final List<RouteStep> steps;
}

/// A level of the path: a few units around one big idea. The path grows by
/// adding levels (one file each, `nivel1.dart`, `nivel2.dart`...); nothing
/// else changes, and the progress saved by id keeps working.
class RouteLevel {
  const RouteLevel({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.groups,
    this.optional = false,
  });

  final String id;

  /// Shown as "Nivel n"; 0 is the optional one with blocks.
  final int number;

  /// An optional level is on the path but the recommended way never waits for
  /// it: it does not count in "paso n de N" and is not the step that follows
  /// until everything else is done.
  final bool optional;

  /// Short name of the level, like "Fundamentos".
  final String title;

  /// One line saying what the level is about.
  final String description;
  final List<RouteGroup> groups;

  List<RouteStep> get steps => [for (final group in groups) ...group.steps];
}

/// The levels of the path, in order.
final routeLevels = <RouteLevel>[nivel0, nivel1];

/// Every unit of the path, in order.
List<RouteGroup> get routeGroups => [for (final level in routeLevels) ...level.groups];

/// Every step of the path, in order.
List<RouteStep> get routeSteps => [for (final level in routeLevels) ...level.steps];

/// The steps of the recommended way: those of the levels that are not
/// optional. The progress and the "paso n de N" count these.
List<RouteStep> get mainSteps => [
  for (final level in routeLevels)
    if (!level.optional) ...level.steps,
];

bool isStepDone(RouteStep step, {required Set<String> lessons, required Set<String> challenges}) =>
    step is LessonStep ? lessons.contains(step.id) : challenges.contains(step.id);

/// The first step not done yet: of the recommended way, then of the optional
/// levels; null when the whole path is done.
RouteStep? nextStep({required Set<String> lessons, required Set<String> challenges}) {
  for (final step in [...mainSteps, ...routeSteps]) {
    if (!isStepDone(step, lessons: lessons, challenges: challenges)) {
      return step;
    }
  }
  return null;
}

/// The first step of the recommended way not done yet; null when it is done
/// (the optional levels do not count).
RouteStep? nextMainStep({required Set<String> lessons, required Set<String> challenges}) {
  for (final step in mainSteps) {
    if (!isStepDone(step, lessons: lessons, challenges: challenges)) return step;
  }
  return null;
}

/// The challenge number [n] (from 1) of the first ten, which the first level
/// uses.
Challenge reto(int n) => challenges[n - 1];

/// The challenge that follows [id] on the path (the next challenge step,
/// skipping lessons); null if [id] is the last one or not a challenge.
Challenge? nextChallenge(String id) {
  final steps = routeSteps;
  final i = steps.indexWhere((s) => s.id == id);
  if (i < 0) return null;
  for (final step in steps.skip(i + 1)) {
    if (step is ChallengeStep) return step.challenge;
  }
  return null;
}
