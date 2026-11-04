import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/classes_screen.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const parImpar = Exercise(
  id: 'par',
  title: 'Par o impar',
  cases: [
    TestCase(inputs: ['8'], expected: '8 es par'),
    TestCase(inputs: ['7'], expected: '7 es impar'),
  ],
);

void main() {
  test('códigos de clase fáciles de dictar y de escribir', () {
    // Eight characters: too many to find by trying them one by one.
    expect(newClassCode(), matches(RegExp(r'^JAG-[A-HJ-NP-Z2-9]{8}$')));
    expect({for (var i = 0; i < 500; i++) newClassCode()}, hasLength(500));
    // The first classes had four, and their codes still work when typed.
    expect(normalizeClassCode('jag 4k7q'), 'JAG-4K7Q');
    expect(normalizeClassCode('4k7q'), 'JAG-4K7Q');
    expect(normalizeClassCode('jag k7q4 m2xp'), 'JAG-K7Q4M2XP');
  });

  test('los casos ocultos se quedan con el profesor y el alumno solo ve cuántos hay', () async {
    final backend = MemoryBackend();
    await backend.registerTeacher(email: 'profe@prepa.mx', password: 'secreto', alias: 'Profa');
    final room = await backend.createClass('1° A');
    const withHidden = Exercise(
      id: 'doble',
      title: 'Doble',
      cases: [
        TestCase(inputs: ['2'], expected: '4'),
        TestCase(inputs: ['0'], expected: '0', hidden: true),
        TestCase(inputs: ['-3'], expected: '-6', hidden: true),
      ],
    );
    final assignment = await backend.assign(room.id, withHidden);
    expect(assignment.hiddenCount, 2);

    // The teacher sees every test.
    final forTeacher = (await backend.assignments(room.id)).single;
    expect(forTeacher.exercise.cases, hasLength(3));
    expect(forTeacher.hiddenCount, 2);

    // A student gets the visible one and a number.
    final teacher = backend.currentUser!;
    await backend.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await backend.joinClass(code: room.code, name: 'Ana');
    final forStudent = (await backend.assignments(room.id)).single;
    expect(forStudent.exercise.cases, hasLength(1));
    expect(forStudent.exercise.cases.single.hidden, isFalse);
    expect(forStudent.hiddenCount, 2);
    expect(forStudent.exercise.toJson().toString(), isNot(contains('-6')));
    backend.actAs(teacher);
  });

  test('el profesor cierra la clase: nadie nuevo entra, quien ya estaba sigue', () async {
    final backend = MemoryBackend();
    final teacher = await backend.registerTeacher(email: 'profe@prepa.mx', password: 'secreto', alias: 'Profa');
    final room = await backend.createClass('1° A');
    expect(room.open, isTrue);

    await backend.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await backend.joinClass(code: room.code, name: 'Ana');

    backend.actAs(teacher);
    await backend.setClassOpen(room.id, open: false);
    expect((await backend.myClasses()).single.open, isFalse);

    await backend.signInAnonymously(alias: 'Beto', role: CloudRole.alumno);
    expect(
      () => backend.joinClass(code: room.code, name: 'Beto'),
      throwsA(isA<CloudException>().having((e) => e.message, 'message', contains('no está recibiendo alumnos nuevos'))),
    );
    // A student cannot open it again.
    expect(() => backend.setClassOpen(room.id, open: true), throwsA(isA<CloudException>()));

    backend.actAs(teacher);
    await backend.setClassOpen(room.id, open: true);
    await backend.signInAnonymously(alias: 'Beto', role: CloudRole.alumno);
    await backend.joinClass(code: room.code, name: 'Beto');
    backend.actAs(teacher);
    expect(await backend.members(room.id), hasLength(2));
  });

  test('la suite completa: el profesor asigna, el alumno prueba y el resultado llega', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backend = MemoryBackend();
    final cloud = Cloud(backend, prefs);

    // The teacher creates a class and assigns an exercise.
    final teacher = await cloud.registerTeacher(email: 'profe@prepa.mx', password: 'secreto', alias: 'Profa. López');
    final room = await cloud.createClass('1° A');
    final assignment = await backend.assign(room.id, parImpar);

    // A student joins with the code (typed loosely) and opens the task.
    final student = await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await cloud.joinClass(code: room.code.toLowerCase().replaceAll('-', ' '), name: 'Ana Pérez');
    final tasks = await backend.assignments(room.id);
    expect(tasks.single.title, 'Par o impar');
    cloud.linkAssignment(tasks.single.exercise, tasks.single);

    // Probar sends the result by itself.
    const source = 'Algoritmo p\n    Leer n\n    Escribir n, " es par"\nFinAlgoritmo\n';
    final result = await checkSolution(source, parImpar);
    final sent = await cloud.submitIfAssigned(
      exercise: parImpar,
      studentName: 'Ana Pérez',
      source: source,
      result: result,
    );
    expect(sent, isTrue);
    expect((await backend.mySubmission(room.id, assignment.id))!.passed, 1);

    // The teacher sees it; another student can't.
    backend.actAs(teacher);
    final submissions = await backend.submissions(room.id, assignment.id);
    expect(submissions[student.uid]!.name, 'Ana Pérez');
    expect(submissions[student.uid]!.source, source);
    expect((await backend.members(room.id)).single.name, 'Ana Pérez');
    await backend.signInAnonymously(alias: 'Beto', role: CloudRole.alumno);
    expect(() => backend.submissions(room.id, assignment.id), throwsA(isA<CloudException>()));
  });

  test('Probar no gasta una escritura cada vez que se aprieta', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backend = _CountingBackend();
    var clock = DateTime(2026, 11, 4, 10);
    final cloud = Cloud(backend, prefs, now: () => clock);
    await cloud.registerTeacher(email: 'profe@prepa.mx', password: 'secreto', alias: 'Profa');
    final room = await cloud.createClass('1° A');
    final assignment = await backend.assign(room.id, parImpar);
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await cloud.joinClass(code: room.code, name: 'Ana');
    cloud.linkAssignment(parImpar, assignment);

    const right = 'Algoritmo p\n    Leer n\n    Escribir n, " es par"\nFinAlgoritmo\n';
    final result = await checkSolution(right, parImpar);
    Future<void> press(String source, CheckResult r) =>
        cloud.submitIfAssigned(exercise: parImpar, studentName: 'Ana', source: source, result: r);

    await press(right, result);
    await press(right, result); // identical: nothing is sent
    expect(backend.submits, 1);

    clock = clock.add(const Duration(seconds: 5));
    await press('$right\n', result); // same result, text changed a moment ago
    expect(backend.submits, 1);

    clock = clock.add(minSend);
    await press('$right\n', result); // enough time has passed
    expect(backend.submits, 2);

    final worse = await checkSolution('Algoritmo p\nFinAlgoritmo\n', parImpar);
    await press('Algoritmo p\nFinAlgoritmo\n', worse); // another result: at once
    expect(backend.submits, 3);
  });

  test('olvidé mi contraseña y borrar la cuenta', () async {
    final backend = MemoryBackend();
    final teacher = await backend.registerTeacher(email: 'profe@escuela.mx', password: 'secreta', alias: 'Profa');
    final room = await backend.createClass('Lógica');
    await backend.signOut();
    await backend.resetPassword('profe@escuela.mx');
    expect(backend.passwordResets, ['profe@escuela.mx']);
    expect(() => backend.resetPassword('nadie@escuela.mx'), throwsA(isA<CloudException>()));

    final student = await backend.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await backend.joinClass(code: room.code, name: 'Ana');
    await backend.deleteAccount();
    expect(backend.currentUser, isNull);
    await backend.signInTeacher(email: 'profe@escuela.mx', password: 'secreta');
    expect((await backend.members(room.id)).map((m) => m.uid), isNot(contains(student.uid)));

    await backend.deleteAccount();
    expect(() => backend.signInTeacher(email: 'profe@escuela.mx', password: 'secreta'), throwsA(isA<CloudException>()));
    expect(teacher.isTeacher, isTrue);
  });

  test('un ejercicio que no viene de una clase no se envía', () async {
    SharedPreferences.setMockInitialValues({});
    final cloud = Cloud(MemoryBackend(), await SharedPreferences.getInstance());
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    final result = await checkSolution('Algoritmo a\nFinAlgoritmo', parImpar);
    expect(await cloud.submitIfAssigned(exercise: parImpar, studentName: 'Ana', source: '', result: result), isFalse);
  });

  test('comunidad: publicar, me sirvió y reportar', () async {
    final backend = MemoryBackend();
    await backend.signInAnonymously(alias: 'Ana', role: CloudRole.autodidacta);
    final p = await backend.publish(
      kind: PublicationKind.programa,
      title: 'Adivina',
      description: 'Juego',
      topic: 'Juegos',
      content: {'source': 'Algoritmo a\nFinAlgoritmo'},
    );
    await backend.signInAnonymously(alias: 'Beto', role: CloudRole.alumno);
    await backend.setUseful(p.id, useful: true);
    await backend.setUseful(p.id, useful: true);
    expect(await backend.usefulCount(p.id), 1);
    await backend.report(p.id, 'spam');
    expect(backend.reports.single.$2, 'spam');
    expect((await backend.publications(kind: PublicationKind.programa)).single.source, contains('Algoritmo'));
  });

  testWidgets('el alumno se une con el código desde la pantalla de clases', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backend = MemoryBackend();
    final cloud = Cloud(backend, prefs);
    await cloud.registerTeacher(email: 'p@x.mx', password: 'secreto', alias: 'Profe');
    final room = await cloud.createClass('1° A');
    await backend.assign(room.id, parImpar);
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);

    Assignment? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: ClassesScreen(
          cloud: cloud,
          exercises: ExerciseStore(prefs),
          onOpenAssignment: (a) => opened = a,
          onOpenSource: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Aún no estás en ninguna clase'), findsOneWidget);
    await tester.tap(find.text('Unirme con un código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Código de la clase'), room.code);
    await tester.enterText(find.widgetWithText(TextField, 'Tu nombre'), 'Ana Pérez');
    await tester.tap(find.text('Unirme'));
    await tester.pumpAndSettle();
    expect(find.text('Par o impar'), findsOneWidget);
    await tester.tap(find.text('Resolver'));
    await tester.pumpAndSettle();
    expect(opened?.title, 'Par o impar');
  });

  testWidgets('la clase muestra al alumno cuántas pruebas ocultas hay y el profesor la cierra', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backend = MemoryBackend();
    final cloud = Cloud(backend, prefs);
    final teacher = await cloud.registerTeacher(email: 'p@x.mx', password: 'secreto', alias: 'Profe');
    final room = await cloud.createClass('1° A');
    await backend.assign(
      room.id,
      const Exercise(
        id: 'doble',
        title: 'Doble',
        cases: [
          TestCase(inputs: ['2'], expected: '4'),
          TestCase(inputs: ['0'], expected: '0', hidden: true),
          TestCase(inputs: ['-3'], expected: '-6', hidden: true),
        ],
      ),
    );
    Future<void> open(ClassRoom r) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ClassScreen(
            cloud: cloud,
            room: r,
            exercises: ExerciseStore(prefs),
            onOpenAssignment: (_) {},
            onOpenSource: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // The teacher closes the class with the switch.
    await open(room);
    expect(find.text('Recibe alumnos nuevos'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Cerrada a alumnos nuevos'), findsOneWidget);
    expect((await backend.myClasses()).single.open, isFalse);

    // A student who is already in sees how many hidden tests the teacher reviews.
    backend.actAs(null);
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    backend.actAs(teacher);
    await backend.setClassOpen(room.id, open: true);
    await cloud.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
    await cloud.joinClass(code: room.code, name: 'Ana');
    await open(room);
    expect(find.textContaining('Tu profe revisa 2 pruebas más que no se ven'), findsOneWidget);
  });
}

const minSend = Cloud.minSendGap;

class _CountingBackend extends MemoryBackend {
  int submits = 0;

  @override
  Future<void> submit({
    required String classId,
    required String assignmentId,
    required String name,
    required String source,
    required int passed,
    required int total,
    int pastedLines = 0,
  }) {
    submits++;
    return super.submit(
      classId: classId,
      assignmentId: assignmentId,
      name: name,
      source: source,
      passed: passed,
      total: total,
      pastedLines: pastedLines,
    );
  }
}
