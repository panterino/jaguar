import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/class_qr.dart';
import 'package:jaguar/src/cloud/cloud_backend.dart';
import 'package:jaguar/src/cloud/classes_screen.dart';
import 'package:jaguar/src/cloud/grades.dart';
import 'package:jaguar/src/share/share_codec.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _task = Exercise(
  id: 't1',
  title: 'Par o impar',
  statement: '',
  cases: [
    TestCase(inputs: ['2'], expected: 'par'),
  ],
);

Assignment _assignment(String id, String title) => Assignment(
  id: id,
  classId: 'c',
  exercise: Exercise(id: id, title: title, statement: '', cases: _task.cases),
);

void main() {
  joinByLinkTests();
  test('el enlace de una clase se lee con el código y se rechaza lo raro', () {
    final link = classLink('JAG-K7Q4M2XP');
    expect(link, startsWith(shareBaseUrl));
    expect((contentFromLink(link)! as SharedClass).code, 'JAG-K7Q4M2XP');
    expect((contentFromLink('https://app.jaguarcode.org/#c=jag-k7q4')! as SharedClass).code, 'JAG-K7Q4');
    expect(contentFromLink('https://app.jaguarcode.org/#c='), isNull);
    expect(contentFromLink('https://app.jaguarcode.org/#c=<script>'), isNull);
  });

  group('calificaciones', () {
    final table = GradesTable(
      assignments: [_assignment('a', 'Par o impar'), _assignment('b', 'Suma, "doble"')],
      members: const [
        Member(uid: 'u1', name: 'Ana'),
        Member(uid: 'u2', name: 'Beto'),
      ],
      submissions: {
        'a': {
          'u1': const Submission(uid: 'u1', name: 'Ana', source: '', passed: 4, total: 4),
          'u2': const Submission(uid: 'u2', name: 'Beto', source: '', passed: 1, total: 4),
        },
        'b': {'u1': const Submission(uid: 'u1', name: 'Ana', source: '', passed: 2, total: 3)},
      },
    );

    test('CSV con BOM, comillas escapadas y sin fechas falsas', () {
      final csv = table.toCsv();
      expect(csv, startsWith('﻿"Alumno","Par o impar","Suma, ""doble""","Tareas completas","Avance"'));
      expect(csv, contains('"Ana","4 de 4","2 de 3",1,50 %'));
      expect(csv, contains('"Beto","1 de 4","",0,0 %'));
      expect(csv, isNot(contains('4/4')));
    });

    test('TSV para pegar en una hoja', () {
      expect(table.toTsv().split('\n')[1], 'Ana\t4 de 4\t2 de 3\t1\t50 %');
    });

    testWidgets('el diálogo muestra la tabla con sus colores y las dos salidas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showGrades(context, className: '3A', table: table),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Calificaciones'), findsOneWidget);
      expect(find.text('4 de 4'), findsOneWidget);
      expect(find.text('Descargar para Excel'), findsOneWidget);
      expect(find.text('Copiar'), findsOneWidget);
    });
  });

  testWidgets('el QR de la clase lleva el enlace y el código a la vista', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showClassQr(context, className: '3A', code: 'JAG-K7Q4M2XP'),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('JAG-K7Q4M2XP'), findsOneWidget);
  });

  testWidgets('unirse con un QR deja el código escrito', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => askJoinCode(context, code: 'JAG-ABCD1234'),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('JAG-ABCD1234'), findsOneWidget);
  });
}

void joinByLinkTests() {
  testWidgets('con el enlace de una clase no se pregunta cómo quieres usar Jaguar: se va a unirse', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      JaguarApp(
        store: ProgramStore(prefs),
        exercises: ExerciseStore(prefs),
        settings: ViewSettings(prefs),
        cloud: Cloud(MemoryBackend(), prefs),
        joinCode: 'JAG-ABCD1234',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('¡Hola! Esto es Jaguar Code'), findsNothing, reason: 'no hay bienvenida genérica');
    // Without an account the first thing is to come in; the code waits.
    expect(find.text('Entrar a Jaguar Code en línea'), findsOneWidget);
    expect(ViewSettings(prefs).teacher, isFalse);
    expect(ViewSettings(prefs).chosenMode, isNotNull, reason: 'queda elegido el modo básico');
  });
}
