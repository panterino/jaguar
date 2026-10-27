import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exercises on this device: the ones the teacher wrote (with their
/// reference solutions, which never leave the device) and the ones the
/// student received through a link.
class ExerciseStore extends ChangeNotifier {
  ExerciseStore(this._prefs) {
    final raw = _prefs.getString(_exercisesKey);
    if (raw == null) return;
    for (final entry in (jsonDecode(raw) as List).cast<Map<String, Object?>>()) {
      final exercise = Exercise.fromJson((entry['exercise']! as Map).cast<String, Object?>());
      _exercises[exercise.id] = exercise;
      if (entry['mine'] == true) _mine.add(exercise.id);
      final solution = entry['solution'] as String?;
      if (solution != null) _solutions[exercise.id] = solution;
    }
  }

  static const _exercisesKey = 'jaguar.exercises';
  static const _studentNameKey = 'jaguar.studentName';

  final SharedPreferences _prefs;
  final Map<String, Exercise> _exercises = {};
  final Set<String> _mine = {};
  final Map<String, String> _solutions = {};

  /// Exercises written on this device, in creation order.
  List<Exercise> get authored => [
    for (final e in _exercises.values)
      if (_mine.contains(e.id)) e,
  ];

  /// Exercises that arrived through a link or a class, newest last. The
  /// challenges are not here: they come with the app.
  List<Exercise> get received => [
    for (final e in _exercises.values)
      if (!_mine.contains(e.id) && !e.id.startsWith('reto-')) e,
  ];

  Exercise? byId(String id) => _exercises[id];

  String? solutionFor(String id) => _solutions[id];

  String? get studentName => _prefs.getString(_studentNameKey);

  set studentName(String? name) {
    if (name == null || name.trim().isEmpty) {
      _prefs.remove(_studentNameKey);
    } else {
      _prefs.setString(_studentNameKey, name.trim());
    }
    notifyListeners();
  }

  /// Saves an exercise written here, with its optional reference solution.
  void saveAuthored(Exercise exercise, {String? solution}) {
    _exercises[exercise.id] = exercise;
    _mine.add(exercise.id);
    if (solution == null || solution.trim().isEmpty) {
      _solutions.remove(exercise.id);
    } else {
      _solutions[exercise.id] = solution;
    }
    _persist();
  }

  /// Saves an exercise received through a link. A newer version of the same
  /// exercise (the teacher fixed a case) replaces the old one.
  void saveReceived(Exercise exercise) {
    _exercises[exercise.id] = exercise;
    _persist();
  }

  void delete(String id) {
    _exercises.remove(id);
    _mine.remove(id);
    _solutions.remove(id);
    _persist();
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  void _persist() {
    _prefs.setString(
      _exercisesKey,
      jsonEncode([
        for (final exercise in _exercises.values)
          {
            'exercise': exercise.toJson(),
            if (_mine.contains(exercise.id)) 'mine': true,
            if (_solutions[exercise.id] != null) 'solution': _solutions[exercise.id],
          },
      ]),
    );
    notifyListeners();
  }
}
