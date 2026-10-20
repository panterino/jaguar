import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/workspace/start_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

Future<void> _prefsWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  _prefs = await SharedPreferences.getInstance();
}

Future<ProgramStore> _pumpPhone(
  WidgetTester tester, {
  Map<String, Object> values = const {'jaguar.view.mode': 'basic'},
  String? source,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await _prefsWith(values);
  final store = ProgramStore(_prefs);
  if (source != null) store.openSource(source);
  await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));
  await tester.pumpAndSettle();
  return store;
}

void main() {
  group('borrar programas', () {
    test('se puede borrar el único y hay forma de deshacer', () async {
      await _prefsWith({});
      final store = ProgramStore(_prefs);
      expect(store.programs, hasLength(1));
      final only = store.programs.single;

      store.delete(only);
      expect(store.isEmpty, isTrue);
      // The editor gets a blank stand-in that is never saved.
      expect(store.current.id, '');
      store.update(store.current.id, 'Algoritmo x\nFinAlgoritmo\n');
      expect(store.isEmpty, isTrue);

      // The deletion survives a restart: the start panel, not a new program.
      expect(ProgramStore(_prefs).isEmpty, isTrue);

      store.restore(only);
      expect(store.programs, [only]);
      expect(identical(store.current, only), isTrue);
    });

    test('borrar el actual abre el más reciente que queda', () async {
      await _prefsWith({});
      final store = ProgramStore(_prefs);
      final first = store.programs.single;
      final second = store.create('Algoritmo dos\nFinAlgoritmo\n');
      store.delete(second);
      expect(identical(store.current, first), isTrue);
    });

    test('el programa en blanco del primer arranque se descarta al elegir cómo empezar', () async {
      await _prefsWith({});
      final store = ProgramStore(_prefs);
      expect(ProgramStore.isBlank(store.current), isTrue);
      store.discardBlank();
      expect(store.isEmpty, isTrue);

      final mine = store.create('Algoritmo mio\n    Escribir 1\nFinAlgoritmo\n');
      store.discardBlank(); // never touches what somebody wrote
      expect(store.programs, [mine]);
    });
  });

  group('celular', () {
    testWidgets('borrar el único programa lleva al inicio y se puede deshacer', (tester) async {
      final store = await _pumpPhone(tester, source: 'Algoritmo mio\n    Escribir 1\nFinAlgoritmo\n');
      // The blank program of a first launch stays in the list next to it.
      for (final program in store.programs.where(ProgramStore.isBlank).toList()) {
        store.delete(program);
      }
      await tester.pumpAndSettle();
      expect(store.programs, hasLength(1));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Eliminar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Es tu único programa. Después verás el inicio para empezar otro. Las copias guardadas no cambian.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();

      expect(store.isEmpty, isTrue);
      expect(find.byType(StartPanel), findsOneWidget);
      expect(find.text('Programa eliminado'), findsOneWidget);

      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(store.programs, hasLength(1));
      expect(find.byType(StartPanel), findsNothing);
      expect(find.byType(CodeEditor), findsOneWidget);
    });

    testWidgets('con la lista vacía se ve el panel de inicio con retos y recientes', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.programs': '[]'});
      expect(find.byType(StartPanel), findsOneWidget);
      expect(find.text('¿Qué quieres hacer?'), findsOneWidget);
      expect(find.text('Llevas 0 de ${challenges.length}'), findsOneWidget);
      expect(find.text('Empezar'), findsOneWidget);
      expect(find.text('Aún no tienes programas. Empieza con un reto o uno nuevo.'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('los botones del inicio miden lo mismo, también con letra grande', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.programs': '[]'}, textScale: 1.3);
      final tiles = [
        for (final label in [
          'Nuevo programa',
          'Abrir archivo',
          'Ejemplos',
          'Guía: cómo funciona todo',
          'Ajustes',
          if (find.text('Abrir enlace').evaluate().isNotEmpty) 'Abrir enlace' else 'Escanear QR o abrir enlace',
        ])
          tester.getSize(find.ancestor(of: find.text(label), matching: find.byType(InkWell)).first),
      ];
      expect(tiles.map((t) => t.height).toSet(), hasLength(1), reason: '$tiles');
      expect(tiles.map((t) => t.width).toSet(), hasLength(1), reason: '$tiles');
    });

    testWidgets('la barra tiene tres controles y el cambio de vista tiene texto', (tester) async {
      await _pumpPhone(tester, source: 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byTooltip('Más opciones'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_2), findsNothing);
      expect(find.byIcon(Icons.account_tree_outlined), findsWidgets); // inside the selector only

      expect(find.text('Código'), findsOneWidget);
      expect(find.text('Diagrama'), findsOneWidget);
      expect(find.text('Programa'), findsOneWidget); // the tab never renames itself

      await tester.tap(find.text('Diagrama'));
      await tester.pumpAndSettle();
      expect(find.text('Programa'), findsOneWidget);
      expect(find.text('Es el mismo programa dibujado. Toca un bloque para ver su línea de código.'), findsOneWidget);
    });

    testWidgets('el menú pone Retos y Programas primero, y lo demás en Más', (tester) async {
      await _pumpPhone(tester, source: 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Retos'), findsOneWidget);
      expect(find.text('Mis programas'), findsOneWidget);
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Guía'), findsOneWidget); // in sight, not folded away
      // No mode switch, name or profile rows in the menu any more.
      expect(find.text('Básico'), findsNothing);
      expect(find.text('Escribe tu nombre'), findsNothing);
      expect(find.textContaining('profesor'), findsNothing);
      // Folded away until opened.
      expect(find.text('Comunidad'), findsNothing);
      await tester.tap(find.text('Más'));
      await tester.pumpAndSettle();
      expect(find.text('Comunidad'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);
    });

    testWidgets('Empezar desde cero abre el Reto 1 con la primera pista', (tester) async {
      await _pumpPhone(tester, values: {});
      expect(find.text('¡Hola! ¿Cómo quieres empezar?'), findsOneWidget);
      expect(find.text('Empezar desde cero'), findsOneWidget);
      expect(find.text('Ya sé algo de programar'), findsOneWidget);
      expect(find.text('Soy profesor'), findsOneWidget);

      await tester.tap(find.text('Empezar desde cero'));
      await tester.pumpAndSettle();
      expect(find.text('Un programa es una lista de instrucciones'), findsOneWidget);
      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();
      expect(find.text('Reto 1'), findsOneWidget);
      expect(find.text('Escribe aquí tu programa. Cada instrucción va en su línea.'), findsOneWidget);
      // The blank program of a first launch did not stay behind.
      expect(ProgramStore(_prefs).programs.where(ProgramStore.isBlank), isEmpty);
    });

    testWidgets('el tour avanza al escribir, al ejecutar y al abrir Pruebas', (tester) async {
      await _pumpPhone(tester, values: {});
      await tester.tap(find.text('Empezar desde cero'));
      await tester.pumpAndSettle();
      // Four small ideas first, then the balloons.
      for (final title in ['Mostrar, preguntar y guardar', 'Código o diagrama: tú eliges', 'Cómo sabes si está bien']) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }
      await tester.tap(find.text('Empezar el reto'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe aquí tu programa. Cada instrucción va en su línea.'), findsOneWidget);

      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('Toca Ejecutar, el triángulo de arriba, para correr tu programa.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Programa'));
      await tester.pumpAndSettle();
      expect(find.text('Toca Pruebas para saber si está bien.'), findsOneWidget);

      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).tourStep, 3);
      expect(find.text('Toca Pruebas para saber si está bien.'), findsNothing);
    });

    testWidgets('Saltar guía termina el tour', (tester) async {
      await _pumpPhone(tester, values: {});
      await tester.tap(find.text('Empezar desde cero'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Saltar guía'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).tourStep, 3);
    });

    testWidgets('Ya sé algo de programar abre Hola mundo sin globos', (tester) async {
      await _pumpPhone(tester, values: {});
      await tester.tap(find.text('Ya sé algo de programar'));
      await tester.pumpAndSettle();
      expect(find.text('Así funciona Jaguar'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('hola_mundo'), findsOneWidget);
      expect(find.text('Escribe aquí tu programa. Cada instrucción va en su línea.'), findsNothing);
      expect(ViewSettings(_prefs).mode, AppMode.full);
    });

    testWidgets('Soy profesor pide confirmar antes de activarse', (tester) async {
      await _pumpPhone(tester, values: {});
      await tester.tap(find.text('Soy profesor'));
      await tester.pumpAndSettle();
      expect(find.text('Modo profesor'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).teacher, isFalse);
      expect(find.text('¡Hola! ¿Cómo quieres empezar?'), findsOneWidget);

      await tester.tap(find.text('Soy profesor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activar modo profesor'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).teacher, isTrue);
      expect(find.text('Mis ejercicios'), findsOneWidget);
    });

    testWidgets('el primer programa que corre se celebra una sola vez', (tester) async {
      await _pumpPhone(tester, source: 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      expect(find.text('¡Tu primer programa corrió!'), findsOneWidget);
      expect(ViewSettings(_prefs).firstRunDone, isTrue);
      await tester.pumpAndSettle(const Duration(seconds: 6));

      await tester.tap(find.text('Programa'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(find.text('¡Tu primer programa corrió!'), findsNothing);
    });

    testWidgets('un programa sin salida lo dice, sin rojo', (tester) async {
      await _pumpPhone(
        tester,
        values: {'jaguar.view.mode': 'basic', 'jaguar.view.firstRunDone': true},
        source: 'Algoritmo callado\n    x <- 1\nFinAlgoritmo\n',
      );
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();
      expect(find.text('Tu programa terminó, pero no mostró nada.'), findsOneWidget);
      expect(find.textContaining('Error'), findsNothing);
    });

    testWidgets('una línea a medias no marca error mientras se escribe', (tester) async {
      await _pumpPhone(tester, source: 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      final editor = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;
      await tester.enterText(editor, 'Algoritmo hola\n    Escribir "hola\nFinAlgoritmo\n');
      await tester.pump(const Duration(seconds: 1));
      // The cursor is at the end of the text, not on line 2: the error shows…
      expect(find.textContaining('Línea 2'), findsOneWidget);
      // …but a block left open is never a mistake while typing.
      await tester.enterText(editor, 'Algoritmo hola\n    Si 1 > 0 Entonces\n        Escribir 1\nFinAlgoritmo\n');
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Línea'), findsNothing);
    });

    testWidgets('con la letra al 130 % la barra y el menú siguen cabiendo', (tester) async {
      await _pumpPhone(
        tester,
        source: 'Algoritmo un_nombre_bastante_largo\n    Escribir "hola"\nFinAlgoritmo\n',
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('pruebas', () {
    Future<void> openChallenge(WidgetTester tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3});
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retos'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saludo'));
      await tester.pumpAndSettle();
    }

    testWidgets('antes de probar todo es neutro; tras editar, gris y no rojo', (tester) async {
      await openChallenge(tester);
      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      expect(find.text('3 pruebas'), findsOneWidget);
      expect(find.text('Aún no has probado. Toca Probar para ver si tu programa las pasa.'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);

      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      expect(find.text('0 de 3 pruebas correctas'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsWidgets);

      await tester.tap(find.text('Programa'));
      await tester.pumpAndSettle();
      final editor = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;
      await tester.enterText(editor, 'Algoritmo saludo\n    Escribir "Hola"\nFinAlgoritmo\n');
      await tester.pump();
      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      expect(find.text('Desactualizado: cambiaste el código desde la última prueba.'), findsOneWidget);
      expect(find.byIcon(Icons.cancel, skipOffstage: false), findsNothing);
      expect(find.byIcon(Icons.cancel_outlined, skipOffstage: false), findsWidgets);
    });

    testWidgets('el resultado sigue ahí al cambiar de pestaña y al reabrir el programa', (tester) async {
      await openChallenge(tester);
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Consola'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      expect(find.text('0 de 3 pruebas correctas'), findsOneWidget);
    });

    testWidgets('reto superado: tarjeta con Siguiente reto', (tester) async {
      await openChallenge(tester);
      final editor = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;
      await tester.enterText(editor, 'Algoritmo saludo\n    Leer n\n    Escribir "Hola, " + n\nFinAlgoritmo\n');
      await tester.pump();
      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      expect(find.text('¡Reto superado!'), findsWidgets);
      expect(find.text('Siguiente reto'), findsOneWidget);
      expect(find.text('Mostrar al profesor'), findsNothing);
    });

    testWidgets('con animaciones desactivadas todo aparece igual', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await openChallenge(tester);
      final editor = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;
      await tester.enterText(editor, 'Algoritmo saludo\n    Leer n\n    Escribir "Hola, ", n\nFinAlgoritmo\n');
      await tester.pump();
      await tester.tap(find.text('Pruebas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      expect(find.text('¡Reto superado!'), findsWidgets);
    });
  });
}
