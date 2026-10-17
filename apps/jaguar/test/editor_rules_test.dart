import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/editor/editor_rules.dart';

/// Types [char] at the `|` in [text] through [PairFormatter].
String type(String text, String char) {
  final cursor = text.indexOf('|');
  final before = text.replaceFirst('|', '');
  final old = TextEditingValue(
    text: before,
    selection: TextSelection.collapsed(offset: cursor),
  );
  final typed = TextEditingValue(
    text: before.replaceRange(cursor, cursor, char),
    selection: TextSelection.collapsed(offset: cursor + 1),
  );
  final result = PairFormatter().formatEditUpdate(old, typed);
  return result.text.replaceRange(result.selection.baseOffset, result.selection.baseOffset, '|');
}

String backspace(String text) {
  final cursor = text.indexOf('|');
  final before = text.replaceFirst('|', '');
  final old = TextEditingValue(
    text: before,
    selection: TextSelection.collapsed(offset: cursor),
  );
  final deleted = TextEditingValue(
    text: before.replaceRange(cursor - 1, cursor, ''),
    selection: TextSelection.collapsed(offset: cursor - 1),
  );
  final result = PairFormatter().formatEditUpdate(old, deleted);
  return result.text.replaceRange(result.selection.baseOffset, result.selection.baseOffset, '|');
}

TextEditingValue at(String text) {
  final cursor = text.indexOf('|');
  return TextEditingValue(
    text: text.replaceFirst('|', ''),
    selection: TextSelection.collapsed(offset: cursor),
  );
}

String show(TextEditingValue v) => v.text.replaceRange(v.selection.baseOffset, v.selection.baseOffset, '|');

void main() {
  group('pares', () {
    test('abre y cierra paréntesis, corchetes y comillas', () {
      expect(type('x <- raiz|', '('), 'x <- raiz(|)');
      expect(type('v|', '['), 'v[|]');
      expect(type('Escribir |', '"'), 'Escribir "|"');
      expect(type("Escribir |", "'"), "Escribir '|'");
    });

    test('escribir el cierre que ya está lo salta', () {
      expect(type('raiz(x|)', ')'), 'raiz(x)|');
      expect(type('Escribir "hola|"', '"'), 'Escribir "hola"|');
    });

    test('no cierra delante de una palabra, dentro de un texto ni de un comentario', () {
      expect(type('|x', '('), '(|x');
      expect(type('Escribir "a |"', '('), 'Escribir "a (|"');
      expect(type('// nota |', '('), '// nota (|');
      expect(type('Escribir l|', "'"), "Escribir l'|");
    });

    test('borrar la apertura de un par vacío borra los dos', () {
      expect(backspace('raiz(|)'), 'raiz|');
      expect(backspace('Escribir "|"'), 'Escribir |');
      expect(backspace('raiz(|x)'), 'raiz|x)');
    });
  });

  group('cierre de bloques al dar Enter', () {
    test('escribe el cierre con la sangría del bloque', () {
      expect(
        show(closeBlockOnEnter(at('    Si x > 1 Entonces\n        |'))),
        '    Si x > 1 Entonces\n        |\n    FinSi',
      );
      expect(show(closeBlockOnEnter(at('Mientras i < 3 Hacer\n    |'))), 'Mientras i < 3 Hacer\n    |\nFinMientras');
      expect(show(closeBlockOnEnter(at('Repetir\n    |'))), 'Repetir\n    |\nHasta Que ');
      expect(show(closeBlockOnEnter(at('Algoritmo a\n    |'))), 'Algoritmo a\n    |\nFinAlgoritmo');
    });

    test('no lo duplica si ya existe o si el bloque ya tiene cuerpo', () {
      const closed = 'Si x Entonces\n    |\nFinSi';
      expect(show(closeBlockOnEnter(at(closed))), closed);
      const withBody = 'Si x Entonces\n    |\n    Escribir x';
      expect(show(closeBlockOnEnter(at(withBody))), withBody);
      const incomplete = 'Si x\n    |';
      expect(show(closeBlockOnEnter(at(incomplete))), incomplete);
    });
  });

  group('líneas', () {
    test('mover arriba y abajo', () {
      expect(show(moveLines(at('a\nb|\nc'), up: true)), 'b|\na\nc');
      expect(show(moveLines(at('a|\nb\nc'), up: false)), 'b\na|\nc');
      expect(show(moveLines(at('a|\nb'), up: true)), 'a|\nb');
    });

    test('duplicar y eliminar', () {
      expect(show(duplicateLines(at('a|\nb'))), 'a\na|\nb');
      expect(show(deleteLines(at('a\nb|\nc'))), 'a\n|c');
      expect(show(deleteLines(at('a\nb|'))), 'a|');
    });
  });

  test('ordenar sangría', () {
    const messy = '''
Algoritmo a
Leer n
      Si n > 0 Entonces
Escribir "pos"
  SiNo
Escribir "neg"
FinSi
Segun n Hacer
1:
Escribir "uno"
De Otro Modo:
Escribir "otro"
FinSegun
Repetir
n <- n - 1
Hasta Que n < 0
FinAlgoritmo''';
    expect(reindent(messy), '''
Algoritmo a
    Leer n
    Si n > 0 Entonces
        Escribir "pos"
    SiNo
        Escribir "neg"
    FinSi
    Segun n Hacer
        1:
            Escribir "uno"
        De Otro Modo:
            Escribir "otro"
    FinSegun
    Repetir
        n <- n - 1
    Hasta Que n < 0
FinAlgoritmo''');
  });

  group('renombrar y buscar', () {
    test('renombra la variable, no textos ni comentarios ni otras palabras', () {
      const source = 'Leer n\nnum <- n * 2 // n es el dato\nEscribir "n = ", N';
      expect(
        renameIdentifier(source, 'n', 'numero'),
        'Leer numero\nnum <- numero * 2 // n es el dato\nEscribir "n = ", numero',
      );
    });

    test('la palabra bajo el cursor', () {
      expect(identifierAt('x <- total + 1', 7), 'total');
      expect(identifierAt('x <- 12', 6), isNull);
    });

    test('buscar sin importar mayúsculas ni acentos', () {
      expect(findMatches('Número numero NUMERO', 'numero').length, 3);
      expect(findMatches('Número numero', 'Número', matchCase: true).length, 1);
    });
  });
}
