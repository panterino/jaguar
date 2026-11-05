import 'dart:convert';

import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_backend.dart';
import 'firebase_rest.dart';

/// Jaguar online over Firebase's REST APIs (see [FirebaseRest]): the accounts
/// are in Firebase Authentication and the classes, the submissions and the
/// community in Firestore. It keeps the same data as the Firebase SDK did, so
/// nothing has to be migrated, and what each person can do is still enforced by
/// `firestore.rules`.
class RestBackend implements CloudBackend {
  RestBackend(this._rest, this._prefs);

  final FirebaseRest _rest;
  final SharedPreferences _prefs;
  CloudUser? _user;

  static const _sessionKey = 'jaguar.cloud.session';

  /// Who the session belongs to, so that without internet the app still knows
  /// the person and shows their classes (it cannot ask the server).
  static const _profileKey = 'jaguar.cloud.profile';

  @override
  CloudUser? get currentUser => _user;

  String get _uid {
    final uid = _user?.uid;
    if (uid == null) throw const CloudException('Primero entra a tu cuenta.');
    return uid;
  }

  Future<CloudUser?> _load() async {
    final uid = _rest.uid!;
    final data = (await _rest.get('users/$uid'))?.data;
    if (data == null) return null;
    return _keep(
      CloudUser(
        uid: uid,
        alias: data['alias'] as String? ?? 'Sin nombre',
        role: CloudRole.values.asNameMap()[data['role']] ?? CloudRole.autodidacta,
        email: _rest.email,
      ),
    );
  }

  CloudUser _keep(CloudUser user) {
    _prefs.setString(
      _profileKey,
      jsonEncode({'uid': user.uid, 'alias': user.alias, 'role': user.role.name, 'email': user.email}),
    );
    return _user = user;
  }

  /// The person kept from the last time there was internet, or null.
  CloudUser? _kept() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      final json = (jsonDecode(raw) as Map).cast<String, Object?>();
      return CloudUser(
        uid: json['uid']! as String,
        alias: json['alias'] as String? ?? 'Sin nombre',
        role: CloudRole.values.asNameMap()[json['role']] ?? CloudRole.autodidacta,
        email: json['email'] as String?,
      );
    } on Object {
      return null;
    }
  }

  Future<CloudUser> _saveProfile(String alias, CloudRole role) async {
    final uid = _rest.uid!;
    await _rest.set('users/$uid', {'alias': alias, 'role': role.name, 'createdAt': ServerValue.timestamp});
    _remember();
    return _keep(CloudUser(uid: uid, alias: alias, role: role, email: _rest.email));
  }

  /// Keeps the session, so the person is still in the next time the app opens.
  void _remember() {
    final token = _rest.refreshToken;
    if (token != null) _prefs.setString(_sessionKey, token);
  }

  @override
  Future<CloudUser?> restore() async {
    final token = _prefs.getString(_sessionKey);
    if (token == null) return null;
    try {
      await _rest.restore(token);
    } on FirebaseRestError catch (e) {
      // No connection: the session is still good, it comes back next time.
      if (e.statusCode == 0 || e.statusCode >= 500) {
        // Without internet the person stays signed in as who they were; the
        // session is renewed by itself when a call goes through.
        final kept = _kept();
        if (kept == null) rethrow;
        _rest.uid = kept.uid;
        return _user = kept;
      }
      // The session ended (the account was deleted, or the token was revoked).
      await _prefs.remove(_sessionKey);
      await _prefs.remove(_profileKey);
      _rest.signOut();
      return null;
    }
    return _load();
  }

  @override
  Future<CloudUser> signInAnonymously({required String alias, required CloudRole role}) => _guard(() async {
    await _rest.signUpAnonymously();
    return _saveProfile(alias, role);
  });

  @override
  Future<CloudUser> signInTeacher({required String email, required String password}) => _guard(() async {
    await _rest.signInWithPassword(email, password);
    _remember();
    return await _load() ?? await _saveProfile(email.split('@').first, CloudRole.profesor);
  });

  @override
  Future<CloudUser> registerTeacher({required String email, required String password, required String alias}) =>
      _guard(() async {
        await _rest.signUpWithPassword(email, password);
        return _saveProfile(alias, CloudRole.profesor);
      });

  @override
  Future<void> signOut() async {
    _rest.signOut();
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_profileKey);
    _user = null;
  }

  @override
  Future<void> resetPassword(String email) => _guard(() => _rest.sendPasswordReset(email));

  @override
  Future<void> deleteAccount() => _guard(() async {
    final uid = _uid;
    // Classes they created, with everything inside.
    for (final room in await _rest.query('classes', where: {'ownerId': uid})) {
      final base = room.path;
      final writes = <Write>[];
      for (final assignment in await _rest.query('assignments', parent: base)) {
        for (final submission in await _rest.query('submissions', parent: assignment.path)) {
          writes.add(Write.delete(submission.path));
        }
        writes.add(Write.delete(assignment.path));
      }
      for (final member in await _rest.query('members', parent: base)) {
        writes.add(Write.delete(member.path));
      }
      for (final hidden in await _rest.query('hiddenCases', parent: base)) {
        writes.add(Write.delete(hidden.path));
      }
      final code = room.data['code'];
      if (code is String && code.isNotEmpty) writes.add(Write.delete('classCodes/$code'));
      writes.add(Write.delete(base));
      await _commitInChunks(writes);
    }
    // Their place and their work in other people's classes.
    final joined = [for (final id in ((await _rest.get('users/$uid'))?.data['classes'] as List?) ?? const []) '$id'];
    for (final classId in joined) {
      try {
        final writes = [
          for (final assignment in await _rest.query('assignments', parent: 'classes/$classId'))
            Write.delete('${assignment.path}/submissions/$uid'),
          Write.delete('classes/$classId/members/$uid'),
        ];
        await _commitInChunks(writes);
      } on FirebaseRestError {
        // The class may be gone already.
      }
    }
    await _commitInChunks([
      for (final publication in await _rest.query('publications', where: {'authorId': uid}))
        Write.delete(publication.path),
      Write.delete('users/$uid'),
    ]);
    await _rest.deleteAccount();
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_profileKey);
    _user = null;
  });

  /// Firestore takes up to 500 writes at once.
  Future<void> _commitInChunks(List<Write> writes) async {
    for (var i = 0; i < writes.length; i += 200) {
      await _rest.commit(writes.sublist(i, i + 200 > writes.length ? writes.length : i + 200));
    }
  }

  // Classes -------------------------------------------------------------------

  @override
  Future<ClassRoom> createClass(String name) => _guard(() async {
    final user = _user;
    if (user == null) throw const CloudException('Primero entra a tu cuenta.');
    var code = newClassCode();
    while (await _rest.get('classCodes/$code') != null) {
      code = newClassCode();
    }
    final id = newDocumentId();
    await _rest.set('classes/$id', {
      'name': name,
      'ownerId': user.uid,
      'ownerAlias': user.alias,
      'code': code,
      'open': true,
      'createdAt': ServerValue.timestamp,
    });
    // After the class, so the rules can check who owns it.
    await _rest.set('classCodes/$code', {'classId': id, 'ownerId': user.uid});
    return ClassRoom(id: id, name: name, code: code, ownerId: user.uid, ownerAlias: user.alias);
  });

  @override
  Future<ClassRoom> joinClass({required String code, required String name}) => _guard(() async {
    final normalized = normalizeClassCode(code);
    final classId = (await _rest.get('classCodes/$normalized'))?.data['classId'] as String?;
    if (classId == null) throw CloudException('No existe ninguna clase con el código $normalized.');
    try {
      await _rest.set('classes/$classId/members/$_uid', {
        'name': name,
        'role': 'alumno',
        'code': normalized,
        'joinedAt': ServerValue.timestamp,
      });
    } on FirebaseRestError catch (e) {
      // The code exists, so what the rules refuse is a closed class.
      if (e.code == 'PERMISSION_DENIED') {
        throw const CloudException('Esa clase no está recibiendo alumnos nuevos. Pídele a tu profe que la abra.');
      }
      rethrow;
    }
    await _rest.set('users/$_uid', {
      'classes': ArrayUnion([classId]),
    }, merge: true);
    final room = await _rest.get('classes/$classId');
    return _classFrom(room!);
  });

  ClassRoom _classFrom(Doc doc) => ClassRoom(
    id: doc.id,
    name: doc.data['name'] as String? ?? 'Clase',
    code: doc.data['code'] as String? ?? '',
    ownerId: doc.data['ownerId'] as String? ?? '',
    ownerAlias: doc.data['ownerAlias'] as String? ?? '',
    open: doc.data['open'] != false,
  );

  @override
  Future<void> setClassOpen(String classId, {required bool open}) =>
      _guard(() => _rest.set('classes/$classId', {'open': open}, merge: true));

  @override
  Future<List<ClassRoom>> myClasses() => _guard(() async {
    final owned = await _rest.query('classes', where: {'ownerId': _uid});
    final joined = [for (final id in ((await _rest.get('users/$_uid'))?.data['classes'] as List?) ?? const []) '$id'];
    final classes = [for (final doc in owned) _classFrom(doc)];
    for (final id in joined) {
      final doc = await _rest.get('classes/$id');
      if (doc != null) classes.add(_classFrom(doc));
    }
    return classes;
  });

  @override
  Future<List<Member>> members(String classId) => _guard(() async {
    final docs = await _rest.query('members', parent: 'classes/$classId');
    return [for (final doc in docs) Member(uid: doc.id, name: doc.data['name'] as String? ?? '')]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  });

  // Assignments ------------------------------------------------------------------

  @override
  Future<List<Assignment>> assignments(String classId) => _guard(() async {
    final docs = await _rest.query('assignments', parent: 'classes/$classId', orderBy: 'createdAt');
    final teacher = _user?.isTeacher ?? false;
    // Only the teacher can read the hidden tests: students get a number.
    final hidden = teacher && docs.any((d) => ((d.data['hiddenCount'] as num?) ?? 0) > 0)
        ? await _hiddenCases(classId)
        : const <String, List<TestCase>>{};
    final result = <Assignment>[];
    for (final doc in docs) {
      var exercise = Exercise.fromJson((doc.data['exercise']! as Map).cast<String, Object?>());
      var count = (doc.data['hiddenCount'] as num?)?.toInt() ?? 0;
      if (teacher && exercise.cases.any((c) => c.hidden)) {
        // An assignment made before the hidden tests were kept apart: its hidden
        // tests are in the open, in the part every student reads. Move them.
        await _storeAssignment(classId, doc.id, exercise, createdAt: doc.data['createdAt'] as DateTime?);
        count = exercise.cases.where((c) => c.hidden).length;
      } else if (hidden.containsKey(doc.id)) {
        exercise = withHiddenCases(exercise, hidden[doc.id]!);
      }
      result.add(
        Assignment(
          id: doc.id,
          classId: classId,
          exercise: exercise,
          createdAt: doc.data['createdAt'] as DateTime?,
          hiddenCount: count,
        ),
      );
    }
    return result;
  });

  Future<Map<String, List<TestCase>>> _hiddenCases(String classId) async {
    try {
      final docs = await _rest.query('hiddenCases', parent: 'classes/$classId');
      return {
        for (final doc in docs)
          doc.id: [
            for (final c in (doc.data['cases'] as List?) ?? const [])
              TestCase.fromJson((c as Map).cast<String, Object?>()),
          ],
      };
    } on FirebaseRestError catch (e) {
      if (e.code == 'PERMISSION_DENIED') return const {};
      rethrow;
    }
  }

  /// Writes the assignment with the visible tests, and the hidden ones apart.
  Future<void> _storeAssignment(String classId, String id, Exercise exercise, {DateTime? createdAt}) async {
    final parts = splitHiddenCases(exercise);
    await _rest.commit([
      Write.set('classes/$classId/assignments/$id', {
        'title': exercise.title,
        'exercise': parts.visible.toJson(),
        'hiddenCount': parts.hidden.length,
        'createdAt': createdAt ?? ServerValue.timestamp,
      }),
      if (parts.hidden.isNotEmpty)
        Write.set('classes/$classId/hiddenCases/$id', {
          'cases': [for (final c in parts.hidden) c.toJson()],
        })
      else
        Write.delete('classes/$classId/hiddenCases/$id'),
    ]);
  }

  @override
  Future<Assignment> assign(String classId, Exercise exercise) => _guard(() async {
    final id = newDocumentId();
    await _storeAssignment(classId, id, exercise);
    return Assignment(
      id: id,
      classId: classId,
      exercise: exercise,
      createdAt: DateTime.now(),
      hiddenCount: exercise.cases.where((c) => c.hidden).length,
    );
  });

  @override
  Future<void> removeAssignment(String classId, String assignmentId) => _guard(
    () => _rest.commit([
      Write.delete('classes/$classId/assignments/$assignmentId'),
      Write.delete('classes/$classId/hiddenCases/$assignmentId'),
    ]),
  );

  @override
  Future<void> removeMember(String classId, String uid) => _guard(() async {
    final assignments = await _rest.query('assignments', parent: 'classes/$classId');
    await _rest.commit([
      for (final a in assignments) Write.delete('classes/$classId/assignments/${a.id}/submissions/$uid'),
      Write.delete('classes/$classId/members/$uid'),
    ]);
  });

  @override
  Future<void> submit({
    required String classId,
    required String assignmentId,
    required String name,
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  }) => _guard(
    () => _rest.set('classes/$classId/assignments/$assignmentId/submissions/$_uid', {
      'name': name,
      'source': source,
      'passed': passed,
      'total': total,
      if (pastedLines > 0) 'pasted': pastedLines,
      'updatedAt': ServerValue.timestamp,
    }),
  );

  Submission _submissionFrom(Doc doc) => Submission(
    uid: doc.id,
    name: doc.data['name'] as String? ?? '',
    source: doc.data['source'] as String? ?? '',
    passed: (doc.data['passed'] as num?)?.toInt() ?? 0,
    total: (doc.data['total'] as num?)?.toInt() ?? 0,
    updatedAt: doc.data['updatedAt'] as DateTime?,
    pastedLines: (doc.data['pasted'] as num?)?.toInt() ?? 0,
  );

  @override
  Future<Map<String, Submission>> submissions(String classId, String assignmentId) => _guard(() async {
    final docs = await _rest.query('submissions', parent: 'classes/$classId/assignments/$assignmentId');
    return {for (final doc in docs) doc.id: _submissionFrom(doc)};
  });

  @override
  Future<Submission?> mySubmission(String classId, String assignmentId) => _guard(() async {
    final doc = await _rest.get('classes/$classId/assignments/$assignmentId/submissions/$_uid');
    return doc == null ? null : _submissionFrom(doc);
  });

  // Community ---------------------------------------------------------------------

  Publication _publicationFrom(Doc doc) {
    final data = doc.data;
    return Publication(
      id: doc.id,
      kind: PublicationKind.values.asNameMap()[data['kind']] ?? PublicationKind.programa,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorAlias: data['authorAlias'] as String? ?? '',
      content: ((data['content'] as Map?) ?? const {}).cast<String, Object?>(),
      remixOf: data['remixOf'] as String?,
      createdAt: data['createdAt'] as DateTime?,
    );
  }

  @override
  Future<List<Publication>> publications({PublicationKind? kind}) => _guard(() async {
    final docs = await _rest.query(
      'publications',
      where: {'status': 'publicado', if (kind != null) 'kind': kind.name},
      orderBy: 'createdAt',
      descending: true,
      limit: 60,
    );
    return [for (final doc in docs) _publicationFrom(doc)];
  });

  @override
  Future<List<Publication>> myPublications() => _guard(() async {
    final docs = await _rest.query('publications', where: {'authorId': _uid}, orderBy: 'createdAt', descending: true);
    return [for (final doc in docs) _publicationFrom(doc)];
  });

  @override
  Future<Publication> publish({
    required PublicationKind kind,
    required String title,
    required String description,
    required String topic,
    required Map<String, Object?> content,
    String? remixOf,
  }) => _guard(() async {
    final user = _user;
    if (user == null) throw const CloudException('Primero entra a tu cuenta.');
    final id = newDocumentId();
    await _rest.set('publications/$id', {
      'kind': kind.name,
      'title': title,
      'description': description,
      'topic': topic,
      'authorId': user.uid,
      'authorAlias': user.alias,
      'content': content,
      'remixOf': ?remixOf,
      'status': 'publicado',
      'createdAt': ServerValue.timestamp,
    });
    return _publicationFrom((await _rest.get('publications/$id'))!);
  });

  @override
  Future<void> unpublish(String publicationId) => _guard(() => _rest.delete('publications/$publicationId'));

  @override
  Future<int> usefulCount(String publicationId) =>
      _guard(() => _rest.count('useful', parent: 'publications/$publicationId'));

  @override
  Future<bool> isUseful(String publicationId) =>
      _guard(() async => await _rest.get('publications/$publicationId/useful/$_uid') != null);

  @override
  Future<void> setUseful(String publicationId, {required bool useful}) => _guard(() {
    final path = 'publications/$publicationId/useful/$_uid';
    return useful ? _rest.set(path, {}) : _rest.delete(path);
  });

  @override
  Future<void> report(String publicationId, String reason) => _guard(
    () => _rest.set('reports/${newDocumentId()}', {
      'publicationId': publicationId,
      'reporterId': _uid,
      'reason': reason,
      'createdAt': ServerValue.timestamp,
    }),
  );

  /// Errors in Spanish, for people.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseRestError catch (e) {
      throw CloudException(offline: e.code == 'NETWORK' || e.code == 'UNAVAILABLE', switch (e.code) {
        'INVALID_LOGIN_CREDENTIALS' ||
        'INVALID_PASSWORD' ||
        'EMAIL_NOT_FOUND' ||
        'INVALID_CREDENTIAL' => 'El correo o la contraseña no coinciden.',
        'EMAIL_EXISTS' => 'Ya hay una cuenta con ese correo. Entra con tu contraseña.',
        'WEAK_PASSWORD' => 'La contraseña es muy corta: usa al menos 6 caracteres.',
        'INVALID_EMAIL' => 'Ese correo no parece válido.',
        'OPERATION_NOT_ALLOWED' => 'Ese tipo de cuenta aún no está activado en el servidor de Jaguar.',
        'CREDENTIAL_TOO_OLD_LOGIN_AGAIN' => 'Por seguridad, sal, vuelve a entrar y entonces borra tu cuenta.',
        'MISSING_EMAIL' => 'Escribe tu correo.',
        'TOO_MANY_ATTEMPTS_TRY_LATER' => 'Demasiados intentos. Espera un rato e intenta de nuevo.',
        'NETWORK' => 'No hay conexión a internet.',
        'PERMISSION_DENIED' => 'No tienes permiso para hacer eso.',
        'UNAVAILABLE' => 'No hay conexión con el servidor. Intenta de nuevo.',
        'RESOURCE_EXHAUSTED' => 'Jaguar llegó hoy a su límite gratuito de uso. Vuelve a intentarlo mañana.',
        _ => 'Algo falló en el servidor: ${e.message}',
      });
    }
  }
}
