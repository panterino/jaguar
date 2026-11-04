import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/editor/keyword_bar.dart';
import 'package:jaguar/src/exercises/exercise_editor_screen.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/workspace/settings_screen.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _par = Exercise(
  id: 'par',
  title: 'Par o impar',
  statement: 'Lee un número entero y muestra si es par o impar.',
  cases: [
    TestCase(inputs: ['8'], expected: '8 es par'),
    TestCase(inputs: ['7'], expected: '7 es impar'),
    TestCase(inputs: ['0'], expected: '0 es par', hidden: true),
  ],
);

const _solucion =
    'Algoritmo par_o_impar\n    Definir n Como Entero\n    Leer n\n    Si n MOD 2 = 0 Entonces\n'
    '        Escribir n, " es par"\n    SiNo\n        Escribir n, " es impar"\n    FinSi\nFinAlgoritmo\n';

Future<ExerciseStore> _store() async {
  SharedPreferences.setMockInitialValues({});
  final store = ExerciseStore(await SharedPreferences.getInstance());
  store.saveAuthored(_par, solution: _solucion);
  return store;
}

Future<void> _pump(WidgetTester tester, Widget screen, Size size, {double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

const _sizes = {'escritorio': Size(1366, 768), 'tableta': Size(900, 700), 'celular': Size(400, 800)};

void main() {
  group('editor de la solución', () {
    testWidgets('usa el editor de código de la app, con su guardado intacto', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), const Size(1366, 768));
      expect(find.byType(CodeEditor), findsOneWidget);
      expect(find.textContaining('par_o_impar', findRichText: true), findsWidgets);
      // The solution is saved with the exercise.
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(store.solutionFor('par'), _solucion);
    });

    testWidgets('autocompleta y sangra al escribir', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), const Size(1366, 768));
      final field = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField));
      await tester.tap(field);
      await tester.pump();
      const base = 'Algoritmo a\n    ';
      for (final text in ['${base}M', '${base}Mi', '${base}Mie']) {
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          ),
        );
        await tester.pump();
      }
      expect(find.text('Mientras'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      final code = tester.widget<TextField>(field).controller!.text;
      expect(code, '${base}Mientras  Hacer\n        \n    FinMientras');
      await tester.pump(const Duration(seconds: 1)); // the error check
    });

    testWidgets('el celular trae la barra de palabras', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), _sizes['celular']!);
      expect(find.byType(KeywordBar), findsOneWidget);
    });
  });

  group('ajustes', () {
    Future<(ViewSettings, SettingsScreen)> screen({Map<String, Object> values = const {}}) async {
      SharedPreferences.setMockInitialValues(values);
      final prefs = await SharedPreferences.getInstance();
      final settings = ViewSettings(prefs);
      return (
        settings,
        SettingsScreen(
          settings: settings,
          exercises: ExerciseStore(prefs),
          onChangeName: () {},
          onWelcome: () {},
          onIntro: () {},
          onRepeatTour: () {},
          onCommunity: () {},
          onAccount: () {},
          onAbout: () {},
        ),
      );
    }

    for (final MapEntry(key: name, value: size) in _sizes.entries) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('no desborda en $name con letra x$scale', (tester) async {
          final (_, settings) = await screen();
          await _pump(tester, settings, size, textScale: scale);
          expect(find.text('Modo y perfil'), findsOneWidget);
          // Everything is reachable: scroll to the last row.
          await tester.scrollUntilVisible(
            find.text('Acerca de Jaguar Code'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          expect(find.text('Acerca de Jaguar Code'), findsOneWidget);
        });
      }
    }

    testWidgets('en escritorio las secciones van en dos columnas centradas', (tester) async {
      final (_, settings) = await screen();
      await _pump(tester, settings, _sizes['escritorio']!);
      final left = tester.getTopLeft(find.text('Modo y perfil'));
      final right = tester.getTopLeft(find.text('Vistas del programa'));
      expect(right.dx, greaterThan(left.dx + 300));
      // Same height: both columns start together.
      expect((right.dy - left.dy).abs(), lessThan(4));
      // Centered, not stuck to the left edge.
      expect(left.dx, greaterThan(100));
    });

    testWidgets('en celular es una sola columna', (tester) async {
      final (_, settings) = await screen();
      await _pump(tester, settings, _sizes['celular']!);
      expect(tester.getTopLeft(find.text('Modo y perfil')).dx, lessThan(40));
    });

    testWidgets('la letra del código se cambia y se ve en la muestra', (tester) async {
      final (settings, screenWidget) = await screen();
      await _pump(tester, screenWidget, _sizes['escritorio']!);
      expect(find.text('14 px'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(120, 0));
      await tester.pump();
      expect(settings.fontSize, greaterThan(14));
      expect(find.text('${settings.fontSize.round()} px'), findsOneWidget);
    });

    testWidgets('Esc regresa', (tester) async {
      final (_, settings) = await screen();
      await _pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => settings)),
              child: const Text('Abrir'),
            ),
          ),
        ),
        _sizes['escritorio']!,
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsNothing);
    });
  });
}
