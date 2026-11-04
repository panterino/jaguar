import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/editor/keyword_bar.dart';
import 'package:jaguar/src/exercises/exercise_editor_screen.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/exercises/exercises_screen.dart';
import 'package:jaguar/src/exercises/project_screen.dart';
import 'package:jaguar/src/exercises/verified_screen.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/workspace/settings_screen.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

Future<void> _pump(WidgetTester tester, Widget screen, Size size, {double textScale = 1, bool settle = true}) async {
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
  // Some screens animate forever (the clock of the verified screen).
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 500));
  }
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

  group('editor de ejercicio, en todos los tamaños', () {
    for (final MapEntry(key: name, value: size) in _sizes.entries) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('no desborda en $name con letra x$scale', (tester) async {
          final store = await _store();
          await _pump(
            tester,
            ExerciseEditorScreen(store: store, exercise: _par),
            size,
            textScale: scale,
          );
          expect(find.text('Tu solución'), findsOneWidget);
          expect(find.byType(CodeEditor), findsOneWidget);
          // On a phone the rest is below: it must be reachable by scrolling.
          await tester.scrollUntilVisible(
            find.text('Generar casos con mi solución'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
        });
        testWidgets('un ejercicio nuevo sin casos tampoco desborda en $name con letra x$scale', (tester) async {
          final store = await _store();
          await _pump(tester, ExerciseEditorScreen(store: store), size, textScale: scale);
          await tester.scrollUntilVisible(
            find.textContaining('Aún no hay casos'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
        });
      }
    }

    testWidgets('en escritorio la solución va al lado y no debajo del enunciado', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), _sizes['escritorio']!);
      final statement = tester.getTopLeft(
        find.byWidgetPredicate((w) => w is TextField && w.decoration?.labelText == 'Enunciado'),
      );
      final editor = tester.getTopLeft(find.byType(CodeEditor));
      expect(editor.dx, greaterThan(statement.dx + 400));
      // The editor takes the height that is left, not a fixed box.
      expect(tester.getSize(find.byType(CodeEditor)).height, greaterThan(400));
    });

    testWidgets('Ctrl+S guarda sin cerrar', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store), _sizes['escritorio']!);
      await tester.enterText(find.widgetWithText(TextField, 'Título'), 'Mi ejercicio');
      // Needs a case to be valid.
      await tester.tap(find.text('Agregar caso'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Salida esperada'), 'hola');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(find.text('Guardado'), findsOneWidget);
      expect(store.authored.map((e) => e.title), contains('Mi ejercicio'));
      expect(find.text('Nuevo ejercicio'), findsOneWidget); // still here
    });
  });

  group('mis ejercicios', () {
    Future<ExerciseStore> two() async {
      final store = await _store();
      store.saveAuthored(
        const Exercise(
          id: 'suma',
          title: 'Suma de dos números',
          statement: 'Suma a y b.',
          cases: [
            TestCase(inputs: ['1', '2'], expected: '3'),
          ],
        ),
      );
      return store;
    }

    for (final MapEntry(key: name, value: size) in _sizes.entries) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('con ejercicios no desborda en $name con letra x$scale', (tester) async {
          final store = await two();
          await _pump(
            tester,
            ExercisesScreen(store: store, onTryAsStudent: (_) {}),
            size,
            textScale: scale,
          );
          expect(find.text('Par o impar'), findsWidgets);
        });
        testWidgets('sin ejercicios no desborda en $name con letra x$scale', (tester) async {
          SharedPreferences.setMockInitialValues({});
          final store = ExerciseStore(await SharedPreferences.getInstance());
          await _pump(
            tester,
            ExercisesScreen(store: store, onTryAsStudent: (_) {}),
            size,
            textScale: scale,
          );
          expect(find.text('Crear mi primer ejercicio'), findsOneWidget);
          expect(find.byType(FloatingActionButton), findsNothing);
        });
      }
    }

    testWidgets('en escritorio muestra el detalle del seleccionado y cambia al elegir otro', (tester) async {
      final store = await two();
      await _pump(tester, ExercisesScreen(store: store, onTryAsStudent: (_) {}), _sizes['escritorio']!);
      expect(find.text('Lee un número entero y muestra si es par o impar.'), findsOneWidget);
      expect(find.text('8 es par'), findsOneWidget);
      expect(find.text('Proyectar'), findsOneWidget);
      expect(find.text('Probar como alumno'), findsOneWidget);
      expect(find.text('Con solución guardada'), findsOneWidget);
      await tester.tap(find.text('Suma de dos números'));
      await tester.pumpAndSettle();
      expect(find.text('Suma a y b.'), findsOneWidget);
      expect(find.text('Sin solución'), findsOneWidget);
      expect(find.text('1 caso'), findsWidgets);
    });

    testWidgets('en escritorio Ctrl+N abre un ejercicio nuevo', (tester) async {
      final store = await two();
      await _pump(tester, ExercisesScreen(store: store, onTryAsStudent: (_) {}), _sizes['escritorio']!);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Nuevo ejercicio'), findsOneWidget);
      expect(find.byType(CodeEditor), findsOneWidget);
    });

    testWidgets('eliminar pide confirmar y deja el siguiente seleccionado', (tester) async {
      final store = await two();
      await _pump(tester, ExercisesScreen(store: store, onTryAsStudent: (_) {}), _sizes['escritorio']!);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('¿Eliminar "Par o impar"?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await tester.pumpAndSettle();
      expect(store.authored.map((e) => e.id), ['suma']);
      expect(find.text('Suma a y b.'), findsOneWidget);
    });

    testWidgets('en celular sigue siendo una lista con su menú', (tester) async {
      final store = await two();
      await _pump(tester, ExercisesScreen(store: store, onTryAsStudent: (_) {}), _sizes['celular']!);
      expect(find.byTooltip('Opciones'), findsNWidgets(2));
      expect(find.text('Nuevo ejercicio'), findsOneWidget); // the floating button
      expect(find.text('Comparación flexible'), findsNothing);
    });
  });

  group('proyectar, verificada y resultados', () {
    for (final MapEntry(key: name, value: size) in _sizes.entries) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('proyectar no desborda en $name con letra x$scale', (tester) async {
          await _pump(tester, const ProjectScreen(exercise: _par), size, textScale: scale);
          expect(find.text('Par o impar'), findsWidgets);
          expect(find.text('Copiar enlace'), findsOneWidget);
        });

        testWidgets('la pantalla verificada no desborda en $name con letra x$scale', (tester) async {
          await _pump(
            tester,
            VerifiedScreen(
              exerciseTitle: 'Par o impar',
              studentName: 'Ana María de los Ángeles Pérez Hernández',
              passedCases: 3,
              verifiedAt: DateTime(2026, 11, 3, 10, 30),
              source: _solucion,
              pastedLines: 12,
            ),
            size,
            textScale: scale,
            settle: false,
          );
          expect(find.text('Ejercicio verificado'), findsOneWidget);
          await tester.pumpWidget(const SizedBox()); // stops the clock timer
        });
      }
    }

    testWidgets('proyectar en escritorio pone el QR al lado del texto y llena la altura', (tester) async {
      await _pump(tester, const ProjectScreen(exercise: _par), _sizes['escritorio']!);
      final qr = tester.getRect(find.byType(QrImageView));
      final text = tester.getTopLeft(find.textContaining('Escanéalo'));
      expect(text.dx, greaterThan(qr.right));
      expect(qr.height, greaterThan(560)); // readable from the back row
      expect(qr.bottom, lessThanOrEqualTo(768));
    });

    testWidgets('la pantalla verificada se centra y su título se lee sobre el verde', (tester) async {
      await _pump(
        tester,
        VerifiedScreen(
          exerciseTitle: 'Par o impar',
          studentName: 'Ana Pérez',
          passedCases: 3,
          verifiedAt: DateTime(2026, 11, 3, 10, 30),
          source: _solucion,
        ),
        _sizes['escritorio']!,
        settle: false,
      );
      final name = tester.getCenter(find.text('Ana Pérez'));
      expect(name.dx, closeTo(683, 2));
      final title = tester.widget<Text>(find.text('Ejercicio verificado'));
      expect(title.style?.color, Colors.white);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('comprobar mi solución: diálogo en escritorio, hoja en celular, sin botón para el profesor', (
      tester,
    ) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), _sizes['escritorio']!);
      await tester.tap(find.text('Comprobar mi solución'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('¡Todos los casos son correctos!'), findsOneWidget);
      expect(find.text('Mostrar al profesor'), findsNothing);
      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('comprobar mi solución en celular usa una hoja inferior', (tester) async {
      final store = await _store();
      await _pump(tester, ExerciseEditorScreen(store: store, exercise: _par), _sizes['celular']!);
      await tester.scrollUntilVisible(
        find.text('Comprobar mi solución'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Comprobar mi solución'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comprobar mi solución'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('¡Todos los casos son correctos!'), findsOneWidget);
    });
  });
}
