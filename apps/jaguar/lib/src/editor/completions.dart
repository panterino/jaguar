import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'syntax_controller.dart';

enum CompletionKind { block, statement, keyword, type, function, variable, value }

/// A suggestion of the autocomplete. [insert] is a snippet: `§` marks
/// where the cursor goes.
class Completion {
  const Completion(this.label, this.insert, this.kind, {this.detail = ''});

  final String label;
  final String insert;
  final CompletionKind kind;
  final String detail;
}

const _statements = <Completion>[
  Completion('Si', 'Si § Entonces\n    \nFinSi', CompletionKind.block, detail: 'Si … Entonces … FinSi'),
  Completion('SiNo', 'SiNo\n    §', CompletionKind.block, detail: 'el otro camino del Si'),
  Completion('Mientras', 'Mientras § Hacer\n    \nFinMientras', CompletionKind.block, detail: 'repetir mientras…'),
  Completion('Para', 'Para i <- 1 Hasta § Hacer\n    \nFinPara', CompletionKind.block, detail: 'repetir contando'),
  Completion('Repetir', 'Repetir\n    §\nHasta Que ', CompletionKind.block, detail: 'repetir hasta que…'),
  Completion(
    'Segun',
    'Segun § Hacer\n    1:\n        \n    De Otro Modo:\n        \nFinSegun',
    CompletionKind.block,
    detail: 'elegir entre opciones',
  ),
  Completion(
    'SubProceso',
    'SubProceso §()\n    \nFinSubProceso',
    CompletionKind.block,
    detail: 'una parte del programa',
  ),
  Completion(
    'Funcion',
    'Funcion resultado <- §()\n    \nFinFuncion',
    CompletionKind.block,
    detail: 'devuelve un valor',
  ),
  Completion('Algoritmo', 'Algoritmo §\n    \nFinAlgoritmo', CompletionKind.block, detail: 'el programa'),
  Completion('Escribir', 'Escribir §', CompletionKind.statement, detail: 'mostrar en la consola'),
  Completion('Leer', 'Leer §', CompletionKind.statement, detail: 'pedir un dato'),
  Completion('Definir', 'Definir § Como Entero', CompletionKind.statement, detail: 'declarar variables'),
  Completion('Dimension', 'Dimension §[10]', CompletionKind.statement, detail: 'crear un arreglo'),
  Completion('Esperar', 'Esperar § Segundos', CompletionKind.statement, detail: 'pausa'),
  Completion('Borrar Pantalla', 'Borrar Pantalla', CompletionKind.statement, detail: 'limpiar la consola'),
];

const _keywords = <Completion>[
  Completion('Entonces', 'Entonces', CompletionKind.keyword),
  Completion('Hacer', 'Hacer', CompletionKind.keyword),
  Completion('Hasta', 'Hasta ', CompletionKind.keyword),
  Completion('Con Paso', 'Con Paso ', CompletionKind.keyword),
  Completion('Como', 'Como ', CompletionKind.keyword),
  Completion('MOD', 'MOD ', CompletionKind.keyword, detail: 'residuo'),
  Completion('Verdadero', 'Verdadero', CompletionKind.value),
  Completion('Falso', 'Falso', CompletionKind.value),
];

const _types = <Completion>[
  Completion('Entero', 'Entero', CompletionKind.type),
  Completion('Real', 'Real', CompletionKind.type),
  Completion('Logico', 'Logico', CompletionKind.type),
  Completion('Caracter', 'Caracter', CompletionKind.type),
  Completion('Texto', 'Texto', CompletionKind.type),
];

final _word = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*');
final _wordEnd = RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*$');

/// The word being typed before [cursor]: its start and text.
({int start, String prefix})? wordBefore(String text, int cursor) {
  final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
  final before = text.substring(lineStart, cursor);
  final match = _wordEnd.firstMatch(before);
  if (match == null) return null;
  // Not inside a text or a comment.
  final head = before.substring(0, match.start);
  if ('"'.allMatches(head).length.isOdd || "'".allMatches(head).length.isOdd || head.contains('//')) return null;
  return (start: lineStart + match.start, prefix: match[0]!);
}

/// Suggestions for the word before [cursor], best first. Statements only
/// where a statement can start; names of the program everywhere.
List<Completion> completionsFor(String text, int cursor, {int max = 8}) {
  final word = wordBefore(text, cursor);
  if (word == null) return const [];
  final prefix = normalize(word.prefix);
  final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
  final atStatementStart = text.substring(lineStart, word.start).trim().isEmpty;
  final afterComo = RegExp(
    r'\bcomo\s+$',
    caseSensitive: false,
  ).hasMatch(normalize(text.substring(lineStart, word.start)));

  bool matches(String label) {
    final l = normalize(label);
    return l.startsWith(prefix) && l != prefix;
  }

  final reserved = {
    for (final c in [..._statements, ..._keywords, ..._types]) normalize(c.label),
    'finsi',
    'finmientras',
    'finpara',
    'finsegun',
    'finalgoritmo',
    'finsubproceso',
    'finfuncion',
    'que',
    'y',
    'o',
    'no',
  };
  final names = <String, String>{};
  for (final match in _word.allMatches(text)) {
    if (match.start == word.start) continue; // the word being typed
    final name = match[0]!;
    final key = normalize(name);
    if (reserved.contains(key) || builtinNames.any((b) => normalize(b) == key)) continue;
    names.putIfAbsent(key, () => name);
  }

  return [
    if (afterComo) ..._types.where((c) => matches(c.label)),
    if (atStatementStart) ..._statements.where((c) => matches(c.label)),
    for (final name in names.values)
      if (matches(name)) Completion(name, name, CompletionKind.variable),
    if (!atStatementStart) ..._keywords.where((c) => matches(c.label)),
    for (final name in builtinNames)
      if (matches(name)) Completion(name, '$name(§)', CompletionKind.function, detail: 'función'),
  ].take(max).toList();
}

/// Checks the code while the student types and keeps the last error, for
/// the red underline, the message at the end of the line and the counter
/// in the status bar. Also keeps the last program that parsed, to match
/// blocks.
class Diagnostics extends ChangeNotifier {
  Diagnostics(this.code) {
    code.addListener(_onChanged);
    _check();
  }

  final SyntaxController code;
  Timer? _timer;
  String? _checked;
  JaguarError? error;
  Program? program;

  void _onChanged() {
    if (code.text == _checked) return;
    _timer?.cancel();
    // Half a word is not a mistake yet.
    _timer = Timer(const Duration(milliseconds: 600), _check);
  }

  void _check() {
    final text = code.text;
    _checked = text;
    try {
      program = parse(text);
      error = null;
    } on JaguarError catch (e) {
      error = e;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    code.removeListener(_onChanged);
    super.dispose();
  }
}
