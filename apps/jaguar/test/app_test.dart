import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/console/console_view.dart';
import 'package:jaguar/src/diagram/diagram_view.dart';
import 'package:jaguar/src/editor/auto_indent.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/editor/syntax_controller.dart';
import 'package:jaguar/src/exercises/exercise_editor_screen.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/share/share_codec.dart';
import 'package:jaguar/src/workspace/app_menus.dart';
import 'package:jaguar/src/workspace/programs_sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences _prefs;

Future<ProgramStore> _store([String? source, String? mode = 'full']) async {
  // Already answered the welcome question, unless a test asks for it.
  SharedPreferences.setMockInitialValues({'jaguar.view.mode': ?mode});
  _prefs = await SharedPreferences.getInstance();
  final store = ProgramStore(_prefs);
  if (source != null) store.openSource(source);
  return store;
}

TextEditingValue _typeEnter(String before) {
  final old = TextEditingValue(
    text: before,
    selection: TextSelection.collapsed(offset: before.length),
  );
  final typed = TextEditingValue(
    text: '$before\n',
    selection: TextSelection.collapsed(offset: before.length + 1),
  );
  return AutoIndentFormatter().formatEditUpdate(old, typed);
}

Finder _inConsole(String text) =>
    find.descendant(of: find.byType(ConsoleView), matching: find.textContaining(text, findRichText: true));

void main() {
  group('enlaces para compartir', () {
    test('ida y vuelta conserva el programa, con acentos', () {
      const source = 'Algoritmo año\n    Escribir "¿Qué tal? ñ"\nFinAlgoritmo\n';
      final link = shareLink(source);
      expect(link, startsWith(shareBaseUrl));
      expect((contentFromLink(link)! as SharedProgram).source, source);
    });

    test('enlaces sin programa o dañados', () {
      expect(contentFromLink('https://jaguar-edu.web.app/'), isNull);
      expect(contentFromLink('https://jaguar-edu.web.app/#p=@@@'), isNull);
      expect(contentFromLink('no es un enlace'), isNull);
    });
  });

  group('autoindentación', () {
    test('mantiene la sangría', () {
      expect(_typeEnter('    a <- 1').text, '    a <- 1\n    ');
    });

    test('agrega un nivel después de abrir un bloque, y escribe su cierre', () {
      expect(_typeEnter('    Si x > 1 Entonces').text, '    Si x > 1 Entonces\n        \n    FinSi');
      expect(_typeEnter('Para i <- 1 Hasta 3 Hacer').text, 'Para i <- 1 Hasta 3 Hacer\n    \nFinPara');
      expect(_typeEnter('Algoritmo prueba').text, 'Algoritmo prueba\n    \nFinAlgoritmo');
    });

    test('escribir un programa completo letra por letra queda bien indentado', () {
      final formatter = AutoIndentFormatter();
      var value = const TextEditingValue();
      const typed =
          'Algoritmo a\nLeer n\nSi n > 0 Entonces\nEscribir "positivo"\nSiNo\nEscribir "no"\nFinSi\n'
          'Para i <- 1 Hasta 3 Hacer\nEscribir i\nFinPara\nRepetir\nn <- n - 1\nHasta Que n < 0\nFinAlgoritmo';
      for (final char in typed.split('')) {
        final offset = value.selection.baseOffset < 0 ? 0 : value.selection.baseOffset;
        final next = TextEditingValue(
          text: value.text.replaceRange(offset, offset, char),
          selection: TextSelection.collapsed(offset: offset + 1),
        );
        value = formatter.formatEditUpdate(value, next);
      }
      expect(
        value.text,
        'Algoritmo a\n'
        '    Leer n\n'
        '    Si n > 0 Entonces\n'
        '        Escribir "positivo"\n'
        '    SiNo\n'
        '        Escribir "no"\n'
        '    FinSi\n'
        '    Para i <- 1 Hasta 3 Hacer\n'
        '        Escribir i\n'
        '    FinPara\n'
        '    Repetir\n'
        '        n <- n - 1\n'
        '    Hasta Que n < 0\n'
        'FinAlgoritmo',
      );
    });

    test('no agrega nivel después de cerrar', () {
      expect(_typeEnter('    FinSi').text, '    FinSi\n    ');
      expect(_typeEnter('Hasta Que x = 1').text, 'Hasta Que x = 1\n');
    });
  });

  test('insertar fragmento respeta la sangría y el cursor', () {
    final controller = SyntaxController(text: '    ')..selection = const TextSelection.collapsed(offset: 4);
    controller.insertSnippet('Si § Entonces\n    \nFinSi');
    expect(controller.text, '    Si  Entonces\n        \n    FinSi');
    expect(controller.selection.baseOffset, 7);
  });

  group('comandos del editor', () {
    SyntaxController select(String text, int start, [int? end]) =>
        SyntaxController(text: text)..selection = TextSelection(baseOffset: start, extentOffset: end ?? start);

    test('comentar y descomentar las líneas seleccionadas', () {
      const source = 'Algoritmo a\n    Leer n\n    Escribir n\nFinAlgoritmo';
      final controller = select(source, 14, 35);
      controller.toggleComment();
      expect(controller.text, 'Algoritmo a\n    // Leer n\n    // Escribir n\nFinAlgoritmo');
      controller.toggleComment();
      expect(controller.text, source);
    });

    test('comentar una sola línea deja el cursor en su lugar', () {
      final controller = select('    Leer n', 9);
      controller.toggleComment();
      expect(controller.text, '    // Leer n');
      expect(controller.selection.baseOffset, 12);
    });

    test('sangrar y quitar sangría a varias líneas', () {
      final controller = select('a\n\nb\nc', 0, 5);
      controller.indentLines(indentUnit);
      expect(controller.text, '    a\n\n    b\nc');
      controller.dedentLines(indentUnit);
      expect(controller.text, 'a\n\nb\nc');
    });

    test('posición del cursor', () {
      expect(select('ab\ncde', 5).cursorPosition, (2, 3));
      expect(select('', 0).cursorPosition, (1, 1));
    });
  });

  test('nombre del programa', () {
    expect(programName('// hola\nAlgoritmo   suma_dos\nFinAlgoritmo'), 'suma_dos');
    expect(programName('Proceso calc;'), 'calc');
    expect(programName(''), 'sin_nombre');
  });

  testWidgets('ejecuta un programa que lee un dato', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = await _store(
      'Algoritmo saludo\n    Escribir "¿Cómo te llamas?"\n    Leer nombre\n    Escribir "Hola, ", nombre\nFinAlgoritmo\n',
    );
    await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));
    expect(find.text('saludo'), findsOneWidget);

    await tester.tap(find.text('Ejecutar'));
    await tester.pumpAndSettle();
    expect(_inConsole('¿Cómo te llamas?'), findsOneWidget);
    expect(find.text('El programa espera un dato (Leer)…'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Ana');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_inConsole('Hola, Ana'), findsOneWidget);
    expect(find.text('Programa terminado'), findsOneWidget);
  });

  testWidgets('muestra el error con sugerencia y lleva a la línea', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = await _store('Algoritmo error\n    Escrivir "hola"\nFinAlgoritmo\n');
    await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));
    await tester.tap(find.text('Ejecutar'));
    await tester.pumpAndSettle();

    expect(find.text('Error de sintaxis en la línea 2'), findsOneWidget);
    expect(find.text("¿Quisiste decir 'Escribir'?"), findsOneWidget);

    await tester.tap(find.text('Ir a la línea 2'));
    await tester.pump();
    final editor = tester.widget<TextField>(find.byType(TextField).first);
    final selection = editor.controller!.selection;
    expect(editor.controller!.text.substring(selection.start, selection.end), '    Escrivir "hola"');
  });

  testWidgets('en celular Atrás cierra el menú y pide confirmar antes de salir', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = await _store('Algoritmo hola\nFinAlgoritmo\n');
    await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));
    await tester.pumpAndSettle();
    final scaffold = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffold.openDrawer();
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Presiona Atrás otra vez para salir'), findsOneWidget);
  });

  testWidgets('en celular cambia entre código y consola', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final store = await _store('Algoritmo hola\n    Escribir "hola desde el cel"\nFinAlgoritmo\n');
    await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));
    expect(find.text('Código'), findsOneWidget);
    expect(find.text('<-'), findsOneWidget); // keyword bar

    await tester.tap(find.byTooltip('Ejecutar'));
    await tester.pumpAndSettle();
    expect(_inConsole('hola desde el cel'), findsOneWidget);
  });

  testWidgets('abrir un ejemplo o crear un programa no pisa el anterior', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const mine = 'Algoritmo mio\n    Escribir 1\nFinAlgoritmo\n';
    final store = await _store(mine);
    await tester.pumpWidget(JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)));

    await tester.tap(find.byTooltip('Abrir menú de navegación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comunidad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tabla de multiplicar'));
    await tester.pumpAndSettle();

    expect(store.current.name, 'tabla');
    expect(store.current.source, contains('Para i <- 1 Hasta 10'));
    expect(store.programs.where((p) => p.source == mine), hasLength(1));

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nuevo programa'));
    await tester.pumpAndSettle();
    expect(store.current.source, newProgramTemplate);
    expect(store.programs.where((p) => p.name == 'tabla'), hasLength(1));
  });

  group('escritorio', () {
    Future<ProgramStore> pumpDesktop(WidgetTester tester, String source, {String? mode = 'full'}) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = await _store(source, mode);
      await tester.pumpWidget(
        JaguarApp(store: store, exercises: ExerciseStore(_prefs), settings: ViewSettings(_prefs)),
      );
      return store;
    }

    testWidgets('barra de menús, panel de programas y barra de estado', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n');
      expect(find.byType(AppMenuBar), findsOneWidget);
      expect(find.byType(ProgramsSidebar), findsOneWidget);
      expect(find.text('Lín. 1, col. 1'), findsOneWidget);
      expect(find.text('<-'), findsNothing); // the keyword bar is for touch screens

      await tester.tap(find.text('Ver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Panel de programas'));
      await tester.pumpAndSettle();
      expect(find.byType(ProgramsSidebar), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Ctrl+Enter ejecuta y el estado lo cuenta', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\n    Escribir "hola desde la PC"\nFinAlgoritmo\n');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(_inConsole('hola desde la PC'), findsOneWidget);
      expect(find.text('Programa terminado'), findsWidgets);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('la primera vez pregunta cómo empezar', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\nFinAlgoritmo\n', mode: null);
      await tester.pumpAndSettle();
      expect(find.text('¡Hola! ¿Cómo quieres empezar?'), findsOneWidget);
      await tester.tap(find.text('Empezar desde cero'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saltar'));
      await tester.pumpAndSettle();
      expect(ViewSettings(_prefs).mode, AppMode.basic);
      expect(find.text('Básico'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Básico muestra menos y Completo todo', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\nFinAlgoritmo\n', mode: 'basic');
      expect(find.text('Archivo'), findsOneWidget);
      expect(find.text('Ver'), findsNothing);
      expect(find.text('Editar'), findsNothing);
      expect(find.text('Guardar'), findsOneWidget); // buttons with text
      expect(find.text('<-'), findsOneWidget); // keyword bar as a reminder
      expect(find.text('Línea 1'), findsOneWidget);

      await tester.tap(find.text('Completo'));
      await tester.pumpAndSettle();
      expect(find.text('Ver'), findsOneWidget);
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('<-'), findsNothing);
      expect(find.text('Lín. 1, col. 1'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('en Básico los atajos siguen funcionando', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\n    Escribir "atajo"\nFinAlgoritmo\n', mode: 'basic');
      await tester.sendKeyEvent(LogicalKeyboardKey.f9);
      await tester.pumpAndSettle();
      expect(_inConsole('atajo'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('el diagrama aparece junto al código y sigue al cursor', (tester) async {
      await pumpDesktop(
        tester,
        'Algoritmo hola\n    Leer n\n    Si n > 0 Entonces\n        Escribir n\n    FinSi\nFinAlgoritmo\n',
      );
      await tester.tap(find.text('Ambos'));
      await tester.pumpAndSettle();
      expect(find.byType(DiagramView), findsOneWidget);
      expect(find.byType(CodeEditor), findsOneWidget);

      // A typo keeps the last diagram and says where the error is.
      await tester.enterText(find.byType(TextField).first, 'Algoritmo hola\n    Si n > Entonces\nFinAlgoritmo\n');
      // Half a word is not a mistake yet: the notice waits a moment.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Corrige el error de la línea 2 para actualizar el diagrama.'), findsNothing);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Corrige el error de la línea 2 para actualizar el diagrama.'), findsOneWidget);

      await tester.tap(find.text('Diagrama'));
      await tester.pumpAndSettle();
      expect(find.byType(CodeEditor), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('paso a paso: pausa, avanza, muestra variables y termina', (tester) async {
      await pumpDesktop(
        tester,
        'Algoritmo pasos\n    a <- 1\n    Leer b\n    a <- a + b\n    Escribir a\nFinAlgoritmo\n',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.pumpAndSettle();
      expect(find.text('Paso a paso · línea 2'), findsOneWidget);
      expect(find.text('VARIABLES'), findsOneWidget);

      await tester.tap(find.text('Siguiente paso'));
      await tester.pumpAndSettle();
      expect(find.text('Paso a paso · línea 3'), findsOneWidget);
      expect(find.text('a'), findsOneWidget); // a <- 1 already ran

      await tester.tap(find.text('Siguiente paso'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '41');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Paso a paso · línea 4'), findsOneWidget);

      await tester.tap(find.byTooltip('Ejecutar el resto sin pausas'));
      await tester.pumpAndSettle();
      expect(_inConsole('42'), findsOneWidget);
      expect(find.text('Programa terminado'), findsWidgets);
      expect(find.text('42'), findsOneWidget); // the final value of a in the table
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('como en DFD: ejecutar hasta aquí (F4) y evaluar', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hasta_aqui\n    a <- 1\n    b <- a + 1\n    Escribir a + b\nFinAlgoritmo\n');
      final editor = tester.widget<TextField>(find.byType(TextField).first);
      editor.controller!.selection = const TextSelection.collapsed(offset: 50); // línea 4
      await tester.sendKeyEvent(LogicalKeyboardKey.f4);
      await tester.pumpAndSettle();
      expect(find.text('Paso a paso · línea 4'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Evaluar'), 'b * 10 = 20 AND .V.');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('= VERDADERO'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('pausar una ejecución normal pasa a paso a paso', (tester) async {
      // Esperar lets the clock of the test move; a tight loop would never
      // give the interface a turn.
      await pumpDesktop(
        tester,
        'Algoritmo eterno\n    i <- 0\n    Mientras Verdadero Hacer\n        Esperar 1 Segundos\n        i <- i + 1\n    FinMientras\nFinAlgoritmo\n',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.f9);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Pausar'));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Paso a paso · línea 5'), findsOneWidget);
      await tester.tap(find.text('Detener'));
      await tester.pumpAndSettle();
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('las herramientas de profesor solo para profesores, y el perfil se cambia cuando sea', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\nFinAlgoritmo\n');
      expect(find.text('Mis ejercicios'), findsNothing);

      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profesor'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Mis ejercicios'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('retos: abrir, ver pistas, resolver y quedar marcado', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\nFinAlgoritmo\n');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retos'));
      await tester.pumpAndSettle();
      expect(find.text('Llevas 0 de 10.', findRichText: true), findsNothing);
      await tester.tap(find.text('Saludo'));
      await tester.pumpAndSettle();
      expect(find.text('Reto 1 · Saludo'), findsOneWidget);
      await tester.tap(find.byTooltip('Pistas'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Necesitas una variable'), findsOneWidget);
      await tester.tap(find.text('A intentarlo'));
      await tester.pumpAndSettle();
      final editor = find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first;
      await tester.enterText(editor, 'Algoritmo saludo\n    Leer n\n    Escribir "Hola, ", n\nFinAlgoritmo\n');
      await tester.tap(find.text('Probar').first);
      await tester.pumpAndSettle();
      expect(find.text('¡Reto superado!'), findsWidgets);
      expect(find.text('Mostrar al profesor'), findsNothing);
      await tester.tap(find.text('Siguiente reto'));
      await tester.pumpAndSettle();
      expect(find.text('Reto 2 · Área del rectángulo'), findsOneWidget);
      await tester.tap(find.text('Retos'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Llevas 1 de 10'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('el planteamiento queda como comentarios al inicio', (tester) async {
      await pumpDesktop(tester, 'Algoritmo suma\n    Leer a, b\nFinAlgoritmo\n');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archivo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Planteamiento (entrada, proceso, salida)…'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Entrada'), 'dos números');
      await tester.enterText(find.widgetWithText(TextField, 'Salida'), 'la suma');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      final editor = tester.widget<TextField>(
        find.descendant(of: find.byType(CodeEditor), matching: find.byType(TextField)).first,
      );
      expect(editor.controller!.text, startsWith('// Entrada: dos números\n// Salida: la suma\nAlgoritmo suma'));
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('el menú Editar comenta la línea del cursor', (tester) async {
      await pumpDesktop(tester, 'Algoritmo hola\n    Escribir 1\nFinAlgoritmo\n');
      final editor = tester.widget<TextField>(find.byType(TextField).first);
      editor.controller!.selection = const TextSelection.collapsed(offset: 20);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Comentar o descomentar'));
      await tester.pumpAndSettle();
      expect(editor.controller!.text, contains('    // Escribir 1'));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  test('guardar un programa eliminado no hace nada', () async {
    final store = await _store('Algoritmo uno\nFinAlgoritmo\n');
    final deleted = store.current;
    store.delete(deleted);
    final before = store.current.source;
    store.update(deleted.id, 'Algoritmo fantasma\nFinAlgoritmo\n');
    expect(store.current.source, before);
    expect(store.programs.any((p) => p.name == 'fantasma'), isFalse);
  });

  group('ejercicios', () {
    const parImpar = Exercise(
      id: 'ej1',
      title: 'Par o impar',
      statement: 'Lee un número y di si es par o impar.',
      cases: [
        TestCase(inputs: ['8'], expected: '8 es par'),
        TestCase(inputs: ['7'], expected: '7 es impar'),
        TestCase(inputs: ['0'], expected: '0 es par', hidden: true),
      ],
    );

    test('enlace de ejercicio ida y vuelta', () {
      final content = contentFromLink(exerciseLink(parImpar));
      expect(content, isA<SharedExercise>());
      expect((content! as SharedExercise).exercise.toJson(), parImpar.toJson());
    });

    test('reabrir el ejercicio continúa el mismo programa', () async {
      final store = await _store();
      final first = store.openExercise(parImpar);
      expect(first.source, contains('Algoritmo par_o_impar'));
      store.update(first.id, 'Algoritmo par_o_impar\n    Escribir 1\nFinAlgoritmo\n');
      store.create(newProgramTemplate);
      final again = store.openExercise(parImpar);
      expect(again.id, first.id);
      expect(again.source, contains('Escribir 1'));
    });

    test('nombres de algoritmo a partir del título', () {
      expect(exerciseSlug('Área del círculo'), 'area_del_circulo');
      expect(exerciseSlug('3 números'), 'ejercicio_3_numeros');
      expect(exerciseSlug('¿?'), 'ejercicio');
    });

    test('la solución del profesor no viaja en el enlace', () async {
      await _store();
      final exercises = ExerciseStore(_prefs)..saveAuthored(parImpar, solution: 'Algoritmo secreta\nFinAlgoritmo');
      expect(exercises.solutionFor('ej1'), contains('secreta'));
      expect(exerciseLink(exercises.byId('ej1')!), isNot(contains('secreta')));
      final decoded = (contentFromLink(exerciseLink(parImpar))! as SharedExercise).exercise;
      expect(decoded.toJson().toString(), isNot(contains('secreta')));
    });

    Future<ExerciseStore> pumpExercise(WidgetTester tester, String solution) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = await _store();
      final exercises = ExerciseStore(_prefs)..saveReceived(parImpar);
      final program = store.openExercise(parImpar);
      store.update(program.id, solution);
      await tester.pumpWidget(JaguarApp(store: store, exercises: exercises, settings: ViewSettings(_prefs)));
      return exercises;
    }

    testWidgets('solución correcta: verificado con el nombre del alumno', (tester) async {
      final exercises = await pumpExercise(
        tester,
        'Algoritmo p\n    Escribir "Dame un número"\n    Leer n\n    Si n MOD 2 = 0 Entonces\n        Escribir n, " es par"\n    SiNo\n        Escribir n, " es impar"\n    FinSi\nFinAlgoritmo\n',
      );
      expect(find.text('Par o impar'), findsOneWidget);
      expect(find.text('3 pruebas del profesor · 1 oculta'), findsOneWidget);

      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      expect(find.text('¡Pasa todas las pruebas!'), findsOneWidget);

      await tester.tap(find.text('Mostrar al profesor'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Ana López');
      await tester.tap(find.text('Listo'));
      // The verified screen has a live clock and a pulse: it never settles.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.text('Ejercicio verificado'), findsOneWidget);
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('3 de 3 casos correctos'), findsOneWidget);
      expect(exercises.studentName, 'Ana López');
    });

    testWidgets('ver una prueba en la consola escribe sus datos sola', (tester) async {
      await pumpExercise(tester, 'Algoritmo p\n    Leer n\n    Escribir n, " es par"\nFinAlgoritmo\n');
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver esta prueba en la consola'));
      await tester.pumpAndSettle();
      expect(_inConsole('7 es par'), findsOneWidget);
      expect(find.text('Programa terminado'), findsOneWidget);
    });

    testWidgets('probar guarda el resultado del programa y avisa si cambió el código', (tester) async {
      await pumpExercise(tester, 'Algoritmo p\n    Leer n\n    Escribir n, " es par"\nFinAlgoritmo\n');
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      final store = ProgramStore(_prefs);
      expect((store.current.testsPassed, store.current.testsTotal), (2, 3));

      await tester.enterText(find.byType(TextField).first, 'Algoritmo p\nFinAlgoritmo\n');
      await tester.pump();
      expect(find.text('Desactualizado: cambiaste el código desde la última prueba.'), findsOneWidget);
    });

    testWidgets('en celular las pruebas son una pestaña', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = await _store();
      final exercises = ExerciseStore(_prefs)..saveReceived(parImpar);
      store.openExercise(parImpar);
      await tester.pumpWidget(JaguarApp(store: store, exercises: exercises, settings: ViewSettings(_prefs)));
      expect(find.text('Pruebas'), findsOneWidget);
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();
      expect(find.text('0 de 3 pruebas correctas'), findsOneWidget);
    });

    testWidgets('crear un ejercicio con un programa genera sus casos', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _store();
      const source =
          '// Lee un número y di si es par o impar.\nAlgoritmo par_o_impar\n    Leer n\n'
          '    Si n MOD 2 = 0 Entonces\n        Escribir "par"\n    SiNo\n        Escribir "impar"\n    FinSi\nFinAlgoritmo\n';
      await tester.pumpWidget(
        MaterialApp(
          home: ExerciseEditorScreen(store: ExerciseStore(_prefs), fromProgram: source),
        ),
      );
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Par o impar'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Lee un número y di si es par o impar.'), findsOneWidget);
      expect(find.textContaining('Listo:'), findsOneWidget);
    });

    testWidgets('solución incorrecta: muestra qué se esperaba y qué salió', (tester) async {
      await pumpExercise(tester, 'Algoritmo p\n    Leer n\n    Escribir n, " es par"\nFinAlgoritmo\n');
      await tester.tap(find.text('Probar'));
      await tester.pumpAndSettle();

      expect(find.text('2 de 3 pruebas correctas'), findsOneWidget);
      expect(find.text('Mostrar al profesor'), findsNothing);
      expect(find.text('7 es impar'), findsOneWidget); // Debe mostrar
      expect(find.text('Tu programa mostró'), findsOneWidget);
      expect(find.text('7 es par'), findsOneWidget);
      // The hidden test passes here (0 es par), so its data never shows.
      expect(find.text('Prueba oculta 1'), findsOneWidget);
      expect(find.text('0 es par'), findsNothing);
    });
  });
}
