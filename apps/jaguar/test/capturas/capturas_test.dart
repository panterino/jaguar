// Genera las capturas del manual dentro de la app. No es una prueba: solo corre
// con `tool/capturas.sh`, que pone JAGUAR_CAPTURAS y convierte las imágenes.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/console/desk_check_screen.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/exercises/exercise_editor_screen.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/lessons/lessons.dart';
import 'package:jaguar/src/exercises/verified_screen.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ayudas.dart';

final _run = Platform.environment['JAGUAR_CAPTURAS'] != null;
final _out = Platform.environment['JAGUAR_CAPTURAS'] ?? '';
const _sdkFonts = '/Users/angel/development/flutter/bin/cache/artifacts/material_fonts';

const _saludo = '''Algoritmo saludo
    Definir nombre Como Caracter
    Escribir "¿Cómo te llamas?"
    Leer nombre
    Escribir "Hola, ", nombre
FinAlgoritmo
''';

late SharedPreferences _prefs;
final _boundary = GlobalKey();

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(File(file).readAsBytes().then((b) => ByteData.view(Uint8List.fromList(b).buffer)));
    }
    await loader.load();
  }

  final roboto = [
    for (final weight in ['Light', 'Regular', 'Medium', 'Bold', 'Black']) '$_sdkFonts/Roboto-$weight.ttf',
  ];
  await load('Roboto', roboto);
  await load('MaterialIcons', ['$_sdkFonts/MaterialIcons-Regular.otf']);
  await load('JetBrainsMono', ['assets/fonts/JetBrainsMono-Regular.ttf', 'assets/fonts/JetBrainsMono-Bold.ttf']);
}

Future<void> _shot(WidgetTester tester, String name, {double pixelRatio = 2}) async {
  // Let images (the mascot) finish decoding before taking the picture.
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.runAsync(() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<ProgramStore> _app(
  WidgetTester tester, {
  Map<String, Object> values = const {},
  String? source,
  Size size = const Size(360, 740),
  bool desktop = false,
  bool? openEditor,
}) async {
  if (desktop) debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  addTearDown(() => debugDefaultTargetPlatformOverride = null);
  SharedPreferences.setMockInitialValues({'jaguar.view.firstRunDone': true, 'jaguar.view.tourStep': 3, ...values});
  _prefs = await SharedPreferences.getInstance();
  final store = ProgramStore(_prefs);
  if (source != null) {
    store.discardBlank();
    store.openSource(source);
  }
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: JaguarApp(
        store: store,
        exercises: ExerciseStore(_prefs),
        settings: ViewSettings(_prefs),
        // A program in hand means the editor; without one, the rooms.
        openEditor: openEditor ?? source != null,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

Future<void> _standalone(WidgetTester tester, Widget screen, {Size size = const Size(360, 740)}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _boundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('es', 'MX'),
        supportedLocales: const [Locale('es', 'MX')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: buildTheme(Brightness.light),
        home: screen,
      ),
    ),
  );
  // Some screens animate forever (the clock), so settle by time.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder get _editor => find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;

void main() {
  setUpAll(() async {
    if (_run) await _loadFonts();
  });

  void scene(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets('captura $name', (tester) async {
      await body(tester);
    }, skip: !_run);
  }

  scene('bienvenida', (tester) async {
    await _app(tester, values: {'jaguar.view.firstRunDone': false});
    await _shot(tester, 'bienvenida');
  });

  scene('intro', (tester) async {
    await _app(tester, values: {'jaguar.view.firstRunDone': false});
    await tester.tap(find.text('Empezar desde cero'));
    await tester.pumpAndSettle();
    await _shot(tester, 'intro');
  });

  scene('reto-inicio', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 0});
    await irASala(tester, 'Ruta');
    await tester.tap(find.text('Saludo'));
    await tester.pumpAndSettle();
    await _shot(tester, 'reto-inicio');
  });

  scene('inicio', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.programs': '[]'});
    await _shot(tester, 'inicio');
  });

  Future<void> abreLeccion(WidgetTester tester, Lesson leccion, {Map<String, Object> values = const {}}) async {
    final fila = find.byKey(ValueKey('paso-${leccion.id}'));
    await _app(tester, values: {'jaguar.view.mode': 'basic', ...values});
    await irASala(tester, 'Ruta');
    await tester.scrollUntilVisible(fila, 200);
    await tester.ensureVisible(fila);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 250));
    await tester.pumpAndSettle();
    await tester.tap(fila);
    await tester.pumpAndSettle();
  }

  scene('leccion-pregunta', (tester) async {
    await abreLeccion(tester, lessonOperations);
    await tester.tap(find.text('12').last);
    await tester.pumpAndSettle();
    await _shot(tester, 'leccion-pregunta');
  });

  scene('leccion-acierto', (tester) async {
    await abreLeccion(tester, lessonOperations);
    await tester.tap(find.text('12').last);
    await tester.pump();
    await tester.tap(find.text('Comprobar'));
    await tester.pump(const Duration(milliseconds: 900));
    await _shot(tester, 'leccion-acierto');
  });

  scene('leccion-error', (tester) async {
    await abreLeccion(tester, lessonOperations);
    await tester.tap(find.text('7').last);
    await tester.pump();
    await tester.tap(find.text('Comprobar'));
    await tester.pump(const Duration(milliseconds: 900));
    await _shot(tester, 'leccion-error');
  });

  scene('leccion-figuras', (tester) async {
    await abreLeccion(tester, lessonFlowcharts);
    await tester.tap(find.byKey(const ValueKey(Figure.parallelogram)));
    await tester.pumpAndSettle();
    await _shot(tester, 'leccion-figuras');
  });

  scene('leccion-ordenar', (tester) async {
    await abreLeccion(tester, lessonFirstProgram);
    for (final q in lessonFirstProgram.questions.take(4)) {
      final c = q as ChoiceQuestion;
      await tester.tap(find.text(c.options[c.answer]).last);
      await tester.pump();
      await tester.tap(find.text('Comprobar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
    }
    final orden = lessonFirstProgram.questions.last as OrderQuestion;
    for (final line in [orden.lines[0], orden.lines[1]]) {
      await tester.tap(find.text(line.trim()).last);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    await _shot(tester, 'leccion-ordenar');
  });

  scene('leccion-final', (tester) async {
    await abreLeccion(tester, lessonOperations);
    for (final q in lessonOperations.questions) {
      final c = q as ChoiceQuestion;
      await tester.tap(find.text(c.options[c.answer]).last);
      await tester.pump();
      await tester.tap(find.text('Comprobar'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(RegExp('Continuar|Terminar')));
      await tester.pumpAndSettle();
    }
    await tester.pump(const Duration(milliseconds: 500));
    await _shot(tester, 'leccion-final');
  });

  scene('ancha-inicio', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, size: const Size(1280, 800), openEditor: false);
    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    await _shot(tester, 'ancha-inicio', pixelRatio: 1);
  });

  scene('ancha-ruta', (tester) async {
    await _app(
      tester,
      values: {
        'jaguar.view.mode': 'basic',
        'jaguar.lecciones.hechas': ['leccion-primer-programa'],
        'jaguar.retos.hechos': ['reto-1-01'],
      },
      size: const Size(1280, 800),
      openEditor: false,
    );
    await irASala(tester, 'Ruta');
    await _shot(tester, 'ancha-ruta', pixelRatio: 1);
  });

  scene('ruta-celular', (tester) async {
    await _app(
      tester,
      values: {
        'jaguar.view.mode': 'basic',
        'jaguar.lecciones.hechas': ['leccion-primer-programa', 'leccion-operaciones'],
        'jaguar.retos.hechos': ['reto-1-01', 'reto-1-02'],
      },
    );
    await irASala(tester, 'Ruta');
    await _shot(tester, 'ruta-celular');
  });

  scene('sala-clases', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'});
    await irASala(tester, 'Clases');
    await _shot(tester, 'sala-clases');
  });

  scene('sala-clases-profe', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'full', 'jaguar.view.teacher': true});
    await irASala(tester, 'Clases');
    await _shot(tester, 'sala-clases-profe');
  });

  scene('sala-taller', (tester) async {
    final store = await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo, openEditor: false);
    store.create('Algoritmo promedio\n    Escribir 1\nFinAlgoritmo\n');
    await irASala(tester, 'Taller');
    await _shot(tester, 'sala-taller');
  });

  scene('codigo', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo);
    await _shot(tester, 'codigo');
  });

  scene('consola-leer', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo);
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Ana');
    await tester.pump();
    await _shot(tester, 'consola-leer');
  });

  scene('primer-programa', (tester) async {
    await _app(
      tester,
      values: {'jaguar.view.mode': 'basic', 'jaguar.view.firstRunDone': false},
      source: 'Algoritmo hola\n    Escribir "¡Hola, mundo!"\nFinAlgoritmo\n',
    );
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await _shot(tester, 'primer-programa');
    await tester.pumpAndSettle(const Duration(seconds: 6));
  });

  scene('diagrama', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.editor': 'diagram'}, source: _saludo);
    await _shot(tester, 'diagrama');
    await tester.pumpAndSettle(const Duration(seconds: 11));
  });

  scene('bloques', (tester) async {
    await _app(
      tester,
      values: {'jaguar.view.mode': 'basic', 'jaguar.view.editor': 'blocks'},
      source:
          'Algoritmo mayor_de_edad\n    Definir edad Como Entero\n    Escribir "¿Cuántos años tienes?"\n    Leer edad\n    Si edad >= 18 Entonces\n        Escribir "Eres mayor de edad"\n    SiNo\n        Escribir "Aún eres menor"\n    FinSi\nFinAlgoritmo\n',
    );
    await _shot(tester, 'bloques');
  });

  scene('error', (tester) async {
    await _app(
      tester,
      values: {'jaguar.view.mode': 'basic'},
      source:
          'Algoritmo edad\n    Definir edad Como Entero\n    Leer edad\n    Si edad >= 18 Entonces\n        Escribir Mayor de edad\n    FinSi\nFinAlgoritmo\n',
    );
    await tester.enterText(
      _editor,
      'Algoritmo edad\n    Definir edad Como Entero\n    Leer edad\n    Si edad >= 18 Entonces\n        Escribir Mayor de edad\n    FinSi\nFinAlgoritmo\n',
    );
    await tester.pump(const Duration(seconds: 1));
    await _shot(tester, 'error');
  });

  scene('mas-opciones', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo);
    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await _shot(tester, 'mas-opciones');
  });

  scene('retos', (tester) async {
    await _app(
      tester,
      values: {
        'jaguar.view.mode': 'basic',
        'jaguar.retos.hechos': ['reto-1-01', 'reto-1-02', 'reto-1-03', 'reto-1-04'],
      },
    );
    await irASala(tester, 'Ruta');
    await _shot(tester, 'retos');
  });

  Future<void> openReto(WidgetTester tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo, openEditor: false);
    await irASala(tester, 'Ruta');
    await tester.tap(find.text('Saludo'));
    await tester.pumpAndSettle();
  }

  scene('reto', (tester) async {
    await openReto(tester);
    await _shot(tester, 'reto');
  });

  scene('pruebas-neutras', (tester) async {
    await openReto(tester);
    await tester.tap(find.text('Pruebas'));
    await tester.pumpAndSettle();
    await _shot(tester, 'pruebas-neutras');
  });

  scene('pruebas-gris', (tester) async {
    await openReto(tester);
    await tester.tap(find.text('Pruebas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Probar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Programa'));
    await tester.pumpAndSettle();
    await tester.enterText(_editor, 'Algoritmo saludo\n    Leer nombre\n    Escribir "Hola"\nFinAlgoritmo\n');
    await tester.pump();
    await tester.tap(find.text('Pruebas'));
    await tester.pumpAndSettle();
    await _shot(tester, 'pruebas-gris');
  });

  scene('reto-superado', (tester) async {
    await openReto(tester);
    await tester.enterText(
      _editor,
      'Algoritmo saludo\n    Leer nombre\n    Escribir "Hola, " + nombre\nFinAlgoritmo\n',
    );
    await tester.pump();
    await tester.tap(find.text('Pruebas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Probar'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold).first)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await _shot(tester, 'reto-superado');
  });

  scene('compartir', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'}, source: _saludo);
    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Compartir'));
    await tester.pumpAndSettle();
    await _shot(tester, 'compartir');
  });

  scene('ajustes', (tester) async {
    await _app(tester, values: {'jaguar.view.mode': 'basic'});
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    await _shot(tester, 'ajustes');
  });

  scene('prueba-escritorio', (tester) async {
    await _standalone(
      tester,
      const DeskCheckScreen(
        name: 'promedio',
        source:
            'Algoritmo promedio\n    Leer a, b\n    s <- a + b\n    p <- s / 2\n    Escribir "Promedio: ", p\nFinAlgoritmo\n',
      ),
    );
    await tester.enterText(find.byType(TextField), '7, 10');
    await tester.tap(find.text('Hacer la tabla'));
    await tester.pumpAndSettle();
    await _shot(tester, 'prueba-escritorio');
  });

  scene('mostrar-al-profe', (tester) async {
    await _standalone(
      tester,
      VerifiedScreen(
        exerciseTitle: 'Par o impar',
        studentName: 'Ana López',
        passedCases: 4,
        verifiedAt: DateTime(2026, 10, 20, 10, 42),
        source: _saludo,
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _shot(tester, 'mostrar-al-profe');
  });

  scene('ejercicio-profe', (tester) async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    await _standalone(
      tester,
      ExerciseEditorScreen(
        store: ExerciseStore(_prefs),
        fromProgram:
            '// Lee un número y di si es par o impar.\nAlgoritmo par_o_impar\n    Definir n Como Entero\n    Leer n\n    Si n MOD 2 = 0 Entonces\n        Escribir n, " es par"\n    SiNo\n        Escribir n, " es impar"\n    FinSi\nFinAlgoritmo\n',
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _shot(tester, 'ejercicio-profe');
  });
}
