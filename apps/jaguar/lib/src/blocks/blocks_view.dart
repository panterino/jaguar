import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../diagram/block_dialogs.dart';
import '../diagram/diagram_editing.dart';
import '../editor/syntax_controller.dart';
import '../theme.dart';
import '../widgets/chunky.dart';

/// The face and text color of a kind of block, and the color of the field
/// pill inside it. One color per idea, so a program can be read by its colors.
class BlockColors {
  const BlockColors(this.face, this.edge, this.ink, this.pillInk);

  final Color face;
  final Color edge;
  final Color ink;

  /// The text of the white pill that holds what the block says.
  final Color pillInk;

  static const _show = BlockColors(Color(0xFF2E7D32), Color(0xFF1B5E20), Colors.white, Color(0xFF2E7D32));
  static const _ask = BlockColors(Color(0xFF0077B6), Color(0xFF005A8C), Colors.white, Color(0xFF0060A0));
  static const _data = BlockColors(Color(0xFF5C4300), Color(0xFF3E2D00), Colors.white, Color(0xFF3E2D00));
  static const _control = BlockColors(Color(0xFF8A4B00), Color(0xFF633500), Colors.white, Color(0xFF1F1B13));
  static const _call = BlockColors(Color(0xFF6B4BB8), Color(0xFF4A3187), Colors.white, Color(0xFF4A3187));
  static const _neutral = BlockColors(Color(0xFF4E4639), Color(0xFF332D24), Colors.white, Color(0xFF1F1B13));

  static BlockColors of(BlockKind? kind) => switch (kind) {
    BlockKind.salida => _show,
    BlockKind.lectura => _ask,
    BlockKind.asignacion => _data,
    BlockKind.decision || BlockKind.segun || BlockKind.mientras || BlockKind.para || BlockKind.repetir => _control,
    BlockKind.llamada => _call,
    null => _neutral,
  };
}

/// The categories of the palette, in the order they are offered.
const _categories = <(String, List<BlockKind>)>[
  ('Mostrar y preguntar', [BlockKind.salida, BlockKind.lectura]),
  ('Datos', [BlockKind.asignacion]),
  ('Decisiones', [BlockKind.decision, BlockKind.segun]),
  ('Repetir', [BlockKind.mientras, BlockKind.para, BlockKind.repetir]),
  ('Funciones', [BlockKind.llamada]),
];

const _kindIcons = {
  BlockKind.salida: Icons.chat_bubble_outline_rounded,
  BlockKind.lectura: Icons.keyboard_outlined,
  BlockKind.asignacion: Icons.edit_note_rounded,
  BlockKind.decision: Icons.call_split_rounded,
  BlockKind.segun: Icons.alt_route_rounded,
  BlockKind.mientras: Icons.loop_rounded,
  BlockKind.para: Icons.repeat_rounded,
  BlockKind.repetir: Icons.replay_rounded,
  BlockKind.llamada: Icons.extension_outlined,
};

/// The program as blocks that fit inside each other, like pieces of a
/// puzzle. It is the same program as the code and the diagram: it follows the
/// code as it changes and, with [editing], tapping a ＋ adds a block there,
/// tapping a block changes it and holding it offers to delete it.
class BlocksView extends StatefulWidget {
  const BlocksView({
    super.key,
    required this.code,
    required this.onTapLine,
    this.executingLine,
    this.editing,
    this.onUndo,
  });

  final SyntaxController code;
  final ValueChanged<int> onTapLine;

  /// Step by step: the block about to run is outlined.
  final int? executingLine;

  /// Null while a program runs: the blocks can only be looked at.
  final DiagramEditing? editing;
  final VoidCallback? onUndo;

  @override
  State<BlocksView> createState() => _BlocksViewState();
}

class _BlocksViewState extends State<BlocksView> {
  Timer? _errorTimer;
  Program? _program;
  String? _parsedSource;
  JaguarError? _error;
  bool _showError = false;

  bool get _editable => widget.editing != null;

  @override
  void initState() {
    super.initState();
    widget.code.addListener(_onCodeChanged);
    _parse();
  }

  @override
  void didUpdateWidget(BlocksView old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code) {
      old.code.removeListener(_onCodeChanged);
      widget.code.addListener(_onCodeChanged);
      _parse();
    }
  }

  @override
  void dispose() {
    widget.code.removeListener(_onCodeChanged);
    _errorTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged() {
    if (widget.code.text != _parsedSource) _parse();
    setState(() {});
  }

  /// Parsing is fast, so the blocks follow every keystroke. An error keeps
  /// the last good blocks and is only announced if it lasts: half a word is
  /// not a mistake yet.
  void _parse() {
    final source = widget.code.text;
    _parsedSource = source;
    try {
      _program = parse(source);
      _error = null;
      _showError = false;
      _errorTimer?.cancel();
    } on JaguarError catch (error) {
      _error = error;
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showError = true);
      });
    }
  }

  /// The program the blocks show, or null (with a message) if the code has
  /// an error: the blocks can't be edited until it is fixed.
  Program? _editableProgram() {
    final program = _program;
    if (program != null && _parsedSource == widget.code.text && _error == null) return program;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Corrige el error de la línea ${_error?.line ?? '?'} para poder editar los bloques.')),
      );
    return null;
  }

  // Actions -----------------------------------------------------------------

  Future<void> _add(InsertPoint point) async {
    final editing = widget.editing;
    final program = _editableProgram();
    if (editing == null || program == null) return;
    final kind = await showModalBottomSheet<BlockKind>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const _Palette(),
    );
    if (kind == null || !mounted) return;
    await editing.insert(context, program, point, kind);
  }

  FlowBlock _flowBlock(Stmt stmt) {
    final kind = kindOf(stmt);
    return FlowBlock(const FlowRect(0, 0, 0, 0), kind?.shape ?? BlockShape.process, '', stmt.line, stmt: stmt);
  }

  Future<void> _edit(Stmt stmt) async {
    final editing = widget.editing;
    if (editing == null) {
      widget.onTapLine(stmt.line);
      return;
    }
    final program = _editableProgram();
    if (program == null) return;
    if (stmt is ForEachStmt) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Este bloque se cambia en la vista Código.')));
      widget.onTapLine(stmt.line);
      return;
    }
    await editing.edit(context, program, _flowBlock(stmt));
  }

  Future<void> _rename() async {
    final editing = widget.editing;
    final program = _editableProgram();
    if (editing == null || program == null) return;
    await editing.edit(context, program, const FlowBlock(FlowRect(0, 0, 0, 0), BlockShape.terminal, 'Inicio', 0));
  }

  Future<void> _menu(Stmt stmt) async {
    final editing = widget.editing;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (editing != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Cambiar'),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Ver en el código'),
              onTap: () => Navigator.pop(context, 'line'),
            ),
            if (editing != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  stmt is IfStmt || stmt is WhileStmt || stmt is ForStmt || stmt is RepeatStmt || stmt is SwitchStmt
                      ? 'Eliminar con todo lo que tiene dentro'
                      : 'Eliminar',
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'edit':
        await _edit(stmt);
      case 'line':
        widget.onTapLine(stmt.line);
      case 'delete':
        final program = _editableProgram();
        if (program != null) widget.editing?.delete(program, _flowBlock(stmt));
    }
  }

  // Drawing -----------------------------------------------------------------

  /// A new block at the end of the program, from the tray at the bottom.
  Future<void> _addAtEnd(BlockKind kind) async {
    final editing = widget.editing;
    final program = _editableProgram();
    if (editing == null || program == null) return;
    final main = program.main;
    await editing.insert(context, program, InsertPoint(main.body, main.body.length, headerLine: main.line), kind);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final program = _program;
    if (program == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _showError && _error != null
                ? 'Aún no hay bloques que mostrar: hay un error en la línea ${_error!.line}. '
                      'Corrígelo en la vista Código.'
                : 'Escribe un programa y aquí aparecerán sus bloques.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final main = program.main;
    final stale = _error != null && _showError;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            children: [
              if (stale)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Hay un error en la línea ${_error!.line}: ves los bloques del último programa que funcionaba.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
                  ),
                )
              else if (_editable && main.body.length < 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Toca un + o un bloque de abajo para agregar. Toca un bloque para cambiarlo; mantenlo pulsado para más.',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              _Block(
                colors: BlockColors.of(null),
                keyword: 'Algoritmo',
                chip: main.name,
                onTap: _editable ? _rename : () => widget.onTapLine(main.line),
              ),
              _body(program, main.body, headerLine: main.line),
              const _Block(
                colors: BlockColors(Color(0xFF4E4639), Color(0xFF332D24), Colors.white, Color(0xFF1F1B13)),
                keyword: 'FinAlgoritmo',
                onTap: null,
              ),
              if (program.functions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'FUNCIONES Y SUBPROCESOS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                for (final sub in program.functions.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _Block(
                      colors: BlockColors.of(BlockKind.llamada),
                      keyword: sub.returnVar == null ? 'SubProceso' : 'Funcion',
                      chip: sub.name,
                      caption: 'Se cambia en la vista Código',
                      onTap: () => widget.onTapLine(sub.line),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              _AsWritten(code: widget.code),
            ],
          ),
        ),
        if (_editable) _Tray(onPick: _addAtEnd),
      ],
    );
  }

  /// A body of statements with a ＋ before, between and after them.
  Widget _body(Program program, List<Stmt> body, {required int headerLine, IfStmt? addElseTo}) {
    InsertPoint at(int index) => InsertPoint(body, index, headerLine: headerLine, addElseTo: addElseTo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Slot(
          onTap: _editable ? () => _add(at(0)) : null,
          empty: body.isEmpty,
          label: addElseTo != null ? 'SiNo' : null,
        ),
        for (final (i, stmt) in body.indexed) ...[
          _statement(program, stmt),
          _Slot(onTap: _editable ? () => _add(at(i + 1)) : null),
        ],
      ],
    );
  }

  Widget _statement(Program program, Stmt stmt) {
    final kind = kindOf(stmt);
    // Definir and Dimension are data too, though they have no block to add.
    final colors = BlockColors.of(kind ?? (stmt is DefineStmt || stmt is DimensionStmt ? BlockKind.asignacion : null));
    final spans = program.spans;
    final executing = widget.executingLine == stmt.line;
    String e(Expr expr) => formatExpr(expr);
    void tap() => _edit(stmt);
    void hold() => _menu(stmt);

    _Block head(String keyword, {String? chip, String? suffix}) => _Block(
      colors: colors,
      keyword: keyword,
      chip: chip,
      suffix: suffix,
      executing: executing,
      onTap: tap,
      onLongPress: hold,
      joined: true,
    );

    Widget compound({
      required _Block header,
      required List<_Part> parts,
      required String last,
      String? lastChip,
      VoidCallback? onLastTap,
    }) => _Compound(colors: colors, header: header, parts: parts, last: last, lastChip: lastChip, onLastTap: onLastTap);

    switch (stmt) {
      case IfStmt():
        final elseLine = spans?.elseLine(stmt);
        return compound(
          header: head('Si', chip: e(stmt.condition), suffix: 'Entonces'),
          parts: [
            _Part(body: _body(program, stmt.thenBody, headerLine: stmt.line)),
            if (elseLine != null)
              _Part(
                label: 'SiNo',
                body: _body(program, stmt.elseBody ?? const [], headerLine: elseLine),
              )
            else if (_editable)
              _Part(
                body: _body(program, <Stmt>[], headerLine: stmt.line, addElseTo: stmt),
              ),
          ],
          last: 'FinSi',
        );
      case WhileStmt():
        return compound(
          header: head('Mientras', chip: e(stmt.condition), suffix: 'Hacer'),
          parts: [_Part(body: _body(program, stmt.body, headerLine: stmt.line))],
          last: 'FinMientras',
        );
      case ForStmt():
        final step = stmt.step == null ? '' : ' Con Paso ${e(stmt.step!)}';
        return compound(
          header: head('Para', chip: '${stmt.variable} <- ${e(stmt.from)} Hasta ${e(stmt.to)}$step', suffix: 'Hacer'),
          parts: [_Part(body: _body(program, stmt.body, headerLine: stmt.line))],
          last: 'FinPara',
        );
      case ForEachStmt():
        return compound(
          header: head('Para Cada', chip: '${stmt.variable} de ${stmt.arrayName}', suffix: 'Hacer'),
          parts: [_Part(body: _body(program, stmt.body, headerLine: stmt.line))],
          last: 'FinPara',
        );
      case RepeatStmt():
        return compound(
          header: head('Repetir'),
          parts: [_Part(body: _body(program, stmt.body, headerLine: stmt.line))],
          last: stmt.untilTrue ? 'Hasta Que' : 'Mientras Que',
          lastChip: e(stmt.condition),
          onLastTap: tap,
        );
      case SwitchStmt():
        return compound(
          header: head('Segun', chip: e(stmt.subject), suffix: 'Hacer'),
          parts: [
            for (final c in stmt.cases)
              _Part(
                label: '${c.values.map(e).join(', ')}:',
                body: _body(program, c.body, headerLine: spans?.caseLine(c) ?? stmt.line),
              ),
            if (stmt.otherwise != null)
              _Part(
                label: 'De Otro Modo:',
                body: _body(program, stmt.otherwise!, headerLine: spans?.otherwiseLine(stmt) ?? stmt.line),
              ),
          ],
          last: 'FinSegun',
        );
      default:
        final (keyword, chip) = _simpleParts(stmt);
        return _Block(
          colors: colors,
          keyword: keyword,
          chip: chip,
          executing: executing,
          onTap: tap,
          onLongPress: hold,
        );
    }
  }

  /// The word and the field of a block without anything inside.
  (String, String?) _simpleParts(Stmt stmt) {
    String e(Expr expr) => formatExpr(expr);
    switch (stmt) {
      case WriteStmt():
        return ('Escribir', stmt.values.map(e).join(', '));
      case ReadStmt():
        return ('Leer', stmt.targets.map(e).join(', '));
      case AssignStmt():
        return ('Asignar', '${e(stmt.target)} <- ${e(stmt.value)}');
      default:
        final text = formatSimpleStmt(stmt);
        final space = text.indexOf(' ');
        return space < 0 ? (text, null) : (text.substring(0, space), text.substring(space + 1));
    }
  }
}

/// One block: a rounded piece with the word of the instruction and, in a
/// white pill, what it says.
class _Block extends StatelessWidget {
  const _Block({
    required this.colors,
    required this.keyword,
    required this.onTap,
    this.chip,
    this.suffix,
    this.onLongPress,
    this.executing = false,
    this.caption,
    this.joined = false,
  });

  final BlockColors colors;
  final String keyword;

  /// What the block says (a condition, the values to show...), in a pill.
  final String? chip;

  /// A word after the pill: Entonces, Hacer.
  final String? suffix;
  final String? caption;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool executing;

  /// The header of a compound block: no rounded bottom, it sits on its body.
  final bool joined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = [keyword, if (chip != null) chip!, if (suffix != null) suffix!].join(' ');
    final content = Row(
      children: [
        Flexible(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                keyword,
                style: TextStyle(color: colors.ink, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              if (chip != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
                  child: Text(
                    chip!,
                    style: monoStyle.copyWith(color: colors.pillInk, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              if (suffix != null)
                Text(
                  suffix!,
                  style: TextStyle(color: colors.ink, fontSize: 15, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ],
    );
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Material(
          color: colors.face,
          borderRadius: joined ? const BorderRadius.vertical(top: Radius.circular(12)) : BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: executing
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.onSurface, width: 3),
                    )
                  : null,
              alignment: Alignment.centerLeft,
              child: caption == null
                  ? content
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        content,
                        Text(caption!, style: TextStyle(color: colors.ink.withValues(alpha: 0.85), fontSize: 12)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A body of a compound block, with the word that opens it (SiNo, a case).
class _Part {
  const _Part({required this.body, this.label});

  final Widget body;
  final String? label;
}

/// A block that holds others: its header, then the blocks inside on a light
/// ground with a rail of the block's color down the left, then the closing
/// word.
class _Compound extends StatelessWidget {
  const _Compound({
    required this.colors,
    required this.header,
    required this.parts,
    required this.last,
    this.lastChip,
    this.onLastTap,
  });

  final BlockColors colors;
  final _Block header;
  final List<_Part> parts;
  final String last;
  final String? lastChip;
  final VoidCallback? onLastTap;

  Widget _word(String text, {String? chip, VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(color: colors.ink, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (chip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              child: Text(
                chip,
                style: monoStyle.copyWith(color: colors.pillInk, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ground = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: colors.face,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              for (final part in parts) ...[
                if (part.label != null) _word(part.label!),
                Container(
                  margin: const EdgeInsets.only(left: 18),
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  decoration: BoxDecoration(
                    color: ground,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  child: part.body,
                ),
              ],
              _word(last, chip: lastChip, onTap: onLastTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// A place where a block can go: a small round button, or a wide dashed one
/// when the body is empty.
class _Slot extends StatelessWidget {
  const _Slot({required this.onTap, this.empty = false, this.label});

  final VoidCallback? onTap;
  final bool empty;

  /// When it adds a SiNo instead of a block.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (onTap == null) return SizedBox(height: empty ? 8 : 6);
    if (empty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Semantics(
          button: true,
          label: label == null ? 'Agregar un bloque aquí' : 'Agregar un bloque en $label',
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outline, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    label == null ? 'Agregar un bloque' : 'Agregar $label',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 26,
      child: Center(
        child: Semantics(
          button: true,
          label: 'Agregar un bloque aquí',
          child: InkResponse(
            onTap: onTap,
            radius: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline.withValues(alpha: 0.7), width: 1.5),
              ),
              child: Icon(Icons.add, size: 14, color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// The blocks at hand, at the bottom: one touch adds one at the end of the
/// program. For another place, the ＋ between blocks.
class _Tray extends StatelessWidget {
  const _Tray({required this.onPick});

  final ValueChanged<BlockKind> onPick;

  static const _names = {
    BlockKind.lectura: 'Leer',
    BlockKind.salida: 'Escribir',
    BlockKind.decision: 'Si',
    BlockKind.mientras: 'Mientras',
    BlockKind.para: 'Para',
    BlockKind.asignacion: 'Asignar',
    BlockKind.segun: 'Segun',
    BlockKind.repetir: 'Repetir',
    BlockKind.llamada: 'Llamar',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SizedBox(
        height: 64,
        child: Semantics(
          label: 'Bloques disponibles: toca uno para agregarlo al final',
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            children: [
              for (final entry in _names.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: BlockColors.of(entry.key).face,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onPick(entry.key),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: BlockColors.of(entry.key).ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The blocks to choose from, by category.
class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text('¿Qué bloque quieres agregar?', style: theme.textTheme.titleMedium),
            for (final (title, kinds) in _categories) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Text(
                  title.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              for (final kind in kinds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Chunky(
                    onTap: () => Navigator.pop(context, kind),
                    fill: BlockColors.of(kind).face,
                    edge: BlockColors.of(kind).edge,
                    radius: 14,
                    minHeight: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    semanticsLabel: '${kind.label}. ${kind.description}',
                    child: Row(
                      children: [
                        Icon(_kindIcons[kind], color: BlockColors.of(kind).ink),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                kind.label,
                                style: TextStyle(
                                  color: BlockColors.of(kind).ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                kind.description,
                                style: TextStyle(color: BlockColors.of(kind).ink.withValues(alpha: 0.85), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The pseudocode of the blocks, to see that blocks and code are the same
/// thing. Folded: the blocks are the main view.
class _AsWritten extends StatelessWidget {
  const _AsWritten({required this.code});

  final SyntaxController code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'EL MISMO PROGRAMA, ESCRITO',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          expandedAlignment: Alignment.centerLeft,
          children: [
            Text.rich(
              code.buildTextSpan(
                context: context,
                style: monoStyle.copyWith(fontSize: 13, color: scheme.onSurface, height: 1.5),
                withComposing: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
