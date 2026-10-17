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
    expect(newClassCode(), matches(RegExp(r'^JAG-[A-HJ-NP-Z2-9]{4}$')));
    expect(normalizeClassCode('jag 4k7q'), 'JAG-4K7Q');
    expect(normalizeClassCode('4k7q'), 'JAG-4K7Q');
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
}
