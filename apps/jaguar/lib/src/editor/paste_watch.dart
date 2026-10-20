import 'package:flutter/services.dart';

/// Notices when a lot of code arrives at once (pasted, or from the
/// keyboard's clipboard), so the teacher can see it next to the result.
/// It never blocks or changes what was written.
///
/// Only edits by the person count: input formatters don't run when the app
/// itself changes the text (opening a program, the diagram, the formatter).
/// Moving code inside the same program (cut and paste) doesn't count either.
class PasteWatch extends TextInputFormatter {
  PasteWatch(this.onLargePaste);

  /// Receives how many lines arrived in one go.
  final void Function(int lines) onLargePaste;

  /// From this many lines on, it's not typing.
  static const minLines = 5;

  /// Text recently removed from the program: pasting it back is moving it.
  final _removed = <String>[];

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final before = oldValue.text;
    final after = newValue.text;
    if (before == after) return newValue;
    var start = 0;
    final shortest = before.length < after.length ? before.length : after.length;
    while (start < shortest && before.codeUnitAt(start) == after.codeUnitAt(start)) {
      start++;
    }
    var end = 0;
    while (end < shortest - start &&
        before.codeUnitAt(before.length - 1 - end) == after.codeUnitAt(after.length - 1 - end)) {
      end++;
    }
    final removed = before.substring(start, before.length - end);
    final inserted = after.substring(start, after.length - end);
    if (removed.trim().isNotEmpty) {
      _removed.add(removed.trim());
      if (_removed.length > 5) _removed.removeAt(0);
    }
    final lines = '\n'.allMatches(inserted.trimRight()).length + 1;
    if (lines >= minLines) {
      final piece = inserted.trim();
      final moved = before.contains(piece) || _removed.any((r) => r.contains(piece));
      if (!moved) onLargePaste(lines);
    }
    return newValue;
  }
}
