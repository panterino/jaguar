import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_backend.dart';
import 'firebase_rest.dart';
import 'rest_backend.dart';
import 'task_store.dart';

export 'cloud_backend.dart';
export 'task_store.dart';

/// Jaguar's online side: classes, assignments, submissions and the
/// community. Jaguar works fully without it; when it is available the same
/// app becomes a suite for students and teachers.
class Cloud extends ChangeNotifier {
  Cloud(this.backend, SharedPreferences prefs, {DateTime Function() now = DateTime.now})
    : _now = now,
      tasks = TaskStore(prefs) {
    tasks.addListener(notifyListeners);
  }

  /// The profile chosen on this device is a teacher's: "Entrar en línea"
  /// starts on Profesor.
  bool prefersTeacher = false;

  final CloudBackend backend;
  final DateTime Function() _now;

  /// What the student did on this device about each task, and a copy of the
  /// classes for when there is no internet.
  final TaskStore tasks;

  @override
  void dispose() {
    tasks.removeListener(notifyListeners);
    super.dispose();
  }

  CloudUser? get user => backend.currentUser;
  bool get signedIn => user != null;

  Future<void> restore() async {
    try {
      await backend.restore();
    } on Object {
      // Offline: the session comes back next time.
    }
    _revision++;
    notifyListeners();
  }

  /// Changes each time the classes may have changed: someone signed in or out,
  /// created a class or joined one. Not when only a task's state changes.
  int get revision => _revision;
  int _revision = 0;

  Future<T> _run<T>(Future<T> Function() action) async {
    final result = await action();
    _revision++;
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

  /// Reads my classes and their tasks from the server, keeps a copy for when
  /// there is no internet, and learns what was already handed in (maybe from
  /// another device). Returns false, with the copy still there, when there is
  /// no connection.
  Future<bool> syncClasses() async {
    final user = this.user;
    if (user == null) return false;
    try {
      final result = <CachedClass>[];
      for (final room in await backend.myClasses()) {
        final assignments = await backend.assignments(room.id);
        if (room.ownerId != user.uid) {
          for (final assignment in assignments) {
            tasks.open(assignment, className: room.name);
            tasks.syncRemote(assignment, await backend.mySubmission(room.id, assignment.id));
          }
        }
        result.add(CachedClass(room, assignments));
      }
      tasks.cacheClasses(user.uid, result);
      return true;
    } on CloudException catch (e) {
      if (e.offline) return false;
      rethrow;
    }
  }

  /// The student opens a task of their class: this device remembers it (and the
  /// work done on it), so it can be done with no internet.
  void linkAssignment(Exercise exercise, Assignment assignment, {String className = ''}) =>
      tasks.open(assignment, className: className);

  /// Hands the work in to the teacher: a step of its own, which needs internet.
  /// Probar does not send anything; this does.
  ///
  /// Throws a [CloudException] if it cannot (with `offline` true when there was
  /// no connection). The work stays on the device either way.
  Future<void> deliver({
    required Exercise exercise,
    required String studentName,
    required String source,
    required CheckResult result,
    int pastedLines = 0,
  }) async {
    final record = tasks.forExercise(exercise.id);
    if (record == null) throw const CloudException('Esta tarea no es de ninguna clase.');
    if (!signedIn) throw const CloudException('Primero entra a tu cuenta.');
    final passed = result.passedCount;
    final total = exercise.cases.length;
    await backend.submit(
      classId: record.classId,
      assignmentId: record.assignmentId,
      name: studentName,
      source: source,
      passed: passed,
      total: total,
      pastedLines: pastedLines,
    );
    tasks.markDelivered(
      exercise.id,
      at: _now(),
      source: source,
      passed: passed,
      total: total,
      pastedLines: pastedLines,
    );
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
