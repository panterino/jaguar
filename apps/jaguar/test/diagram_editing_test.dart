import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/diagram/block_dialogs.dart';
import 'package:jaguar/src/diagram/diagram_editing.dart';
import 'package:jaguar/src/editor/syntax_controller.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// A screen with one button that runs [action] with a real context.
Future<void> pumpWith(WidgetTester tester, Future<void> Function(BuildContext) action) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => action(context), child: const Text('go')),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

InsertPoint mainEnd(Program program) =>
    flowchartsFor(program).first.inserts.lastWhere((i) => i.point.headerLine == 1).point;

void main() {
  const empty = 'Algoritmo saludo\n    \nFinAlgoritmo\n';

  testWidgets('agregar una Salida escrita como en DFD queda en PSeInt', (tester) async {
    final code = SyntaxController(text: empty);
    final program = parse(code.text);
    final editing = DiagramEditing(code: code, notation: Notation.dfd);
    await pumpWith(tester, (context) => editing.insert(context, program, mainEnd(program), BlockKind.salida));

    expect(find.text('Salida'), findsOneWidget);
    await tester.enterText(find.byType(TextField), "'Hola, ', SQRT(16)");
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(code.text, contains('    Escribir "Hola, ", Raiz(16)'));
    expect(find.text('Salida'), findsNothing);
  });

  testWidgets('un error se explica en el diálogo y no cambia el código', (tester) async {
    final code = SyntaxController(text: empty);
    final program = parse(code.text);
    final editing = DiagramEditing(code: code, notation: Notation.pseint);
    await pumpWith(tester, (context) => editing.insert(context, program, mainEnd(program), BlockKind.asignacion));

    await tester.enterText(find.byType(TextField).at(0), 'total');
    await tester.enterText(find.byType(TextField).at(1), '3 +');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(find.text('Asignación'), findsOneWidget, reason: 'el diálogo sigue abierto');
    expect(find.textContaining('Falta un valor'), findsOneWidget);
    expect(code.text, empty);
  });

  testWidgets('el Ciclo Para pide contador, inicio, fin e incremento', (tester) async {
    final code = SyntaxController(text: empty);
    final program = parse(code.text);
    final editing = DiagramEditing(code: code, notation: Notation.dfd);
    await pumpWith(tester, (context) => editing.insert(context, program, mainEnd(program), BlockKind.para));
    await tester.enterText(find.byType(TextField).at(2), '10');
    await tester.enterText(find.byType(TextField).at(3), '2');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(code.text, contains('    Para i <- 1 Hasta 10 Con Paso 2 Hacer\n    FinPara'));
  });

  testWidgets('editar una decisión cambia solo su línea', (tester) async {
    const source =
        'Algoritmo a\n    Leer n\n    Si n > 0 Entonces // revisa\n        Escribir n\n    FinSi\nFinAlgoritmo\n';
    final code = SyntaxController(text: source);
    final program = parse(source);
    final block = flowchartsFor(program).first.blockForLine(3)!;
    final editing = DiagramEditing(code: code, notation: Notation.dfd);
    await pumpWith(tester, (context) => editing.edit(context, program, block));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'n > 0');
    await tester.enterText(find.byType(TextField), 'n >= 0 AND n != 5');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(code.text, source.replaceFirst('Si n > 0 Entonces', 'Si n >= 0 Y n <> 5 Entonces'));
  });

  test('eliminar un bloque', () {
    const source = 'Algoritmo a\n    Leer n\n    Escribir n\nFinAlgoritmo\n';
    final code = SyntaxController(text: source);
    final program = parse(source);
    DiagramEditing(
      code: code,
      notation: Notation.pseint,
    ).delete(program, flowchartsFor(program).first.blockForLine(2)!);
    expect(code.text, 'Algoritmo a\n    Escribir n\nFinAlgoritmo\n');
  });

  testWidgets('tocar Inicio cambia el nombre del algoritmo', (tester) async {
    final code = SyntaxController(text: empty);
    final program = parse(code.text);
    final inicio = flowchartsFor(program).first.blocks.first;
    final editing = DiagramEditing(code: code, notation: Notation.pseint);
    await pumpWith(tester, (context) => editing.edit(context, program, inicio));
    await tester.enterText(find.byType(TextField), 'area del circulo');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('sin espacios'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'area_circulo');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(code.text, startsWith('Algoritmo area_circulo\n'));
  });
}
