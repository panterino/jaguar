import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

const _parImpar = Exercise(
  id: 'par',
  title: 'Par o impar',
  statement: 'Lee un número y di si es par o impar.',
  cases: [
    TestCase(inputs: ['8'], expected: '8 es par'),
    TestCase(inputs: ['7'], expected: '7 es impar'),
    TestCase(inputs: ['0'], expected: '0 es par', hidden: true),
  ],
);

String program(String body) => 'Algoritmo a\n$body\nFinAlgoritmo\n';

void main() {
  group('comparación flexible', () {
    bool flexible(String actual, String expected) => outputMatches(actual, expected, MatchMode.flexible);

    test('acepta mensajes propios del alumno', () {
      expect(flexible('Dame un número:\nEl 8 es par\n', '8 es par'), isTrue);
      expect(flexible('Número: 8 es par', '8 es par'), isTrue);
    });

    test('ignora mayúsculas, acentos y espacios extra', () {
      expect(flexible('EL  RESULTADO   es:  15', 'resultado es: 15'), isTrue);
      expect(flexible('Raíz = 3', 'raiz = 3'), isTrue);
    });

    test('respeta el orden de las líneas', () {
      expect(flexible('1\n2\n3\n', '1\n3'), isTrue);
      expect(flexible('1\n2\n3\n', '3\n1'), isFalse);
    });

    test('no confunde números que contienen al esperado', () {
      expect(flexible('18 es par', '8 es par'), isFalse);
      expect(flexible('Total: 150', 'total: 15'), isFalse);
      expect(flexible('Total: 15.', 'total: 15'), isTrue);
    });

    test('falta una línea esperada', () {
      expect(flexible('8 es par', '8 es par\nfin'), isFalse);
    });
  });

  test('comparación exacta', () {
    expect(outputMatches('Hola  \nMundo\n\n', 'Hola\nMundo', MatchMode.exact), isTrue);
    expect(outputMatches('hola\nMundo', 'Hola\nMundo', MatchMode.exact), isFalse);
  });

  group('comprobar solución', () {
    test('solución correcta con mensajes propios', () async {
      final result = await checkSolution(
        program(
          'Escribir "Escribe un número:"\nLeer n\nSi n MOD 2 = 0 Entonces\nEscribir n, " es par"\nSiNo\nEscribir n, " es impar"\nFinSi',
        ),
        _parImpar,
      );
      expect(result.passed, isTrue);
      expect(result.passedCount, 3);
    });

    test('solución que falla un caso oculto', () async {
      final result = await checkSolution(
        program('Leer n\nSi n MOD 2 = 0 Y n > 0 Entonces\nEscribir n, " es par"\nSiNo\nEscribir n, " es impar"\nFinSi'),
        _parImpar,
      );
      expect(result.passed, isFalse);
      expect([for (final c in result.cases) c.passed], [true, true, false]);
      expect(result.cases.last.output, '0 es impar\n');
    });

    test('error de sintaxis no ejecuta ningún caso', () async {
      final result = await checkSolution(program('Si 1 Entonces'), _parImpar);
      expect(result.passed, isFalse);
      expect(result.syntaxError, isNotNull);
      expect(result.cases, isEmpty);
    });

    test('ciclo infinito falla el caso sin colgarse', () async {
      final result = await checkSolution(
        program('Leer n\nMientras Verdadero Hacer\nFinMientras'),
        _parImpar,
        maxSteps: 1000,
      );
      expect(result.passedCount, 0);
      expect(result.cases.first.error!.message, contains('pasos'));
    });

    test('pedir más datos de los que hay falla con mensaje claro', () async {
      final result = await checkSolution(program('Leer a, b\nEscribir a + b'), _parImpar);
      expect(result.cases.first.error!.message, contains('ya no hay datos'));
    });

    test('Aleatorio da el mismo resultado en cada comprobación', () async {
      const exercise = Exercise(
        id: 'r',
        title: 'r',
        cases: [TestCase(expected: '')],
      );
      final source = program('Escribir Aleatorio(1, 1000)');
      final first = await checkSolution(source, exercise);
      final second = await checkSolution(source, exercise);
      expect(first.cases.single.output, second.cases.single.output);
    });
  });

  test('JSON ida y vuelta', () {
    const exercise = Exercise(
      id: 'x1',
      title: 'Suma',
      statement: 'Suma dos números',
      mode: MatchMode.exact,
      cases: [
        TestCase(inputs: ['1', '2'], expected: '3'),
        TestCase(inputs: ['5', '5'], expected: '10', hidden: true),
      ],
    );
    final copy = Exercise.fromJson(exercise.toJson());
    expect(copy.toJson(), exercise.toJson());
    expect(copy.mode, MatchMode.exact);
    expect(copy.cases.last.hidden, isTrue);
  });

  group('salida esperada desde la solución del profesor', () {
    test('quita los mensajes que piden datos', () async {
      final result = await expectedOutputFor(
        program('Escribir "Escribe un número:"\nLeer n\nEscribir "Otro:"\nLeer m\nEscribir "Suma: ", n + m'),
        ['2', '3'],
        MatchMode.flexible,
      );
      expect(result.error, isNull);
      expect(result.output, 'Suma: 5');
    });

    test('mensaje en la misma línea con Sin Saltar', () async {
      final result = await expectedOutputFor(program('Escribir Sin Saltar "Número: "\nLeer n\nEscribir n * 2'), [
        '4',
      ], MatchMode.flexible);
      expect(result.output, '8');
    });

    test('conserva resultados que se muestran entre lecturas', () async {
      final result = await expectedOutputFor(
        program('Leer a\nEscribir "Doble: ", a * 2\nEscribir "Dame otro"\nLeer b\nEscribir "Triple: ", b * 3'),
        ['1', '2'],
        MatchMode.flexible,
      );
      expect(result.output, 'Doble: 2\nTriple: 6');
    });

    test('en modo exacto conserva todo', () async {
      final result = await expectedOutputFor(program('Escribir "N:"\nLeer n\nEscribir n'), ['5'], MatchMode.exact);
      expect(result.output, 'N:\n5');
    });

    test('la salida calculada la pasa un alumno con otros mensajes', () async {
      const solution =
          'Escribir "Escribe un número:"\nLeer n\nSi n MOD 2 = 0 Entonces\nEscribir n, " es par"\nSiNo\nEscribir n, " es impar"\nFinSi';
      final cases = [
        for (final input in ['8', '7'])
          TestCase(
            inputs: [input],
            expected: (await expectedOutputFor(program(solution), [input], MatchMode.flexible)).output,
          ),
      ];
      final exercise = Exercise(id: 'x', title: 'x', cases: cases);
      final student = program(
        'Escribir "Dame un valor"\nLeer v\nSi v MOD 2 = 0 Entonces\nEscribir v, " es par"\nSiNo\nEscribir v, " es impar"\nFinSi',
      );
      expect((await checkSolution(student, exercise)).passed, isTrue);
    });

    test('reporta el error de la solución', () async {
      final result = await expectedOutputFor(program('Leer a, b'), ['1'], MatchMode.flexible);
      expect(result.error, isNotNull);
    });
  });

  group('por qué falla una prueba', () {
    Future<CaseResult> one(String body, List<String> inputs, String expected) async => (await runTests(program(body), [
      TestCase(inputs: inputs, expected: expected),
    ], MatchMode.flexible)).cases.single;

    test('salida distinta: dice qué línea faltó y qué salió en su lugar', () async {
      final result = await one('Leer n\nEscribir n, " es par"', ['7'], '7 es impar');
      expect(result.failure, CaseFailure.wrongOutput);
      expect(result.mismatch!.expected, '7 es impar');
      expect(result.mismatch!.actual, '7 es par');
    });

    test('la salida se acabó antes', () async {
      final result = await one('Escribir "uno"', [], 'uno\ndos');
      expect(result.mismatch!.expectedLine, 1);
      expect(result.mismatch!.actual, isNull);
    });

    test('pidió más datos de los que tiene la prueba', () async {
      final result = await one('Leer a, b\nEscribir a + b', ['1'], '3');
      expect(result.failure, CaseFailure.missingInput);
    });

    test('ciclo infinito', () async {
      final result = await one('Mientras Verdadero Hacer\n    x <- 1\nFinMientras', [], 'nada');
      expect(result.failure, CaseFailure.tooSlow);
    });

    test('otro error de ejecución', () async {
      final result = await one('Escribir 1 / 0', [], '0');
      expect(result.failure, CaseFailure.error);
    });

    test('comparación exacta: primera línea distinta', () {
      final mismatch = firstMismatch('a\nb\nc', 'a\nB\nc', MatchMode.exact)!;
      expect(mismatch.expectedLine, 1);
      expect(mismatch.expected, 'B');
      expect(mismatch.actual, 'b');
      expect(firstMismatch('a\n', 'a', MatchMode.exact), isNull);
    });
  });

  test('nombre de la prueba y revisión viajan en el JSON', () {
    const exercise = Exercise(
      id: 'x',
      title: 'X',
      revision: 3,
      cases: [
        TestCase(name: 'Número par', inputs: ['8'], expected: '8 es par'),
      ],
    );
    final decoded = Exercise.fromJson(exercise.toJson());
    expect(decoded.revision, 3);
    expect(decoded.cases.single.name, 'Número par');
    expect(Exercise.fromJson(_parImpar.toJson()).revision, 1);
  });
}
