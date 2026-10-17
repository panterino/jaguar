import 'package:jaguar_core/jaguar_core.dart';
import 'package:test/test.dart';

Flowchart chart(String source) => flowchartsFor(parse(source)).first;

/// Inserts [text] at the ＋ number [n] of the main chart.
String insertAt(String source, int n, String text) {
  final program = parse(source);
  final insert = flowchartsFor(program).first.inserts[n];
  return insertStatement(source, program, insert.point, text).source;
}

void main() {
  const program = '''
Algoritmo demo
    // Pide un número
    Leer n
    Si n > 0 Entonces
        Escribir "positivo" // mensaje
    FinSi
FinAlgoritmo
''';

  test('cada flecha tiene su ＋', () {
    final inserts = chart(program).inserts;
    // main: antes de Leer, entre Leer y Si, después del Si; Sí: antes y después; No: vacío.
    expect(inserts, hasLength(6));
  });

  test('insertar al inicio va debajo de Algoritmo, con sangría', () {
    final result = insertAt(
      program,
      chart(program).inserts.indexWhere((i) => i.point.index == 0 && i.point.headerLine == 1),
      'x <- 1',
    );
    expect(result.split('\n')[1], '    x <- 1');
    expect(result, contains('// Pide un número'), reason: 'los comentarios se quedan');
  });

  test('insertar después de un Si va después de su FinSi', () {
    final source = insertAt(
      program,
      chart(program).inserts.indexWhere((i) => i.point.index == 2 && i.point.headerLine == 1),
      'Escribir "fin"',
    );
    expect(source.split('\n')[6], '    Escribir "fin"');
    expect(parse(source).main.body, hasLength(3));
  });

  test('el lado No de un Si sin SiNo escribe el SiNo', () {
    final p = parse(program);
    final no = flowchartsFor(p).first.inserts.firstWhere((i) => i.point.addElseTo != null);
    final source = insertStatement(program, p, no.point, 'Escribir "no positivo"').source;
    expect(source, contains('    SiNo\n        Escribir "no positivo"\n    FinSi'));
    final ifStmt = parse(source).main.body[1] as IfStmt;
    expect(ifStmt.elseBody, hasLength(1));
  });

  test('un bloque nuevo con varias líneas conserva su sangría relativa', () {
    final first = chart(program).inserts.indexWhere((i) => i.point.index == 0 && i.point.headerLine == 1);
    final source = insertAt(program, first, 'Mientras n > 0 Hacer\n    n <- n - 1\nFinMientras');
    expect(source, contains('    Mientras n > 0 Hacer\n        n <- n - 1\n    FinMientras'));
    expect(() => parse(source), returnsNormally);
  });

  test('eliminar un Si quita todo el bloque', () {
    final p = parse(program);
    final result = deleteStatement(program, p, p.main.body[1]);
    expect(result.source, isNot(contains('FinSi')));
    expect(parse(result.source).main.body, hasLength(1));
  });

  test('eliminar en un Según conserva la etiqueta del caso', () {
    const source = 'Algoritmo a\n    Segun n Hacer\n        1: Escribir "uno"\n    FinSegun\nFinAlgoritmo';
    final p = parse(source);
    final write = (p.main.body.single as SwitchStmt).cases.single.body.single;
    expect(deleteStatement(source, p, write).source, contains('        1:\n    FinSegun'));
  });

  test('reemplazar un bloque conserva el comentario del final', () {
    final p = parse(program);
    final write = (p.main.body[1] as IfStmt).thenBody.single;
    final result = replaceStatementHead(program, write, 'Escribir "es positivo"');
    expect(result.source, contains('        Escribir "es positivo" // mensaje'));
  });

  test('reemplazar la condición de un Repetir', () {
    const source = 'Algoritmo a\n    Repetir\n        Leer n\n    Hasta Que n > 0\nFinAlgoritmo';
    final p = parse(source);
    final result = replaceRepeatCondition(source, p, p.main.body.single as RepeatStmt, 'Hasta Que n >= 10');
    expect(result.source, contains('    Hasta Que n >= 10\nFinAlgoritmo'));
  });

  test('en un programa nuevo el primer bloque ocupa la línea en blanco', () {
    const source = 'Algoritmo a\n    \nFinAlgoritmo\n';
    expect(insertAt(source, 0, 'Leer n'), 'Algoritmo a\n    Leer n\nFinAlgoritmo\n');
  });
}
