import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/editor/syntax_controller.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/python/python_view.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fuente =
    'Algoritmo hola\n    Definir n Como Entero\n    Leer n\n    Si n > 1 Entonces\n        Escribir "mayor"\n    FinSi\nFinAlgoritmo\n';

void main() {
  testWidgets('la vista Python muestra el programa traducido y sigue al código', (tester) async {
    final code = SyntaxController(text: _fuente);
    addTearDown(code.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(Brightness.light),
        home: Scaffold(body: PythonView(code: code)),
      ),
    );
    String texto() => tester
        .widgetList<SelectableText>(find.byType(SelectableText))
        .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
        .join();
    expect(texto(), contains('n = int(input())'));
    expect(texto(), contains('if n > 1:'));
    expect(texto(), contains('print("mayor")'));
    expect(find.textContaining('Solo se lee'), findsOneWidget);

    code.text = _fuente.replaceAll('mayor', 'grande');
    await tester.pump();
    expect(texto(), contains('print("grande")'));

    // With an error it keeps the last translation and says where the error is.
    code.text = 'Algoritmo hola\n    Escribir "hola\nFinAlgoritmo\n';
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('Hay un error en la línea'), findsOneWidget);
    expect(texto(), contains('print("grande")'));
  });

  group('la vista Python está apagada hasta que se enciende', () {
    Future<ViewSettings> abre(WidgetTester tester, {Map<String, Object> values = const {}}) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3, ...values});
      final prefs = await SharedPreferences.getInstance();
      final settings = ViewSettings(prefs);
      await tester.pumpWidget(
        JaguarApp(
          store: ProgramStore(prefs)..openSource(_fuente),
          exercises: ExerciseStore(prefs),
          settings: settings,
          openEditor: true,
        ),
      );
      await tester.pumpAndSettle();
      return settings;
    }

    testWidgets('por defecto el selector tiene tres vistas', (tester) async {
      final settings = await abre(tester);
      expect(settings.pythonEnabled, isFalse);
      expect(find.text('Código'), findsOneWidget);
      expect(find.text('Diagrama'), findsOneWidget);
      expect(find.text('Bloques'), findsOneWidget);
      expect(find.text('Python'), findsNothing);
    });

    testWidgets('encendida, aparece como cuarta vista y se puede abrir', (tester) async {
      final settings = await abre(tester, values: {'jaguar.view.python': true});
      expect(find.text('Python'), findsOneWidget);
      await tester.tap(find.text('Python'));
      await tester.pumpAndSettle();
      expect(settings.editorView, EditorView.python);
      expect(find.byType(PythonView), findsOneWidget);
    });

    testWidgets('al apagarla estando en Python, regresa al código', (tester) async {
      final settings = await abre(tester, values: {'jaguar.view.python': true, 'jaguar.view.editor': 'python'});
      expect(find.byType(PythonView), findsOneWidget);
      settings.pythonEnabled = false;
      await tester.pumpAndSettle();
      expect(settings.editorView, EditorView.code);
      expect(find.byType(PythonView), findsNothing);
    });
  });

  test('ninguna parte de la Ruta enciende Python todavía; el ajuste sí existe', () {
    expect(routeLevels.any((l) => l.unlocksPython), isFalse);
    expect(levelOf(routeSteps.first), isNotNull);
  });
}
