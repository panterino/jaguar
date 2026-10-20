// Capturas para el manual del sitio (sitio/manual.html):
//
//   flutter test tool/capturas/manual_test.dart --update-goldens
//
// Quedan en tool/capturas/salida/manual/ y de ahí se recortan y comprimen.

// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar_core/jaguar_core.dart' show Exercise;
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/challenges/challenges_screen.dart';
import 'package:jaguar/src/console/desk_check_screen.dart';
import 'package:jaguar/src/exercises/exercise_editor_screen.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/exercises/verified_screen.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _saludo = '''Algoritmo saludo
    Definir nombre Como Caracter
    Escribir "¿Cómo te llamas?"
    Leer nombre
    Escribir "Hola, ", nombre
FinAlgoritmo
''';

const _promedio = '''Algoritmo promedio
    Definir a, b, p Como Real
    Escribir "Primera calificación:"
    Leer a
    Escribir "Segunda calificación:"
    Leer b
    p <- (a + b) / 2
    Si p >= 6 Entonces
        Escribir "Aprobado con ", p
    SiNo
        Escribir "Reprobado con ", p
    FinSi
FinAlgoritmo
''';

const _conError = '''Algoritmo edad
    Definir edad Como Entero
    Leer edad
    Si edad >= 18 Entonces
        Escribir Mayor de edad
    FinSi
FinAlgoritmo
''';

Future<void> _fuentes() async {
  final flutter = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final material = '$flutter/bin/cache/artifacts/material_fonts';
  Future<void> carga(String familia, List<String> archivos) async {
    final loader = FontLoader(familia);
    for (final a in archivos) {
      loader.addFont(File(a).readAsBytes().then((b) => ByteData.view(b.buffer)));
    }
    await loader.load();
  }

  final roboto = [for (final p in ['Regular', 'Medium', 'Bold']) '$material/Roboto-$p.ttf'];
  await carga('Roboto', roboto);
  // Textos sin familia (el diagrama, algunos botones): que no salgan como cuadros.
  for (final f in ['FlutterTest', 'Ahem', 'Segoe UI', '.SF UI Text', 'sans-serif']) {
    await carga(f, roboto);
  }
  await carga('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  await carga('JetBrainsMono', ['assets/fonts/JetBrainsMono-Regular.ttf', 'assets/fonts/JetBrainsMono-Bold.ttf']);
}

const _celular = Size(360, 740);

Future<(ProgramStore, ExerciseStore, ViewSettings)> _abre(
  WidgetTester tester, {
  Size size = _celular,
  double dpr = 2,
  String source = _saludo,
  Exercise? exercise,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', ...prefs});
  final p = await SharedPreferences.getInstance();
  final store = ProgramStore(p);
  final exercises = ExerciseStore(p);
  if (exercise != null) {
    exercises.saveReceived(exercise);
    final program = store.openExercise(exercise);
    store.update(program.id, source);
  } else {
    store.openSource(source);
  }
  final settings = ViewSettings(p);
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = size * dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(JaguarApp(store: store, exercises: exercises, settings: settings));
  await tester.pumpAndSettle();
  return (store, exercises, settings);
}

Future<void> _pantalla(WidgetTester tester, Widget home, {Size size = _celular, double dpr = 2, bool settle = true}) async {
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = size * dpr;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'MX'),
      theme: buildTheme(Brightness.light),
      home: home,
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _foto(String nombre) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('salida/manual/$nombre.png'));

Future<void> _ejecuta(WidgetTester tester, {List<String> datos = const []}) async {
  await tester.tap(find.byTooltip('Ejecutar'));
  await tester.pumpAndSettle();
  for (final d in datos) {
    await tester.enterText(find.byType(TextField).last, d);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(_fuentes);

  testWidgets('bienvenida', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = _celular * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(JaguarApp(store: ProgramStore(p), exercises: ExerciseStore(p), settings: ViewSettings(p)));
    await tester.pumpAndSettle();
    await _foto('c01_bienvenida');
  });

  testWidgets('codigo', (tester) async {
    await _abre(tester);
    await _foto('c02_codigo');
    await tester.tap(find.byTooltip('Abrir menú de navegación').first);
    await tester.pumpAndSettle();
    await _foto('c08_menu');
  });

  testWidgets('consola', (tester) async {
    await _abre(tester);
    await _ejecuta(tester);
    await tester.enterText(find.byType(TextField).last, 'Ana');
    await tester.pumpAndSettle();
    await _foto('c03_consola_leer');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _foto('c03b_consola_fin');
  });

  testWidgets('diagrama', (tester) async {
    await _abre(tester, prefs: {'jaguar.view.editor': 'diagram'});
    await _foto('c04_diagrama');
    await tester.tap(find.text('Lectura').first);
    await tester.pumpAndSettle();
    await _foto('c04b_diagrama_figura');
  });

  testWidgets('error', (tester) async {
    await _abre(tester, source: _conError);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await _foto('c05_error');
  });

  testWidgets('retos', (tester) async {
    SharedPreferences.setMockInitialValues({'jaguar.retos.hechos': ['reto-1-01']});
    final p = await SharedPreferences.getInstance();
    await _pantalla(tester, ChallengesScreen(settings: ViewSettings(p), onOpen: (_) {}));
    await _foto('c06_retos');
  });

  testWidgets('reto', (tester) async {
    final reto = challenges.first;
    await _abre(
      tester,
      exercise: reto.exercise,
      source: '// Ejercicio: Reto 1 · Saludo\nAlgoritmo saludo\n    Leer nombre\n    Escribir "Hola, ", nombre\nFinAlgoritmo\n',
    );
    await _foto('c07_reto');
    await tester.tap(find.byTooltip('Pistas'));
    await tester.pumpAndSettle();
    await _foto('c07b_pistas');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Probar').first);
    await tester.pumpAndSettle();
    await _foto('c07c_reto_superado');
  });

  testWidgets('pantalla verde', (tester) async {
    await _pantalla(
      tester,
      VerifiedScreen(
        exerciseTitle: 'Par o impar',
        studentName: 'Ana López',
        passedCases: 4,
        verifiedAt: DateTime(2026, 10, 19, 10, 42),
        source: _saludo,
      ),
      settle: false,
    );
    await _foto('c09_verificado');
  });

  testWidgets('prueba de escritorio', (tester) async {
    await _pantalla(
      tester,
      const DeskCheckScreen(
        name: 'promedio',
        source: 'Algoritmo promedio\n    Leer a, b\n    s <- a + b\n    p <- s / 2\n    Escribir "Promedio: ", p\nFinAlgoritmo\n',
      ),
    );
    await tester.enterText(find.byType(TextField), '7, 10');
    await tester.tap(find.text('Hacer la tabla'));
    await tester.pumpAndSettle();
    await _foto('c10_escritorio');
  });

  testWidgets('compartir', (tester) async {
    await _abre(tester);
    await tester.tap(find.byTooltip('Compartir (QR o enlace)'));
    await tester.pumpAndSettle();
    await _foto('c11_compartir');
  });

  testWidgets('computadora', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await _abre(
        tester,
        size: const Size(1366, 768),
        dpr: 1,
        source: _promedio,
        prefs: {'jaguar.view.editor': 'both'},
      );
      await tester.tap(find.byTooltip('Ejecutar (Ctrl+Enter o F9)'));
      await tester.pumpAndSettle();
      for (final d in ['8', '7']) {
        await tester.enterText(find.byType(TextField).last, d);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }
      await _foto('d01_computadora');
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('ejercicio del profe', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    await _pantalla(
      tester,
      ExerciseEditorScreen(
        store: ExerciseStore(p),
        fromProgram:
            '// Lee un número entero y muestra si es par o impar.\nAlgoritmo par_impar\n    Definir n Como Entero\n    Leer n\n    Si n MOD 2 = 0 Entonces\n        Escribir n, " es par"\n    SiNo\n        Escribir n, " es impar"\n    FinSi\nFinAlgoritmo\n',
      ),
      size: const Size(360, 1100),
    );
    await _foto('c12_ejercicio_profe');
  });
}
