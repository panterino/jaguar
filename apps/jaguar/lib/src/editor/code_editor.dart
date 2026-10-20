import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../settings.dart';
import '../theme.dart';
import 'auto_indent.dart';
import 'paste_watch.dart';
import 'completions.dart';
import 'editor_rules.dart';
import 'syntax_controller.dart';

const _lineHeight = 1.5;
const _padding = EdgeInsets.symmetric(vertical: 12);

/// Code editor with line numbers, in the spirit of VS Code: brackets and
/// blocks that close themselves, indentation guides, the matching block
/// marked, errors underlined while typing, autocomplete, find and replace,
/// line operations and renaming. Lines do not wrap, so the line numbers
/// always match; long lines scroll horizontally.
class CodeEditor extends StatefulWidget {
  const CodeEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errorLine,
    this.fontSize = 14,
    this.highlightCurrentLine = false,
    this.inlineErrors = true,
    this.onLargePaste,
    this.undoController,
    this.executingLine,
    this.diagnostics,
  });

  final SyntaxController controller;
  final FocusNode focusNode;
  final double fontSize;

  /// Desktop: a band behind the cursor's line, as in other code editors.
  final bool highlightCurrentLine;

  /// The error message at the end of its line. Phones show it below the
  /// editor instead, where it fits.
  final bool inlineErrors;

  /// Called when many lines arrive at once (see [PasteWatch]).
  final void Function(int lines)? onLargePaste;

  /// Lets the Editar menu undo and redo.
  final UndoHistoryController? undoController;

  /// Step by step: the line about to run, marked and kept in view.
  final int? executingLine;

  /// Line (1-based) marked in the gutter after an error.
  final int? errorLine;

  /// Errors found while typing, and the program to match blocks.
  final Diagnostics? diagnostics;

  @override
  State<CodeEditor> createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  late final _pasteWatch = PasteWatch((lines) => widget.onLargePaste?.call(lines));

  final _vertical = ScrollController();
  final _horizontal = ScrollController();
  final _findField = TextEditingController();
  final _replaceField = TextEditingController();
  final _findFocus = FocusNode();

  List<Completion> _completions = const [];
  int _selected = 0;
  int _completionStart = 0;
  String _lastText = '';

  bool _findOpen = false;
  bool _replaceOpen = false;
  bool _matchCase = false;
  int _matchIndex = 0;

  SyntaxController get _code => widget.controller;

  @override
  void initState() {
    super.initState();
    _lastText = _code.text;
    _code.addListener(_onCodeChanged);
    _findField.addListener(() => setState(() => _matchIndex = 0));
  }

  @override
  void didUpdateWidget(CodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCodeChanged);
      widget.controller.addListener(_onCodeChanged);
    }
    final line = widget.executingLine;
    if (line != null && line != oldWidget.executingLine) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(line));
    }
  }

  @override
  void dispose() {
    _code.removeListener(_onCodeChanged);
    _vertical.dispose();
    _horizontal.dispose();
    _findField.dispose();
    _replaceField.dispose();
    _findFocus.dispose();
    super.dispose();
  }

  double get _lineHeightPx => MediaQuery.textScalerOf(context).scale(widget.fontSize) * _lineHeight;

  /// Scrolls just enough for [line] to be visible, with some context.
  void _reveal(int line) {
    if (!_vertical.hasClients) return;
    final lineHeight = _lineHeightPx;
    final top = _padding.top + (line - 1) * lineHeight;
    final position = _vertical.position;
    final viewport = position.viewportDimension;
    if (top >= position.pixels + lineHeight && top + 2 * lineHeight <= position.pixels + viewport) return;
    final target = (top - viewport / 3).clamp(0.0, position.maxScrollExtent);
    _vertical.animateTo(target, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  // Autocomplete -------------------------------------------------------------

  void _onCodeChanged() {
    final text = _code.text;
    final typed = text.length == _lastText.length + 1;
    _lastText = text;
    final selection = _code.selection;
    if (!selection.isValid || !selection.isCollapsed || !widget.focusNode.hasFocus) {
      _closeCompletions();
      return;
    }
    final cursor = selection.baseOffset;
    final word = wordBefore(text, cursor);
    // Opens while typing a word; then follows it until the word ends.
    if (word == null || (!typed && _completions.isEmpty) || word.prefix.length < 2 && _completions.isEmpty) {
      _closeCompletions();
      return;
    }
    final list = completionsFor(text, cursor);
    setState(() {
      _completions = list;
      _completionStart = word.start;
      _selected = 0;
    });
  }

  /// Ctrl+Space: suggestions for the word under the cursor, even short.
  void suggest() {
    final cursor = _code.selection.baseOffset;
    if (cursor < 0) return;
    final word = wordBefore(_code.text, cursor);
    if (word == null) return;
    setState(() {
      _completions = completionsFor(_code.text, cursor);
      _completionStart = word.start;
      _selected = 0;
    });
  }

  void _closeCompletions() {
    if (_completions.isNotEmpty) setState(() => _completions = const []);
  }

  void _accept(Completion completion) {
    final cursor = _code.selection.baseOffset;
    final text = _code.text;
    final without = text.replaceRange(_completionStart, cursor, '');
    _completions = const [];
    _code.value = TextEditingValue(
      text: without,
      selection: TextSelection.collapsed(offset: _completionStart),
    );
    _code.insertSnippet(completion.insert);
    _lastText = _code.text;
    setState(() {});
  }

  // Keys ----------------------------------------------------------------------

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final keyboard = HardwareKeyboard.instance;
    final primary = isApple ? keyboard.isMetaPressed : keyboard.isControlPressed;

    if (_completions.isNotEmpty) {
      if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
        final step = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
        setState(() => _selected = (_selected + step) % _completions.length);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.tab) {
        _accept(_completions[_selected]);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.escape) {
        _closeCompletions();
        return KeyEventResult.handled;
      }
    }
    if (key == LogicalKeyboardKey.escape && _findOpen) {
      closeFind();
      return KeyEventResult.handled;
    }

    // Tab indents instead of moving focus; with several lines selected it
    // indents all of them, and Shift+Tab goes back.
    if (key == LogicalKeyboardKey.tab) {
      if (keyboard.isShiftPressed) {
        _code.dedentLines(indentUnit);
      } else if (_code.selectsSeveralLines) {
        _code.indentLines(indentUnit);
      } else {
        _code.insertSnippet(indentUnit);
      }
      return KeyEventResult.handled;
    }
    if (keyboard.isAltPressed && (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.arrowDown)) {
      final up = key == LogicalKeyboardKey.arrowUp;
      _code.value = keyboard.isShiftPressed ? duplicateLines(_code.value) : moveLines(_code.value, up: up);
      return KeyEventResult.handled;
    }
    if (primary && keyboard.isShiftPressed && key == LogicalKeyboardKey.keyK) {
      _code.value = deleteLines(_code.value);
      return KeyEventResult.handled;
    }
    if (keyboard.isAltPressed && keyboard.isShiftPressed && key == LogicalKeyboardKey.keyF) {
      reindentAll();
      return KeyEventResult.handled;
    }
    if (primary && key == LogicalKeyboardKey.keyF) {
      openFind();
      return KeyEventResult.handled;
    }
    if (primary && key == LogicalKeyboardKey.keyH) {
      openFind(replace: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.f2) {
      renameAtCursor();
      return KeyEventResult.handled;
    }
    if (keyboard.isControlPressed && key == LogicalKeyboardKey.space) {
      suggest();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // Commands (also in the Editar menu) ------------------------------------------

  void moveLinesBy({required bool up}) => _code.value = moveLines(_code.value, up: up);
  void duplicate() => _code.value = duplicateLines(_code.value);
  void deleteLine() => _code.value = deleteLines(_code.value);

  /// Ordenar sangría: every line at the depth of its block.
  void reindentAll() {
    final line = _code.cursorPosition.$1;
    final text = reindent(_code.text);
    if (text == _code.text) return;
    _code.value = TextEditingValue(text: text);
    _code.selectLine(line);
    _code.selection = TextSelection.collapsed(offset: _code.selection.end);
  }

  /// F2: renames the variable under the cursor everywhere in the program.
  Future<void> renameAtCursor() async {
    final offset = _code.selection.baseOffset;
    final name = offset < 0 ? null : identifierAt(_code.text, offset);
    if (name == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pon el cursor sobre una variable para cambiarle el nombre.')));
      return;
    }
    final count = occurrencesOf(_code.text, name).length;
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(name: name, count: count),
    );
    if (newName == null || newName == name) return;
    _code.value = TextEditingValue(text: renameIdentifier(_code.text, name, newName), selection: _code.selection);
    widget.focusNode.requestFocus();
  }

  void openFind({bool replace = false}) {
    final selection = _code.selection;
    if (selection.isValid && !selection.isCollapsed) {
      final selected = selection.textInside(_code.text);
      if (!selected.contains('\n')) _findField.text = selected;
    }
    setState(() {
      _findOpen = true;
      _replaceOpen = replace;
    });
    _findField.selection = TextSelection(baseOffset: 0, extentOffset: _findField.text.length);
    _findFocus.requestFocus();
  }

  void closeFind() {
    setState(() => _findOpen = false);
    widget.focusNode.requestFocus();
  }

  List<TextRange> get _matches =>
      _findOpen ? findMatches(_code.text, _findField.text, matchCase: _matchCase) : const [];

  void _goToMatch(int delta) {
    final matches = _matches;
    if (matches.isEmpty) return;
    setState(() => _matchIndex = (_matchIndex + delta) % matches.length);
    final match = matches[_matchIndex];
    _code.selection = TextSelection(baseOffset: match.start, extentOffset: match.end);
    _reveal('\n'.allMatches(_code.text.substring(0, match.start)).length + 1);
  }

  void _replaceOne() {
    final matches = _matches;
    if (matches.isEmpty) return;
    final match = matches[_matchIndex % matches.length];
    _code.value = TextEditingValue(
      text: _code.text.replaceRange(match.start, match.end, _replaceField.text),
      selection: TextSelection.collapsed(offset: match.start + _replaceField.text.length),
    );
    setState(() {});
  }

  void _replaceAll() {
    final matches = _matches;
    if (matches.isEmpty) return;
    var text = _code.text;
    for (final match in matches.reversed) {
      text = text.replaceRange(match.start, match.end, _replaceField.text);
    }
    _code.value = TextEditingValue(text: text);
    setState(() {});
  }

  // Build ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fontSize = widget.fontSize;
    final textScaler = MediaQuery.textScalerOf(context);
    final strut = StrutStyle(fontFamily: monoFamily, fontSize: fontSize, height: _lineHeight, forceStrutHeight: true);
    // No letter spacing: the theme's would make lines wider than measured.
    final textStyle = monoStyle.copyWith(
      fontSize: fontSize,
      height: _lineHeight,
      letterSpacing: 0,
      color: scheme.onSurface,
    );
    final charWidth = (TextPainter(
      text: TextSpan(text: 'M', style: textStyle),
      textDirection: TextDirection.ltr,
      // The field scales its text with the system setting; measure the same.
      textScaler: textScaler,
    )..layout()).width;

    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, widget.focusNode, ?widget.diagnostics]),
      builder: (context, _) {
        final text = widget.controller.text;
        final lines = text.split('\n');
        final lineHeight = textScaler.scale(fontSize) * _lineHeight;
        final cursorLine = widget.controller.cursorPosition.$1;
        final currentLine = widget.highlightCurrentLine && widget.focusNode.hasFocus ? cursorLine : null;
        final diagnostic = widget.diagnostics?.shownError;
        final errorLine = widget.errorLine ?? diagnostic?.line;
        final longest = lines.fold('', (longest, line) => line.length > longest.length ? line : longest);
        // Measured in bold, the widest the line can be drawn: if the field
        // were narrower, the line would wrap and stop matching its number.
        final longestWidth = (TextPainter(
          text: TextSpan(
            text: longest,
            style: textStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout()).width;
        // Room for the error message at the end of its line.
        var lensWidth = 0.0;
        if (widget.inlineErrors && diagnostic != null && diagnostic.line >= 1 && diagnostic.line <= lines.length) {
          lensWidth = (lines[diagnostic.line - 1].length + 4 + _lensText(diagnostic).length) * charWidth;
        }
        final gutterWidth = math.max(3, '${lines.length}'.length + 1) * charWidth + 12;
        final matches = _matches;

        final decorations = _EditorDecorations(
          lines: lines,
          charWidth: charWidth,
          lineHeight: lineHeight,
          top: _padding.top,
          scheme: scheme,
          blockLines: _blockLines(cursorLine),
          brackets: widget.focusNode.hasFocus ? _matchingBrackets(text, _code.selection.baseOffset) : const [],
          matches: [for (final m in matches) _position(lines, m)],
          currentMatch: matches.isEmpty ? -1 : _matchIndex % matches.length,
          diagnostic: diagnostic,
          lens: diagnostic == null || !widget.inlineErrors ? null : _lensText(diagnostic),
          lensStyle: textStyle.copyWith(
            fontSize: fontSize * 0.9,
            fontStyle: FontStyle.italic,
            color: scheme.error.withValues(alpha: 0.85),
          ),
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = math.max(
              constraints.maxWidth - gutterWidth,
              math.max(longestWidth, lensWidth) + 4 * charWidth,
            );
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: gutterWidth,
                  child: ColoredBox(color: scheme.surfaceContainerLow),
                ),
                Scrollbar(
                  controller: _vertical,
                  child: SingleChildScrollView(
                    controller: _vertical,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _focusAtEnd,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Stack(
                          children: [
                            if (widget.executingLine case final line?)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: _padding.top + (line - 1) * lineHeight,
                                height: lineHeight,
                                child: ColoredBox(color: jaguarYellow.withValues(alpha: 0.35)),
                              ),
                            if (currentLine != null)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: _padding.top + (currentLine - 1) * lineHeight,
                                height: lineHeight,
                                child: ColoredBox(color: scheme.onSurface.withValues(alpha: 0.05)),
                              ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Gutter(
                                  lineCount: lines.length,
                                  width: gutterWidth,
                                  errorLine: errorLine,
                                  currentLine: currentLine,
                                  style: textStyle,
                                  strut: strut,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _horizontal,
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: contentWidth,
                                      child: CustomPaint(
                                        painter: decorations,
                                        child: Focus(
                                          onKeyEvent: _onKey,
                                          skipTraversal: true,
                                          // Compact density would shift the text off the line numbers.
                                          child: Theme(
                                            data: theme.copyWith(visualDensity: VisualDensity.standard),
                                            child: TextField(
                                              controller: widget.controller,
                                              focusNode: widget.focusNode,
                                              undoController: widget.undoController,
                                              maxLines: null,
                                              minLines: 1,
                                              style: textStyle,
                                              strutStyle: strut,
                                              // Android defaults to full-width boxes, which put the
                                              // end handle past the end of the selection.
                                              selectionWidthStyle: ui.BoxWidthStyle.tight,
                                              keyboardType: TextInputType.multiline,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              smartQuotesType: SmartQuotesType.disabled,
                                              smartDashesType: SmartDashesType.disabled,
                                              textCapitalization: TextCapitalization.none,
                                              inputFormatters: [_pasteWatch, PairFormatter(), AutoIndentFormatter()],
                                              decoration: const InputDecoration.collapsed(
                                                hintText: 'Escribe tu algoritmo aquí…',
                                              ).copyWith(contentPadding: _padding),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_completions.isNotEmpty)
                  AnimatedBuilder(
                    animation: Listenable.merge([_vertical, _horizontal]),
                    builder: (context, _) {
                      final (line, column) = _code.cursorPosition;
                      final start = column - (_code.selection.baseOffset - _completionStart);
                      final left = gutterWidth + start * charWidth - (_horizontal.hasClients ? _horizontal.offset : 0);
                      final top = _padding.top + line * lineHeight - (_vertical.hasClients ? _vertical.offset : 0) + 2;
                      return Positioned(
                        left: left.clamp(0, math.max(0, constraints.maxWidth - 320)),
                        top: top,
                        child: _CompletionList(completions: _completions, selected: _selected, onTap: _accept),
                      );
                    },
                  ),
                if (_findOpen)
                  Positioned(
                    top: 6,
                    right: 18,
                    child: _FindBar(
                      find: _findField,
                      replace: _replaceField,
                      focusNode: _findFocus,
                      showReplace: _replaceOpen,
                      matchCase: _matchCase,
                      matchCount: matches.length,
                      matchIndex: matches.isEmpty ? 0 : _matchIndex % matches.length + 1,
                      onToggleReplace: () => setState(() => _replaceOpen = !_replaceOpen),
                      onToggleCase: () => setState(() => _matchCase = !_matchCase),
                      onNext: () => _goToMatch(1),
                      onPrevious: () => _goToMatch(-1),
                      onReplace: _replaceOne,
                      onReplaceAll: _replaceAll,
                      onClose: closeFind,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  String _lensText(JaguarError error) => error.hint == null ? error.message : '${error.message} ${error.hint}';

  /// The lines of the block whose keyword is on [line]: Si, SiNo and FinSi
  /// light up together.
  List<int> _blockLines(int line) {
    final program = widget.diagnostics?.program;
    final spans = program?.spans;
    if (program == null || spans == null || !widget.focusNode.hasFocus) return const [];
    List<int>? found;
    void visit(List<Stmt> body) {
      for (final stmt in body) {
        if (found != null) return;
        final lines = switch (stmt) {
          IfStmt() => [stmt.line, ?spans.elseLine(stmt), spans.endLine(stmt)],
          SwitchStmt() => [stmt.line, ?spans.otherwiseLine(stmt), spans.endLine(stmt)],
          WhileStmt() || ForStmt() || ForEachStmt() || RepeatStmt() => [stmt.line, spans.endLine(stmt)],
          _ => const <int>[],
        };
        if (lines.length > 1 && lines.contains(line)) {
          found = lines;
          return;
        }
        switch (stmt) {
          case IfStmt():
            visit(stmt.thenBody);
            visit(stmt.elseBody ?? const []);
          case SwitchStmt():
            for (final c in stmt.cases) {
              visit(c.body);
            }
            visit(stmt.otherwise ?? const []);
          case WhileStmt(:final body) || ForStmt(:final body) || ForEachStmt(:final body) || RepeatStmt(:final body):
            visit(body);
          default:
            break;
        }
      }
    }

    for (final sub in [program.main, ...program.functions.values]) {
      final end = spans.subprogramEnd(sub);
      if (end != null && (line == sub.line || line == end)) return [sub.line, end];
      visit(sub.body);
      if (found != null) return found!;
    }
    return const [];
  }

  /// The bracket next to the cursor and its partner, as (line, column).
  List<(int, int)> _matchingBrackets(String text, int cursor) {
    if (cursor < 0) return const [];
    const open = {'(': ')', '[': ']'};
    const close = {')': '(', ']': '['};
    for (final at in [cursor - 1, cursor]) {
      if (at < 0 || at >= text.length) continue;
      final char = text[at];
      final forward = open.containsKey(char);
      if (!forward && !close.containsKey(char)) continue;
      final target = forward ? open[char]! : close[char]!;
      var depth = 0;
      for (var i = at; forward ? i < text.length : i >= 0; i += forward ? 1 : -1) {
        final c = text[i];
        if (c == '\n') break;
        if (c == char) depth++;
        if (c == target && --depth == 0) {
          final lines = text.split('\n');
          return [
            _position(lines, TextRange(start: at, end: at + 1)).$1,
            _position(lines, TextRange(start: i, end: i + 1)).$1,
          ];
        }
      }
    }
    return const [];
  }

  /// A range as ((line, column), length), 1-based line, 0-based column.
  ((int, int), int) _position(List<String> lines, TextRange range) {
    var offset = 0;
    for (var i = 0; i < lines.length; i++) {
      if (range.start <= offset + lines[i].length) return ((i + 1, range.start - offset), range.end - range.start);
      offset += lines[i].length + 1;
    }
    return ((lines.length, 0), 0);
  }

  void _focusAtEnd() {
    if (widget.focusNode.hasFocus) return;
    widget.focusNode.requestFocus();
    widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
  }
}

/// Everything drawn behind the text: indentation guides, the matching
/// block and brackets, search results and the error.
class _EditorDecorations extends CustomPainter {
  _EditorDecorations({
    required this.lines,
    required this.charWidth,
    required this.lineHeight,
    required this.top,
    required this.scheme,
    required this.blockLines,
    required this.brackets,
    required this.matches,
    required this.currentMatch,
    required this.diagnostic,
    required this.lens,
    required this.lensStyle,
  });

  final List<String> lines;
  final double charWidth;
  final double lineHeight;
  final double top;
  final ColorScheme scheme;
  final List<int> blockLines;
  final List<(int, int)> brackets;
  final List<((int, int), int)> matches;
  final int currentMatch;
  final JaguarError? diagnostic;
  final String? lens;
  final TextStyle lensStyle;

  double _y(int line) => top + (line - 1) * lineHeight;

  @override
  void paint(Canvas canvas, Size size) {
    _guides(canvas);
    final box = Paint()
      ..color = scheme.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // The keywords of the block under the cursor: Si / SiNo / FinSi.
    for (final line in blockLines) {
      if (line < 1 || line > lines.length) continue;
      final text = lines[line - 1];
      final start = text.length - text.trimLeft().length;
      final word = RegExp(r'^\S+').stringMatch(text.trimLeft()) ?? '';
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(start * charWidth - 1, _y(line) + 1, word.length * charWidth + 2, lineHeight - 2),
          const Radius.circular(3),
        ),
        box,
      );
    }
    for (final (line, column) in brackets) {
      canvas.drawRect(Rect.fromLTWH(column * charWidth, _y(line) + 2, charWidth, lineHeight - 4), box);
    }
    for (final (i, ((line, column), length)) in matches.indexed) {
      canvas.drawRect(
        Rect.fromLTWH(column * charWidth, _y(line) + 1, math.max(1, length) * charWidth, lineHeight - 2),
        Paint()..color = (i == currentMatch ? jaguarYellow : jaguarYellow.withValues(alpha: 0.35)),
      );
    }
    _error(canvas);
  }

  /// A thin line per indentation level, as in VS Code.
  void _guides(Canvas canvas) {
    final paint = Paint()
      ..color = scheme.outlineVariant.withValues(alpha: 0.7)
      ..strokeWidth = 1;
    int indentOf(String line) => line.length - line.trimLeft().length;
    for (var i = 0; i < lines.length; i++) {
      var indent = indentOf(lines[i]);
      if (lines[i].trim().isEmpty) {
        // Empty lines continue the guides around them.
        final before = lines.take(i).lastWhere((l) => l.trim().isNotEmpty, orElse: () => '');
        final after = lines.skip(i + 1).firstWhere((l) => l.trim().isNotEmpty, orElse: () => '');
        indent = math.min(indentOf(before), indentOf(after));
      }
      for (var level = 0; level + indentUnit.length <= indent; level += indentUnit.length) {
        final x = level * charWidth + 0.5;
        canvas.drawLine(Offset(x, _y(i + 1)), Offset(x, _y(i + 2)), paint);
      }
    }
  }

  /// A red wave under the error and its message at the end of the line.
  void _error(Canvas canvas) {
    final error = diagnostic;
    if (error == null || error.line < 1 || error.line > lines.length) return;
    final text = lines[error.line - 1];
    var start = math.max(0, error.column - 1);
    if (start >= text.length) start = math.max(0, text.trimRight().length - 1);
    var end = start;
    while (end < text.length && RegExp(r'[^\s]').hasMatch(text[end]) && !(end > start && '()[],'.contains(text[end]))) {
      end++;
    }
    if (end == start) end = start + 1;
    final y = _y(error.line) + lineHeight - 3;
    final wave = Path()..moveTo(start * charWidth, y);
    var x = start * charWidth;
    var up = true;
    while (x < end * charWidth) {
      x += 2;
      wave.lineTo(x, y + (up ? -2 : 0));
      up = !up;
    }
    canvas.drawPath(
      wave,
      Paint()
        ..color = scheme.error
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (lens != null) {
      final painter = TextPainter(
        text: TextSpan(text: lens, style: lensStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final lensX = (text.length + 3) * charWidth;
      painter.paint(canvas, Offset(lensX, _y(error.line) + (lineHeight - painter.height) / 2));
    }
  }

  @override
  bool shouldRepaint(_EditorDecorations old) => true;
}

class _CompletionList extends StatelessWidget {
  const _CompletionList({required this.completions, required this.selected, required this.onTap});

  final List<Completion> completions;
  final int selected;
  final ValueChanged<Completion> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      elevation: 6,
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, completion) in completions.indexed)
                InkWell(
                  onTap: () => onTap(completion),
                  child: Container(
                    color: i == selected ? scheme.secondaryContainer : null,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(_icon(completion.kind), size: 16, color: _color(completion.kind, scheme)),
                        const SizedBox(width: 8),
                        Text(completion.label, style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            completion.detail,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(CompletionKind kind) => switch (kind) {
    CompletionKind.block => Icons.account_tree_outlined,
    CompletionKind.statement => Icons.subdirectory_arrow_right,
    CompletionKind.keyword => Icons.text_fields,
    CompletionKind.type => Icons.category_outlined,
    CompletionKind.function => Icons.functions,
    CompletionKind.variable => Icons.data_object,
    CompletionKind.value => Icons.toggle_on_outlined,
  };

  Color _color(CompletionKind kind, ColorScheme scheme) => switch (kind) {
    CompletionKind.block || CompletionKind.statement || CompletionKind.keyword => scheme.primary,
    CompletionKind.function => scheme.secondary,
    _ => scheme.tertiary,
  };
}

class _FindBar extends StatelessWidget {
  const _FindBar({
    required this.find,
    required this.replace,
    required this.focusNode,
    required this.showReplace,
    required this.matchCase,
    required this.matchCount,
    required this.matchIndex,
    required this.onToggleReplace,
    required this.onToggleCase,
    required this.onNext,
    required this.onPrevious,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onClose,
  });

  final TextEditingController find;
  final TextEditingController replace;
  final FocusNode focusNode;
  final bool showReplace;
  final bool matchCase;
  final int matchCount;
  final int matchIndex;
  final VoidCallback onToggleReplace;
  final VoidCallback onToggleCase;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onReplace;
  final VoidCallback onReplaceAll;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget field(TextEditingController controller, String hint, {FocusNode? focus, VoidCallback? onSubmit}) => SizedBox(
      width: 200,
      height: 30,
      child: TextField(
        controller: controller,
        focusNode: focus,
        style: monoStyle.copyWith(fontSize: 13, letterSpacing: 0),
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => onSubmit?.call(),
      ),
    );
    IconButton button(IconData icon, String tooltip, VoidCallback? onPressed, {bool selected = false}) => IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      isSelected: selected,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      padding: EdgeInsets.zero,
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onClose,
        const SingleActivator(LogicalKeyboardKey.enter, shift: true): onPrevious,
        const SingleActivator(LogicalKeyboardKey.f3): onNext,
      },
      child: Material(
        elevation: 4,
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              button(
                showReplace ? Icons.expand_more : Icons.chevron_right,
                'Reemplazar (${shortcutLabel('H')})',
                onToggleReplace,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      field(find, 'Buscar', focus: focusNode, onSubmit: onNext),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          matchCount == 0 ? 'Sin resultados' : '$matchIndex de $matchCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: matchCount == 0 && find.text.isNotEmpty ? scheme.error : null,
                          ),
                        ),
                      ),
                      button(Icons.text_fields, 'Distinguir mayúsculas y acentos', onToggleCase, selected: matchCase),
                      button(Icons.arrow_upward, 'Anterior (Shift+Enter)', matchCount == 0 ? null : onPrevious),
                      button(Icons.arrow_downward, 'Siguiente (Enter)', matchCount == 0 ? null : onNext),
                      button(Icons.close, 'Cerrar (Esc)', onClose),
                    ],
                  ),
                  if (showReplace) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        field(replace, 'Reemplazar con', onSubmit: onReplace),
                        const SizedBox(width: 6),
                        TextButton(onPressed: matchCount == 0 ? null : onReplace, child: const Text('Reemplazar')),
                        TextButton(onPressed: matchCount == 0 ? null : onReplaceAll, child: const Text('Todos')),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.name, required this.count});

  final String name;
  final int count;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _field = TextEditingController(text: widget.name)
    ..selection = TextSelection(baseOffset: 0, extentOffset: widget.name.length);
  String? _error;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _save() {
    final name = _field.text.trim();
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*$').hasMatch(name)) {
      setState(() => _error = 'Usa letras, números y _, sin espacios, y empieza con una letra.');
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Renombrar '${widget.name}'"),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _field,
          autofocus: true,
          autocorrect: false,
          style: monoStyle.copyWith(letterSpacing: 0),
          decoration: InputDecoration(
            labelText: 'Nuevo nombre',
            helperText: 'Cambia ${widget.count} ${widget.count == 1 ? 'lugar' : 'lugares'} del programa.',
            errorText: _error,
          ),
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Renombrar')),
      ],
    );
  }
}

class _Gutter extends StatelessWidget {
  const _Gutter({
    required this.lineCount,
    required this.width,
    required this.errorLine,
    required this.currentLine,
    required this.style,
    required this.strut,
  });

  final int lineCount;
  final double width;
  final int? errorLine;
  final int? currentLine;
  final TextStyle style;
  final StrutStyle strut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: _padding.copyWith(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var line = 1; line <= lineCount; line++)
            Text(
              '$line',
              strutStyle: strut,
              style: style.copyWith(
                color: line == errorLine
                    ? scheme.error
                    : scheme.onSurfaceVariant.withValues(alpha: line == currentLine ? 1 : 0.6),
                fontWeight: line == errorLine ? FontWeight.w700 : null,
              ),
            ),
        ],
      ),
    );
  }
}
