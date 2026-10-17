import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

List<Flowchart> charts(String source) => flowchartsFor(parse(source));

bool _overlap(FlowRect a, FlowRect b) => a.left < b.right && b.left < a.right && a.top < b.bottom && b.top < a.bottom;

void main() {
  group('texto de los bloques', () {
    String expr(String text) =>
        formatExpr((parse('Algoritmo a\n    x <- $text\nFinAlgoritmo').main.body.single as AssignStmt).value);

    test('solo los paréntesis necesarios', () {
      expect(expr('(a + b) * 2'), '(a + b) * 2');
      expect(expr('a + b * 2'), 'a + b * 2');
      expect(expr('a - (b - c)'), 'a - (b - c)');
      expect(expr('(a - b) - c'), 'a - b - c');
      expect(expr('-(a + 1)'), '-(a + 1)');
      expect(expr('2 ^ (1 + 1)'), '2^(1 + 1)');
      expect(expr('NO (a > 1 Y b)'), 'NO (a > 1 Y b)');
      expect(expr('a MOD 2 = 0 O b'), 'a MOD 2 = 0 O b');
    });

    test('textos, arreglos y funciones', () {
      expect(expr('"hola"'), '"hola"');
      expect(expr('v[i + 1]'), 'v[i + 1]');
      expect(expr('raiz(x) + 0.5'), 'raiz(x) + 0.5');
    });
  });

  group('diagrama', () {
    test('un programa en secuencia: Inicio, bloques y Fin con su línea', () {
      final chart = charts('Algoritmo a\n    Leer n\n    m <- n * 2\n    Escribir m\nFinAlgoritmo').single;
      expect(chart.title, 'Algoritmo a');
      expect(
        [for (final b in chart.blocks) b.shape],
        [BlockShape.terminal, BlockShape.input, BlockShape.process, BlockShape.output, BlockShape.terminal],
      );
      expect([for (final b in chart.blocks) b.text], ['Inicio', 'Leer n', 'm <- n * 2', 'Escribir m', 'Fin']);
      expect(chart.blockForLine(3)!.text, 'm <- n * 2');
      final rect = chart.blockForLine(2)!.rect;
      expect(chart.blockAt(rect.centerX, rect.centerY)!.line, 2);
    });

    test('Si con Sí y No', () {
      final chart = charts(
        'Algoritmo a\n    Leer n\n    Si n > 0 Entonces\n        Escribir "positivo"\n    SiNo\n        Escribir "no"\n    FinSi\nFinAlgoritmo',
      ).single;
      expect(chart.blockForLine(3)!.shape, BlockShape.decision);
      expect(chart.labels.map((l) => l.text), containsAll(['Sí', 'No']));
      final yes = chart.blockForLine(4)!.rect;
      final no = chart.blockForLine(6)!.rect;
      expect(yes.left, greaterThan(no.right), reason: 'Sí va a la derecha');
    });

    test('nada se enciman, aunque todo esté anidado', () {
      const source = '''
Algoritmo todo
    Definir i, n Como Entero
    Leer n
    Para i <- 1 Hasta n Con Paso 2 Hacer
        Si i MOD 3 = 0 Entonces
            Mientras n > 0 Hacer
                n <- n - 1
            FinMientras
        SiNo
            Segun i Hacer
                1: Escribir "uno"
                5, 7: Escribir "cinco o siete"
                De Otro Modo: Escribir "otro"
            FinSegun
        FinSi
    FinPara
    Repetir
        n <- n + 1
    Hasta Que n > 10
    Escribir n
FinAlgoritmo

SubProceso saluda(nombre)
    Escribir "Hola ", nombre
FinSubProceso
''';
      final all = charts(source);
      expect(all, hasLength(2));
      expect(all[1].title, 'SubProceso saluda(nombre)');
      final blocks = all.first.blocks;
      for (var i = 0; i < blocks.length; i++) {
        for (var j = i + 1; j < blocks.length; j++) {
          expect(
            _overlap(blocks[i].rect, blocks[j].rect),
            isFalse,
            reason: '"${blocks[i].text}" y "${blocks[j].text}"',
          );
        }
        final r = blocks[i].rect;
        expect(r.left >= 0 && r.top >= 0 && r.right <= all.first.width && r.bottom <= all.first.height, isTrue);
      }
      for (final line in all.first.lines) {
        for (final (x, y) in line.points) {
          expect(x >= 0 && x <= all.first.width && y >= 0 && y <= all.first.height, isTrue);
        }
      }
    });
  });

  group('paso a paso', () {
    test('avisa en cada instrucción y en cada vuelta del ciclo', () async {
      final lines = <int>[];
      final program = parse(
        'Algoritmo a\n    i <- 0\n    Mientras i < 2 Hacer\n        i <- i + 1\n    FinMientras\nFinAlgoritmo',
      );
      final interpreter = Interpreter(program, BufferedIO(), onStep: (s, line) async => lines.add(line));
      await interpreter.run();
      expect(lines, [2, 3, 4, 3, 4, 3]);
      expect(interpreter.finalVariables, {'i': 2});
    });

    test('valores en la tabla de variables', () async {
      final program = parse(
        'Algoritmo a\n    Dimension v[3]\n    v[1] <- 5\n    t <- "hola"\n    b <- Verdadero\nFinAlgoritmo',
      );
      final interpreter = Interpreter(program, BufferedIO());
      await interpreter.run();
      final vars = interpreter.finalVariables;
      expect(debugValue(vars['v']), '[5, ·, ·]');
      expect(debugValue(vars['t']), '"hola"');
      expect(debugValue(vars['b']), 'VERDADERO');
      expect(debugValue(null), '(sin valor)');
    });
  });

  test('Repetir: cada vuelta se detiene en la línea de Hasta Que', () async {
    final lines = <int>[];
    final program = parse(
      'Algoritmo a\n    i <- 0\n    Repetir\n        i <- i + 1\n    Hasta Que i = 2\nFinAlgoritmo',
    );
    await Interpreter(program, BufferedIO(), onStep: (s, line) async => lines.add(line)).run();
    expect(lines, [2, 3, 4, 5, 4, 5]);
    expect(flowchartsFor(program).single.blockForLine(5)!.shape, BlockShape.decision);
  });

  test('el evaluador usa las variables del momento', () async {
    final program = parse('Algoritmo a\n    x <- 6\n    Escribir x\nFinAlgoritmo');
    Object? value;
    late Interpreter interpreter;
    interpreter = Interpreter(
      program,
      BufferedIO(),
      onStep: (s, line) async {
        if (line == 3) value = await interpreter.evaluateText('x * 7 = 42 AND .V.');
      },
    );
    await interpreter.run();
    expect(value, true);
  });
}
