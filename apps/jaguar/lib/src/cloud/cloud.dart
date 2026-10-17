import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'cloud_backend.dart';
import 'firebase_backend.dart';

export 'cloud_backend.dart';

/// Jaguar's online side: classes, assignments, submissions and the
/// community. Jaguar works fully without it; when it is available the same
/// app becomes a suite for students and teachers.
class Cloud extends ChangeNotifier {
  Cloud(this.backend, this._prefs) {
    final raw = _prefs.getString(_linksKey);
    if (raw != null) _links.addAll((jsonDecode(raw) as Map).cast<String, String>());
  }

  static const _linksKey = 'jaguar.cloud.assignments';

  final CloudBackend backend;
  final SharedPreferences _prefs;

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
  }) async {
    final link = _links[exercise.id];
    if (link == null || !signedIn) return false;
    final [classId, assignmentId] = link.split('/');
    try {
      await backend.submit(
        classId: classId,
        assignmentId: assignmentId,
        name: studentName,
        source: source,
        passed: result.passedCount,
        total: exercise.cases.length,
      );
      return true;
    } on Object {
      return false;
    }
  }
}

/// Connects to Firebase. Returns null where it can't (no configuration for
/// this platform, no network on first start): Jaguar then works offline.
Future<Cloud?> connectCloud(SharedPreferences prefs) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // `--dart-define=JAGUAR_EMULATORS=true` uses the local emulators.
    if (const bool.fromEnvironment('JAGUAR_EMULATORS')) {
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
    }
    final cloud = Cloud(FirebaseBackend(), prefs);
    await cloud.restore();
    return cloud;
  } on Object catch (error) {
    debugPrint('Jaguar sin nube: $error');
    return null;
  }
}
