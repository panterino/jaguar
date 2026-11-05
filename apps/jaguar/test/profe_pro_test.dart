import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/account_dialog.dart';
import 'package:jaguar/src/cloud/classes_screen.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/widgets/pro_widgets.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sizes = {'escritorio': Size(1440, 900), 'celular': Size(360, 640)};

Future<void> _size(WidgetTester tester, Size size, {double textScale = 1}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

const _doble = Exercise(
  id: 'doble',
  title: 'Doble de un número',
  cases: [
    TestCase(inputs: ['2'], expected: '4'),
    TestCase(inputs: ['5'], expected: '10'),
    TestCase(inputs: ['0'], expected: '0', hidden: true),
  ],
);
const _good = 'Algoritmo d\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
const _forTheExample =
    'Algoritmo d\n    Leer n\n    Si n = 2 Entonces\n        Escribir 4\n    SiNo\n        Escribir 10\n    FinSi\nFinAlgoritmo\n';

void main() {
  for (final MapEntry(key: name, value: size) in _sizes.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('el modal de entrar no desborda en $name con letra x$scale, ni de alumno ni de profesor', (
        tester,
      ) async {
        await _size(tester, size, textScale: scale);
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final cloud = Cloud(MemoryBackend(), prefs);
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) =>
                  TextButton(onPressed: () => showAccountDialog(context, cloud), child: const Text('abrir')),
            ),
          ),
        );
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();
        expect(find.text('Entrar a Jaguar Code en línea'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Profesor'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Crear cuenta'));
        await tester.pumpAndSettle();
        expect(find.text('Nombre que verán tus alumnos'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('en el modal, el aviso de privacidad y los campos comparten el mismo borde', (tester) async {
    await _size(tester, _sizes['escritorio']!);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cloud = Cloud(MemoryBackend(), prefs)..prefersTeacher = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) =>
              TextButton(onPressed: () => showAccountDialog(context, cloud), child: const Text('abrir')),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    // Teacher with an account: email, password, forgot link, privacy line.
    final fieldLeft = tester.getTopLeft(find.byType(TextField).first).dx;
    expect(tester.getTopLeft(find.textContaining('Al entrar aceptas')).dx, fieldLeft);
    expect(
      tester.getTopLeft(find.text('Con tu correo, para que tus clases te sigan a cualquier equipo.')).dx,
      fieldLeft,
    );
    // The forgot-password link sits under the password, on the field's right edge.
    final forgot = tester.getTopRight(find.text('Olvidé mi contraseña')).dx;
    final fieldRight = tester.getTopRight(find.byType(TextField).last).dx;
    expect(fieldRight - forgot, lessThan(16));
  });

  testWidgets('crear cuenta quita "olvidé mi contraseña" y cambiar de rol limpia el error', (tester) async {
    await _size(tester, _sizes['escritorio']!);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cloud = Cloud(MemoryBackend(), prefs)..prefersTeacher = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) =>
              TextButton(onPressed: () => showAccountDialog(context, cloud), child: const Text('abrir')),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Olvidé mi contraseña'), findsOneWidget);
    await tester.tap(find.text('Entrar').last);
    await tester.pumpAndSettle();
    expect(find.text('Escribe tu correo y tu contraseña.'), findsOneWidget);
    await tester.tap(find.text('Alumno'));
    await tester.pumpAndSettle();
    expect(find.text('Escribe tu correo y tu contraseña.'), findsNothing);
    await tester.tap(find.text('Profesor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
    expect(find.text('Olvidé mi contraseña'), findsNothing);
  });

  testWidgets('el código de la clase cabe en una línea aunque el espacio sea poco', (tester) async {
    await _size(tester, const Size(360, 640));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(width: 200, child: CodeBadge(code: 'JAG-M3AUCRKY')),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(CodeBadge)).height, lessThan(70));
  });

  testWidgets('las iniciales salen del nombre y no truenan con un nombre de una palabra o vacío', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            InitialsAvatar(name: 'Ana Pérez'),
            InitialsAvatar(name: 'luna'),
            InitialsAvatar(name: '   '),
          ],
        ),
      ),
    );
    expect(find.text('AP'), findsOneWidget);
    expect(find.text('L'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });

  group('la clase del profesor, con lo que Jaguar revisó', () {
    late Cloud cloud;
    late ClassRoom room;

    Future<void> setUpClass(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final backend = MemoryBackend();
      cloud = Cloud(backend, prefs);
      final teacher = await backend.registerTeacher(email: 'p@x.mx', password: 'secreto', alias: 'Profa. López');
      room = await backend.createClass('Programación 3A');
      final task = await backend.assign(room.id, _doble);
      Future<void> student(String name, String? source, int said) async {
        backend.actAs(null);
        await backend.signInAnonymously(alias: name, role: CloudRole.alumno);
        await backend.joinClass(code: room.code, name: name);
        if (source != null) {
          await backend.submit(
            classId: room.id,
            assignmentId: task.id,
            name: name,
            source: source,
            passed: said,
            total: said,
          );
        }
      }

      await student('Ana Pérez', _good, 3);
      await student('Beto Ruiz', _forTheExample, 3);
      await student('Carla Soto', null, 0);
      backend.actAs(teacher);
    }

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ClassScreen(
            cloud: cloud,
            room: room,
            exercises: ExerciseStore(await SharedPreferences.getInstance()),
            onOpenAssignment: (_) {},
            onOpenSource: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('marca la entrega cuyo número no era cierto y muestra las cifras de la clase', (tester) async {
      await _size(tester, _sizes['escritorio']!);
      await setUpClass(tester);
      await open(tester);
      // Ana really passed 3 of 3; Beto said 3 of 3 but his program only fits the examples.
      expect(find.text('3 de 3'), findsOneWidget);
      expect(find.text('2 de 3'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is Tooltip && (w.message?.contains('El alumno dijo 3 de 3') ?? false)),
        findsOneWidget,
      );
      // The figures of the class.
      expect(find.text('Alumnos'), findsOneWidget);
      expect(find.text('Entregas completas'), findsOneWidget);
      expect(find.text('33 %'), findsOneWidget);
      expect(find.text('Incluye 1 prueba oculta'), findsOneWidget);
    });

    testWidgets('calificaciones revisadas: se ven como hoja y se pueden copiar', (tester) async {
      await _size(tester, _sizes['escritorio']!);
      await setUpClass(tester);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      await open(tester);
      await tester.scrollUntilVisible(find.text('Calificaciones'), 200, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('Calificaciones'));
      await tester.pumpAndSettle();
      expect(find.text('Descargar para Excel'), findsOneWidget);
      await tester.tap(find.text('Copiar'));
      await tester.pumpAndSettle();
      expect(find.text('Copiado. Pégalo en una hoja de cálculo.'), findsOneWidget);
      expect(copied!.split('\n'), [
        'Alumno\tDoble de un número\tTareas completas\tAvance',
        'Ana Pérez\t3 de 3\t1\t100 %',
        'Beto Ruiz\t2 de 3\t0\t0 %',
        'Carla Soto\t\t0\t0 %',
      ]);
    });
  });
}
