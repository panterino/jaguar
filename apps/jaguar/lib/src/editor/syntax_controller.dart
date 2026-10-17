import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

const _keywords = {
  'algoritmo', 'finalgoritmo', 'proceso', 'finproceso', 'funcion', 'finfuncion', //
  'subproceso', 'finsubproceso', 'subalgoritmo', 'finsubalgoritmo', 'definir', 'como',
  'dimension', 'dimensionar', 'escribir', 'imprimir', 'mostrar', 'leer', 'si',
  'entonces', 'sino', 'finsi', 'segun', 'hacer', 'finsegun', 'mientras',
  'finmientras', 'repetir', 'hasta', 'que', 'para', 'con', 'paso', 'finpara', 'cada',
  'esperar', 'fin', 'de', 'otro', 'modo', 'por', 'referencia', 'valor', 'sin',
  'saltar', 'bajar', 'tecla', 'segundo', 'segundos', 'milisegundo', 'milisegundos',
  'borrar', 'limpiar', 'pantalla', 'caso', 'opcion',
};

const _operatorWords = {'y', 'o', 'no', 'mod'};

const _constants = {'verdadero', 'falso', 'pi'};

const _types = {'entero', 'real', 'numero', 'numerico', 'logico', 'caracter', 'texto', 'cadena'};

final _builtins = {for (final name in builtinNames) normalize(name)};

final _token = RegExp(
  r'(//[^\n]*)' // comment
  r'|("[^"\n]*"?|“[^”\n]*”?|'
  "'[^'\\n]*'?"
  r')' // string
  r'|(\d+(?:\.\d+)?)' // number
  r'|([A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*)' // word
  r'|(<-|<=|>=|<>|==|!=|:=|[-+*/^%=<>&|~!])', // operator
);

/// A text controller that colors PSeInt pseudocode.
class SyntaxController extends TextEditingController {
  SyntaxController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // While an IME is composing (e.g. accents on mobile) keep the default
    // underline behavior.
    if (withComposing && value.composing.isValid && !value.composing.isCollapsed) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    final colors = SyntaxColors.of(context);
    final spans = <TextSpan>[];
    var last = 0;
    for (final match in _token.allMatches(text)) {
      if (match.start > last) spans.add(TextSpan(text: text.substring(last, match.start)));
      spans.add(TextSpan(text: match[0], style: _styleFor(match, colors)));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: style, children: spans);
  }

  TextStyle? _styleFor(RegExpMatch match, SyntaxColors colors) {
    if (match[1] != null) return TextStyle(color: colors.comment, fontStyle: FontStyle.italic);
    if (match[2] != null) return TextStyle(color: colors.string);
    if (match[3] != null) return TextStyle(color: colors.number);
    if (match[5] != null) return TextStyle(color: colors.operator);
    final word = normalize(match[4]!);
    if (_keywords.contains(word)) return TextStyle(color: colors.keyword, fontWeight: FontWeight.w700);
    if (_operatorWords.contains(word)) return TextStyle(color: colors.operator, fontWeight: FontWeight.w700);
    if (_constants.contains(word)) return TextStyle(color: colors.number);
    if (_types.contains(word)) return TextStyle(color: colors.type);
    if (_builtins.contains(word)) return TextStyle(color: colors.builtin);
    return null;
  }

  /// Selects the whole [line] (1-based) so the student sees where an error is.
  void selectLine(int line) {
    var start = 0;
    for (var i = 1; i < line; i++) {
      final next = text.indexOf('\n', start);
      if (next < 0) break;
      start = next + 1;
    }
    var end = text.indexOf('\n', start);
    if (end < 0) end = text.length;
    selection = TextSelection(baseOffset: start, extentOffset: end);
  }

  /// The cursor's line and column, both 1-based.
  (int line, int column) get cursorPosition {
    final offset = selection.isValid ? selection.extentOffset.clamp(0, text.length) : 0;
    final before = text.substring(0, offset);
    final lineStart = before.lastIndexOf('\n') + 1;
    return ('\n'.allMatches(before).length + 1, offset - lineStart + 1);
  }

  /// Start offsets of the lines the selection touches.
  List<int> _selectedLineStarts() {
    final sel = selection.isValid ? selection : TextSelection.collapsed(offset: text.length);
    var end = sel.end;
    // A selection that ends at the start of a line does not include it.
    if (end > sel.start && text[end - 1] == '\n') end--;
    final starts = <int>[sel.start == 0 ? 0 : text.lastIndexOf('\n', sel.start - 1) + 1];
    for (var i = text.indexOf('\n', starts.first); i >= 0 && i < end; i = text.indexOf('\n', i + 1)) {
      starts.add(i + 1);
    }
    return starts;
  }

  /// Rewrites each selected line with [edit] and keeps those lines selected.
  void _editLines(String Function(String line) edit) {
    final starts = _selectedLineStarts();
    final first = starts.first;
    var last = text.indexOf('\n', starts.last);
    if (last < 0) last = text.length;
    final lines = text.substring(first, last).split('\n').map(edit).join('\n');
    final multiline = starts.length > 1;
    final caret = selection.isValid ? selection.extentOffset : first;
    final delta = lines.length - (last - first);
    value = TextEditingValue(
      text: text.replaceRange(first, last, lines),
      selection: multiline
          ? TextSelection(baseOffset: first, extentOffset: first + lines.length)
          : TextSelection.collapsed(offset: (caret + delta).clamp(first, first + lines.length)),
    );
  }

  /// Comments the selected lines with `//`, or uncomments them if they all
  /// are comments already.
  void toggleComment() {
    final starts = _selectedLineStarts();
    final lines = [for (final s in starts) text.substring(s, _lineEnd(s))];
    final code = lines.where((l) => l.trim().isNotEmpty);
    final uncomment = code.isNotEmpty && code.every((l) => l.trimLeft().startsWith('//'));
    _editLines((line) {
      if (line.trim().isEmpty) return line;
      final indent = RegExp(r'^[ \t]*').stringMatch(line)!;
      final rest = line.substring(indent.length);
      if (!uncomment) return '$indent// $rest';
      return indent + rest.substring(rest.startsWith('// ') ? 3 : 2);
    });
  }

  void indentLines(String unit) => _editLines((line) => line.isEmpty ? line : '$unit$line');

  void dedentLines(String unit) => _editLines((line) {
    if (line.startsWith('\t')) return line.substring(1);
    var spaces = 0;
    while (spaces < unit.length && spaces < line.length && line[spaces] == ' ') {
      spaces++;
    }
    return line.substring(spaces);
  });

  bool get selectsSeveralLines => selection.isValid && text.substring(selection.start, selection.end).contains('\n');

  int _lineEnd(int start) {
    final end = text.indexOf('\n', start);
    return end < 0 ? text.length : end;
  }

  /// Inserts [snippet] at the cursor. Newlines keep the current line's
  /// indentation and `§` marks where the cursor ends up.
  void insertSnippet(String snippet) {
    final current = value;
    final selection = current.selection.isValid
        ? current.selection
        : TextSelection.collapsed(offset: current.text.length);
    final lineStart = selection.start == 0 ? 0 : current.text.lastIndexOf('\n', selection.start - 1) + 1;
    final indent = RegExp(r'^[ \t]*').stringMatch(current.text.substring(lineStart)) ?? '';
    var insertion = snippet.replaceAll('\n', '\n$indent');
    final cursor = insertion.indexOf('§');
    insertion = insertion.replaceFirst('§', '');
    value = TextEditingValue(
      text: current.text.replaceRange(selection.start, selection.end, insertion),
      selection: TextSelection.collapsed(offset: selection.start + (cursor >= 0 ? cursor : insertion.length)),
    );
  }
}
