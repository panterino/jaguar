import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar/src/lessons/nivel1.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ayudas.dart';

void main() {
  group('la Ruta tiene forma', () {
    test('niveles, unidades y pasos con ids únicos y contenido', () {
      expect(routeLevels, isNotEmpty);
      expect(routeLevels.map((l) => l.id).toSet(), hasLength(routeLevels.length));
      for (final level in routeLevels) {
        expect(level.title, isNotEmpty, reason: level.id);
        expect(level.description, isNotEmpty, reason: level.id);
        expect(level.groups, isNotEmpty, reason: level.id);
        for (final group in level.groups) {
          expect(group.title, isNotEmpty);
          expect(group.description, isNotEmpty, reason: group.title);
          expect(group.steps, isNotEmpty, reason: group.title);
        }
      }
      final ids = routeSteps.map((s) => s.id).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'un paso repetido en la Ruta');
    });

    test('todo reto de la Ruta existe y todo paso tiene su lección o su reto', () {
      for (final step in routeSteps) {
        switch (step) {
          case LessonStep():
            expect(lessonById(step.id), isNotNull, reason: step.id);
          case ChallengeStep():
            expect(challengeById(step.id), isNotNull, reason: step.id);
        }
      }
    });

    test('el siguiente paso es el primero sin hacer y al final no hay ninguno', () {
      // The recommended way starts at level 1, not at the optional blocks.
      expect(nextStep(lessons: {}, challenges: {})!.id, mainSteps.first.id);
      expect(mainSteps.first.id, lessonFirstProgram.id);
      final lessons = {for (final s in routeSteps.whereType<LessonStep>()) s.id};
      final done = {for (final s in routeSteps.whereType<ChallengeStep>()) s.id};
      expect(nextStep(lessons: lessons, challenges: done), isNull);
    });
  });

  group('la Ruta en pantalla', () {
    Future<ViewSettings> abre(WidgetTester tester, Map<String, Object> values) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3, ...values});
      final prefs = await SharedPreferences.getInstance();
      final settings = ViewSettings(prefs);
      await tester.pumpWidget(
        JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: settings),
      );
      await tester.pumpAndSettle();
      return settings;
    }

    testWidgets('muestra el nivel, sus unidades y una copa por unidad', (tester) async {
      await abre(tester, {});
      await irASala(tester, 'Ruta');
      expect(find.text('NIVEL 1'), findsOneWidget);
      expect(find.text(nivel1.title), findsOneWidget);
      expect(find.text('0 de ${nivel1.steps.length}'), findsOneWidget);
      expect(find.text('Copa de la unidad'), findsWidgets);
    });

    testWidgets('abre en tu paso cuando ya avanzaste, y "Ir a mi paso" lleva de vuelta', (tester) async {
      final lessons = [for (final s in mainSteps.take(8).whereType<LessonStep>()) s.id];
      final retos = [for (final s in mainSteps.take(8).whereType<ChallengeStep>()) s.id];
      await abre(tester, {'jaguar.lecciones.hechas': lessons, 'jaguar.retos.hechos': retos});
      await irASala(tester, 'Ruta');
      await tester.pumpAndSettle();

      final next = nextStep(lessons: lessons.toSet(), challenges: retos.toSet())!;
      // The road opened at the step that follows: it is on screen.
      final node = find.byKey(ValueKey('paso-${next.id}'));
      expect(node, findsOneWidget);
      final y = tester.getCenter(node).dy;
      expect(y, inInclusiveRange(0, 800));
      expect(find.text('Ir a mi paso'), findsOneWidget);
      // Nothing to jump to while you are on it: the button is hidden (zero opacity).
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).last).opacity, 0);

      // Going to the top shows the button; touching it comes back.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
      await tester.pumpAndSettle();
      expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).last).opacity, 1);
      await tester.tap(find.text('Ir a mi paso'));
      await tester.pumpAndSettle();
      expect(find.byKey(ValueKey('paso-${next.id}')), findsOneWidget);
    });

    testWidgets('la copa se enciende al terminar una unidad', (tester) async {
      final group = nivel1.groups.first;
      await abre(tester, {
        'jaguar.lecciones.hechas': [for (final s in group.steps.whereType<LessonStep>()) s.id],
        'jaguar.retos.hechos': [for (final s in group.steps.whereType<ChallengeStep>()) s.id],
      });
      await irASala(tester, 'Ruta');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Unidad completa'), -300);
      expect(find.text('Unidad completa'), findsOneWidget);
    });
  });
}
