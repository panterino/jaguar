import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/files/psc_files.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/share/share_codec.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('los retos están etiquetados', () {
    test('cada reto tiene área, nivel, lenguaje, autor y licencia', () {
      for (final challenge in challenges) {
        expect(challenge.subject, isNotEmpty, reason: challenge.id);
        expect(challenge.level, inInclusiveRange(1, 5), reason: challenge.id);
        expect(challenge.languages, contains('Pseudocódigo'), reason: challenge.id);
        expect(challenge.author, 'Jaguar');
        expect(challenge.license, 'CC BY-SA');
      }
    });

    test('las áreas son las del temario y todas tienen retos', () {
      final subjects = {for (final c in challenges) c.subject};
      expect(subjects, {'Variables', 'Operadores', 'Condicionales', 'Ciclos'});
    });
  });

  group('guardar todos los programas', () {
    test('un zip con un .psc por programa, con el nombre del algoritmo', () {
      final bytes = programsZipBytes([
        'Algoritmo suma\n    Escribir 1\nFinAlgoritmo\n',
        'Algoritmo resta\n    Escribir 2\nFinAlgoritmo\n',
      ], nameOf: programName);
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.files.map((f) => f.name), ['suma.psc', 'resta.psc']);
    });

    test('dos programas con el mismo nombre no se pisan', () {
      final bytes = programsZipBytes([
        'Algoritmo igual\n    Escribir 1\nFinAlgoritmo\n',
        'Algoritmo igual\n    Escribir 2\nFinAlgoritmo\n',
        'Algoritmo igual\n    Escribir 3\nFinAlgoritmo\n',
      ], nameOf: programName);
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.files.map((f) => f.name), ['igual.psc', 'igual_2.psc', 'igual_3.psc']);
    });

    test('el archivo se lee igual en PSeInt: saltos de línea de Windows', () {
      final bytes = programsZipBytes(['Algoritmo a\n    Escribir "á"\nFinAlgoritmo\n'], nameOf: programName);
      final content = ZipDecoder().decodeBytes(bytes).files.single.content as List<int>;
      expect(content.contains(13), isTrue); // \r
      expect(decodeSource(content), contains('Escribir "á"'));
    });
  });

  group('las direcciones nuevas', () {
    test('los enlaces nuevos salen de app.jaguarcode.org', () {
      expect(shareLink('Algoritmo a\nFinAlgoritmo\n'), startsWith('https://app.jaguarcode.org/#p='));
    });

    test('un enlace de la dirección vieja sigue abriendo el programa', () {
      final fragment = Uri.parse(shareLink('Algoritmo a\nFinAlgoritmo\n')).fragment;
      for (final host in ['jaguar-edu.web.app', 'app.jaguarcode.org', 'localhost:8080']) {
        final content = contentFromLink('https://$host/#$fragment');
        expect(content, isA<SharedProgram>(), reason: host);
        expect((content! as SharedProgram).source, contains('Algoritmo a'));
      }
    });
  });

  testWidgets('Clases muestra los ejercicios recibidos y no los retos', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3});
    final prefs = await SharedPreferences.getInstance();
    final exercises = ExerciseStore(prefs);
    exercises.saveReceived(challenges.first.exercise);
    exercises.saveReceived(
      const Exercise(
        id: 'tarea-1',
        title: 'Par o impar',
        statement: 'Di si un número es par.',
        cases: [TestCase(inputs: ['2'], expected: 'par')],
      ),
    );
    await tester.pumpWidget(JaguarApp(store: ProgramStore(prefs), exercises: exercises, settings: ViewSettings(prefs)));
    await tester.pumpAndSettle();

    // Inicio puts the teacher's exercise first.
    expect(find.text('DEL PROFE'), findsOneWidget);
    expect(find.text('Par o impar'), findsOneWidget);

    await tester.tap(find.text('Clases'));
    await tester.pumpAndSettle();
    expect(find.text('Par o impar'), findsOneWidget);
    expect(find.text('Reto 1 · Saludo'), findsNothing);
    expect(find.text('Clases en línea'), findsOneWidget);

    await tester.tap(find.text('Par o impar'));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
    expect(ProgramStore(prefs).programs.any((p) => p.exerciseId == 'tarea-1'), isTrue);
  });

  group('Clases con la nube', () {
    Future<(Cloud, MemoryBackend)> classWith(WidgetTester tester, {required bool asTeacher}) async {
      SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3});
      final prefs = await SharedPreferences.getInstance();
      final backend = MemoryBackend();
      final cloud = Cloud(backend, prefs);
      final teacher = await backend.registerTeacher(email: 'p@x.mx', password: 'secreto', alias: 'Martínez');
      final room = await backend.createClass('Programación 3A');
      await backend.assign(
        room.id,
        const Exercise(
          id: 'par',
          title: 'Par o impar',
          statement: 'Di si es par.',
          cases: [TestCase(inputs: ['2'], expected: 'par')],
        ),
      );
      if (asTeacher) return (cloud, backend);
      backend.actAs(null);
      await backend.signInAnonymously(alias: 'Leo', role: CloudRole.alumno);
      await backend.joinClass(code: room.code, name: 'Leo');
      expect(teacher.isTeacher, isTrue);
      return (cloud, backend);
    }

    testWidgets('el alumno ve su clase, la tarea y cuánto lleva', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (cloud, _) = await classWith(tester, asTeacher: false);
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: ViewSettings(prefs), cloud: cloud),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clases'));
      await tester.pumpAndSettle();

      expect(find.text('Programación 3A'), findsOneWidget);
      expect(find.text('Prof. Martínez'), findsOneWidget);
      expect(find.text('Par o impar'), findsOneWidget);
      expect(find.text('Sin empezar'), findsOneWidget);
      expect(find.text('Unirme con código'), findsOneWidget);

      // Opening the task goes to the editor, and Atrás returns to the room.
      await tester.tap(find.text('Par o impar'));
      await tester.pumpAndSettle();
      expect(find.text('Probar'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Programación 3A'), findsOneWidget);
    });

    testWidgets('el profe ve su clase con el código y puede crear otra', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (cloud, _) = await classWith(tester, asTeacher: true);
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: ViewSettings(prefs), cloud: cloud),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clases'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Tu clase · código JAG-'), findsOneWidget);
      expect(find.text('Ver entregas'), findsOneWidget);
      expect(find.text('Crear clase'), findsOneWidget);
      expect(find.text('Unirme con código'), findsNothing);
    });

    testWidgets('sin sesión invita a entrar', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3});
      final prefs = await SharedPreferences.getInstance();
      final cloud = Cloud(MemoryBackend(), prefs);
      await tester.pumpWidget(
        JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: ViewSettings(prefs), cloud: cloud),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clases'));
      await tester.pumpAndSettle();
      expect(find.text('Tus clases en línea'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
