import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

Future<String> run(String body, [List<String> inputs = const []]) async {
  final result = await runProgram('Algoritmo a\n$body\nFinAlgoritmo\n', inputs: inputs);
  if (result.error != null) fail(result.error!.format('Algoritmo a\n$body\nFinAlgoritmo\n'));
  return result.output;
}

Expr expr(String text) => (parse('Algoritmo a\n    x <- $text\nFinAlgoritmo').main.body.single as AssignStmt).value;

void main() {
  group('sintaxis de DFD', () {
    test('flecha, textos con comilla simple y salida con comas', () async {
      expect(
        await run("    a ← 4\n    b ← 6\n    Escribir 'Las soluciones son: A = ', a, ' y B = ', b"),
        'Las soluciones son: A = 4 y B = 6\n',
      );
    });

    test('constantes .V. y .F., diferente != y operadores en inglés', () async {
      expect(await run('    Escribir .V. AND NOT .F.'), 'VERDADERO\n');
      expect(await run('    Escribir 3 != 4, " ", 7 MOD 2'), 'VERDADERO 1\n');
      expect(await run('    Escribir .V. XOR .V., " ", .V. XNOR .V.'), 'FALSO VERDADERO\n');
      expect(await run('    Escribir .V. NAND .F., " ", .F. NOR .F.'), 'VERDADERO VERDADERO\n');
      expect(await run('    Escribir 1 < 2 OR 1 > 2'), 'VERDADERO\n');
    });

    test('funciones de DFD', () async {
      expect(
        await run('    Escribir SQRT(16), " ", ABS(-2), " ", LEN(\'hola\'), " ", ROUND(2.6), " ", TRUNC(2.6)'),
        '4 2 4 3 2\n',
      );
      expect(await run('    Escribir LOG(1000)'), '3\n');
      expect(await run("    Escribir SUBSTRING('pseudocodigo', 7, 6)"), 'codigo\n');
    });

    test('arreglos con paréntesis', () async {
      expect(await run('    Dimension v[3]\n    v(2) ← 5\n    Escribir v(2) * 2'), '10\n');
    });
  });

  group('de DFD a pseudocódigo y de regreso', () {
    test('se escribe como PSeInt', () {
      expect(formatExpr(expr("SQRT(n) + LEN('ab')")), 'Raiz(n) + Longitud("ab")');
      expect(formatExpr(expr('a != b AND NOT c')), 'a <> b Y NO c');
      expect(formatExpr(expr('.V.')), 'Verdadero');
      expect(formatExpr(expr('LOG(x)')), 'Ln(x) / Ln(10)');
    });

    test('y se muestra en notación DFD', () {
      String dfd(String text) => formatExpr(expr(text), notation: Notation.dfd);
      expect(dfd('Raiz(n) + Longitud("ab")'), "SQRT(n) + LEN('ab')");
      expect(dfd('a <> b Y NO c O d'), 'a != b AND NOT c OR d');
      expect(dfd('Verdadero'), '.V.');
      expect(dfd('Subcadena(t, 2, 5)'), 'SUBSTRING(t, 2, 5 - 2 + 1)');
      final program = parse(
        'Algoritmo a\n    Dimension v[3]\n    Leer n\n    v[1] <- n\n    Escribir "n = ", v[1]\nFinAlgoritmo',
      );
      expect(program.main.body.skip(1).map((s) => formatSimpleStmt(s, notation: Notation.dfd)), [
        'n',
        'v(1) ← n',
        "'n = ', v(1)",
      ]);
    });

    test('el Para en el diagrama de DFD', () {
      final chart = flowchartsFor(
        parse('Algoritmo a\n    Para i <- 1 Hasta 10 Hacer\n        Escribir i\n    FinPara\nFinAlgoritmo'),
        notation: Notation.dfd,
      ).single;
      expect(chart.blockForLine(2)!.text, 'i ← 1, 10, 1');
    });
  });
}
