// Capturas en tamaño de celular con las fuentes reales, para revisar la
// interfaz sin un teléfono a la mano:
//
//   flutter test tool/capturas --update-goldens
//
// Las imágenes quedan en tool/capturas/salida/ (no se suben al repo).

// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _programa = '''Algoritmo adivina
    Definir secreto, intento, intentos Como Entero
    secreto <- 42
    intentos <- 0
    Escribir "Pensé un número del 1 al 100. ¡Adivínalo!"
    Repetir
        Leer intento
        intentos <- intentos + 1
        Si intento < secreto Entonces
            Escribir "Más grande..."
        SiNo
            Si intento > secreto Entonces
                Escribir "Más pequeño..."
            FinSi
        FinSi
    Hasta Que intento = secreto
    Escribir "¡Correcto! Lo lograste en ", intentos, " intentos."
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

  await carga('Roboto', [for (final p in ['Regular', 'Medium', 'Bold']) '$material/Roboto-$p.ttf']);
  await carga('MaterialIcons', ['$material/MaterialIcons-Regular.otf']);
  await carga('JetBrainsMono', ['assets/fonts/JetBrainsMono-Regular.ttf', 'assets/fonts/JetBrainsMono-Bold.ttf']);
}

Future<void> _abre(
  WidgetTester tester, {
  Size size = const Size(360, 740),
  Map<String, Object> prefs = const {},
  bool nube = false,
}) async {
  SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'basic', ...prefs});
  final p = await SharedPreferences.getInstance();
  final store = ProgramStore(p)..openSource(_programa);
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  addTearDown(tester.view.reset);
  final cloud = nube ? Cloud(MemoryBackend(), p) : null;
  await tester.pumpWidget(
    JaguarApp(store: store, exercises: ExerciseStore(p), settings: ViewSettings(p), cloud: cloud),
  );
  await tester.pumpAndSettle();
}

Future<void> _foto(String nombre) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('salida/$nombre.png'));

void main() {
  setUpAll(_fuentes);

  testWidgets('celular', (tester) async {
    await _abre(tester);
    await _foto('01_codigo');
    await tester.tap(find.byTooltip('Abrir menú de navegación').first);
    await tester.pumpAndSettle();
    await _foto('02_menu');
  });

  testWidgets('celular completo', (tester) async {
    await _abre(tester, prefs: {'jaguar.view.mode': 'full'});
    await _foto('03_codigo_completo');
  });

  testWidgets('celular diagrama', (tester) async {
    await _abre(tester, prefs: {'jaguar.view.editor': 'diagram'});
    await _foto('04_diagrama');
  });

  testWidgets('celular chico', (tester) async {
    await _abre(tester, size: const Size(320, 640));
    await _foto('05_chico');
  });

  testWidgets('consola', (tester) async {
    await _abre(tester);
    await tester.tap(find.byTooltip('Ejecutar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '50');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _foto('07_consola');
  });

  testWidgets('cuenta', (tester) async {
    await _abre(tester, nube: true);
    await tester.tap(find.byTooltip('Abrir menú de navegación').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Entrar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profesor').last);
    await tester.pumpAndSettle();
    await _foto('08_cuenta');
  });

  testWidgets('bienvenida', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(720, 1480);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(JaguarApp(store: ProgramStore(p), exercises: ExerciseStore(p), settings: ViewSettings(p)));
    await tester.pumpAndSettle();
    await _foto('06_bienvenida');
  });
}
