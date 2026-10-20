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
    this.testedSource,
    this.pastedLines = 0,
  });

  factory SavedProgram.fromJson(Map<String, Object?> json) => SavedProgram(
    id: json['id']! as String,
    source: json['source']! as String,
    updatedAt: DateTime.parse(json['updatedAt']! as String),
    exerciseId: json['exerciseId'] as String?,
    testsPassed: (json['testsPassed'] as num?)?.toInt(),
    testsTotal: (json['testsTotal'] as num?)?.toInt(),
    testedSource: json['testedSource'] as String?,
    pastedLines: (json['pastedLines'] as num?)?.toInt() ?? 0,
  );

  final String id;
  String source;
  DateTime updatedAt;

  /// The exercise this program solves, if it was opened from one.
  final String? exerciseId;

  /// The last Probar: how many tests passed, shown next to the program.
  int? testsPassed;
  int? testsTotal;

  /// The code that last run through Probar, to tell whether the result still
  /// applies after the code changed.
  String? testedSource;

  /// The most lines that arrived at once while writing it (pasted). The
  /// teacher sees it next to the submission.
  int pastedLines;

  String get name => programName(source);

  Map<String, Object?> toJson() => {
    'id': id,
    'source': source,
    'updatedAt': updatedAt.toIso8601String(),
    if (exerciseId != null) 'exerciseId': exerciseId,
    if (testsTotal != null) ...{
      'testsPassed': testsPassed,
      'testsTotal': testsTotal,
      if (testedSource != null) 'testedSource': testedSource,
    },
    if (pastedLines > 0) 'pastedLines': pastedLines,
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
    // A first launch starts with a blank program; a person who deleted them
    // all (the key exists, with an empty list) lands on the start panel.
    if (raw == null) create(newProgramTemplate);
    final savedId = _prefs.getString(_currentKey);
    _current = _programs.where((p) => p.id == savedId).firstOrNull ?? _programs.firstOrNull;
  }

  static const _programsKey = 'jaguar.programs';
  static const _currentKey = 'jaguar.current';

  final SharedPreferences _prefs;
  final List<SavedProgram> _programs = [];
  SavedProgram? _current;

  /// Shown by the editor while there are no programs; it is never saved.
  final _placeholder = SavedProgram(id: '', source: newProgramTemplate, updatedAt: DateTime.fromMillisecondsSinceEpoch(0));

  /// Most recently edited first.
  List<SavedProgram> get programs => [..._programs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  /// The program in the editor. With no programs it is a blank stand-in with
  /// an empty id, so saving to it does nothing.
  SavedProgram get current => _current ?? _placeholder;

  /// No programs: the workspace shows the start panel.
  bool get isEmpty => _programs.isEmpty;

  /// A program nobody has written in yet.
  static bool isBlank(SavedProgram program) =>
      program.exerciseId == null &&
      program.source.replaceAll(RegExp(r'\s+'), ' ').trim() == newProgramTemplate.replaceAll(RegExp(r'\s+'), ' ').trim();

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
    if (!_programs.contains(program)) return;
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

  void recordTests(String id, {required int passed, required int total, String? source}) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index < 0) return;
    _programs[index]
      ..testsPassed = passed
      ..testsTotal = total
      ..testedSource = source;
    _persist();
  }

  void recordPaste(String id, int lines) {
    final index = _programs.indexWhere((p) => p.id == id);
    if (index < 0 || lines <= _programs[index].pastedLines) return;
    _programs[index].pastedLines = lines;
    _persist();
  }

  int pastedLines(String id) => _programs.where((p) => p.id == id).firstOrNull?.pastedLines ?? 0;

  /// Removes [program]. The last one can go too: the start panel takes over.
  void delete(SavedProgram program) {
    _programs.remove(program);
    if (identical(_current, program)) _current = programs.firstOrNull;
    _persist();
  }

  /// Puts back a program that [delete] removed (Deshacer) and opens it.
  void restore(SavedProgram program) {
    if (_programs.contains(program)) return;
    _programs.add(program);
    _current = program;
    _persist();
  }

  /// Drops the blank program a first launch creates, once the person has
  /// chosen where to start.
  void discardBlank() {
    final blank = _programs.where(isBlank).toList();
    if (blank.length != 1 || _programs.length != 1) return;
    _programs.remove(blank.first);
    _current = null;
    _persist();
  }

  void _persist() {
    _prefs.setString(_programsKey, jsonEncode([for (final p in _programs) p.toJson()]));
    final current = _current;
    if (current == null) {
      _prefs.remove(_currentKey);
    } else {
      _prefs.setString(_currentKey, current.id);
    }
    notifyListeners();
  }
}
