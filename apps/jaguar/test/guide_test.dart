import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/help/guide_screen.dart';

void main() {
  testWidgets('la guía abre en la pestaña del perfil y lleva a cada lugar', (tester) async {
    var retos = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => GuideScreen(onOpenChallenges: () => retos++)),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Tu primer programa'), findsOneWidget);

    await tester.tap(find.text('Retos'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver los retos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver los retos'));
    await tester.pumpAndSettle();
    expect(retos, 1);
    expect(find.byType(GuideScreen), findsNothing);
  });

  testWidgets('a un profe le abre en Profe', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GuideScreen(teacher: true)));
    await tester.pumpAndSettle();
    expect(find.text('Crea un ejercicio'), findsOneWidget);
    // Sin la acción disponible, no hay botón.
    await tester.tap(find.text('Crea un ejercicio'));
    await tester.pumpAndSettle();
    expect(find.text('Ir a Mis ejercicios'), findsNothing);
  });
}
