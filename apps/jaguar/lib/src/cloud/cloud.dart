import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_backend.dart';
import 'firebase_rest.dart';
import 'rest_backend.dart';

export 'cloud_backend.dart';

/// Jaguar's online side: classes, assignments, submissions and the
/// community. Jaguar works fully without it; when it is available the same
/// app becomes a suite for students and teachers.
class Cloud extends ChangeNotifier {
  Cloud(this.backend, this._prefs, {DateTime Function() now = DateTime.now}) : _now = now {
    final raw = _prefs.getString(_linksKey);
    if (raw != null) _links.addAll((jsonDecode(raw) as Map).cast<String, String>());
  }

  /// The profile chosen on this device is a teacher's: "Entrar en línea"
  /// starts on Profesor.
  bool prefersTeacher = false;

  static const _linksKey = 'jaguar.cloud.assignments';

  final CloudBackend backend;
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  /// What Probar last sent for each assignment, so pressing it again and
  /// again does not spend the free daily writes of the project.
  final Map<String, ({String source, int passed, int total, DateTime at})> _lastSent = {};

  /// Same program with another result is sent at once; the same result with
  /// edits, at most this often.
  static const minSendGap = Duration(seconds: 20);

  /// Exercise id → `classId/assignmentId`, for the exercises opened from a
  /// class: their Probar results go to the teacher.
  final Map<String, String> _links = {};

  CloudUser? get user => backend.currentUser;
  bool get signedIn => user != null;

  Future<void> restore() async {
    try {
      await backend.restore();
    } on Object {
      // Offline: the session comes back next time.
    }
    notifyListeners();
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    final result = await action();
    notifyListeners();
    return result;
  }

  Future<CloudUser> signInAnonymously({required String alias, required CloudRole role}) =>
      _run(() => backend.signInAnonymously(alias: alias, role: role));
  Future<CloudUser> signInTeacher({required String email, required String password}) =>
      _run(() => backend.signInTeacher(email: email, password: password));
  Future<CloudUser> registerTeacher({required String email, required String password, required String alias}) =>
      _run(() => backend.registerTeacher(email: email, password: password, alias: alias));
  Future<void> signOut() => _run(backend.signOut);
  Future<void> resetPassword(String email) => backend.resetPassword(email);
  Future<void> deleteAccount() => _run(backend.deleteAccount);

  Future<ClassRoom> createClass(String name) => _run(() => backend.createClass(name));
  Future<ClassRoom> joinClass({required String code, required String name}) =>
      _run(() => backend.joinClass(code: code, name: name));

  /// Remembers that [exercise] belongs to an assignment of a class.
  void linkAssignment(Exercise exercise, Assignment assignment) {
    _links[exercise.id] = '${assignment.classId}/${assignment.id}';
    _prefs.setString(_linksKey, jsonEncode(_links));
  }

  /// Sends the result of Probar to the teacher, when the exercise came
  /// from a class. Quietly does nothing otherwise or when offline.
  Future<bool> submitIfAssigned({
    required Exercise exercise,
    required String studentName,
    required String source,
    required CheckResult result,
    int pastedLines = 0,
  }) async {
    final link = _links[exercise.id];
    if (link == null || !signedIn) return false;
    final [classId, assignmentId] = link.split('/');
    final passed = result.passedCount;
    final total = exercise.cases.length;
    final before = _lastSent[link];
    final now = _now();
    if (before != null && before.passed == passed && before.total == total) {
      // Nothing new for the teacher: skip if the program is the same, or if
      // only the text changed a moment ago.
      if (before.source == source || now.difference(before.at) < minSendGap) return true;
    }
    try {
      await backend.submit(
        classId: classId,
        assignmentId: assignmentId,
        name: studentName,
        source: source,
        passed: passed,
        total: total,
        pastedLines: pastedLines,
      );
      _lastSent[link] = (source: source, passed: passed, total: total, at: now);
      return true;
    } on Object {
      return false;
    }
  }
}

/// The Firebase project of Jaguar. The key is public (it identifies the
/// project, like the one in the landing page): what protects the data is
/// `firestore.rules`.
const _apiKey = 'AIzaSyD771Ak8TGNvnW1B_vRhMb6AG0IxPssrcE';
const _projectId = 'jaguarapp-50a15';

/// Connects the online side. There is nothing to install or start: the calls
/// go through Firebase's REST APIs (see [FirebaseRest]), so it is the same on
/// every platform. Without a connection the calls fail with a message and
/// Jaguar keeps working offline.
Future<Cloud> connectCloud(SharedPreferences prefs, {FirebaseRest? rest}) async {
  // `--dart-define=JAGUAR_EMULATORS=true` uses the local emulators.
  final firebase =
      rest ??
      (const bool.fromEnvironment('JAGUAR_EMULATORS')
          ? FirebaseRest.emulator(projectId: _projectId)
          : FirebaseRest(apiKey: _apiKey, projectId: _projectId));
  final cloud = Cloud(RestBackend(firebase, prefs), prefs);
  await cloud.restore();
  return cloud;
}
