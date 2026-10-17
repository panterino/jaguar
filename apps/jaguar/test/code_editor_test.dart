import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/editor/completions.dart';
import 'package:jaguar/src/editor/syntax_controller.dart';

Future<(SyntaxController, GlobalKey<CodeEditorState>)> pumpEditor(WidgetTester tester, String text) async {
  final code = SyntaxController(text: text);
  final focus = FocusNode();
  final key = GlobalKey<CodeEditorState>();
  final diagnostics = Diagnostics(code);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CodeEditor(key: key, controller: code, focusNode: focus, diagnostics: diagnostics),
      ),
    ),
  );
  focus.requestFocus();
  await tester.pump();
  return (code, key);
}

void main() {
  test('sugerencias: instrucciones al inicio, variables en todos lados', () {
    const text = 'Algoritmo a\n    Leer total\n    Mi';
    expect(completionsFor(text, text.length).first.label, 'Mientras');
    const expr = 'Algoritmo a\n    Leer total\n    x <- to';
    final names = completionsFor(expr, expr.length).map((c) => c.label);
    expect(names, contains('total'));
    expect(names, isNot(contains('Mientras')));
    const types = 'Definir x Como En';
    expect(completionsFor(types, types.length).first.label, 'Entero');
    const inText = 'Escribir "Mi';
    expect(completionsFor(inText, inText.length), isEmpty);
  });

  testWidgets('el autocompletado aparece al escribir y Enter lo acepta', (tester) async {
    final (code, _) = await pumpEditor(tester, 'Algoritmo a\n    ');
    // One letter at a time, as typed.
    for (final text in ['Algoritmo a\n    M', 'Algoritmo a\n    Mi', 'Algoritmo a\n    Mie']) {
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
    expect(code.text, 'Algoritmo a\n    Mientras  Hacer\n        \n    FinMientras');
    await tester.pump(const Duration(seconds: 1)); // the error check
  });

  testWidgets('buscar y reemplazar todos', (tester) async {
    final (code, key) = await pumpEditor(tester, 'x <- 1\nEscribir x\nx <- x + 1');
    key.currentState!.openFind(replace: true);
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Buscar'), 'x');
    await tester.pump();
    expect(find.text('1 de 4'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Reemplazar con'), 'n');
    await tester.tap(find.text('Todos'));
    await tester.pump();
    expect(code.text, 'n <- 1\nEscribir n\nn <- n + 1');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('F2 renombra la variable en todo el programa', (tester) async {
    final (code, key) = await pumpEditor(tester, 'Leer n\nEscribir "n", n');
    code.selection = const TextSelection.collapsed(offset: 5);
    key.currentState!.renameAtCursor();
    await tester.pumpAndSettle();
    expect(find.text('Cambia 2 lugares del programa.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Nuevo nombre'), 'numero');
    await tester.tap(find.text('Renombrar'));
    await tester.pumpAndSettle();
    expect(code.text, 'Leer numero\nEscribir "n", numero');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('los errores se marcan mientras se escribe', (tester) async {
    final (code, _) = await pumpEditor(tester, 'Algoritmo a\n    Escribir (1 + 2\nFinAlgoritmo');
    await tester.pump(const Duration(milliseconds: 700));
    final editor = tester.state<CodeEditorState>(find.byType(CodeEditor));
    expect(editor.widget.diagnostics!.error?.line, 2);
    code.text = 'Algoritmo a\n    Escribir (1 + 2)\nFinAlgoritmo';
    await tester.pump(const Duration(milliseconds: 700));
    expect(editor.widget.diagnostics!.error, isNull);
  });
}
