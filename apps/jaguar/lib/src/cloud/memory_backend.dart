import 'dart:math' as math;

import 'package:jaguar_core/jaguar_core.dart';

import 'cloud_backend.dart';

/// Jaguar online, kept in memory: for tests, and to try the classes and
/// the community without a server. Shared between "devices" by passing the
/// same instance and switching users with [actAs].
class MemoryBackend implements CloudBackend {
  final _random = math.Random(7);
  final Map<String, CloudUser> _users = {};
  final Map<String, ({String password, String uid})> _teachers = {};
  final Map<String, ClassRoom> _classes = {};
  final Map<String, Map<String, Member>> _members = {};
  final Map<String, Set<String>> _joined = {};
  final Map<String, List<Assignment>> _assignments = {};
  final Map<String, Map<String, Submission>> _submissions = {};
  final List<Publication> _publications = [];
  final Map<String, Set<String>> _useful = {};
  final List<(String, String)> reports = [];
  int _ids = 0;
  CloudUser? _user;

  String _id() => 'id${_ids++}';

  /// Simulates having no internet: what needs the network refuses, with the
  /// same error the real client gives.
  bool offline = false;

  void _needsNetwork() {
    if (offline) throw const CloudException('No hay conexión a internet.', offline: true);
  }

  /// Switches to another user, as if on another device.
  void actAs(CloudUser? user) => _user = user;

  @override
  CloudUser? get currentUser => _user;

  CloudUser get _me => _user ?? (throw const CloudException('Primero entra a tu cuenta.'));

  @override
  Future<CloudUser?> restore() async => _user;

  @override
  Future<CloudUser> signInAnonymously({required String alias, required CloudRole role}) async {
    final user = CloudUser(uid: _id(), alias: alias, role: role);
    _users[user.uid] = user;
    return _user = user;
  }

  @override
  Future<CloudUser> signInTeacher({required String email, required String password}) async {
    final account = _teachers[email];
    if (account == null || account.password != password) {
      throw const CloudException('El correo o la contraseña no coinciden.');
    }
    return _user = _users[account.uid]!;
  }

  @override
  Future<CloudUser> registerTeacher({required String email, required String password, required String alias}) async {
    if (_teachers.containsKey(email)) throw const CloudException('Ya hay una cuenta con ese correo.');
    final user = CloudUser(uid: _id(), alias: alias, role: CloudRole.profesor, email: email);
    _users[user.uid] = user;
    _teachers[email] = (password: password, uid: user.uid);
    return _user = user;
  }

  @override
  Future<void> signOut() async => _user = null;

  /// Emails "sent" by [resetPassword], for tests.
  final passwordResets = <String>[];

  @override
  Future<void> resetPassword(String email) async {
    if (!_teachers.containsKey(email)) throw const CloudException('No hay ninguna cuenta con ese correo.');
    passwordResets.add(email);
  }

  @override
  Future<void> deleteAccount() async {
    final me = _me;
    _users.remove(me.uid);
    _teachers.removeWhere((_, account) => account.uid == me.uid);
    _classes.removeWhere((_, room) => room.ownerId == me.uid);
    for (final members in _members.values) {
      members.remove(me.uid);
    }
    _joined.remove(me.uid);
    _user = null;
  }

  @override
  Future<ClassRoom> createClass(String name) async {
    final me = _me;
    final room = ClassRoom(id: _id(), name: name, code: newClassCode(_random), ownerId: me.uid, ownerAlias: me.alias);
    _classes[room.id] = room;
    return room;
  }

  @override
  Future<void> setClassOpen(String classId, {required bool open}) async {
    _requireOwner(classId);
    final room = _classes[classId]!;
    _classes[classId] = ClassRoom(
      id: room.id,
      name: room.name,
      code: room.code,
      ownerId: room.ownerId,
      ownerAlias: room.ownerAlias,
      open: open,
    );
  }

  @override
  Future<ClassRoom> joinClass({required String code, required String name}) async {
    final normalized = normalizeClassCode(code);
    final room = _classes.values.where((c) => c.code == normalized).firstOrNull;
    if (room == null) throw CloudException('No existe ninguna clase con el código $normalized.');
    if (!room.open) {
      throw const CloudException('Esa clase no está recibiendo alumnos nuevos. Pídele a tu profe que la abra.');
    }
    (_members[room.id] ??= {})[_me.uid] = Member(uid: _me.uid, name: name);
    (_joined[_me.uid] ??= {}).add(room.id);
    return room;
  }

  @override
  Future<List<ClassRoom>> myClasses() async {
    _needsNetwork();
    return [
      ..._classes.values.where((c) => c.ownerId == _me.uid),
      for (final id in _joined[_me.uid] ?? const <String>{}) _classes[id]!,
    ];
  }

  void _requireOwner(String classId) {
    if (_classes[classId]?.ownerId != _me.uid) throw const CloudException('No tienes permiso para hacer eso.');
  }

  @override
  Future<List<Member>> members(String classId) async {
    _requireOwner(classId);
    return [...?_members[classId]?.values];
  }

  @override
  Future<List<Assignment>> assignments(String classId) async {
    _needsNetwork();
    final mine = _classes[classId]?.ownerId == _me.uid;
    return [
      for (final a in _assignments[classId] ?? const <Assignment>[])
        // A student gets the visible tests and the number of the hidden ones.
        if (mine)
          a
        else
          Assignment(
            id: a.id,
            classId: a.classId,
            exercise: splitHiddenCases(a.exercise).visible,
            createdAt: a.createdAt,
            hiddenCount: a.hiddenCount,
          ),
    ];
  }

  @override
  Future<Assignment> assign(String classId, Exercise exercise) async {
    _requireOwner(classId);
    final assignment = Assignment(
      id: _id(),
      classId: classId,
      exercise: exercise,
      createdAt: DateTime.now(),
      hiddenCount: exercise.cases.where((c) => c.hidden).length,
    );
    (_assignments[classId] ??= []).add(assignment);
    return assignment;
  }

  @override
  Future<void> removeAssignment(String classId, String assignmentId) async {
    _requireOwner(classId);
    _assignments[classId]?.removeWhere((a) => a.id == assignmentId);
  }

  @override
  Future<void> removeMember(String classId, String uid) async {
    _requireOwner(classId);
    _members[classId]?.remove(uid);
    for (final entry in _submissions.entries) {
      if (entry.key.startsWith('$classId/')) entry.value.remove(uid);
    }
  }

  @override
  Future<void> submit({
    required String classId,
    required String assignmentId,
    required String name,
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  }) async {
    _needsNetwork();
    if (!(_members[classId]?.containsKey(_me.uid) ?? false)) {
      throw const CloudException('No tienes permiso para hacer eso.');
    }
    (_submissions['$classId/$assignmentId'] ??= {})[_me.uid] = Submission(
      uid: _me.uid,
      name: name,
      source: source,
      passed: passed,
      total: total,
      updatedAt: DateTime.now(),
      pastedLines: pastedLines,
    );
  }

  @override
  Future<Map<String, Submission>> submissions(String classId, String assignmentId) async {
    _requireOwner(classId);
    return {...?_submissions['$classId/$assignmentId']};
  }

  @override
  Future<Submission?> mySubmission(String classId, String assignmentId) async {
    _needsNetwork();
    return _submissions['$classId/$assignmentId']?[_me.uid];
  }

  @override
  Future<List<Publication>> publications({PublicationKind? kind}) async => [
    for (final p in _publications.reversed)
      if (kind == null || p.kind == kind) p,
  ];

  @override
  Future<List<Publication>> myPublications() async => [
    for (final p in _publications.reversed)
      if (p.authorId == _me.uid) p,
  ];

  @override
  Future<Publication> publish({
    required PublicationKind kind,
    required String title,
    required String description,
    required String topic,
    required Map<String, Object?> content,
    String? remixOf,
  }) async {
    final publication = Publication(
      id: _id(),
      kind: kind,
      title: title,
      description: description,
      topic: topic,
      authorId: _me.uid,
      authorAlias: _me.alias,
      content: content,
      remixOf: remixOf,
      createdAt: DateTime.now(),
    );
    _publications.add(publication);
    return publication;
  }

  @override
  Future<void> unpublish(String publicationId) async =>
      _publications.removeWhere((p) => p.id == publicationId && p.authorId == _me.uid);

  @override
  Future<int> usefulCount(String publicationId) async => _useful[publicationId]?.length ?? 0;

  @override
  Future<bool> isUseful(String publicationId) async => _useful[publicationId]?.contains(_me.uid) ?? false;

  @override
  Future<void> setUseful(String publicationId, {required bool useful}) async {
    final set = _useful[publicationId] ??= {};
    useful ? set.add(_me.uid) : set.remove(_me.uid);
  }

  @override
  Future<void> report(String publicationId, String reason) async => reports.add((publicationId, reason));
}
