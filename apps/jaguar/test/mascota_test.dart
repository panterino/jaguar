import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/widgets/mascota.dart';

void main() {
  testWidgets('cada pose y cada cara de la mascota se dibuja sin errores', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final pose in MascotPose.values) Mascota(pose: pose, size: 80),
                for (final face in MascotFace.values) MascotaCara(face: face, size: 60),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Mascota), findsNWidgets(MascotPose.values.length));
    expect(find.byType(MascotaCara), findsNWidgets(MascotFace.values.length));
    expect(tester.takeException(), isNull);
  });

  testWidgets('todas las poses y caras tienen su archivo en los assets', (tester) async {
    for (final asset in [...MascotPose.values.map((p) => p.asset), ...MascotFace.values.map((f) => f.asset)]) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: asset);
    }
  });
}
