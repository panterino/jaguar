import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _algorithmName = RegExp(r'^\s*(?:algoritmo|proceso)\s+([^\s/;]+)', caseSensitive: false, multiLine: true);

/// The name a program gives itself in `Algoritmo nombre`.
String programName(String source) => _algorithmName.firstMatch(source)?.group(1) ?? 'sin_nombre';

class SavedProgram {
  SavedProgram({
    required this.id,
    required this.source,
    required this.updatedAt,
    this.exerciseId,
    this.testsPassed,
    this.testsTotal,
  });

  factory SavedProgram.fromJson(Map<String, Object?> json) => SavedProgram(
    id: json['id']! as String,
    source: json['source']! as String,
    updatedAt: DateTime.parse(json['updatedAt']! as String),
    exerciseId: json['exerciseId'] as String?,
    testsPassed: (json['testsPassed'] as num?)?.toInt(),
    testsTotal: (json['testsTotal'] as num?)?.toInt(),
  );

  final String id;
  String source;
  DateTime updatedAt;

  /// The exercise this program solves, if it was opened from one.
  final String? exerciseId;

  /// The last Probar: how many tests passed, shown next to the program.
  int? testsPassed;
  int? testsTotal;

  String get name => programName(source);

  Map<String, Object?> toJson() => {
    'id': id,
    'source': source,
    'updatedAt': updatedAt.toIso8601String(),
    if (exerciseId != null) 'exerciseId': exerciseId,
    if (testsTotal != null) ...{'testsPassed': testsPassed, 'testsTotal': testsTotal},
  };
}

/// A valid algorithm name from an exercise title: "Área del círculo" →
/// `area_del_circulo`.
String exerciseSlug(String title) {
  var slug = normalize(title).replaceAll(RegExp(r'[^a-z0-9ñ]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  if (slug.length > 30) slug = slug.substring(0, 30).replaceAll(RegExp(r'_+$'), '');
  if (slug.isEmpty) return 'ejercicio';
  if (RegExp(r'^[0-9]').hasMatch(slug)) slug = 'ejercicio_$slug';
  return slug;
}

const newProgramTemplate = 'Algoritmo mi_programa\n    \nFinAlgoritmo\n';

/// The student's programs, saved on the device (localStorage on the web).
/// No account needed.
class ProgramStore extends ChangeNotifier {
  ProgramStore(this._prefs) {
    final raw = _prefs.getString(_programsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, Object?>>();
      _programs.addAll(list.map(SavedProgram.fromJson));
    }
    if (_programs.isEmpty) create(newProgramTemplate);
    final savedId = _prefs.getString(_currentKey);
    _current = _programs.firstWhere((p) => p.id == savedId, orElse: () => _programs.first);
  }

  static const _programsKey = 'jaguar.programs';
  static const _currentKey = 'jaguar.current';

  final SharedPreferences _prefs;
  final List<SavedProgram> _programs = [];
  late SavedProgram _current;

  /// Most recently edited first.
  List<SavedProgram> get programs => [..._programs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  SavedProgram get current => _current;

  SavedProgram create(String source, {String? exerciseId}) {
    final program = SavedProgram(
      id: DateTime.now().microsecondsSinceEpoch.toRadixString(36),
      source: source,
      updatedAt: DateTime.now(),
      exerciseId: exerciseId,
    );
    _programs.add(program);
    _current = program;
    _persist();
    return program;
  }

  /// Opens [source] as a program, reusing an identical one if it exists, so
  /// reopening the same shared link does not create duplicates.
  SavedProgram openSource(String source) {
    for (final program in _programs) {
      if (program.source == source) {
        select(program);
        return program;
      }
    }
    return create(source);
  }

  /// Opens the student's program for [exercise], creating it the first time.
  /// Reopening the exercise's link continues where the student left off.
  SavedProgram openExercise(Exercise exercise) {
    for (final program in _programs) {
      if (program.exerciseId == exercise.id) {
        select(program);
        return program;
      }
    }
    final name = exerciseSlug(exercise.title);
    return create('// Ejercicio: ${exercise.title}\nAlgoritmo $name\n    \nFinAlgoritmo\n', exerciseId: exercise.id);
  }

  void select(SavedProgram program) {
    _current = program;
    _persist();
  }

  /// Saves [source] into the program with [id]; does nothing if it was deleted.
  void update(String id, String source) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index < 0 || _programs[index].source == source) return;
    _programs[index]
      ..source = source
      ..updatedAt = DateTime.now();
    _persist();
  }

  void recordTests(String id, {required int passed, required int total}) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index < 0) return;
    _programs[index]
      ..testsPassed = passed
      ..testsTotal = total;
    _persist();
  }

  void delete(SavedProgram program) {
    _programs.remove(program);
    if (_programs.isEmpty) create(newProgramTemplate);
    if (identical(_current, program)) _current = programs.first;
    _persist();
  }

  void _persist() {
    _prefs.setString(_programsKey, jsonEncode([for (final p in _programs) p.toJson()]));
    _prefs.setString(_currentKey, _current.id);
    notifyListeners();
  }
}
