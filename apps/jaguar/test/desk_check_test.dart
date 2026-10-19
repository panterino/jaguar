import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/console/desk_check_screen.dart';

const _source = '''Algoritmo doble
    Leer a
    b <- a * 2
    Escribir b
FinAlgoritmo
''';

void main() {
  testWidgets('la prueba de escritorio llena la tabla con los datos de entrada', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DeskCheckScreen(name: 'doble', source: _source)));
    await tester.enterText(find.byType(TextField), '4');
    await tester.tap(find.text('Hacer la tabla'));
    await tester.pumpAndSettle();
    expect(find.text('3: b <- a * 2'), findsOneWidget);
    expect(find.text('8'), findsWidgets);
  });

  testWidgets('practicar: el alumno llena y Jaguar revisa', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DeskCheckScreen(name: 'doble', source: _source)));
    await tester.enterText(find.byType(TextField), '4');
    await tester.tap(find.text('Hacer la tabla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practicar: yo la lleno'));
    await tester.pumpAndSettle();
    // Two values change: a in step 1 and b in step 2.
    final guesses = find.widgetWithText(TextField, '?');
    expect(guesses, findsNWidgets(2));
    await tester.enterText(guesses.at(0), '4');
    await tester.enterText(guesses.at(1), '9');
    await tester.tap(find.text('Revisar'));
    await tester.pumpAndSettle();
    expect(find.text('Acertaste 1 de 2 valores. En rojo, los que no coinciden.'), findsOneWidget);
  });
}
