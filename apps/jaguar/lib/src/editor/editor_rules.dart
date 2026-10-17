import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'auto_indent.dart';

// ---------------------------------------------------------------------------
// Pairs: ( [ " ' close themselves, as in VS Code.

const _pairs = {'(': ')', '[': ']', '"': '"', "'": "'"};
const _closers = {')', ']', '"', "'"};

/// Closes brackets and quotes while typing, steps over a closer that is
/// already there, and deletes both halves of an empty pair.
class PairFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.selection.isCollapsed || !oldValue.selection.isValid) return newValue;
    final grew = newValue.text.length - oldValue.text.length;
    final cursor = newValue.selection.baseOffset;
    if (grew == 1 && cursor >= 1 && oldValue.selection.isCollapsed) {
      return _typed(oldValue, newValue, newValue.text[cursor - 1], cursor);
    }
    if (grew == -1 && oldValue.selection.isCollapsed && cursor == oldValue.selection.baseOffset - 1) {
      return _backspace(oldValue, newValue, cursor);
    }
    return newValue;
  }

  TextEditingValue _typed(TextEditingValue oldValue, TextEditingValue newValue, String char, int cursor) {
    final text = newValue.text;
    final next = cursor < text.length ? text[cursor] : '';
    // Typing the closer that is right there just steps over it.
    if (_closers.contains(char) && next == char && !_insideString(oldValue.text, cursor - 1, except: char)) {
      return TextEditingValue(
        text: oldValue.text,
        selection: TextSelection.collapsed(offset: cursor),
      );
    }
    final closer = _pairs[char];
    if (closer == null) return newValue;
    final line = _lineBefore(text, cursor - 1);
    if (_inComment(line)) return newValue;
    // Only before a space, the end or a closer: `(x` stays as typed.
    if (next.isNotEmpty && next.trim().isNotEmpty && !_closers.contains(next) && next != ',') return newValue;
    if (char == '"' || char == "'") {
      final previous = cursor >= 2 ? text[cursor - 2] : '';
      // Not after a letter (an apostrophe in a word) and not to close a text.
      if (RegExp(r'[A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]').hasMatch(previous)) return newValue;
      if (_insideString(oldValue.text, cursor - 1)) return newValue;
    } else if (_insideString(oldValue.text, cursor - 1)) {
      return newValue;
    }
    return TextEditingValue(
      text: text.replaceRange(cursor, cursor, closer),
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  TextEditingValue _backspace(TextEditingValue oldValue, TextEditingValue newValue, int cursor) {
    final old = oldValue.text;
    final deleted = old[cursor];
    final closer = _pairs[deleted];
    if (closer == null || cursor + 1 >= old.length || old[cursor + 1] != closer) return newValue;
    return TextEditingValue(
      text: newValue.text.replaceRange(cursor, cursor + 1, ''),
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

String _lineBefore(String text, int offset) =>
    text.substring(text.lastIndexOf('\n', math.max(0, offset - 1)) + 1, offset);

bool _inComment(String lineBefore) => _commentStart(lineBefore) != null;

/// Where `//` starts in [line], ignoring texts in quotes.
int? _commentStart(String line) {
  String? quote;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (quote != null) {
      if (char == quote) quote = null;
    } else if (char == '"' || char == "'") {
      quote = char;
    } else if (line.startsWith('//', i)) {
      return i;
    }
  }
  return null;
}

/// Whether [offset] is inside a text in quotes on its line. With [except],
/// that quote counts as not opened yet (for stepping over it).
bool _insideString(String text, int offset, {String? except}) {
  final line = _lineBefore(text, offset);
  String? quote;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (quote != null) {
      if (char == quote) quote = null;
    } else if (char == '"' || char == "'") {
      quote = char;
    } else if (line.startsWith('//', i)) {
      return true;
    }
  }
  return quote != null && quote != except;
}

// ---------------------------------------------------------------------------
// Blocks: Enter after `Si … Entonces` writes the FinSi.

final _blockOpener = RegExp(
  r'^(\s*)(algoritmo|proceso|subproceso|subalgoritmo|funcion|si|mientras|para|segun|repetir)\b(.*)$',
  caseSensitive: false,
);

/// The closing line for an opening one, or null.
String? closerFor(String openingLine) {
  final match = _blockOpener.firstMatch(normalize(openingLine));
  if (match == null) return null;
  final rest = match[3]!.trim();
  return switch (match[2]!) {
    'algoritmo' => 'FinAlgoritmo',
    'proceso' => 'FinProceso',
    'subproceso' => 'FinSubProceso',
    'subalgoritmo' => 'FinSubAlgoritmo',
    'funcion' => 'FinFuncion',
    'si' when rest.endsWith('entonces') => 'FinSi',
    'mientras' when rest.endsWith('hacer') => 'FinMientras',
    'para' when rest.endsWith('hacer') => 'FinPara',
    'segun' when rest.endsWith('hacer') => 'FinSegun',
    'repetir' when rest.isEmpty => 'Hasta Que ',
    _ => null,
  };
}

/// After Enter at the end of an opening line, adds its closer below the
/// new line unless the block already has one (or already has a body).
TextEditingValue closeBlockOnEnter(TextEditingValue value) {
  final cursor = value.selection.baseOffset;
  final text = value.text;
  final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
  final previousStart = text.lastIndexOf('\n', math.max(0, lineStart - 2)) + 1;
  if (lineStart == 0) return value;
  final previous = text.substring(previousStart, lineStart - 1);
  final closer = closerFor(previous);
  if (closer == null) return value;
  final indent = RegExp(r'^[ \t]*').stringMatch(previous)!;
  // Already closed, or with a body: look at the next line with text.
  final lineEnd = text.indexOf('\n', cursor);
  if (lineEnd >= 0) {
    if (text.substring(cursor, lineEnd).trim().isNotEmpty) return value;
    for (final next in text.substring(lineEnd + 1).split('\n')) {
      if (next.trim().isEmpty) continue;
      final nextIndent = RegExp(r'^[ \t]*').stringMatch(next)!;
      if (nextIndent.length > indent.length) return value;
      if (nextIndent.length == indent.length && normalize(next.trim()).startsWith(normalize(closer.trim()))) {
        return value;
      }
      break;
    }
  } else if (text.substring(cursor).trim().isNotEmpty) {
    return value;
  }
  final insertAt = lineEnd < 0 ? text.length : lineEnd;
  return TextEditingValue(text: text.replaceRange(insertAt, insertAt, '\n$indent$closer'), selection: value.selection);
}

// ---------------------------------------------------------------------------
// Lines: move, duplicate, delete (Alt+↑/↓, Shift+Alt+↓, Ctrl+Shift+K).

({int start, int end}) _selectedLines(TextEditingValue value) {
  final text = value.text;
  final selection = value.selection.isValid ? value.selection : const TextSelection.collapsed(offset: 0);
  final start = text.lastIndexOf('\n', math.max(0, selection.start - 1)) + (selection.start == 0 ? 0 : 1);
  var endOffset = selection.end;
  if (endOffset > selection.start && text[endOffset - 1] == '\n') endOffset--;
  var end = text.indexOf('\n', endOffset);
  if (end < 0) end = text.length;
  return (start: selection.start == 0 ? 0 : start, end: end);
}

TextEditingValue moveLines(TextEditingValue value, {required bool up}) {
  final text = value.text;
  final (:start, :end) = _selectedLines(value);
  final block = text.substring(start, end);
  if (up) {
    if (start == 0) return value;
    final previousStart = text.lastIndexOf('\n', start - 2) + 1;
    final previous = text.substring(previousStart, start - 1);
    final moved = text.replaceRange(previousStart, end, '$block\n$previous');
    final shift = -(previous.length + 1);
    return TextEditingValue(text: moved, selection: _shift(value.selection, shift));
  }
  if (end >= text.length) return value;
  var nextEnd = text.indexOf('\n', end + 1);
  if (nextEnd < 0) nextEnd = text.length;
  final next = text.substring(end + 1, nextEnd);
  final moved = text.replaceRange(start, nextEnd, '$next\n$block');
  return TextEditingValue(text: moved, selection: _shift(value.selection, next.length + 1));
}

TextEditingValue duplicateLines(TextEditingValue value) {
  final text = value.text;
  final (:start, :end) = _selectedLines(value);
  final block = text.substring(start, end);
  return TextEditingValue(
    text: text.replaceRange(end, end, '\n$block'),
    selection: _shift(value.selection, block.length + 1),
  );
}

TextEditingValue deleteLines(TextEditingValue value) {
  final text = value.text;
  final (:start, :end) = _selectedLines(value);
  final removeEnd = end < text.length ? end + 1 : end;
  final removeStart = end >= text.length && start > 0 ? start - 1 : start;
  final result = text.replaceRange(removeStart, removeEnd, '');
  return TextEditingValue(
    text: result,
    selection: TextSelection.collapsed(offset: math.min(removeStart, result.length)),
  );
}

TextSelection _shift(TextSelection selection, int by) =>
    TextSelection(baseOffset: selection.baseOffset + by, extentOffset: selection.extentOffset + by);

// ---------------------------------------------------------------------------
// Ordenar sangría (Shift+Alt+F): every line at the depth of its block.

final _closingLine = RegExp(
  r'^(fin\s?(si|para|mientras|segun|algoritmo|proceso|funcion|subproceso|subalgoritmo)|hasta\s+que|mientras\s+que)\b',
);

/// `1:`, `2, 3: Escribir "x"`, `De Otro Modo:`: a case of Según.
bool _isCaseLabel(String normalized) {
  if (RegExp(r'^(de\s+otro\s+modo|caso|opcion)\b').hasMatch(normalized)) return true;
  final colon = normalized.indexOf(':');
  if (colon <= 0 || normalized.startsWith(':=', colon)) return false;
  final head = normalized.substring(0, colon);
  return !head.contains('<-') && !RegExp(r'^(escribir|leer|si|mientras|para|definir)\b').hasMatch(head);
}

/// Re-indents [source] by its blocks, four spaces per level. Lines keep
/// their text; only the leading spaces change.
String reindent(String source) {
  final out = <String>[];
  var depth = 0;
  // Inside Según, case labels sit one level in and their bodies two.
  final segunDepths = <int>[];
  for (final raw in source.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) {
      out.add('');
      continue;
    }
    final n = normalize(line);
    final inSegun = segunDepths.isNotEmpty && depth >= segunDepths.last + 1;
    var level = depth;
    if (_closingLine.hasMatch(n)) {
      if (n.startsWith('finsegun') || n.startsWith('fin segun')) {
        depth = segunDepths.isEmpty ? math.max(0, depth - 1) : segunDepths.removeLast();
      } else {
        depth = math.max(0, depth - 1);
      }
      level = depth;
    } else if (n == 'sino') {
      level = math.max(0, depth - 1);
    } else if (inSegun && _isCaseLabel(n) && !n.startsWith('//')) {
      level = segunDepths.last + 1;
      depth = level + 1;
    }
    out.add('${indentUnit * level}$line');
    if (closerFor(line) != null) {
      if (normalize(line).startsWith('segun')) segunDepths.add(depth);
      depth++;
    }
  }
  return out.join('\n');
}

// ---------------------------------------------------------------------------
// Renombrar (F2) and Buscar (Ctrl+F).

final _identifierChar = RegExp(r'[A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]');

/// The word under [offset], if it is a name (not a keyword or number).
String? identifierAt(String text, int offset) {
  var start = offset;
  var end = offset;
  while (start > 0 && _identifierChar.hasMatch(text[start - 1])) {
    start--;
  }
  while (end < text.length && _identifierChar.hasMatch(text[end])) {
    end++;
  }
  if (start == end) return null;
  final word = text.substring(start, end);
  if (RegExp(r'^[0-9]').hasMatch(word)) return null;
  return word;
}

/// Ranges of the name [name] as a whole word, outside texts and comments.
/// Names are not case sensitive in PSeInt, so neither is this.
List<TextRange> occurrencesOf(String text, String name) {
  final target = normalize(name);
  final ranges = <TextRange>[];
  var offset = 0;
  for (final line in text.split('\n')) {
    final comment = _commentStart(line) ?? line.length;
    String? quote;
    var i = 0;
    while (i < comment) {
      final char = line[i];
      if (quote != null) {
        if (char == quote) quote = null;
        i++;
      } else if (char == '"' || char == "'") {
        quote = char;
        i++;
      } else if (_identifierChar.hasMatch(char)) {
        final start = i;
        while (i < line.length && _identifierChar.hasMatch(line[i])) {
          i++;
        }
        if (normalize(line.substring(start, i)) == target) {
          ranges.add(TextRange(start: offset + start, end: offset + i));
        }
      } else {
        i++;
      }
    }
    offset += line.length + 1;
  }
  return ranges;
}

String renameIdentifier(String text, String from, String to) {
  final ranges = occurrencesOf(text, from);
  final buffer = StringBuffer();
  var last = 0;
  for (final range in ranges) {
    buffer
      ..write(text.substring(last, range.start))
      ..write(to);
    last = range.end;
  }
  buffer.write(text.substring(last));
  return buffer.toString();
}

/// Plain-text matches of [query]; ignoring case and accents unless
/// [matchCase].
List<TextRange> findMatches(String text, String query, {bool matchCase = false}) {
  if (query.isEmpty) return const [];
  final haystack = matchCase ? text : _fold(text);
  final needle = matchCase ? query : _fold(query);
  final ranges = <TextRange>[];
  var from = 0;
  while (true) {
    final index = haystack.indexOf(needle, from);
    if (index < 0) break;
    ranges.add(TextRange(start: index, end: index + needle.length));
    from = index + math.max(1, needle.length);
  }
  return ranges;
}

/// Lowercase without accents, keeping every character in place.
String _fold(String text) => normalize(text);
