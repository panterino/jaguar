import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/cloud_backend.dart';
import 'package:jaguar/src/cloud/firebase_rest.dart';
import 'package:jaguar/src/cloud/rest_backend.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Jaguar online against the real thing: the Firebase emulators (Authentication
/// and Firestore) with the rules of `firestore.rules`. Run it with
/// `tool/probar_nube.sh`. Without the emulators, these tests are skipped.
const _project = 'demo-jaguar';

Future<bool> _listening(int port) async {
  try {
    final socket = await Socket.connect('127.0.0.1', port, timeout: const Duration(milliseconds: 500));
    socket.destroy();
    return true;
  } on Object {
    return false;
  }
}

/// A person with their own session on their own "device".
class _Person {
  _Person(this.rest, this.backend, this.prefs);

  final FirebaseRest rest;
  final RestBackend backend;
  final SharedPreferences prefs;

  static Future<_Person> device() async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final rest = FirebaseRest.emulator(projectId: _project);
    return _Person(rest, RestBackend(rest, prefs), prefs);
  }
}

var _counter = 0;
String _email() => 'profe${DateTime.now().microsecondsSinceEpoch}_${_counter++}@correo.mx';

const _exercise = Exercise(
  id: 'ej-1',
  title: 'Doble de un número',
  statement: 'Pide un número y muestra su doble.',
  cases: [
    TestCase(inputs: ['2'], expected: '4'),
    TestCase(inputs: ['0'], expected: '0', hidden: true),
  ],
);

void main() {
  late bool emulators;

  setUpAll(() async {
    emulators = await _listening(8080) && await _listening(9099);
  });

  void online(String name, Future<void> Function() body) {
    test(name, () async {
      if (!emulators) {
        markTestSkipped('Sin emuladores: corre tool/probar_nube.sh');
        return;
      }
      await body();
    }, timeout: const Timeout(Duration(seconds: 60)));
  }

  Future<CloudException> failure(Future<Object?> Function() action) async {
    try {
      await action();
    } on CloudException catch (e) {
      return e;
    }
    fail('Se esperaba un CloudException');
  }

  group('cuentas', () {
    online('un profe se registra, sale y vuelve a entrar con su correo', () async {
      final email = _email();
      final device = await _Person.device();
      final teacher = await device.backend.registerTeacher(email: email, password: 'secreto1', alias: 'Profe Ana');
      expect(teacher.role, CloudRole.profesor);
      expect(teacher.alias, 'Profe Ana');
      expect(teacher.email, email);

      await device.backend.signOut();
      expect(device.backend.currentUser, isNull);
      expect(device.prefs.getString('jaguar.cloud.session'), isNull);

      final again = await device.backend.signInTeacher(email: email, password: 'secreto1');
      expect(again.uid, teacher.uid);
      expect(again.alias, 'Profe Ana');
    });

    online('los errores de cuenta salen en español', () async {
      final email = _email();
      final device = await _Person.device();
      await device.backend.registerTeacher(email: email, password: 'secreto1', alias: 'Ana');

      final other = await _Person.device();
      expect(
        (await failure(() => other.backend.registerTeacher(email: email, password: 'secreto1', alias: 'X'))).message,
        contains('Ya hay una cuenta'),
      );
      expect(
        (await failure(() => other.backend.signInTeacher(email: email, password: 'mala-clave'))).message,
        'El correo o la contraseña no coinciden.',
      );
      expect(
        (await failure(() => other.backend.registerTeacher(email: _email(), password: '123', alias: 'X'))).message,
        contains('muy corta'),
      );
      expect(
        (await failure(
          () => other.backend.registerTeacher(email: 'no-es-correo', password: 'secreto1', alias: 'X'),
        )).message,
        contains('no parece válido'),
      );
    });

    online('la sesión se restaura al abrir la app otra vez', () async {
      final device = await _Person.device();
      final student = await device.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);

      final reopened = FirebaseRest.emulator(projectId: _project);
      final backend = RestBackend(reopened, device.prefs);
      final restored = await backend.restore();
      expect(restored?.uid, student.uid);
      expect(restored?.alias, 'Luis');
      expect(restored?.role, CloudRole.alumno);
    });

    online('una sesión que ya no existe se descarta sin error', () async {
      final device = await _Person.device();
      await device.prefs.setString('jaguar.cloud.session', 'token-que-no-sirve');
      expect(await device.backend.restore(), isNull);
      expect(device.prefs.getString('jaguar.cloud.session'), isNull);
    });
  });

  group('clases', () {
    online('la clase completa: crear, unirse, asignar, entregar y revisar', () async {
      final teacherDevice = await _Person.device();
      await teacherDevice.backend.registerTeacher(email: _email(), password: 'secreto1', alias: 'Profe Ana');
      final room = await teacherDevice.backend.createClass('Lógica 1A');
      expect(room.name, 'Lógica 1A');
      expect(room.code, matches(RegExp(r'^JAG-[A-Z0-9]{4,8}$')));
      expect((await teacherDevice.backend.myClasses()).map((c) => c.id), [room.id]);

      final studentDevice = await _Person.device();
      await studentDevice.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      final joined = await studentDevice.backend.joinClass(code: room.code.toLowerCase(), name: 'Luis');
      expect(joined.id, room.id);
      expect((await studentDevice.backend.myClasses()).map((c) => c.id), [room.id]);
      expect((await teacherDevice.backend.members(room.id)).map((m) => m.name), ['Luis']);

      final assignment = await teacherDevice.backend.assign(room.id, _exercise);
      final seen = await studentDevice.backend.assignments(room.id);
      expect(seen.single.exercise.title, 'Doble de un número');
      expect(seen.single.exercise.cases, hasLength(2));

      await studentDevice.backend.submit(
        classId: room.id,
        assignmentId: assignment.id,
        name: 'Luis',
        source: 'Algoritmo a\n    Leer n\n    Escribir n * 2\nFinAlgoritmo',
        passed: 1,
        total: 2,
        pastedLines: 3,
      );
      final all = await teacherDevice.backend.submissions(room.id, assignment.id);
      expect(all, hasLength(1));
      final entry = all.values.single;
      expect(entry.name, 'Luis');
      expect(entry.passed, 1);
      expect(entry.total, 2);
      expect(entry.pastedLines, 3);
      expect(entry.updatedAt, isNotNull, reason: 'la hora la pone el servidor');
      expect((await studentDevice.backend.mySubmission(room.id, assignment.id))?.passed, 1);

      // Rewriting the submission keeps one entry.
      await studentDevice.backend.submit(
        classId: room.id,
        assignmentId: assignment.id,
        name: 'Luis',
        source: 'Algoritmo a\nFinAlgoritmo',
        passed: 2,
        total: 2,
      );
      expect((await teacherDevice.backend.submissions(room.id, assignment.id)).values.single.passed, 2);

      await teacherDevice.backend.removeAssignment(room.id, assignment.id);
      expect(await studentDevice.backend.assignments(room.id), isEmpty);
    });

    online('un código que no existe se dice claro', () async {
      final device = await _Person.device();
      await device.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      expect(
        (await failure(() => device.backend.joinClass(code: 'JAG-ZZZZ', name: 'Luis'))).message,
        contains('No existe ninguna clase'),
      );
    });

    online('quien no es de la clase no ve nada de ella', () async {
      final teacherDevice = await _Person.device();
      await teacherDevice.backend.registerTeacher(email: _email(), password: 'secreto1', alias: 'Profe Ana');
      final room = await teacherDevice.backend.createClass('Privada');
      final assignment = await teacherDevice.backend.assign(room.id, _exercise);

      final stranger = await _Person.device();
      await stranger.backend.signInAnonymously(alias: 'Intruso', role: CloudRole.alumno);
      expect((await failure(() => stranger.backend.assignments(room.id))).message, 'No tienes permiso para hacer eso.');
      expect((await failure(() => stranger.backend.members(room.id))).message, 'No tienes permiso para hacer eso.');
      expect(
        (await failure(
          () => stranger.backend.submit(
            classId: room.id,
            assignmentId: assignment.id,
            name: 'X',
            source: 's',
            passed: 1,
            total: 1,
          ),
        )).message,
        'No tienes permiso para hacer eso.',
      );
    });
  });

  group('comunidad', () {
    online('publicar, dar «me sirvió», reportar y retirar', () async {
      final author = await _Person.device();
      await author.backend.signInAnonymously(alias: 'Ana', role: CloudRole.autodidacta);
      final publication = await author.backend.publish(
        kind: PublicationKind.programa,
        title: 'Tabla del 7',
        description: 'Muestra la tabla',
        topic: 'ciclos',
        content: {'source': 'Algoritmo t\nFinAlgoritmo', 'n': 7},
      );
      expect(publication.title, 'Tabla del 7');
      expect(publication.content['n'], 7);
      expect(publication.createdAt, isNotNull);
      expect((await author.backend.myPublications()).map((p) => p.id), [publication.id]);

      final reader = await _Person.device();
      await reader.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      final listed = await reader.backend.publications(kind: PublicationKind.programa);
      expect(listed.map((p) => p.id), contains(publication.id));
      expect(
        (await reader.backend.publications(kind: PublicationKind.tutorial)).map((p) => p.id),
        isNot(contains(publication.id)),
      );

      expect(await reader.backend.usefulCount(publication.id), 0);
      expect(await reader.backend.isUseful(publication.id), isFalse);
      await reader.backend.setUseful(publication.id, useful: true);
      expect(await reader.backend.isUseful(publication.id), isTrue);
      expect(await reader.backend.usefulCount(publication.id), 1);
      await reader.backend.setUseful(publication.id, useful: false);
      expect(await reader.backend.usefulCount(publication.id), 0);

      await reader.backend.report(publication.id, 'Contenido que no va');

      expect(
        (await failure(() => reader.backend.unpublish(publication.id))).message,
        'No tienes permiso para hacer eso.',
      );
      await author.backend.unpublish(publication.id);
      expect((await reader.backend.publications()).map((p) => p.id), isNot(contains(publication.id)));
    });
  });

  group('borrar la cuenta', () {
    online('se lleva todo lo suyo: su lugar en la clase, su entrega y sus publicaciones', () async {
      final teacher = await _Person.device();
      await teacher.backend.registerTeacher(email: _email(), password: 'secreto1', alias: 'Profe Ana');
      final room = await teacher.backend.createClass('Clase');
      final assignment = await teacher.backend.assign(room.id, _exercise);

      final student = await _Person.device();
      await student.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      await student.backend.joinClass(code: room.code, name: 'Luis');
      await student.backend.submit(
        classId: room.id,
        assignmentId: assignment.id,
        name: 'Luis',
        source: 's',
        passed: 1,
        total: 2,
      );
      final publication = await student.backend.publish(
        kind: PublicationKind.programa,
        title: 'Mío',
        description: '',
        topic: '',
        content: {'source': 's'},
      );

      await student.backend.deleteAccount();
      expect(student.backend.currentUser, isNull);
      expect(student.prefs.getString('jaguar.cloud.session'), isNull);

      expect(await teacher.backend.members(room.id), isEmpty);
      expect(await teacher.backend.submissions(room.id, assignment.id), isEmpty);
      final reader = await _Person.device();
      await reader.backend.signInAnonymously(alias: 'Ana', role: CloudRole.autodidacta);
      expect((await reader.backend.publications()).map((p) => p.id), isNot(contains(publication.id)));
    });

    online('un profe que borra su cuenta se lleva su clase completa', () async {
      final teacher = await _Person.device();
      await teacher.backend.registerTeacher(email: _email(), password: 'secreto1', alias: 'Profe Ana');
      final room = await teacher.backend.createClass('Clase');
      final assignment = await teacher.backend.assign(room.id, _exercise);

      final student = await _Person.device();
      await student.backend.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      await student.backend.joinClass(code: room.code, name: 'Luis');
      await student.backend.submit(
        classId: room.id,
        assignmentId: assignment.id,
        name: 'Luis',
        source: 's',
        passed: 1,
        total: 2,
      );

      await teacher.backend.deleteAccount();

      // The code no longer opens anything.
      final late = await _Person.device();
      await late.backend.signInAnonymously(alias: 'Tarde', role: CloudRole.alumno);
      expect(
        (await failure(() => late.backend.joinClass(code: room.code, name: 'Tarde'))).message,
        contains('No existe ninguna clase'),
      );
    });
  });
}
