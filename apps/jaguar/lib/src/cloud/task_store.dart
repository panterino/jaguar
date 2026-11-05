import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_backend.dart';

/// Where a task of a class stands for the student, as in a classroom: to do,
/// handed in, or handed in and then changed.
enum TaskState {
  /// Not handed in. Maybe not even started.
  todo,

  /// Handed in, and the program is the same.
  delivered,

  /// Handed in, and the student changed the program after that.
  changed,
}

/// What this device knows about one assignment: the work the student did here
/// and whether it was handed in. The work stays on the device until the
/// student hands it in, which is a step of its own and needs internet.
class TaskRecord {
  const TaskRecord({
    required this.exerciseId,
    required this.classId,
    required this.assignmentId,
    this.className = '',
    this.title = '',
    this.source,
    this.passed,
    this.total,
    this.pastedLines = 0,
    this.workedAt,
    this.deliveredAt,
    this.deliveredPassed,
    this.deliveredTotal,
    this.deliveredSource,
    this.hiddenCount = 0,
  });

  final String exerciseId;
  final String classId;
  final String assignmentId;
  final String className;
  final String title;

  /// The last program tried here, and how many tests it passed.
  final String? source;
  final int? passed;
  final int? total;
  final int pastedLines;
  final DateTime? workedAt;

  /// What was handed in, and when. Null if nothing was.
  final DateTime? deliveredAt;
  final int? deliveredPassed;
  final int? deliveredTotal;

  /// The program that was handed in. Null when the delivery was found on the
  /// server and this device never saw the program.
  final String? deliveredSource;

  /// Tests the teacher checks that the student does not see.
  final int hiddenCount;

  String get key => '$classId/$assignmentId';

  /// [current] is the program in the editor now, to know if it changed after
  /// the delivery.
  TaskState stateFor([String? current]) {
    if (deliveredAt == null) return TaskState.todo;
    final handedIn = deliveredSource;
    if (current != null && handedIn != null && current.trim() != handedIn.trim()) return TaskState.changed;
    return TaskState.delivered;
  }

  /// The state judged by the last program tried here.
  TaskState get state => stateFor(source);

  TaskRecord copyWith({
    String? className,
    String? title,
    String? source,
    int? passed,
    int? total,
    int? pastedLines,
    DateTime? workedAt,
    DateTime? deliveredAt,
    int? deliveredPassed,
    int? deliveredTotal,
    String? deliveredSource,
    int? hiddenCount,
  }) => TaskRecord(
    exerciseId: exerciseId,
    classId: classId,
    assignmentId: assignmentId,
    className: className ?? this.className,
    title: title ?? this.title,
    source: source ?? this.source,
    passed: passed ?? this.passed,
    total: total ?? this.total,
    pastedLines: pastedLines ?? this.pastedLines,
    workedAt: workedAt ?? this.workedAt,
    deliveredAt: deliveredAt ?? this.deliveredAt,
    deliveredPassed: deliveredPassed ?? this.deliveredPassed,
    deliveredTotal: deliveredTotal ?? this.deliveredTotal,
    deliveredSource: deliveredSource ?? this.deliveredSource,
    hiddenCount: hiddenCount ?? this.hiddenCount,
  );

  Map<String, Object?> toJson() => {
    'exerciseId': exerciseId,
    'classId': classId,
    'assignmentId': assignmentId,
    if (className.isNotEmpty) 'className': className,
    if (title.isNotEmpty) 'title': title,
    if (source != null) 'source': source,
    if (passed != null) 'passed': passed,
    if (total != null) 'total': total,
    if (pastedLines > 0) 'pasted': pastedLines,
    if (workedAt != null) 'workedAt': workedAt!.millisecondsSinceEpoch,
    if (deliveredAt != null) 'deliveredAt': deliveredAt!.millisecondsSinceEpoch,
    if (deliveredPassed != null) 'deliveredPassed': deliveredPassed,
    if (deliveredTotal != null) 'deliveredTotal': deliveredTotal,
    if (deliveredSource != null) 'deliveredSource': deliveredSource,
    if (hiddenCount > 0) 'hidden': hiddenCount,
  };

  factory TaskRecord.fromJson(Map<String, Object?> json) {
    DateTime? time(String key) =>
        json[key] is num ? DateTime.fromMillisecondsSinceEpoch((json[key]! as num).toInt()) : null;
    return TaskRecord(
      exerciseId: json['exerciseId']! as String,
      classId: json['classId']! as String,
      assignmentId: json['assignmentId']! as String,
      className: json['className'] as String? ?? '',
      title: json['title'] as String? ?? '',
      source: json['source'] as String?,
      passed: (json['passed'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
      pastedLines: (json['pasted'] as num?)?.toInt() ?? 0,
      workedAt: time('workedAt'),
      deliveredAt: time('deliveredAt'),
      deliveredPassed: (json['deliveredPassed'] as num?)?.toInt(),
      deliveredTotal: (json['deliveredTotal'] as num?)?.toInt(),
      deliveredSource: json['deliveredSource'] as String?,
      hiddenCount: (json['hidden'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A class with its tasks, as the server last said. Kept so that the tasks
/// can be seen and worked on with no internet.
class CachedClass {
  const CachedClass(this.room, this.assignments);

  final ClassRoom room;
  final List<Assignment> assignments;

  Map<String, Object?> toJson() => {
    'room': room.toJson(),
    'assignments': [for (final a in assignments) a.toJson()],
  };

  factory CachedClass.fromJson(Map<String, Object?> json) =>
      CachedClass(ClassRoom.fromJson((json['room']! as Map).cast<String, Object?>()), [
        for (final a in (json['assignments'] as List? ?? const []))
          Assignment.fromJson((a as Map).cast<String, Object?>()),
      ]);
}

/// The student's side of the tasks, on this device: what they worked on, what
/// they handed in, and a copy of their classes for when there is no internet.
class TaskStore extends ChangeNotifier {
  TaskStore(this._prefs) {
    final raw = _prefs.getString(_recordsKey);
    if (raw != null) {
      for (final entry in (jsonDecode(raw) as List).cast<Map<String, Object?>>()) {
        final record = TaskRecord.fromJson(entry);
        _records[record.key] = record;
      }
    }
    final cache = _prefs.getString(_cacheKey);
    if (cache != null) {
      final decoded = (jsonDecode(cache) as Map).cast<String, Object?>();
      for (final entry in decoded.entries) {
        _cache[entry.key] = [
          for (final c in (entry.value as List)) CachedClass.fromJson((c as Map).cast<String, Object?>()),
        ];
      }
    }
    // Before this store, the device only knew which exercise belonged to which
    // assignment.
    final old = _prefs.getString(_oldLinksKey);
    if (old != null) {
      for (final entry in (jsonDecode(old) as Map).cast<String, String>().entries) {
        final parts = entry.value.split('/');
        if (parts.length != 2) continue;
        _records.putIfAbsent(
          entry.value,
          () => TaskRecord(exerciseId: entry.key, classId: parts[0], assignmentId: parts[1]),
        );
      }
      _prefs.remove(_oldLinksKey);
      _persistRecords();
    }
  }

  static const _recordsKey = 'jaguar.tasks';
  static const _cacheKey = 'jaguar.tasks.cache';
  static const _oldLinksKey = 'jaguar.cloud.assignments';

  final SharedPreferences _prefs;
  final Map<String, TaskRecord> _records = {};
  final Map<String, List<CachedClass>> _cache = {};

  TaskRecord? forExercise(String exerciseId) {
    for (final record in _records.values) {
      if (record.exerciseId == exerciseId) return record;
    }
    return null;
  }

  TaskRecord? forAssignment(String classId, String assignmentId) => _records['$classId/$assignmentId'];

  /// The student opens a task: the device remembers it, keeping any work
  /// already done.
  void open(Assignment assignment, {String className = ''}) {
    final key = '${assignment.classId}/${assignment.id}';
    final before = _records[key];
    _records[key] =
        (before ??
                TaskRecord(
                  exerciseId: assignment.exercise.id,
                  classId: assignment.classId,
                  assignmentId: assignment.id,
                ))
            .copyWith(
              title: assignment.title,
              className: className.isEmpty ? null : className,
              hiddenCount: assignment.hiddenCount,
            );
    _persistRecords();
  }

  /// Probar was pressed: the result stays on the device. Nothing is sent.
  void recordWork(
    String exerciseId, {
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  }) {
    final record = forExercise(exerciseId);
    if (record == null) return;
    _records[record.key] = record.copyWith(
      source: source,
      passed: passed,
      total: total,
      pastedLines: pastedLines,
      workedAt: DateTime.now(),
    );
    _persistRecords();
  }

  /// The teacher got the work.
  void markDelivered(
    String exerciseId, {
    required DateTime at,
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  }) {
    final record = forExercise(exerciseId);
    if (record == null) return;
    _records[record.key] = record.copyWith(
      source: source,
      passed: passed,
      total: total,
      pastedLines: pastedLines,
      deliveredAt: at,
      deliveredPassed: passed,
      deliveredTotal: total,
      deliveredSource: source,
    );
    _persistRecords();
  }

  /// The server says what was delivered (maybe from another device): that wins
  /// when this device has no delivery or an older one.
  void syncRemote(Assignment assignment, Submission? remote) {
    if (remote == null) return;
    final key = '${assignment.classId}/${assignment.id}';
    final record =
        _records[key] ??
        TaskRecord(exerciseId: assignment.exercise.id, classId: assignment.classId, assignmentId: assignment.id);
    final at = remote.updatedAt;
    final newer = record.deliveredAt == null || (at != null && at.isAfter(record.deliveredAt!));
    if (!newer) return;
    _records[key] = record.copyWith(
      title: assignment.title,
      deliveredAt: at ?? DateTime.now(),
      deliveredPassed: remote.passed,
      deliveredTotal: remote.total,
      deliveredSource: remote.source,
    );
    _persistRecords();
  }

  /// Handed in, here or as the server says.
  bool isDelivered(Assignment assignment, [Submission? remote]) =>
      remote != null || (forAssignment(assignment.classId, assignment.id)?.deliveredAt != null);

  // The copy of the classes -----------------------------------------------------

  void cacheClasses(String uid, List<CachedClass> classes) {
    _cache[uid] = classes;
    _prefs.setString(
      _cacheKey,
      jsonEncode({
        for (final entry in _cache.entries) entry.key: [for (final c in entry.value) c.toJson()],
      }),
    );
    notifyListeners();
  }

  /// The classes of [uid] as last seen with internet, or null if never.
  List<CachedClass>? cachedClasses(String uid) => _cache[uid];

  /// Tasks of the classes where [uid] is a student that are not handed in.
  List<(CachedClass, Assignment)> pending(String uid) => [
    for (final c in cachedClasses(uid) ?? const <CachedClass>[])
      if (c.room.ownerId != uid)
        for (final a in c.assignments)
          if (!isDelivered(a)) (c, a),
  ];

  void clearFor(String uid) {
    _cache.remove(uid);
    _prefs.setString(
      _cacheKey,
      jsonEncode({
        for (final entry in _cache.entries) entry.key: [for (final c in entry.value) c.toJson()],
      }),
    );
    notifyListeners();
  }

  void _persistRecords() {
    _prefs.setString(_recordsKey, jsonEncode([for (final r in _records.values) r.toJson()]));
    notifyListeners();
  }
}
