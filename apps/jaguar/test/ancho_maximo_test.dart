import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';

void main() {
  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MaxWidth(child: child!),
        home: Builder(
          builder: (context) => Scaffold(body: Text('${MediaQuery.sizeOf(context).width}', key: const Key('w'))),
        ),
      ),
    );
  }

  testWidgets('en un monitor ultraancho la app se queda centrada con un ancho máximo', (tester) async {
    await pump(tester, const Size(3440, 1440));
    final scaffold = tester.getRect(find.byType(Scaffold));
    expect(scaffold.width, maxAppWidth);
    expect(scaffold.center.dx, 1720);
    // The screens see the width they have, not the monitor's.
    expect(find.text('$maxAppWidth'), findsOneWidget);
  });

  testWidgets('en una pantalla normal no cambia nada', (tester) async {
    await pump(tester, const Size(1366, 768));
    expect(tester.getRect(find.byType(Scaffold)).width, 1366);
    expect(find.text('1366.0'), findsOneWidget);
  });
}
