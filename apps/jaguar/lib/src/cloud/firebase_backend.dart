import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'cloud_backend.dart';

/// Jaguar online with Firebase: Authentication for accounts and Firestore
/// for classes, submissions and the community. What each user can read and
/// write is enforced by `firestore.rules`.
class FirebaseBackend implements CloudBackend {
  FirebaseBackend({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  CloudUser? _user;

  @override
  CloudUser? get currentUser => _user;

  String get _uid {
    final user = _user;
    if (user == null) throw const CloudException('Primero entra a tu cuenta.');
    return user.uid;
  }

  DocumentReference<Map<String, Object?>> _profile(String uid) => _db.doc('users/$uid');

  Future<CloudUser?> _load(User user) async {
    final snapshot = await _profile(user.uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return _user = CloudUser(
      uid: user.uid,
      alias: data['alias'] as String? ?? 'Sin nombre',
      role: CloudRole.values.asNameMap()[data['role']] ?? CloudRole.autodidacta,
      email: user.email,
    );
  }

  Future<CloudUser> _saveProfile(User user, String alias, CloudRole role) async {
    await _profile(user.uid).set({'alias': alias, 'role': role.name, 'createdAt': FieldValue.serverTimestamp()});
    return _user = CloudUser(uid: user.uid, alias: alias, role: role, email: user.email);
  }

  @override
  Future<CloudUser?> restore() async {
    final user = _auth.currentUser ?? await _auth.authStateChanges().first;
    if (user == null) return null;
    return _load(user);
  }

  @override
  Future<CloudUser> signInAnonymously({required String alias, required CloudRole role}) => _guard(() async {
    final credential = await _auth.signInAnonymously();
    return _saveProfile(credential.user!, alias, role);
  });

  @override
  Future<CloudUser> signInTeacher({required String email, required String password}) => _guard(() async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await _load(credential.user!) ??
        await _saveProfile(credential.user!, email.split('@').first, CloudRole.profesor);
  });

  @override
  Future<CloudUser> registerTeacher({required String email, required String password, required String alias}) =>
      _guard(() async {
        final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        return _saveProfile(credential.user!, alias, CloudRole.profesor);
      });

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
  }

  @override
  Future<void> resetPassword(String email) => _guard(() async {
    await _auth.setLanguageCode('es');
    await _auth.sendPasswordResetEmail(email: email);
  });

  @override
  Future<void> deleteAccount() => _guard(() async {
    final user = _auth.currentUser;
    final uid = _uid;
    if (user == null) throw const CloudException('Primero entra a tu cuenta.');
    // Classes they created, with everything inside.
    final owned = await _db.collection('classes').where('ownerId', isEqualTo: uid).get();
    for (final room in owned.docs) {
      for (final member in (await room.reference.collection('members').get()).docs) {
        await member.reference.delete();
      }
      for (final assignment in (await room.reference.collection('assignments').get()).docs) {
        for (final submission in (await assignment.reference.collection('submissions').get()).docs) {
          await submission.reference.delete();
        }
        await assignment.reference.delete();
      }
      final code = room.data()['code'];
      if (code is String && code.isNotEmpty) await _db.doc('classCodes/$code').delete();
      await room.reference.delete();
    }
    // Their place and their work in other people's classes.
    final joined = [for (final id in ((await _profile(uid).get()).data()?['classes'] as List?) ?? const []) '$id'];
    for (final classId in joined) {
      try {
        for (final assignment in (await _db.collection('classes/$classId/assignments').get()).docs) {
          await assignment.reference.collection('submissions').doc(uid).delete();
        }
        await _db.doc('classes/$classId/members/$uid').delete();
      } on FirebaseException {
        // The class may be gone already.
      }
    }
    for (final publication in (await _db.collection('publications').where('authorId', isEqualTo: uid).get()).docs) {
      await publication.reference.delete();
    }
    await _profile(uid).delete();
    await user.delete();
    _user = null;
  });

  // Classes -------------------------------------------------------------------

  @override
  Future<ClassRoom> createClass(String name) => _guard(() async {
    final user = _user!;
    var code = newClassCode();
    while ((await _db.doc('classCodes/$code').get()).exists) {
      code = newClassCode();
    }
    final ref = _db.collection('classes').doc();
    await ref.set({
      'name': name,
      'ownerId': user.uid,
      'ownerAlias': user.alias,
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // After the class, so the rules can check who owns it.
    await _db.doc('classCodes/$code').set({'classId': ref.id, 'ownerId': user.uid});
    return ClassRoom(id: ref.id, name: name, code: code, ownerId: user.uid, ownerAlias: user.alias);
  });

  @override
  Future<ClassRoom> joinClass({required String code, required String name}) => _guard(() async {
    final normalized = normalizeClassCode(code);
    final codeDoc = await _db.doc('classCodes/$normalized').get();
    final classId = codeDoc.data()?['classId'] as String?;
    if (classId == null) throw CloudException('No existe ninguna clase con el código $normalized.');
    await _db.doc('classes/$classId/members/$_uid').set({
      'name': name,
      'role': 'alumno',
      'code': normalized,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await _profile(_uid).update({
      'classes': FieldValue.arrayUnion([classId]),
    });
    return _classFrom(await _db.doc('classes/$classId').get());
  });

  ClassRoom _classFrom(DocumentSnapshot<Map<String, Object?>> snapshot) {
    final data = snapshot.data() ?? const {};
    return ClassRoom(
      id: snapshot.id,
      name: data['name'] as String? ?? 'Clase',
      code: data['code'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      ownerAlias: data['ownerAlias'] as String? ?? '',
    );
  }

  @override
  Future<List<ClassRoom>> myClasses() => _guard(() async {
    final owned = await _db.collection('classes').where('ownerId', isEqualTo: _uid).get();
    final profile = await _profile(_uid).get();
    final joined = [for (final id in (profile.data()?['classes'] as List?) ?? const []) '$id'];
    final classes = [for (final doc in owned.docs) _classFrom(doc)];
    for (final id in joined) {
      final snapshot = await _db.doc('classes/$id').get();
      if (snapshot.exists) classes.add(_classFrom(snapshot));
    }
    return classes;
  });

  @override
  Future<List<Member>> members(String classId) => _guard(() async {
    final snapshot = await _db.collection('classes/$classId/members').get();
    return [for (final doc in snapshot.docs) Member(uid: doc.id, name: doc.data()['name'] as String? ?? '')]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  });

  // Assignments ------------------------------------------------------------------

  @override
  Future<List<Assignment>> assignments(String classId) => _guard(() async {
    final snapshot = await _db.collection('classes/$classId/assignments').orderBy('createdAt').get();
    return [
      for (final doc in snapshot.docs)
        Assignment(
          id: doc.id,
          classId: classId,
          exercise: Exercise.fromJson((doc.data()['exercise']! as Map).cast<String, Object?>()),
          createdAt: (doc.data()['createdAt'] as Timestamp?)?.toDate(),
        ),
    ];
  });

  @override
  Future<Assignment> assign(String classId, Exercise exercise) => _guard(() async {
    final ref = _db.collection('classes/$classId/assignments').doc();
    await ref.set({'title': exercise.title, 'exercise': exercise.toJson(), 'createdAt': FieldValue.serverTimestamp()});
    return Assignment(id: ref.id, classId: classId, exercise: exercise, createdAt: DateTime.now());
  });

  @override
  Future<void> removeAssignment(String classId, String assignmentId) =>
      _guard(() => _db.doc('classes/$classId/assignments/$assignmentId').delete());

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
    () => _db.doc('classes/$classId/assignments/$assignmentId/submissions/$_uid').set({
      'name': name,
      'source': source,
      'passed': passed,
      'total': total,
      if (pastedLines > 0) 'pasted': pastedLines,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
  );

  Submission _submissionFrom(DocumentSnapshot<Map<String, Object?>> doc) {
    final data = doc.data() ?? const {};
    return Submission(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      source: data['source'] as String? ?? '',
      passed: (data['passed'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toInt() ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      pastedLines: (data['pasted'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<Map<String, Submission>> submissions(String classId, String assignmentId) => _guard(() async {
    final snapshot = await _db.collection('classes/$classId/assignments/$assignmentId/submissions').get();
    return {for (final doc in snapshot.docs) doc.id: _submissionFrom(doc)};
  });

  @override
  Future<Submission?> mySubmission(String classId, String assignmentId) => _guard(() async {
    final doc = await _db.doc('classes/$classId/assignments/$assignmentId/submissions/$_uid').get();
    return doc.exists ? _submissionFrom(doc) : null;
  });

  // Community ---------------------------------------------------------------------

  Publication _publicationFrom(DocumentSnapshot<Map<String, Object?>> doc) {
    final data = doc.data() ?? const {};
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<List<Publication>> publications({PublicationKind? kind}) => _guard(() async {
    Query<Map<String, Object?>> q = _db.collection('publications').where('status', isEqualTo: 'publicado');
    if (kind != null) q = q.where('kind', isEqualTo: kind.name);
    final snapshot = await q.orderBy('createdAt', descending: true).limit(60).get();
    return [for (final doc in snapshot.docs) _publicationFrom(doc)];
  });

  @override
  Future<List<Publication>> myPublications() => _guard(() async {
    final snapshot = await _db
        .collection('publications')
        .where('authorId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .get();
    return [for (final doc in snapshot.docs) _publicationFrom(doc)];
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
    final user = _user!;
    final ref = _db.collection('publications').doc();
    await ref.set({
      'kind': kind.name,
      'title': title,
      'description': description,
      'topic': topic,
      'authorId': user.uid,
      'authorAlias': user.alias,
      'content': content,
      'remixOf': ?remixOf,
      'status': 'publicado',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return _publicationFrom(await ref.get());
  });

  @override
  Future<void> unpublish(String publicationId) => _guard(() => _db.doc('publications/$publicationId').delete());

  @override
  Future<int> usefulCount(String publicationId) => _guard(() async {
    final aggregate = await _db.collection('publications/$publicationId/useful').count().get();
    return aggregate.count ?? 0;
  });

  @override
  Future<bool> isUseful(String publicationId) =>
      _guard(() async => (await _db.doc('publications/$publicationId/useful/$_uid').get()).exists);

  @override
  Future<void> setUseful(String publicationId, {required bool useful}) => _guard(() {
    final ref = _db.doc('publications/$publicationId/useful/$_uid');
    return useful ? ref.set({}) : ref.delete();
  });

  @override
  Future<void> report(String publicationId, String reason) => _guard(
    () => _db.collection('reports').add({
      'publicationId': publicationId,
      'reporterId': _uid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    }),
  );

  /// Firebase errors in Spanish, for people.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw CloudException(switch (e.code) {
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'El correo o la contraseña no coinciden.',
        'email-already-in-use' => 'Ya hay una cuenta con ese correo. Entra con tu contraseña.',
        'weak-password' => 'La contraseña es muy corta: usa al menos 6 caracteres.',
        'invalid-email' => 'Ese correo no parece válido.',
        'operation-not-allowed' => 'Ese tipo de cuenta aún no está activado en el servidor de Jaguar.',
        'network-request-failed' => 'No hay conexión a internet.',
        'requires-recent-login' => 'Por seguridad, sal, vuelve a entrar y entonces borra tu cuenta.',
        'missing-email' => 'Escribe tu correo.',
        _ => 'No se pudo entrar: ${e.message ?? e.code}',
      });
    } on FirebaseException catch (e) {
      throw CloudException(switch (e.code) {
        'permission-denied' => 'No tienes permiso para hacer eso.',
        'unavailable' => 'No hay conexión con el servidor. Intenta de nuevo.',
        _ => 'Algo falló en el servidor: ${e.message ?? e.code}',
      });
    }
  }
}
