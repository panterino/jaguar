import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import 'editor_rules.dart';

const indentUnit = '    ';

final _opener = RegExp(
  r'^\s*((algoritmo|proceso|funcion|subproceso|subalgoritmo)\b.*|si\b.*|sino|segun\b.*|mientras\b.*hacer|'
  r'para\b.*|repetir|de otro modo\s*:|.*:\s*)$',
);

final _closer = RegExp(
  r'^\s*(fin\s?(si|para|mientras|segun|algoritmo|proceso|funcion|subproceso|subalgoritmo)|sino|hasta que|'
  r'mientras que|de otro modo)$',
);

final _leadingSpace = RegExp(r'^[ \t]*');

/// Keeps indentation tidy while typing, which saves a lot of taps on a phone
/// keyboard:
/// - Enter keeps the previous line's indentation, one level more after a
///   line that opens a block (`Si ... Entonces`, `Para ...`).
/// - Finishing a closing word (`FinSi`, `SiNo`, `Hasta Que`...) moves that
///   line back to the level of the block it closes.
class AutoIndentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cursor = newValue.selection.baseOffset;
    if (newValue.text.length - oldValue.text.length != 1 || !newValue.selection.isCollapsed || cursor < 1) {
      return newValue;
    }
    return newValue.text[cursor - 1] == '\n' ? _indentNewLine(newValue, cursor) : _dedentCloser(newValue, cursor);
  }

  TextEditingValue _indentNewLine(TextEditingValue value, int cursor) {
    final before = value.text.substring(0, cursor - 1);
    final previousLine = before.substring(before.lastIndexOf('\n') + 1);
    var indent = _leadingSpace.stringMatch(previousLine) ?? '';
    final normalized = normalize(previousLine);
    if (_opener.hasMatch(normalized) && !normalized.trim().startsWith('//')) indent += indentUnit;
    if (indent.isEmpty) return value;
    // After `Si … Entonces` and the like, the closing line comes too.
    return closeBlockOnEnter(
      TextEditingValue(
        text: value.text.replaceRange(cursor, cursor, indent),
        selection: TextSelection.collapsed(offset: cursor + indent.length),
      ),
    );
  }

  TextEditingValue _dedentCloser(TextEditingValue value, int cursor) {
    final text = value.text;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    var lineEnd = text.indexOf('\n', cursor);
    if (lineEnd < 0) lineEnd = text.length;
    // Only when the closing word was just completed at the end of the line.
    if (cursor != lineEnd) return value;
    final line = text.substring(lineStart, lineEnd);
    if (!_closer.hasMatch(normalize(line)) || _closer.hasMatch(normalize(line.substring(0, line.length - 1)))) {
      return value;
    }

    // The block's level: the previous line's if it opened the block (an
    // empty block), one less if it is a line inside the block.
    final previous = _previousNonEmptyLine(text, lineStart);
    if (previous == null) return value;
    final previousIndent = _width(_leadingSpace.stringMatch(previous) ?? '');
    final opensBlock = _opener.hasMatch(normalize(previous));
    final target = opensBlock ? previousIndent : previousIndent - indentUnit.length;
    final currentIndent = _leadingSpace.stringMatch(line) ?? '';
    if (target < 0 || _width(currentIndent) <= target) return _dropAutoCloser(value, cursor);

    final newIndent = ' ' * target;
    final delta = newIndent.length - currentIndent.length;
    return _dropAutoCloser(
      TextEditingValue(
        text: text.replaceRange(lineStart, lineStart + currentIndent.length, newIndent),
        selection: TextSelection.collapsed(offset: cursor + delta),
      ),
      cursor + delta,
    );
  }

  /// Typing `FinSi` by hand right above the FinSi that Enter wrote: the
  /// written one goes, as VS Code does when typing a closing bracket.
  TextEditingValue _dropAutoCloser(TextEditingValue value, int cursor) {
    final text = value.text;
    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    final lineEnd = text.indexOf('\n', cursor);
    if (lineEnd < 0) return value;
    final line = text.substring(lineStart, lineEnd);
    var nextStart = lineEnd + 1;
    while (nextStart < text.length) {
      var nextEnd = text.indexOf('\n', nextStart);
      if (nextEnd < 0) nextEnd = text.length;
      final next = text.substring(nextStart, nextEnd);
      if (next.trim().isEmpty) {
        nextStart = nextEnd + 1;
        continue;
      }
      final sameIndent = (_leadingSpace.stringMatch(next) ?? '') == (_leadingSpace.stringMatch(line) ?? '');
      if (sameIndent && normalize(next.trim()) == normalize(line.trim())) {
        return TextEditingValue(text: text.replaceRange(lineEnd, nextEnd, ''), selection: value.selection);
      }
      return value;
    }
    return value;
  }

  String? _previousNonEmptyLine(String text, int lineStart) {
    var end = lineStart - 1;
    while (end > 0) {
      final start = text.lastIndexOf('\n', end - 1) + 1;
      final line = text.substring(start, end);
      if (line.trim().isNotEmpty) return line;
      end = start - 1;
    }
    return null;
  }

  int _width(String indent) => indent.replaceAll('\t', indentUnit).length;
}
