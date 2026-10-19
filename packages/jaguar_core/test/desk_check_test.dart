import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

void main() {
  test('una fila por instrucción, con las variables después de cada una', () async {
    const source = '''Algoritmo suma
    Leer a
    b <- a * 2
    Escribir "Doble: ", b
FinAlgoritmo
''';
    final check = await deskCheck(source, inputs: ['4']);
    expect(check.error, isNull);
    expect(check.variables, ['a', 'b']);
    expect(check.rows.map((r) => r.line), [2, 3, 4]);
    expect(check.rows.map((r) => r.instruction).first, 'Leer a');
    expect(check.value(0, 'a'), '4');
    expect(check.value(0, 'b'), '');
    expect(check.value(1, 'b'), '8');
    expect(check.changed(1, 'b'), isTrue);
    expect(check.changed(2, 'b'), isFalse);
    expect(check.rows.last.output, 'Doble: 8\n');
  });

  test('los ciclos repiten sus filas', () async {
    const source = '''Algoritmo cuenta
    Para i <- 1 Hasta 3 Hacer
        s <- i
    FinPara
FinAlgoritmo
''';
    final check = await deskCheck(source);
    final assignments = [for (var r = 0; r < check.rows.length; r++) if (check.rows[r].line == 3) check.value(r, 's')];
    expect(assignments, ['1', '2', '3']);
  });

  test('un error termina la tabla y se informa', () async {
    final check = await deskCheck('Algoritmo a\n    Leer x\nFinAlgoritmo\n');
    expect(check.error?.cause, ErrorCause.noMoreInput);
  });

  test('un ciclo infinito se corta', () async {
    final check = await deskCheck('Algoritmo a\n    Mientras Verdadero Hacer\n        x <- 1\n    FinMientras\nFinAlgoritmo\n', maxRows: 20);
    expect(check.truncated, isTrue);
    expect(check.rows.length, 20);
  });

  test('se copia como tabla separada por tabuladores', () async {
    final check = await deskCheck('Algoritmo a\n    x <- 5\n    Escribir x\nFinAlgoritmo\n');
    expect(check.toTsv().split('\n').first, 'Paso\tLínea\tInstrucción\tx\tPantalla');
    expect(check.toTsv().split('\n')[2], '2\t3\tEscribir x\t5\t5');
  });
}
