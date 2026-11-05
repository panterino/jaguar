import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/cloud_backend.dart';
import 'package:jaguar/src/cloud/regrade.dart';
import 'package:jaguar_core/jaguar_core.dart';

const _exercise = Exercise(
  id: 'doble',
  title: 'Doble',
  cases: [
    TestCase(inputs: ['2'], expected: '4'),
    TestCase(inputs: ['5'], expected: '10'),
    TestCase(inputs: ['0'], expected: '0', hidden: true),
    TestCase(inputs: ['-3'], expected: '-6', hidden: true),
  ],
);

const _assignment = Assignment(id: 'a1', classId: 'c1', exercise: _exercise, hiddenCount: 2);

Submission _sent(String source, {required int passed, required int total}) =>
    Submission(uid: 'u1', name: 'Ana', source: source, passed: passed, total: total);

void main() {
  test('una entrega que pide memoria sin fin no tumba la revisión: se detiene y cuenta como fallida', () async {
    const bomb =
        'Algoritmo d\n    s <- "ab"\n    Para i <- 1 Hasta 60 Hacer\n        s <- s + s\n    FinPara\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
    final started = DateTime.now();
    final graded = await regrade(_assignment, _sent(bomb, passed: 4, total: 4));
    expect(graded.passed, 0);
    expect(graded.complete, isFalse);
    expect(graded.overstated, isTrue);
    expect(DateTime.now().difference(started), lessThan(const Duration(seconds: 10)));
  });

  test('muchos arreglos enormes tampoco: la revisión termina', () async {
    const arrays =
        'Algoritmo d\n    Dimension a[9000000]\n    Dimension b[9000000]\n    Dimension c[9000000]\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
    final graded = await regrade(_assignment, _sent(arrays, passed: 4, total: 4));
    expect(graded.passed, 0);
    expect(graded.overstated, isTrue);
  });

  test('una solución buena pasa todo, también lo oculto', () async {
    const good = 'Algoritmo d\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
    final graded = await regrade(_assignment, _sent(good, passed: 4, total: 4));
    expect(graded.passed, 4);
    expect(graded.total, 4);
    expect(graded.complete, isTrue);
    expect(graded.overstated, isFalse);
  });

  test('un alumno que escribe 4 de 4 sin que sea cierto no engaña al profesor', () async {
    // Pasa los casos visibles (2 y 5) pero no los ocultos.
    const forTheExample =
        'Algoritmo d\n    Leer n\n    Si n = 2 Entonces\n        Escribir 4\n    SiNo\n        Escribir 10\n    FinSi\nFinAlgoritmo\n';
    final graded = await regrade(_assignment, _sent(forTheExample, passed: 4, total: 4));
    expect(graded.passed, 2, reason: 'los ocultos (0 y -3) lo delatan');
    expect(graded.total, 4);
    expect(graded.complete, isFalse);
    expect(graded.overstated, isTrue);
  });

  test('un total inventado también se nota', () async {
    const good = 'Algoritmo d\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
    // Dice 1 de 1: el profesor ve que eran 4 pruebas.
    final graded = await regrade(_assignment, _sent(good, passed: 1, total: 1));
    expect(graded.total, 4);
    expect(graded.passed, 4);
    expect(graded.overstated, isTrue);
  });

  test('un programa que ni se lee da cero y dice por qué', () async {
    final graded = await regrade(_assignment, _sent('esto no es un programa', passed: 4, total: 4));
    expect(graded.passed, 0);
    expect(graded.syntaxError, isNotNull);
    expect(graded.overstated, isTrue);
  });

  test('revisar a todos los de una tarea', () async {
    const good = 'Algoritmo d\n    Leer n\n    Escribir n * 2\nFinAlgoritmo\n';
    const bad = 'Algoritmo d\n    Escribir 4\nFinAlgoritmo\n';
    final all = await regradeAll(_assignment, {
      'ana': _sent(good, passed: 4, total: 4),
      'beto': _sent(bad, passed: 4, total: 4),
    });
    expect(all['ana']!.passed, 4);
    expect(all['beto']!.passed, 1);
    expect(all['beto']!.overstated, isTrue);
  });
}
