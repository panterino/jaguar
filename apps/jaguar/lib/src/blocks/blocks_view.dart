import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../diagram/block_dialogs.dart';
import '../diagram/diagram_editing.dart';
import '../editor/syntax_controller.dart';
import '../theme.dart';
import '../widgets/chunky.dart';

/// The face, the edge under it and the text color of a kind of block. One
/// color per idea, so a program can be read by its colors.
class BlockColors {
  const BlockColors(this.face, this.edge, this.ink);

  final Color face;
  final Color edge;
  final Color ink;

  static const _show = BlockColors(Color(0xFFF4B723), Color(0xFFA8730A), Color(0xFF2A1B0F));
  static const _ask = BlockColors(Color(0xFF0B6BAF), Color(0xFF064B7D), Colors.white);
  static const _data = BlockColors(Color(0xFF17796C), Color(0xFF0E564D), Colors.white);
  static const _decide = BlockColors(Color(0xFF6B4BB8), Color(0xFF4A3187), Colors.white);
  static const _repeat = BlockColors(Color(0xFFBF5700), Color(0xFF8A3E00), Colors.white);
  static const _call = BlockColors(Color(0xFFC2185B), Color(0xFF8A0F41), Colors.white);
  static const _neutral = BlockColors(Color(0xFF65503D), Color(0xFF3E2F20), Colors.white);

  static BlockColors of(BlockKind? kind) => switch (kind) {
    BlockKind.salida => _show,
    BlockKind.lectura => _ask,
    BlockKind.asignacion => _data,
    BlockKind.decision || BlockKind.segun => _decide,
    BlockKind.mientras || BlockKind.para || BlockKind.repetir => _repeat,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        if (stale)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Hay un error en la línea ${_error!.line}: ves los bloques del último programa que funcionaba.',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          )
        else if (_editable)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Toca un + para agregar un bloque, toca un bloque para cambiarlo y mantenlo pulsado para más opciones.',
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        _Block(
          colors: BlockColors.of(null),
          text: 'Algoritmo ${main.name}',
          onTap: _editable ? _rename : () => widget.onTapLine(main.line),
        ),
        _body(program, main.body, headerLine: main.line),
        _Block(colors: BlockColors.of(null), text: 'FinAlgoritmo', onTap: null),
        if (program.functions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Funciones y SubProcesos', style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 6),
          for (final sub in program.functions.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _Block(
                colors: BlockColors.of(BlockKind.llamada),
                text: '${sub.returnVar == null ? 'SubProceso' : 'Funcion'} ${sub.name}',
                caption: 'Se cambia en la vista Código',
                onTap: () => widget.onTapLine(sub.line),
              ),
            ),
        ],
        const SizedBox(height: 16),
        _AsWritten(code: widget.code),
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

    Widget header(String text, {String? footer, VoidCallback? onFooterTap, required Widget inside}) => _Compound(
      colors: colors,
      header: _Block(colors: colors, text: text, executing: executing, onTap: tap, onLongPress: hold),
      footer: footer,
      onFooterTap: onFooterTap,
      child: inside,
    );

    switch (stmt) {
      case IfStmt():
        final elseLine = spans?.elseLine(stmt);
        return header(
          'Si ${e(stmt.condition)} Entonces',
          footer: 'FinSi',
          inside: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _body(program, stmt.thenBody, headerLine: stmt.line),
              if (elseLine != null) ...[
                _Divider(colors: colors, text: 'SiNo'),
                _body(program, stmt.elseBody ?? const [], headerLine: elseLine),
              ] else if (_editable)
                _body(program, <Stmt>[], headerLine: stmt.line, addElseTo: stmt),
            ],
          ),
        );
      case WhileStmt():
        return header(
          'Mientras ${e(stmt.condition)} Hacer',
          footer: 'FinMientras',
          inside: _body(program, stmt.body, headerLine: stmt.line),
        );
      case ForStmt():
        final step = stmt.step == null ? '' : ' Con Paso ${e(stmt.step!)}';
        return header(
          'Para ${stmt.variable} <- ${e(stmt.from)} Hasta ${e(stmt.to)}$step Hacer',
          footer: 'FinPara',
          inside: _body(program, stmt.body, headerLine: stmt.line),
        );
      case ForEachStmt():
        return header(
          'Para Cada ${stmt.variable} de ${stmt.arrayName} Hacer',
          footer: 'FinPara',
          inside: _body(program, stmt.body, headerLine: stmt.line),
        );
      case RepeatStmt():
        return header(
          'Repetir',
          footer: '${stmt.untilTrue ? 'Hasta Que' : 'Mientras Que'} ${e(stmt.condition)}',
          onFooterTap: tap,
          inside: _body(program, stmt.body, headerLine: stmt.line),
        );
      case SwitchStmt():
        return header(
          'Segun ${e(stmt.subject)} Hacer',
          footer: 'FinSegun',
          inside: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in stmt.cases) ...[
                _Divider(colors: colors, text: '${c.values.map(e).join(', ')}:'),
                _body(program, c.body, headerLine: spans?.caseLine(c) ?? stmt.line),
              ],
              if (stmt.otherwise != null) ...[
                _Divider(colors: colors, text: 'De Otro Modo:'),
                _body(program, stmt.otherwise!, headerLine: spans?.otherwiseLine(stmt) ?? stmt.line),
              ],
            ],
          ),
        );
      default:
        return _Block(
          colors: colors,
          text: formatSimpleStmt(stmt),
          executing: executing,
          onTap: tap,
          onLongPress: hold,
        );
    }
  }
}

/// One block: a rounded piece with weight and the line it stands for.
class _Block extends StatelessWidget {
  const _Block({
    required this.colors,
    required this.text,
    required this.onTap,
    this.onLongPress,
    this.executing = false,
    this.caption,
  });

  final BlockColors colors;
  final String text;
  final String? caption;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool executing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: onLongPress,
      child: Chunky(
        onTap: onTap,
        fill: colors.face,
        edge: colors.edge,
        outline: executing ? theme.colorScheme.onSurface : null,
        radius: 14,
        minHeight: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        semanticsLabel: text,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: monoStyle.copyWith(color: colors.ink, fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
              ),
              if (caption != null)
                Text(caption!, style: TextStyle(color: colors.ink.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A block that holds others: its header, a rail down the left side with the
/// blocks inside, and a closing bar.
class _Compound extends StatelessWidget {
  const _Compound({required this.colors, required this.header, required this.child, this.footer, this.onFooterTap});

  final BlockColors colors;
  final Widget header;
  final Widget child;
  final String? footer;
  final VoidCallback? onFooterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 18, margin: const EdgeInsets.only(bottom: 0), color: colors.face),
              Expanded(
                child: Padding(padding: const EdgeInsets.only(left: 6), child: child),
              ),
            ],
          ),
        ),
        if (footer != null)
          GestureDetector(
            onTap: onFooterTap,
            child: Container(
              height: 34,
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: colors.face,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                boxShadow: [BoxShadow(color: colors.edge, offset: const Offset(0, 4))],
              ),
              child: Text(
                footer!,
                style: monoStyle.copyWith(color: colors.ink, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}

/// A label between two bodies of one block: SiNo, a case of Según.
class _Divider extends StatelessWidget {
  const _Divider({required this.colors, required this.text});

  final BlockColors colors;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 2, bottom: 2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: colors.face.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(10)),
    child: Text(
      text,
      style: monoStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
  );
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
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 20, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    label == null ? 'Agregar un bloque' : 'Agregar $label',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 32,
      child: Center(
        child: Semantics(
          button: true,
          label: 'Agregar un bloque aquí',
          child: InkResponse(
            onTap: onTap,
            radius: 24,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
                border: Border.all(color: scheme.outline, width: 1.5),
              ),
              child: Icon(Icons.add, size: 18, color: scheme.onSurfaceVariant),
            ),
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
    return Card(
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text('Así se escribe'),
          subtitle: const Text('Los mismos bloques, en pseudocódigo'),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          children: [
            SelectableText(
              code.text.trimRight(),
              style: monoStyle.copyWith(fontSize: 13, color: scheme.onSurface, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
