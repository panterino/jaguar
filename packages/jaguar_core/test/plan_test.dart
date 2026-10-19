import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

void main() {
  const program = 'Algoritmo suma\n    Leer a, b\n    Escribir a + b\nFinAlgoritmo\n';

  test('el planteamiento se escribe como comentarios al inicio', () {
    final source = writePlan(program, const ProgramPlan(input: 'dos números', process: 'sumarlos', output: 'la suma'));
    expect(source, startsWith('// Entrada: dos números\n// Proceso: sumarlos\n// Salida: la suma\nAlgoritmo suma'));
    final plan = readPlan(source);
    expect(plan.input, 'dos números');
    expect(plan.output, 'la suma');
  });

  test('cambiarlo reemplaza el anterior y respeta otros comentarios', () {
    final first = writePlan('// Autor: Ana\n$program', const ProgramPlan(input: 'a', output: 'b'));
    final second = writePlan(first, const ProgramPlan(input: 'dos números', process: 'sumar\nlos dos'));
    expect(second, '// Entrada: dos números\n// Proceso: sumar los dos\n// Autor: Ana\n$program');
    expect(readPlan(second).output, '');
  });

  test('sin planteamiento', () {
    expect(readPlan(program).isEmpty, isTrue);
    expect(writePlan(program, const ProgramPlan()), program);
  });

  test('el programa con planteamiento sigue corriendo igual', () async {
    final source = writePlan(program, const ProgramPlan(input: 'dos números'));
    expect((await runProgram(source, inputs: ['2', '3'])).output, '5\n');
  });
}
