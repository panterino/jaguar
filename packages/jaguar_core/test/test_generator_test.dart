import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

String program(String body) => 'Algoritmo a\n$body\nFinAlgoritmo\n';

Exercise exercise(List<TestCase> tests) => Exercise(id: 'x', title: 'x', cases: tests);

void main() {
  test('par o impar: casos de los dos caminos, y la solución los pasa', () async {
    final solution = program(
      '    Definir n Como Entero\n    Escribir "Dame un número"\n    Leer n\n'
      '    Si n MOD 2 = 0 Entonces\n        Escribir n, " es par"\n    SiNo\n        Escribir n, " es impar"\n    FinSi',
    );
    final tests = await suggestTests(solution);
    expect(tests.length, greaterThanOrEqualTo(2));
    expect(tests.any((t) => t.expected.contains('es par')), isTrue);
    expect(tests.any((t) => t.expected.contains('es impar')), isTrue);
    expect(tests.every((t) => !t.expected.contains('Dame un número')), isTrue, reason: 'sin el mensaje que pide datos');
    expect((await checkSolution(solution, exercise(tests))).passed, isTrue);

    final wrong = program('    Leer n\n    Escribir n, " es par"');
    expect((await checkSolution(wrong, exercise(tests))).passed, isFalse);
  });

  test('prueba los límites de una comparación', () async {
    final solution = program(
      '    Leer edad\n    Si edad >= 18 Entonces\n        Escribir "Mayor"\n    SiNo\n        Escribir "Menor"\n    FinSi',
    );
    final tests = await suggestTests(solution, count: 4);
    final inputs = tests.map((t) => t.inputs.single).toSet();
    expect(inputs.intersection({'17', '18', '19'}), isNotEmpty);
    // A solution with > instead of >= fails some case if 18 is there.
    final offByOne = program(
      '    Leer edad\n    Si edad > 18 Entonces\n        Escribir "Mayor"\n    SiNo\n        Escribir "Menor"\n    FinSi',
    );
    if (inputs.contains('18')) {
      expect((await checkSolution(offByOne, exercise(tests))).passed, isFalse);
    }
  });

  test('un ciclo que lee hasta un centinela termina', () async {
    final solution = program(
      '    suma <- 0\n    Leer n\n    Mientras n <> 0 Hacer\n        suma <- suma + n\n        Leer n\n    FinMientras\n'
      '    Escribir "Suma: ", suma',
    );
    final tests = await suggestTests(solution);
    expect(tests, isNotEmpty);
    expect(tests.every((t) => t.inputs.last == '0'), isTrue);
  });

  test('textos: usa los que el programa compara', () async {
    final solution = program(
      '    Leer respuesta\n    Si respuesta = "si" Entonces\n        Escribir "Bien"\n    SiNo\n        Escribir "Otro"\n    FinSi',
    );
    final tests = await suggestTests(solution);
    expect(tests.any((t) => t.inputs.single == 'si'), isTrue);
    expect(tests.any((t) => t.expected == 'Bien'), isTrue);
    expect(tests.any((t) => t.expected == 'Otro'), isTrue);
  });

  test('marca como oculto el último caso', () async {
    final solution = program(
      '    Leer n\n    Si n > 0 Entonces\n        Escribir "positivo"\n    SiNo\n        Si n = 0 Entonces\n'
      '            Escribir "cero"\n        SiNo\n            Escribir "negativo"\n        FinSi\n    FinSi',
    );
    final tests = await suggestTests(solution);
    expect(tests.length, greaterThanOrEqualTo(3));
    expect(tests.last.hidden, isTrue);
    expect(tests.first.hidden, isFalse);
  });
}
