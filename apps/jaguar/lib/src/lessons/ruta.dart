import '../challenges/challenges.dart';
import 'lessons.dart';
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
  const RouteLevel({required this.id, required this.title, required this.description, required this.groups});

  final String id;

  /// Short name of the level, like "Fundamentos".
  final String title;

  /// One line saying what the level is about.
  final String description;
  final List<RouteGroup> groups;

  List<RouteStep> get steps => [for (final group in groups) ...group.steps];
}

/// The levels of the path, in order.
final routeLevels = <RouteLevel>[nivel1];

/// Every unit of the path, in order.
List<RouteGroup> get routeGroups => [for (final level in routeLevels) ...level.groups];

/// Every step of the path, in order.
List<RouteStep> get routeSteps => [for (final level in routeLevels) ...level.steps];

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

/// The challenge number [n] (from 1) of the first ten, which the first level
/// uses.
Challenge reto(int n) => challenges[n - 1];
