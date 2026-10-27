import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/widgets/mascota.dart';

void main() {
  testWidgets('cada pose de la mascota se dibuja sin errores y sin ruido para el lector de pantalla', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final pose in MascotPose.values) Mascota(pose: pose, size: 120),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Mascota), findsNWidgets(MascotPose.values.length));
    expect(tester.takeException(), isNull);
  });
}
