import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../editor/syntax_controller.dart';
import '../programs/program_store.dart';
import '../theme.dart';
import 'block_dialogs.dart';
import 'diagram_editing.dart';
import 'diagram_painter.dart';

/// The program as a flowchart. It follows the code as the student types,
/// and with [editing] it is also a DFD-style editor: choose an object in
/// the palette and tap a ＋ on an arrow to put it there; double-click a
/// block to change it.
class DiagramView extends StatefulWidget {
  const DiagramView({
    super.key,
    required this.code,
    required this.onTapLine,
    this.executingLine,
    this.notation = Notation.pseint,
    this.onNotationChanged,
    this.editing,
    this.onUndo,
  });

  final SyntaxController code;
  final ValueChanged<int> onTapLine;

  /// Step by step: the block about to run lights up in yellow.
  final int? executingLine;

  /// PSeInt or DFD notation inside the blocks.
  final Notation notation;
  final ValueChanged<Notation>? onNotationChanged;

  /// Null for a read-only diagram (while a program runs).
  final DiagramEditing? editing;
  final VoidCallback? onUndo;

  @override
  State<DiagramView> createState() => _DiagramViewState();
}

class _DiagramViewState extends State<DiagramView> {
  final _transform = TransformationController();
  final _focus = FocusNode(debugLabel: 'diagrama');
  Timer? _errorTimer;
  Program? _program;
  DiagramSheet? _sheet;
  String? _parsedSource;
  JaguarError? _error;
  bool _showError = false;
  late double _charWidth = diagramCharWidth();
  Size _viewport = Size.zero;
  bool _fitted = false;

  /// The object chosen in the palette; null is the selection cursor.
  BlockKind? _tool;
  FlowInsert? _hovered;

  bool get _editable => widget.editing != null;

  @override
  void initState() {
    super.initState();
    widget.code.addListener(_onCodeChanged);
    _parse();
  }

  @override
  void didUpdateWidget(DiagramView old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code) {
      old.code.removeListener(_onCodeChanged);
      widget.code.addListener(_onCodeChanged);
      _parse();
    } else if (old.notation != widget.notation) {
      _parse();
    }
  }

  @override
  void dispose() {
    widget.code.removeListener(_onCodeChanged);
    _errorTimer?.cancel();
    _transform.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    if (widget.code.text != _parsedSource) _parse();
    setState(() {});
  }

  /// Parsing is fast, so the diagram follows every keystroke. An error
  /// keeps the last good diagram and is only announced if it lasts: half a
  /// word is not a mistake yet.
  void _parse() {
    final source = widget.code.text;
    _parsedSource = source;
    try {
      final program = parse(source);
      _program = program;
      _sheet = DiagramSheet(
        flowchartsFor(
          program,
          metrics: FlowMetrics(charWidth: _charWidth),
          notation: widget.notation,
        ),
      );
      _error = null;
      _showError = false;
      _errorTimer?.cancel();
    } on JaguarError catch (error) {
      _error = error;
      _program = null;
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showError = true);
      });
    }
  }

  int? get _cursorLine {
    final selection = widget.code.selection;
    return selection.isValid ? widget.code.cursorPosition.$1 : null;
  }

  /// The block of the line under the cursor, for Supr and Enter.
  FlowBlock? get _selectedBlock {
    final line = _cursorLine;
    return line == null ? null : _sheet?.blockForLine(line);
  }

  /// The program the diagram shows, or null (with a message) if the code
  /// has an error: the diagram can't be edited until it is fixed.
  Program? _editableProgram() {
    final program = _program;
    if (program != null && _parsedSource == widget.code.text) return program;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Corrige el error de la línea ${_error?.line ?? '?'} para poder editar el diagrama.')),
    );
    return null;
  }

  // Gestures ----------------------------------------------------------------

  Future<void> _onTap(TapUpDetails details) async {
    _focus.requestFocus();
    final sheet = _sheet;
    if (sheet == null) return;
    final position = details.localPosition;
    final insert = _editable ? sheet.insertAt(position) : null;
    if (insert != null) {
      final tool = _tool;
      if (tool != null) {
        setState(() => _tool = null);
        await _insert(insert, tool);
      } else {
        await _chooseAndInsert(insert, details.globalPosition);
      }
      return;
    }
    final block = sheet.blockAt(position);
    if (block != null && block.line > 0) widget.onTapLine(block.line);
  }

  Future<void> _onDoubleTap(Offset position) async {
    final block = _sheet?.blockAt(position);
    if (block != null && _editable) await _edit(block);
  }

  Future<void> _onContextMenu(Offset local, Offset global) async {
    final block = _sheet?.blockAt(local);
    if (block == null || !_editable) return;
    if (block.line > 0) widget.onTapLine(block.line);
    final canDelete = block.stmt != null;
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(global.dx, global.dy, global.dx, global.dy),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Editar')),
        ),
        if (canDelete)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Eliminar')),
          ),
      ],
    );
    if (choice == 'edit') await _edit(block);
    if (choice == 'delete') _delete(block);
  }

  Future<void> _chooseAndInsert(FlowInsert insert, Offset global) async {
    final scheme = Theme.of(context).colorScheme;
    final kind = await showMenu<BlockKind>(
      context: context,
      position: RelativeRect.fromLTRB(global.dx, global.dy, global.dx, global.dy),
      items: [
        for (final kind in BlockKind.values)
          PopupMenuItem(
            value: kind,
            child: Row(
              children: [
                SizedBox(width: 30, height: 18, child: CustomPaint(painter: ShapeIconPainter(kind.shape, scheme))),
                const SizedBox(width: 10),
                Text(kind.label),
              ],
            ),
          ),
      ],
    );
    if (kind != null) await _insert(insert, kind);
  }

  Future<void> _insert(FlowInsert insert, BlockKind kind) async {
    final program = _editableProgram();
    if (program != null) await widget.editing!.insert(context, program, insert.point, kind);
  }

  Future<void> _edit(FlowBlock block) async {
    final program = _editableProgram();
    if (program != null) await widget.editing!.edit(context, program, block);
  }

  void _delete(FlowBlock block) {
    final program = _editableProgram();
    if (program != null) widget.editing!.delete(program, block);
  }

  /// DFD's keys: Supr deletes the selected object, Enter edits it, Esc
  /// goes back to the cursor.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !_editable) return KeyEventResult.ignored;
    // A dialog or menu on top gets the keys, not the diagram behind it.
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && _tool != null) {
      setState(() => _tool = null);
      return KeyEventResult.handled;
    }
    final block = _selectedBlock;
    if (block == null) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) {
      _delete(block);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter) {
      _edit(block);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // View --------------------------------------------------------------------

  void _zoom(double factor) {
    final center = _viewport.center(Offset.zero);
    final matrix = _transform.value.clone()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(factor, factor, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    _transform.value = matrix;
  }

  /// Shows the whole diagram, never bigger than its real size.
  void _fit() {
    final sheet = _sheet;
    if (sheet == null || _viewport.isEmpty) return;
    const padding = 24.0;
    final compact = _viewport.width < 600;
    final left = _editable && !compact ? _paletteWidth + padding : padding;
    final top = _editable && compact ? 48 + padding / 2 : padding;
    final widthScale = (_viewport.width - left - padding) / sheet.size.width;
    // A phone fits the width and scrolls down; fitting a long program
    // whole would leave its blocks unreadable.
    final scale = compact
        ? math.min(1.0, math.max(widthScale, 0.55))
        : math.min(1.0, math.min(widthScale, (_viewport.height - top - padding) / sheet.size.height));
    final dx = left + (_viewport.width - left - padding - sheet.size.width * scale) / 2;
    _transform.value = Matrix4.identity()
      ..translateByDouble(compact ? dx : math.max(dx, left), top, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  Future<void> _exportPng() async {
    final sheet = _sheet;
    if (sheet == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final colors = DiagramColors.of(buildTheme(Brightness.light).colorScheme);
    const scale = 2.0;
    const margin = 24.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scale)
      ..drawColor(Colors.white, BlendMode.src)
      ..translate(margin, margin);
    DiagramPainter(sheet, colors).paint(canvas, sheet.size);
    final width = ((sheet.size.width + 2 * margin) * scale).ceil();
    final height = ((sheet.size.height + 2 * margin) * scale).ceil();
    final image = await recorder.endRecording().toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Guardar diagrama',
        fileName: '${programName(widget.code.text)}_diagrama.png',
        type: FileType.custom,
        allowedExtensions: const ['png'],
        bytes: data.buffer.asUint8List(),
      );
      if (path != null || kIsWeb) messenger.showSnackBar(const SnackBar(content: Text('Diagrama guardado')));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No se pudo guardar la imagen: $e')));
    }
  }

  static const _paletteWidth = 152.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sheet = _sheet;
    final cursorLine = _cursorLine;
    final emptyProgram = _program != null && _program!.main.body.isEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        // Phones: the palette is a strip on top instead of a column that
        // would cover half the diagram.
        final compact = constraints.maxWidth < 600;
        final hintLeft = compact ? 12.0 : _paletteWidth + 20;
        final hintTop = compact && _editable ? 60.0 : 12.0;
        if (!_fitted && sheet != null) {
          _fitted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
        }
        return Focus(
          focusNode: _focus,
          onKeyEvent: _onKey,
          child: ColoredBox(
            color: scheme.surface,
            child: Stack(
              children: [
                if (sheet == null)
                  const Center(child: Text('Escribe tu algoritmo para ver su diagrama'))
                else
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transform,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(400),
                      minScale: 0.2,
                      maxScale: 3,
                      child: MouseRegion(
                        cursor: _tool != null ? SystemMouseCursors.copy : SystemMouseCursors.basic,
                        onHover: _editable
                            ? (event) {
                                final hovered = sheet.insertAt(event.localPosition);
                                if (!identical(hovered, _hovered)) setState(() => _hovered = hovered);
                              }
                            : null,
                        child: GestureDetector(
                          onTapUp: _onTap,
                          onDoubleTapDown: (details) => _pendingDoubleTap = details.localPosition,
                          onDoubleTap: () {
                            final position = _pendingDoubleTap;
                            if (position != null) _onDoubleTap(position);
                          },
                          onSecondaryTapUp: (d) => _onContextMenu(d.localPosition, d.globalPosition),
                          onLongPressStart: (d) => _onContextMenu(d.localPosition, d.globalPosition),
                          child: CustomPaint(
                            size: sheet.size,
                            painter: DiagramPainter(
                              sheet,
                              DiagramColors.of(scheme),
                              highlightLine: widget.executingLine == null ? cursorLine : null,
                              executingLine: widget.executingLine,
                              showInserts: _editable,
                              toolSelected: _tool != null,
                              hoveredInsert: _hovered,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_editable)
                  if (compact)
                    Positioned(left: 0, right: 0, top: 0, child: _paletteStrip(scheme))
                  else
                    Positioned(left: 8, top: 8, bottom: 64, child: _palette(scheme)),
                if (_editable && (_tool != null || emptyProgram))
                  Positioned(
                    left: hintLeft,
                    right: 12,
                    top: hintTop,
                    child: _Hint(
                      text: _tool != null
                          ? 'Toca un ＋ del diagrama para colocar: ${_tool!.label}.  (Esc para cancelar)'
                          : compact
                          ? 'Elige un objeto arriba y toca el ＋ entre Inicio y Fin.'
                          : 'Elige un objeto a la izquierda y toca el ＋ entre Inicio y Fin. '
                                'O toca el ＋ directamente para ver la lista.',
                    ),
                  ),
                if (_error != null && _showError)
                  Positioned(
                    left: _editable ? hintLeft : 12,
                    right: 12,
                    top: hintTop,
                    child: Material(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => widget.onTapLine(_error!.line),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            'Corrige el error de la línea ${_error!.line} para actualizar el diagrama.',
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: _toolbar(scheme, sheet, compact: compact),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset? _pendingDoubleTap;

  /// DFD's object bar: the cursor, then one button per object.
  Widget _palette(ColorScheme scheme) {
    Widget tool(BlockKind? kind) {
      final selected = _tool == kind;
      return Tooltip(
        message: kind == null ? 'Seleccionar y editar bloques' : '${kind.label}: ${kind.description}',
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _tool = selected ? null : kind),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    height: 16,
                    child: kind == null
                        ? Icon(Icons.near_me_outlined, size: 16, color: scheme.onSurface)
                        : CustomPaint(painter: ShapeIconPainter(kind.shape, scheme, selected: selected)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kind?.label ?? 'Cursor',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 1,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: _paletteWidth,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tool(null),
              const Divider(height: 8),
              for (final kind in BlockKind.values.where((k) => k.inDfd)) tool(kind),
              const Divider(height: 8),
              for (final kind in BlockKind.values.where((k) => !k.inDfd)) tool(kind),
            ],
          ),
        ),
      ),
    );
  }

  /// The palette as one scrollable row, for phones.
  Widget _paletteStrip(ColorScheme scheme) {
    Widget tool(BlockKind? kind) {
      final selected = _tool == kind;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
          avatar: SizedBox(
            width: 22,
            height: 14,
            child: kind == null
                ? Icon(Icons.near_me_outlined, size: 14, color: scheme.onSurface)
                : CustomPaint(painter: ShapeIconPainter(kind.shape, scheme, selected: selected)),
          ),
          label: Text(kind?.label ?? 'Cursor', style: const TextStyle(fontSize: 12)),
          selected: selected,
          onSelected: (_) => setState(() => _tool = selected ? null : kind),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          children: [
            tool(null),
            for (final kind in BlockKind.values.where((k) => k.inDfd)) tool(kind),
            for (final kind in BlockKind.values.where((k) => !k.inDfd)) tool(kind),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(ColorScheme scheme, DiagramSheet? sheet, {bool compact = false}) {
    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.onNotationChanged != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SegmentedButton<Notation>(
                segments: const [
                  ButtonSegment(
                    value: Notation.pseint,
                    label: Text('PSeInt'),
                    tooltip: 'x <- a + 1, "texto", Y, O, <>',
                  ),
                  ButtonSegment(value: Notation.dfd, label: Text('DFD'), tooltip: "x ← a + 1, 'texto', AND, OR, !="),
                ],
                selected: {widget.notation},
                showSelectedIcon: false,
                onSelectionChanged: (s) => widget.onNotationChanged!(s.single),
                style: SegmentedButton.styleFrom(
                  visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          if (widget.onUndo != null)
            IconButton(tooltip: 'Deshacer', icon: const Icon(Icons.undo), onPressed: widget.onUndo),
          // On a touch screen the diagram zooms with two fingers.
          if (!compact) ...[
            IconButton(tooltip: 'Alejar', icon: const Icon(Icons.zoom_out), onPressed: () => _zoom(0.8)),
            IconButton(tooltip: 'Acercar', icon: const Icon(Icons.zoom_in), onPressed: () => _zoom(1.25)),
          ],
          IconButton(tooltip: 'Ver todo', icon: const Icon(Icons.fit_screen_outlined), onPressed: _fit),
          IconButton(
            tooltip: 'Guardar como imagen',
            icon: const Icon(Icons.image_outlined),
            onPressed: sheet == null ? null : _exportPng,
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The font may have loaded after the first layout.
    final width = diagramCharWidth();
    if (width != _charWidth) {
      _charWidth = width;
      _parse();
    }
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 18, color: scheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(text, style: TextStyle(color: scheme.onSecondaryContainer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
