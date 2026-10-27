import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayudas.dart';

Future<ViewSettings> _abre(WidgetTester tester, {Size size = const Size(400, 800)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3});
  final prefs = await SharedPreferences.getInstance();
  final settings = ViewSettings(prefs);
  await tester.pumpWidget(JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: settings));
  await tester.pumpAndSettle();
  return settings;
}

/// Answers the question on screen: taps the option with this text (or the
/// figure, or the lines in order) and checks it.
Future<void> _responde(WidgetTester tester, Question q, {required bool bien}) async {
  switch (q) {
    case ChoiceQuestion():
      final i = bien ? q.answer : (q.answer + 1) % q.options.length;
      await tester.tap(find.text(q.options[i]).last);
    case FigureQuestion():
      final figura = bien ? q.answer : Figure.values[(q.answer.index + 1) % Figure.values.length];
      await tester.tap(find.byKey(ValueKey(figura)));
    case OrderQuestion():
      final lines = bien ? q.lines : q.lines.reversed.toList();
      for (final line in lines) {
        await tester.tap(find.text(line.trim()).last);
        await tester.pump();
      }
    case FindErrorQuestion():
      final i = bien ? q.errorLine : (q.errorLine + 1) % q.lines.length;
      await tester.tap(find.text(q.lines[i]).last);
  }
  await tester.pump();
  await tester.tap(find.text('Comprobar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('una lección completa: preguntas, explicación, resultado y queda hecha', (tester) async {
    final settings = await _abre(tester);
    await irASala(tester, 'Ruta');
    await tester.tap(find.text('Tu primer programa'));
    await tester.pumpAndSettle();

    final preguntas = lessonFirstProgram.questions;
    for (final (i, q) in preguntas.indexed) {
      expect(find.text(q.prompt), findsOneWidget, reason: 'pregunta ${i + 1}');
      expect(find.text('Comprobar'), findsOneWidget);
      await _responde(tester, q, bien: true);
      expect(find.text('¡Correcto!'), findsOneWidget);
      expect(find.text(q.right), findsOneWidget);
      await tester.tap(find.text(i == preguntas.length - 1 ? 'Terminar' : 'Continuar'));
      await tester.pumpAndSettle();
    }

    expect(find.text('¡Lección completa!'), findsOneWidget);
    expect(find.text('${preguntas.length} de ${preguntas.length}'), findsOneWidget);
    expect(settings.doneLessons, {lessonFirstProgram.id});

    // "Seguir con" lleva al reto 1 (el siguiente paso de la ruta).
    expect(find.text('Ver tu ruta'), findsOneWidget);
    await tester.tap(find.textContaining('Seguir con:'));
    await tester.pumpAndSettle();
    expect(find.text('Ruta · Nivel 1 · Reto 1'), findsOneWidget);
  });

  testWidgets('una respuesta mala explica por qué y la pregunta vuelve al final', (tester) async {
    await _abre(tester);
    await irASala(tester, 'Ruta');
    await tester.tap(find.text('Tu primer programa'));
    await tester.pumpAndSettle();

    final q = lessonFirstProgram.questions.first;
    await _responde(tester, q, bien: false);
    expect(find.text('Casi'), findsOneWidget);
    expect(find.text(q.wrong), findsOneWidget);

    // Las demás bien; al final regresa la que falló, y esa vez no cuenta como acierto a la primera.
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    for (final other in lessonFirstProgram.questions.skip(1)) {
      await _responde(tester, other, bien: true);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }
    expect(find.text(q.prompt), findsOneWidget);
    await _responde(tester, q, bien: true);
    await tester.tap(find.text('Terminar'));
    await tester.pumpAndSettle();
    expect(find.text('4 de 5'), findsOneWidget);
  });

  testWidgets('las preguntas de figuras y de ordenar se pueden responder', (tester) async {
    await _abre(tester);
    await irASala(tester, 'Ruta');
    await tester.scrollUntilVisible(find.text('Diagramas de flujo'), 200);
    await tester.ensureVisible(find.text('Diagramas de flujo'));
    await tester.pumpAndSettle();
    // Fuera de la barra de arriba, donde sí se puede tocar.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 250));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diagramas de flujo'));
    await tester.pumpAndSettle();
    final figura = lessonFlowcharts.questions.first as FigureQuestion;
    await _responde(tester, figura, bien: true);
    expect(find.text(figura.right), findsOneWidget);
  });

  testWidgets('las lecciones sirven también en pantalla ancha', (tester) async {
    await _abre(tester, size: const Size(1400, 900));
    // Con la riel a un lado: Ruta abre la ruta, no el editor.
    await irASala(tester, 'Ruta');
    expect(find.text('Primeros pasos'), findsOneWidget);
    await tester.tap(find.text('Tu primer programa'));
    await tester.pumpAndSettle();
    expect(find.text(lessonFirstProgram.questions.first.prompt), findsOneWidget);
  });
}
