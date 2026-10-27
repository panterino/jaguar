import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/blocks/blocks_view.dart';
import 'package:jaguar/src/challenges/challenges.dart';
import 'package:jaguar/src/diagram/diagram_editing.dart';
import 'package:jaguar/src/editor/syntax_controller.dart';
import 'package:jaguar/src/programs/examples.dart';
import 'package:jaguar/src/theme.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'retos_test.dart' as retos;

/// The block that says [text] (its semantics label is the whole line).
Finder _bloque(String text) => find.byWidgetPredicate((w) => w is Semantics && w.properties.label == text);

/// Blocks whose line starts with [start].
Finder _bloqueQue(String start) =>
    find.byWidgetPredicate((w) => w is Semantics && (w.properties.label ?? '').startsWith(start));

const _hola = 'Algoritmo hola\n    Escribir "hola"\nFinAlgoritmo\n';

Future<SyntaxController> _pump(WidgetTester tester, String source, {bool editable = true, int? executing}) async {
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final code = SyntaxController(text: source);
  addTearDown(code.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: BlocksView(
          code: code,
          executingLine: executing,
          editing: editable ? DiagramEditing(code: code, notation: Notation.pseint) : null,
          onTapLine: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return code;
}

void main() {
  group('todo programa del proyecto se puede mostrar en bloques', () {
    final sources = <String, String>{
      for (final (title, source) in examples) 'ejemplo $title': source,
      for (final entry in retos.solutions.entries) 'solución ${entry.key}': entry.value,
    };
    for (final entry in sources.entries) {
      testWidgets(entry.key, (tester) async {
        await _pump(tester, entry.value);
        expect(_bloqueQue('Algoritmo '), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('una decisión y un ciclo se muestran como bloques dentro de bloques', (tester) async {
    await _pump(
      tester,
      'Algoritmo a\n    Leer n\n    Si n > 1 Entonces\n        Escribir "mayor"\n    SiNo\n        Escribir "menor"\n    FinSi\n'
      '    Para i <- 1 Hasta 3 Hacer\n        Escribir i\n    FinPara\nFinAlgoritmo\n',
    );
    expect(_bloque('Algoritmo a'), findsOneWidget);
    expect(_bloque('Si n > 1 Entonces'), findsOneWidget);
    expect(find.text('SiNo'), findsOneWidget);
    expect(find.text('FinSi'), findsOneWidget);
    expect(_bloqueQue('Para i <- 1 Hasta 3'), findsOneWidget);
    expect(find.text('FinPara'), findsOneWidget);
    expect(_bloque('Leer n'), findsOneWidget);
  });

  testWidgets('agregar un bloque con el + escribe la línea en el programa', (tester) async {
    final code = await _pump(tester, _hola);
    // The ＋ under the last block.
    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    expect(find.text('¿Qué bloque quieres agregar?'), findsOneWidget);
    await tester.tap(find.text('Salida'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '"adiós"');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(code.text, contains('Escribir "adiós"'));
    // The blocks follow the code.
    expect(_bloqueQue('Escribir "adiós"'), findsOneWidget);
  });

  testWidgets('tocar un bloque lo cambia y el código lo refleja', (tester) async {
    final code = await _pump(tester, _hola);
    await tester.tap(_bloque('Escribir "hola"'));
    await tester.pumpAndSettle();
    expect(find.text('Guardar'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '"chao"');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(code.text, contains('Escribir "chao"'));
    expect(code.text, isNot(contains('"hola"')));
  });

  testWidgets('mantener pulsado ofrece eliminar el bloque', (tester) async {
    final code = await _pump(tester, _hola);
    await tester.longPress(_bloque('Escribir "hola"'));
    await tester.pumpAndSettle();
    expect(find.text('Cambiar'), findsOneWidget);
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(code.text, isNot(contains('Escribir')));
  });

  testWidgets('agregar a un Si sin SiNo escribe el SiNo', (tester) async {
    final code = await _pump(
      tester,
      'Algoritmo a\n    Leer n\n    Si n > 1 Entonces\n        Escribir "mayor"\n    FinSi\nFinAlgoritmo\n',
    );
    expect(find.text('Agregar SiNo'), findsOneWidget);
    await tester.tap(find.text('Agregar SiNo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salida'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '"menor"');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(code.text, contains('SiNo'));
    expect(code.text, contains('Escribir "menor"'));
    expect(parse(code.text).main.body.whereType<IfStmt>().single.elseBody, isNotNull);
  });

  testWidgets('mientras corre el programa los bloques solo se miran', (tester) async {
    await _pump(tester, _hola, editable: false, executing: 2);
    expect(find.byIcon(Icons.add), findsNothing);
    expect(find.textContaining('Toca un +'), findsNothing);
  });

  testWidgets('con un error no se pierden los bloques y se avisa si dura', (tester) async {
    final code = await _pump(tester, _hola);
    code.text = 'Algoritmo hola\n    Escribir "hola\nFinAlgoritmo\n';
    await tester.pump();
    // Half a word is not a mistake yet.
    expect(_bloque('Escribir "hola"'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.textContaining('Hay un error en la línea'), findsOneWidget);
    expect(_bloque('Escribir "hola"'), findsOneWidget);
  });

  testWidgets('"Así se escribe" muestra el pseudocódigo de los bloques', (tester) async {
    await _pump(tester, _hola);
    await tester.scrollUntilVisible(
      find.text('EL MISMO PROGRAMA, ESCRITO'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('EL MISMO PROGRAMA, ESCRITO'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Algoritmo hola', findRichText: true), findsWidgets);
  });

  testWidgets('la bandeja de abajo agrega un bloque al final del programa', (tester) async {
    final code = await _pump(tester, _hola);
    // The tray is the last thing on screen: its chip is the last "Escribir".
    await tester.tap(find.text('Escribir').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '"fin"');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    final lines = code.text.trimRight().split('\n');
    expect(lines.last, 'FinAlgoritmo');
    expect(lines[lines.length - 2].trim(), 'Escribir "fin"');
  });

  testWidgets('mientras corre el programa no hay bandeja', (tester) async {
    await _pump(tester, _hola, editable: false);
    expect(find.text('Mientras'), findsNothing);
  });
}
