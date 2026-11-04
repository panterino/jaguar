import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/classes_screen.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sizes = {'escritorio': Size(1366, 768), 'tableta': Size(900, 700), 'celular': Size(400, 800)};

Exercise _exercise(int n) => Exercise(
  id: 'e$n',
  title: 'Ejercicio número $n con un título bastante largo',
  statement: 'x',
  cases: const [
    TestCase(inputs: ['1'], expected: '1'),
  ],
);

/// A class with [tasks] assignments and [students] students, the first of
/// them with everything done and the second with a pasted program.
Future<(Cloud, ClassRoom, ExerciseStore)> _classWith({int tasks = 2, int students = 3, bool asTeacher = true}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final backend = MemoryBackend();
  final cloud = Cloud(backend, prefs);
  await backend.registerTeacher(email: 'p@x.mx', password: 'secreto', alias: 'Martínez');
  final room = await backend.createClass('Programación 3A');
  final assigned = [for (var i = 1; i <= tasks; i++) await backend.assign(room.id, _exercise(i))];
  for (var s = 1; s <= students; s++) {
    backend.actAs(null);
    final name = 'Alumno número $s';
    await backend.signInAnonymously(alias: name, role: CloudRole.alumno);
    await backend.joinClass(code: room.code, name: name);
    for (final (i, a) in assigned.indexed) {
      if (s == 1 || (s == 2 && i == 0)) {
        await backend.submit(
          classId: room.id,
          assignmentId: a.id,
          name: name,
          source: '// Entrega de $name\nAlgoritmo x\nFinAlgoritmo\n',
          passed: s == 1 ? 1 : 0,
          total: 1,
          pastedLines: s == 2 ? 12 : 0,
        );
      }
    }
  }
  await backend.signInTeacher(email: 'p@x.mx', password: 'secreto');
  return (cloud, room, ExerciseStore(prefs));
}

Future<void> _pump(WidgetTester tester, Widget screen, Size size, {double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

ClassScreen _classScreen(Cloud cloud, ClassRoom room, ExerciseStore store, {ValueChanged<String>? onOpenSource}) =>
    ClassScreen(
      cloud: cloud,
      room: room,
      exercises: store,
      onOpenAssignment: (_) {},
      onOpenSource: onOpenSource ?? (_) {},
    );

/// Buttons made with `.icon` are a subclass of FilledButton.
Finder _button(String label) => find.ancestor(of: find.text(label), matching: find.bySubtype<FilledButton>());

void main() {
  for (final MapEntry(key: name, value: size) in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('la clase del profesor no desborda en $name con letra x$scale', (tester) async {
        final (cloud, room, store) = await _classWith();
        await _pump(tester, _classScreen(cloud, room, store), size, textScale: scale);
        expect(find.text('Programación 3A'), findsOneWidget);
        expect(find.text('Alumno número 1'), findsOneWidget);
      });

      testWidgets('con muchas tareas y alumnos tampoco desborda en $name con letra x$scale', (tester) async {
        final (cloud, room, store) = await _classWith(tasks: 7, students: 30);
        await _pump(tester, _classScreen(cloud, room, store), size, textScale: scale);
        expect(find.text('Programación 3A'), findsOneWidget);
      });

      testWidgets('la lista de clases no desborda en $name con letra x$scale', (tester) async {
        final (cloud, _, store) = await _classWith();
        await _pump(
          tester,
          ClassesScreen(cloud: cloud, exercises: store, onOpenAssignment: (_) {}, onOpenSource: (_) {}),
          size,
          textScale: scale,
        );
        expect(find.text('Programación 3A'), findsOneWidget);
      });
    }
  }

  testWidgets('en escritorio la tabla de entregas ocupa el ancho, con totales por tarea', (tester) async {
    final (cloud, room, store) = await _classWith();
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    // Both tasks are columns, with how many finished.
    expect(find.text('1 de 3 completas'), findsNWidgets(4)); // two headers and two tasks in the panel
    expect(find.text('Sin entregar'), findsWidgets);
    // The table starts after the left panel and reaches the right edge.
    final grid = tester.getTopLeft(find.text('Alumno'));
    expect(grid.dx, greaterThan(300));
    expect(tester.getTopLeft(find.text('Asignar ejercicio')).dx, lessThan(340));
  });

  testWidgets('el encabezado queda fijo al bajar por los alumnos', (tester) async {
    final (cloud, room, store) = await _classWith(students: 30);
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    final before = tester.getTopLeft(find.text('Alumno'));
    await tester.drag(find.text('Alumno número 3'), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Alumno')), before);
    expect(find.text('Alumno número 1'), findsNothing); // scrolled away
  });

  testWidgets('tocar una entrega abre el código y avisa del pegado', (tester) async {
    final (cloud, room, store) = await _classWith();
    String? opened;
    await _pump(
      tester,
      _classScreen(cloud, room, store, onOpenSource: (source) => opened = source),
      _sizes['escritorio']!,
    );
    // Student 2 pasted 12 lines in the first task.
    await tester.tap(find.byTooltip('Ver la entrega de Alumno número 2'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pegó 12 líneas de una vez mientras'), findsOneWidget);
    await tester.tap(find.text('Abrir una copia'));
    await tester.pumpAndSettle();
    expect(opened, contains('Entrega de Alumno número 2'));
  });

  testWidgets('quitar una tarea pide confirmar', (tester) async {
    final (cloud, room, store) = await _classWith();
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    await tester.tap(find.byTooltip('Quitar tarea').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('se pierden sus entregas'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar tarea'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Quitar tarea').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Quitar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar tarea'), findsOneWidget);
  });

  testWidgets('asignar en escritorio abre un diálogo, no una hoja', (tester) async {
    final (cloud, room, store) = await _classWith();
    store.saveAuthored(_exercise(9));
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    await tester.tap(find.text('Asignar ejercicio'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byTooltip('Cerrar'), findsOneWidget);
    await tester.tap(find.text('Ejercicio número 9 con un título bastante largo'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Ejercicio número 9 con un título bastante largo'), findsWidgets);
  });

  testWidgets('sin tareas hay un estado vacío con el botón para asignar', (tester) async {
    final (cloud, room, store) = await _classWith(tasks: 0, students: 0);
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    expect(find.text('Aún no hay tareas'), findsOneWidget);
    // The panel button and the one in the empty state.
    expect(_button('Asignar ejercicio'), findsNWidgets(2));
  });

  testWidgets('con tareas pero sin alumnos explica que se unan con el código', (tester) async {
    final (cloud, room, store) = await _classWith(tasks: 2, students: 0);
    await _pump(tester, _classScreen(cloud, room, store), _sizes['escritorio']!);
    expect(find.text('Aún no hay alumnos'), findsOneWidget);
  });

  testWidgets('en celular la clase conserva el botón flotante y la tabla de siempre', (tester) async {
    final (cloud, room, store) = await _classWith();
    await _pump(tester, _classScreen(cloud, room, store), _sizes['celular']!);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
  });

  testWidgets('en escritorio Mis clases pone Crear clase arriba y no flotando', (tester) async {
    final (cloud, _, store) = await _classWith();
    await _pump(
      tester,
      ClassesScreen(cloud: cloud, exercises: store, onOpenAssignment: (_) {}, onOpenSource: (_) {}),
      _sizes['escritorio']!,
    );
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(_button('Crear clase'), findsOneWidget);
  });
}
