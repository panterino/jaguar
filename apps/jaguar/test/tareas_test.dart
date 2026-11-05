import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jaguar/src/cloud/cloud_backend.dart';
import 'package:jaguar/src/cloud/firebase_rest.dart';
import 'package:jaguar/src/cloud/rest_backend.dart';
import 'package:jaguar/src/cloud/task_store.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _task = Exercise(
  id: 'par',
  title: 'Par o impar',
  statement: 'Di si es par.',
  cases: [
    TestCase(inputs: ['2'], expected: 'par'),
  ],
);

void main() {
  _extra();
  const source = 'Algoritmo p\n    Leer n\n    Escribir "par"\nFinAlgoritmo\n';

  Future<(Cloud, MemoryBackend, Assignment)> setup() async {
    SharedPreferences.setMockInitialValues({});
    final backend = MemoryBackend();
    final cloud = Cloud(backend, await SharedPreferences.getInstance());
    final teacher = await cloud.registerTeacher(email: 'p@e.mx', password: 'secreto', alias: 'Profa');
    final room = await cloud.createClass('3A');
    final assignment = await backend.assign(room.id, _task);
    backend.actAs(null);
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await cloud.joinClass(code: room.code, name: 'Ana');
    expect(teacher.isTeacher, isTrue);
    await cloud.syncClasses();
    return (cloud, backend, assignment);
  }

  test('una tarea sin entregar aparece pendiente, y entregada deja de avisar', () async {
    final (cloud, backend, assignment) = await setup();
    final uid = cloud.user!.uid;
    expect(cloud.tasks.pending(uid), hasLength(1));

    cloud.linkAssignment(_task, assignment, className: '3A');
    final result = await checkSolution(source, _task);
    cloud.tasks.recordWork('par', source: source, passed: result.passedCount, total: 1);
    expect(cloud.tasks.pending(uid), hasLength(1), reason: 'probar no entrega');
    expect(await backend.mySubmission(assignment.classId, assignment.id), isNull);

    await cloud.deliver(exercise: _task, studentName: 'Ana', source: source, result: result);
    expect(cloud.tasks.pending(uid), isEmpty);
    expect(cloud.tasks.forExercise('par')!.stateFor(source), TaskState.delivered);
  });

  test('cambiar el programa después de entregar lo marca con cambios', () async {
    final (cloud, _, assignment) = await setup();
    cloud.linkAssignment(_task, assignment, className: '3A');
    final result = await checkSolution(source, _task);
    await cloud.deliver(exercise: _task, studentName: 'Ana', source: source, result: result);
    final record = cloud.tasks.forExercise('par')!;
    expect(record.stateFor('$source\n'), TaskState.delivered, reason: 'espacios al final no cuentan');
    expect(record.stateFor('${source}Escribir "x"\n'), TaskState.changed);
  });

  test('sin internet la entrega falla con aviso y el trabajo se queda', () async {
    final (cloud, backend, assignment) = await setup();
    cloud.linkAssignment(_task, assignment, className: '3A');
    final result = await checkSolution(source, _task);
    cloud.tasks.recordWork('par', source: source, passed: 1, total: 1);

    backend.offline = true;
    await expectLater(
      cloud.deliver(exercise: _task, studentName: 'Ana', source: source, result: result),
      throwsA(isA<CloudException>().having((e) => e.offline, 'offline', isTrue)),
    );
    final record = cloud.tasks.forExercise('par')!;
    expect(record.deliveredAt, isNull);
    expect(record.source, source);
    // The copy of the classes still works with no internet.
    expect(await cloud.syncClasses(), isFalse);
    expect(cloud.tasks.cachedClasses(cloud.user!.uid), hasLength(1));

    backend.offline = false;
    await cloud.deliver(exercise: _task, studentName: 'Ana', source: source, result: result);
    expect(cloud.tasks.forExercise('par')!.deliveredAt, isNotNull);
  });

  test('una entrega hecha desde otro aparato se reconoce al sincronizar', () async {
    final (cloud, backend, assignment) = await setup();
    await backend.submit(
      classId: assignment.classId,
      assignmentId: assignment.id,
      name: 'Ana',
      source: source,
      passed: 1,
      total: 1,
    );
    await cloud.syncClasses();
    expect(cloud.tasks.pending(cloud.user!.uid), isEmpty);
  });
}

void _extra() {
  test('sin internet la sesión se conserva con quien era, sin pedir entrar otra vez', () async {
    SharedPreferences.setMockInitialValues({
      'jaguar.cloud.session': 'token-guardado',
      'jaguar.cloud.profile': '{"uid":"u1","alias":"Luis","role":"alumno","email":null}',
    });
    final prefs = await SharedPreferences.getInstance();
    final offline = MockClient((_) async => throw http.ClientException('sin red'));
    final backend = RestBackend(FirebaseRest(apiKey: 'k', projectId: 'p', client: offline), prefs);
    final user = await backend.restore();
    expect(user?.uid, 'u1');
    expect(user?.alias, 'Luis');
    expect(backend.currentUser?.role, CloudRole.alumno);
  });

  test('sin internet y sin nadie guardado, no hay sesión inventada', () async {
    SharedPreferences.setMockInitialValues({'jaguar.cloud.session': 'token-guardado'});
    final prefs = await SharedPreferences.getInstance();
    final offline = MockClient((_) async => throw http.ClientException('sin red'));
    final backend = RestBackend(FirebaseRest(apiKey: 'k', projectId: 'p', client: offline), prefs);
    await expectLater(backend.restore(), throwsA(isA<FirebaseRestError>()));
    expect(backend.currentUser, isNull);
  });

  test('las pruebas que el alumno no ve se recuerdan con la tarea', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final tasks = TaskStore(prefs);
    tasks.open(
      Assignment(id: 'a', classId: 'c', exercise: _task, hiddenCount: 2),
      className: '3A',
    );
    expect(TaskStore(prefs).forExercise('par')!.hiddenCount, 2);
  });
}
