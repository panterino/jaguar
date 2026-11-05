import 'package:flutter_test/flutter_test.dart';
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
