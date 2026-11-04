import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/main.dart';
import 'package:jaguar/src/editor/code_editor.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/programs/program_store.dart';
import 'package:jaguar/src/settings.dart';
import 'package:jaguar/src/widgets/page_width.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _ultraancho = Size(3440, 1440);

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'jaguar.view.mode': 'full'});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    JaguarApp(store: ProgramStore(prefs), exercises: ExerciseStore(prefs), settings: ViewSettings(prefs)),
  );
  await tester.pumpAndSettle();
}

/// How wide the room's content is: the box that holds it, whatever it is made of.
double _pageBox(WidgetTester tester) => [
  for (final e in find.byType(ConstrainedBox).evaluate())
    if ((e.widget as ConstrainedBox).constraints.maxWidth == pageWidth) tester.getSize(find.byWidget(e.widget)).width,
].fold(0.0, (a, b) => a > b ? a : b);

void main() {
  testWidgets('PageWidth centra el contenido, deja la altura y no hace nada si cabe', (tester) async {
    Future<void> pump(double width) async {
      tester.view.physicalSize = Size(width, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PageWidth(width: 960, child: SizedBox.expand(key: Key('c'))),
          ),
        ),
      );
    }

    await pump(3000);
    expect(tester.getSize(find.byKey(const Key('c'))), const Size(960, 600));
    expect(tester.getCenter(find.byKey(const Key('c'))).dx, 1500);
    await pump(800);
    expect(tester.getSize(find.byKey(const Key('c'))).width, 800);
  });

  testWidgets('en un monitor 21:9 la barra lateral sigue en el borde y las salas tienen el mismo ancho', (
    tester,
  ) async {
    await _pump(tester, _ultraancho);

    // The Taller is the first screen on a wide window: it uses all of it.
    expect(tester.getSize(find.byType(CodeEditor).first).width, greaterThan(pageWidth));

    final widths = <String, double>{};
    for (final room in ['Inicio', 'Ruta', 'Clases']) {
      await tester.tap(find.text(room).first);
      await tester.pumpAndSettle();
      // The side bar is at the window's left edge, not inside a centered column.
      expect(tester.getTopLeft(find.text(room).first).dx, lessThan(100), reason: room);
      widths[room] = _pageBox(tester);
      expect(widths[room], pageWidth, reason: room);
    }
    // The three rooms take the same width, so they do not jump when switching.
    expect(widths['Inicio'], widths['Ruta']);
    expect(widths['Ruta'], widths['Clases']);
  });
}
