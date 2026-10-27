import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/lessons/lesson_screen.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ayudas.dart';

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
  bool openEditor = true,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await _prefsWith(values);
  final store = ProgramStore(_prefs);
  if (source != null) store.openSource(source);
  await tester.pumpWidget(
    JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs), openEditor: openEditor),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('lo escrito se guarda al pasar a segundo plano, sin esperar al temporizador', (tester) async {
    final store = await _pumpPhone(tester, source: 'Algoritmo x\nFinAlgoritmo\n');
    await tester.enterText(find.byType(EditableText).first, 'Algoritmo x\n    Escribir 1\nFinAlgoritmo\n');
    // No pump: the delayed save has not run yet.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(ProgramStore(_prefs).current.source, contains('Escribir 1'));
    expect(store.current.source, contains('Escribir 1'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

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
    testWidgets('borrar el único programa deja el taller vacío y se puede deshacer', (tester) async {
      final store = await _pumpPhone(
        tester,
        source: 'Algoritmo mio\n    Escribir 1\nFinAlgoritmo\n',
        openEditor: false,
      );
      // The blank program of a first launch stays in the list next to it.
      for (final program in store.programs.where(ProgramStore.isBlank).toList()) {
        store.delete(program);
      }
      await tester.pumpAndSettle();
      expect(store.programs, hasLength(1));

      await irASala(tester, 'Taller');
      await tester.tap(find.byTooltip('Eliminar "mio"'));
      await tester.pumpAndSettle();
      expect(
        find.text('Es tu único programa. Después verás el inicio para empezar otro. Las copias guardadas no cambian.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Eliminar').last);
      await tester.pumpAndSettle();

      expect(store.isEmpty, isTrue);
      expect(find.text('Tu taller está vacío'), findsOneWidget);
      expect(find.text('Programa eliminado'), findsOneWidget);
      expect(find.byType(CodeEditor), findsNothing);

      await tester.tap(find.text('Deshacer'));
      await tester.pumpAndSettle();
      expect(store.programs, hasLength(1));
      expect(find.text('Tu taller está vacío'), findsNothing);
      expect(find.text('mio'), findsOneWidget);
      // Still in the rooms: nothing opened by itself.
      expect(find.byType(CodeEditor), findsNothing);
    });

    testWidgets('el inicio de un primer uso es un portal con las tres secciones, sin scroll', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.programs': '[]'}, openEditor: false);
      expect(find.textContaining('Soy Jaguar'), findsOneWidget);
      // Ruta, Taller and Clases, each saying where you stand.
      expect(find.text('Ruta'), findsOneWidget);
      expect(find.text('Empieza aquí: Tu primer programa'), findsOneWidget);
      expect(find.text('Taller'), findsOneWidget);
      expect(find.text('0 programas'), findsOneWidget);
      expect(find.text('Clases'), findsOneWidget);
      expect(find.byType(CodeEditor), findsNothing);
      // No bottom bar and no buttons inside the cards: the card is the way in.
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
      // Everything fits: nothing to scroll.
      expect(find.byType(Scrollable), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('las cuatro salas caben con letra grande', (tester) async {
      await _pumpPhone(
        tester,
        values: {'jaguar.view.mode': 'basic', 'jaguar.programs': '[]'},
        textScale: 1.3,
        openEditor: false,
      );
      expect(tester.takeException(), isNull, reason: 'Inicio');
      for (final room in ['Ruta', 'Clases', 'Taller']) {
        await irASala(tester, room);
        expect(tester.takeException(), isNull, reason: room);
      }
    });

    testWidgets('la Ruta agrupa lecciones y retos, y abre el reto que se toca', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3}, openEditor: false);
      await irASala(tester, 'Ruta');
      expect(find.text('Primeros pasos'), findsOneWidget);
      expect(find.text('0 de 2'), findsOneWidget);
      expect(find.text('Tu primer programa'), findsOneWidget);
      expect(find.text('Saludo'), findsOneWidget);
      await tester.tap(find.text('Saludo'));
      await tester.pumpAndSettle();
      expect(find.text('Ruta · Nivel 1 · Reto 1'), findsOneWidget);
      expect(find.byType(CodeEditor), findsOneWidget);
      // Atrás comes back to the room, not out of the app.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(CodeEditor), findsNothing);
      expect(find.text('Primeros pasos'), findsOneWidget);
    });

    testWidgets('la Ruta avisa que nada está bloqueado', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3}, openEditor: false);
      await irASala(tester, 'Ruta');
      await tester.scrollUntilVisible(find.textContaining('Nada está bloqueado'), 200);
      expect(find.textContaining('Nada está bloqueado'), findsOneWidget);
    });

    testWidgets('el Taller lista y busca, y marca de dónde viene cada programa', (tester) async {
      final store = await _pumpPhone(
        tester,
        source: 'Algoritmo promedio\n    Escribir 1\nFinAlgoritmo\n',
        openEditor: false,
      );
      store.create('Algoritmo suma\n    Escribir 2\nFinAlgoritmo\n');
      await tester.pumpAndSettle();
      await irASala(tester, 'Taller');
      expect(find.text('promedio'), findsOneWidget);
      expect(find.text('suma'), findsOneWidget);
      expect(find.text('Mío'), findsWidgets);

      await tester.enterText(find.byType(TextField), 'prom');
      await tester.pumpAndSettle();
      expect(find.text('promedio'), findsOneWidget);
      expect(find.text('suma'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('Ningún programa se llama así.'), findsOneWidget);
    });

    testWidgets('Ajustes está en Inicio y trae Acerca de', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3}, openEditor: false);
      await tester.tap(find.byTooltip('Ajustes'));
      await tester.pumpAndSettle();
      expect(find.text('Modo y perfil'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Acerca de Jaguar Code'), 200);
      expect(find.text('Acerca de Jaguar Code'), findsOneWidget);
    });

    testWidgets('la barra tiene tres controles y el cambio de vista tiene texto', (tester) async {
      await _pumpPhone(tester, source: 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byTooltip('Más opciones'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.byIcon(Icons.qr_code_2), findsNothing);
      expect(find.text('Bloques'), findsOneWidget); // inside the selector only

      expect(find.text('Código'), findsOneWidget);
      expect(find.text('Diagrama'), findsOneWidget);
      expect(find.text('Programa'), findsOneWidget); // the tab never renames itself

      await tester.tap(find.text('Diagrama'));
      await tester.pumpAndSettle();
      expect(find.text('Programa'), findsOneWidget);
      expect(find.text('Es el mismo programa dibujado. Toca un bloque para ver su línea de código.'), findsOneWidget);
    });

    testWidgets('Empezar desde cero abre la lección 1, sin pasar por la introducción', (tester) async {
      await _pumpPhone(tester, values: {}, openEditor: false);
      expect(find.text('¡Hola! Esto es Jaguar Code'), findsOneWidget);
      expect(find.text('Empezar desde cero'), findsOneWidget);
      expect(find.text('Ya sé algo de programar'), findsOneWidget);
      expect(find.text('Soy profesor'), findsOneWidget);

      await tester.tap(find.text('Empezar desde cero'));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
      expect(find.text('Un programa es una lista de instrucciones'), findsNothing);
      // The balloons wait for the first challenge.
      expect(ViewSettings(_prefs).tourStep, 0);
      // The blank program of a first launch did not stay behind.
      expect(ProgramStore(_prefs).programs.where(ProgramStore.isBlank), isEmpty);
    });

    testWidgets('el tour avanza al escribir, al ejecutar y al abrir Pruebas', (tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 0}, openEditor: false);
      await irASala(tester, 'Ruta');
      await tester.tap(find.text('Saludo'));
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
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 0}, openEditor: false);
      await irASala(tester, 'Ruta');
      await tester.tap(find.text('Saludo'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Saltar guía'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).tourStep, 3);
    });

    testWidgets('Ya sé algo de programar abre Hola mundo sin globos', (tester) async {
      await _pumpPhone(tester, values: {}, openEditor: false);
      await tester.tap(find.text('Ya sé algo de programar'));
      await tester.pumpAndSettle();
      expect(find.text('Así funciona Jaguar Code'), findsOneWidget);
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(find.text('hola_mundo'), findsOneWidget);
      expect(find.text('Escribe aquí tu programa. Cada instrucción va en su línea.'), findsNothing);
      expect(ViewSettings(_prefs).mode, AppMode.full);
    });

    testWidgets('Soy profesor pide confirmar antes de activarse', (tester) async {
      await _pumpPhone(tester, values: {}, openEditor: false);
      await tester.tap(find.text('Soy profesor'));
      await tester.pumpAndSettle();
      expect(find.text('Modo profesor'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).teacher, isFalse);
      expect(find.text('¡Hola! Esto es Jaguar Code'), findsOneWidget);

      await tester.tap(find.text('Soy profesor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activar modo profesor'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).teacher, isTrue);
      await irASala(tester, 'Clases');
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
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('pruebas', () {
    Future<void> openChallenge(WidgetTester tester) async {
      await _pumpPhone(tester, values: {'jaguar.view.mode': 'basic', 'jaguar.view.tourStep': 3}, openEditor: false);
      await irASala(tester, 'Ruta');
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
      await tester.scrollUntilVisible(find.byIcon(Icons.cancel_outlined), 100);
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
