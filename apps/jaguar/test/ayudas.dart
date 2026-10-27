import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Va a una sala (Inicio, Ruta, Clases o Taller) como lo haría una persona:
/// en el celular vuelve al inicio y toca la tarjeta; en pantalla ancha toca
/// el riel.
Future<void> irASala(WidgetTester tester, String sala) async {
  final volver = find.byTooltip('Volver al inicio');
  if (volver.evaluate().isNotEmpty) {
    await tester.tap(volver);
    await tester.pumpAndSettle();
    if (sala == 'Inicio') return;
  }
  final destino = find.text(sala);
  if (destino.evaluate().isEmpty) {
    await tester.scrollUntilVisible(destino, 200);
  }
  await tester.ensureVisible(destino.first);
  await tester.pumpAndSettle();
  await tester.tap(destino.first);
  await tester.pumpAndSettle();
}
