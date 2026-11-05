import 'dart:math' as math;

import 'package:jaguar_core/jaguar_core.dart';

/// Who is using Jaguar online. Students and self-learners use an
/// anonymous account with an alias (no email); teachers sign in with email
/// so their classes are not lost.
enum CloudRole { alumno, profesor, autodidacta }

class CloudUser {
  const CloudUser({required this.uid, required this.alias, required this.role, this.email});

  final String uid;
  final String alias;
  final CloudRole role;

  /// Only teachers have one.
  final String? email;

  bool get isTeacher => role == CloudRole.profesor;
}

class ClassRoom {
  const ClassRoom({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerId,
    required this.ownerAlias,
    this.open = true,
  });

  final String id;
  final String name;

  /// What students type to join, like `JAG-K7Q4M2XP` (older classes have
  /// shorter ones, like `JAG-4K7Q`).
  final String code;
  final String ownerId;
  final String ownerAlias;

  /// A closed class takes no new students; the ones already in stay.
  final bool open;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'ownerId': ownerId,
    'ownerAlias': ownerAlias,
    'open': open,
  };

  factory ClassRoom.fromJson(Map<String, Object?> json) => ClassRoom(
    id: json['id']! as String,
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    ownerId: json['ownerId'] as String? ?? '',
    ownerAlias: json['ownerAlias'] as String? ?? '',
    open: json['open'] != false,
  );
}

class Member {
  const Member({required this.uid, required this.name});

  final String uid;
  final String name;
}

class Assignment {
  const Assignment({
    required this.id,
    required this.classId,
    required this.exercise,
    this.createdAt,
    this.hiddenCount = 0,
  });

  final String id;
  final String classId;

  /// What the person who asks gets: the teacher, every test; a student, only
  /// the visible ones (the hidden ones never leave the teacher's side).
  final Exercise exercise;
  final DateTime? createdAt;

  /// How many hidden tests the assignment has. A student sees only the number.
  final int hiddenCount;

  String get title => exercise.title;

  Map<String, Object?> toJson() => {
    'id': id,
    'classId': classId,
    'exercise': exercise.toJson(),
    if (createdAt != null) 'createdAt': createdAt!.millisecondsSinceEpoch,
    if (hiddenCount > 0) 'hiddenCount': hiddenCount,
  };

  factory Assignment.fromJson(Map<String, Object?> json) => Assignment(
    id: json['id']! as String,
    classId: json['classId']! as String,
    exercise: Exercise.fromJson((json['exercise']! as Map).cast<String, Object?>()),
    createdAt: json['createdAt'] is num
        ? DateTime.fromMillisecondsSinceEpoch((json['createdAt']! as num).toInt())
        : null,
    hiddenCount: (json['hiddenCount'] as num?)?.toInt() ?? 0,
  );
}

class Submission {
  const Submission({
    required this.uid,
    required this.name,
    required this.source,
    required this.passed,
    required this.total,
    this.updatedAt,
    this.pastedLines = 0,
  });

  final String uid;
  final String name;
  final String source;
  final int passed;
  final int total;
  final DateTime? updatedAt;

  /// The most lines the student pasted at once while writing it.
  final int pastedLines;

  bool get complete => total > 0 && passed == total;
}

enum PublicationKind { programa, ejercicio, tutorial }

/// Something shared with the community: a program anyone can open, try
/// and remix, or an exercise for the shared bank.
class Publication {
  const Publication({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.topic,
    required this.authorId,
    required this.authorAlias,
    required this.content,
    this.remixOf,
    this.createdAt,
  });

  final String id;
  final PublicationKind kind;
  final String title;
  final String description;
  final String topic;
  final String authorId;
  final String authorAlias;

  /// `{source: ...}` for a program, `{exercise: {...}}` for an exercise.
  final Map<String, Object?> content;
  final String? remixOf;
  final DateTime? createdAt;

  String? get source => content['source'] as String?;

  Exercise? get exercise {
    final json = content['exercise'];
    return json is Map ? Exercise.fromJson(json.cast<String, Object?>()) : null;
  }
}

/// The topics of the original Jaguar plan, to file publications under.
const topics = [
  'Secuencia',
  'Variables y operaciones',
  'Entrada y salida',
  'Condiciones',
  'Ciclos',
  'Arreglos',
  'Funciones',
  'Textos',
  'Juegos',
  'Matemáticas',
  'Proyectos',
];

class CloudException implements Exception {
  const CloudException(this.message, {this.offline = false});

  final String message;

  /// There was no connection (or no way to reach the server): the work is not
  /// lost, it can be sent later. Anything else is a refusal or a failure.
  final bool offline;

  @override
  String toString() => message;
}

/// Everything Jaguar does online. [FirebaseBackend] talks to Firebase;
/// [MemoryBackend] keeps it all in memory, for tests.
abstract class CloudBackend {
  CloudUser? get currentUser;

  /// Restores the session of a previous visit, if any.
  Future<CloudUser?> restore();

  Future<CloudUser> signInAnonymously({required String alias, required CloudRole role});
  Future<CloudUser> signInTeacher({required String email, required String password});
  Future<CloudUser> registerTeacher({required String email, required String password, required String alias});
  Future<void> signOut();

  /// Sends the teacher an email to choose a new password.
  Future<void> resetPassword(String email);

  /// Deletes the account and what it left online: profile, publications,
  /// its place in classes and its submissions; for a teacher, also the
  /// classes they created. Programs on the device are not touched.
  Future<void> deleteAccount();

  // Classes.
  Future<ClassRoom> createClass(String name);

  /// Closes the class to new students, or opens it again. Only its teacher.
  Future<void> setClassOpen(String classId, {required bool open});
  Future<ClassRoom> joinClass({required String code, required String name});
  Future<List<ClassRoom>> myClasses();
  Future<List<Member>> members(String classId);

  // Assignments and submissions.
  Future<List<Assignment>> assignments(String classId);
  Future<Assignment> assign(String classId, Exercise exercise);
  Future<void> removeAssignment(String classId, String assignmentId);

  /// The teacher takes a student out of the class, with their submissions.
  Future<void> removeMember(String classId, String uid);
  Future<void> submit({
    required String classId,
    required String assignmentId,
    required String name,
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  });
  Future<Map<String, Submission>> submissions(String classId, String assignmentId);
  Future<Submission?> mySubmission(String classId, String assignmentId);

  // Community.
  Future<List<Publication>> publications({PublicationKind? kind});
  Future<List<Publication>> myPublications();
  Future<Publication> publish({
    required PublicationKind kind,
    required String title,
    required String description,
    required String topic,
    required Map<String, Object?> content,
    String? remixOf,
  });
  Future<void> unpublish(String publicationId);
  Future<int> usefulCount(String publicationId);
  Future<bool> isUseful(String publicationId);
  Future<void> setUseful(String publicationId, {required bool useful});
  Future<void> report(String publicationId, String reason);
}

const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/// A class code easy to read aloud and to copy from the board: no 0/O, 1/I/L.
/// Eight characters, so it cannot be found by trying them one by one (the
/// first ones were four).
String newClassCode([math.Random? random, int length = 8]) {
  final r = random ?? math.Random.secure();
  return 'JAG-${List.generate(length, (_) => _codeAlphabet[r.nextInt(_codeAlphabet.length)]).join()}';
}

/// An exercise split in what students may see and what only the teacher may:
/// its hidden tests (see `firestore.rules`, `hiddenCases`).
({Exercise visible, List<TestCase> hidden}) splitHiddenCases(Exercise exercise) => (
  visible: Exercise(
    id: exercise.id,
    title: exercise.title,
    statement: exercise.statement,
    mode: exercise.mode,
    revision: exercise.revision,
    cases: [
      for (final c in exercise.cases)
        if (!c.hidden) c,
    ],
  ),
  hidden: [
    for (final c in exercise.cases)
      if (c.hidden) c,
  ],
);

/// The whole exercise again, for the teacher: the visible tests, then the hidden ones.
Exercise withHiddenCases(Exercise visible, List<TestCase> hidden) => Exercise(
  id: visible.id,
  title: visible.title,
  statement: visible.statement,
  mode: visible.mode,
  revision: visible.revision,
  cases: [...visible.cases, ...hidden],
);

/// Codes are typed by hand: accept `jag4k7q`, `JAG 4K7Q`, `4k7q`.
String normalizeClassCode(String input) {
  final letters = input.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  final tail = letters.startsWith('JAG') ? letters.substring(3) : letters;
  return 'JAG-$tail';
}
