import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

/// The objects of the palette.
enum BlockKind {
  asignacion('Asignación', BlockShape.process, 'Guarda un valor en una variable'),
  lectura('Lectura', BlockShape.input, 'Pide datos al usuario (Leer)'),
  salida('Salida', BlockShape.output, 'Muestra textos y valores (Escribir)'),
  decision('Decisión', BlockShape.decision, 'Hace una cosa u otra según una condición (Si)'),
  mientras('Ciclo Mientras', BlockShape.decision, 'Repite mientras se cumpla una condición'),
  para('Ciclo Para', BlockShape.loop, 'Repite contando de un valor a otro'),
  repetir('Repetir', BlockShape.decision, 'Repite hasta que se cumpla una condición'),
  segun('Según', BlockShape.decision, 'Elige entre varias opciones'),
  llamada('Llamada', BlockShape.call, 'Ejecuta un SubProceso');

  const BlockKind(this.label, this.shape, this.description);

  final String label;
  final BlockShape shape;
  final String description;

  /// The basic objects of a flowchart; Repetir and Según are extra.
  bool get inDfd => this != repetir && this != segun;
}

/// One field of a block's dialog.
class BlockField {
  BlockField(this.label, {String initial = '', this.hint, this.help, this.examples = const []})
    : controller = TextEditingController(text: initial);

  final String label;
  final String? hint;
  final String? help;

  /// Whole answers to try: tapping one fills the field.
  final List<String> examples;
  final TextEditingController controller;

  String get value => controller.text.trim();
}

/// The fields of each object, as in DFD, filled from [stmt] when editing.
List<BlockField> fieldsFor(BlockKind kind, {Stmt? stmt, Notation notation = Notation.pseint}) {
  String e(Expr expr) => formatExpr(expr, notation: notation);
  String list(List<Expr> exprs) => exprs.map(e).join(', ');
  final arrow = assignArrow(notation);
  return switch (kind) {
    BlockKind.asignacion => [
      BlockField('Variable', initial: stmt is AssignStmt ? e(stmt.target) : '', hint: 'total'),
      BlockField(
        'Valor',
        initial: stmt is AssignStmt ? e(stmt.value) : '',
        hint: 'precio * cantidad',
        help: 'La variable recibe este valor: variable $arrow valor',
      ),
    ],
    BlockKind.lectura => [
      BlockField(
        'Variables a leer',
        initial: stmt is ReadStmt ? list(stmt.targets) : '',
        hint: 'nombre, edad',
        help: 'Separa varias con comas. El usuario escribe un dato por cada una.',
      ),
    ],
    BlockKind.salida => [
      BlockField(
        'Qué mostrar',
        initial: stmt is WriteStmt ? list(stmt.values) : '',
        hint: '"Hola " + nombre',
        help: 'Escribe textos entre comillas y valores de variables. Únelos con + o con comas.',
        examples: const ['"Hola " + nombre', '"Total: ", total'],
      ),
    ],
    BlockKind.decision => [
      BlockField('Condición', initial: stmt is IfStmt ? e(stmt.condition) : '', hint: 'edad >= 18'),
    ],
    BlockKind.mientras => [
      BlockField('Condición', initial: stmt is WhileStmt ? e(stmt.condition) : '', hint: 'intentos < 3'),
    ],
    BlockKind.para => [
      BlockField('Contador', initial: stmt is ForStmt ? stmt.variable : 'i'),
      BlockField('Valor inicial', initial: stmt is ForStmt ? e(stmt.from) : '1'),
      BlockField('Valor final', initial: stmt is ForStmt ? e(stmt.to) : '', hint: '10'),
      BlockField('Incremento', initial: stmt is ForStmt && stmt.step != null ? e(stmt.step!) : '1'),
    ],
    BlockKind.repetir => [
      BlockField(
        'Repetir hasta que',
        initial: stmt is RepeatStmt ? e(stmt.condition) : '',
        hint: 'respuesta = "no"',
        help: 'El ciclo termina cuando esta condición es verdadera.',
      ),
    ],
    BlockKind.segun => [
      BlockField('Variable o expresión', initial: stmt is SwitchStmt ? e(stmt.subject) : '', hint: 'opcion'),
      if (stmt == null)
        BlockField('Opciones', initial: '1, 2, 3', help: 'Un camino por cada valor, separados por comas.'),
    ],
    BlockKind.llamada => [
      BlockField('SubProceso', initial: stmt is CallStmt ? stmt.call.name : '', hint: 'saludar'),
      BlockField('Argumentos', initial: stmt is CallStmt ? list(stmt.call.args) : '', hint: 'nombre'),
    ],
  };
}

/// The pseudocode for a new block, or for the first line of an edited one.
/// For a Repetir being edited it is the `Hasta Que` line.
String blockText(BlockKind kind, List<BlockField> fields, {required bool isNew}) {
  String f(int i) => fields[i].value;
  return switch (kind) {
    BlockKind.asignacion => '${f(0)} <- ${f(1)}',
    BlockKind.lectura => 'Leer ${f(0)}',
    BlockKind.salida => 'Escribir ${f(0)}',
    BlockKind.decision => isNew ? 'Si ${f(0)} Entonces\nSiNo\nFinSi' : 'Si ${f(0)} Entonces',
    BlockKind.mientras => isNew ? 'Mientras ${f(0)} Hacer\nFinMientras' : 'Mientras ${f(0)} Hacer',
    BlockKind.para => [
      'Para ${f(0)} <- ${f(1)} Hasta ${f(2)}',
      if (f(3).isNotEmpty && f(3) != '1') ' Con Paso ${f(3)}',
      ' Hacer',
      if (isNew) '\nFinPara',
    ].join(),
    BlockKind.repetir => isNew ? 'Repetir\nHasta Que ${f(0)}' : 'Hasta Que ${f(0)}',
    BlockKind.segun =>
      isNew
          ? [
              'Segun ${f(0)} Hacer',
              for (final option in f(1).split(',').map((o) => o.trim()).where((o) => o.isNotEmpty)) '    $option:',
              '    De Otro Modo:',
              'FinSegun',
            ].join('\n')
          : 'Segun ${f(0)} Hacer',
    BlockKind.llamada => f(1).isEmpty ? f(0) : '${f(0)}(${f(1)})',
  };
}

/// The kind of block that draws [stmt].
BlockKind? kindOf(Stmt stmt) => switch (stmt) {
  AssignStmt() => BlockKind.asignacion,
  ReadStmt() => BlockKind.lectura,
  WriteStmt() => BlockKind.salida,
  IfStmt() => BlockKind.decision,
  WhileStmt() => BlockKind.mientras,
  ForStmt() => BlockKind.para,
  RepeatStmt() => BlockKind.repetir,
  SwitchStmt() => BlockKind.segun,
  CallStmt() => BlockKind.llamada,
  _ => null,
};

/// Asks for a block's fields. [onSave] applies the text and returns an
/// error message to show, or null when it worked and the dialog can close.
Future<void> showBlockDialog(
  BuildContext context, {
  required BlockKind kind,
  required List<BlockField> fields,
  required bool isNew,
  required String? Function(String text) onSave,
}) => showDialog<void>(
  context: context,
  builder: (context) => _BlockDialog(kind: kind, fields: fields, isNew: isNew, onSave: onSave),
);

class _BlockDialog extends StatefulWidget {
  const _BlockDialog({required this.kind, required this.fields, required this.isNew, required this.onSave});

  final BlockKind kind;
  final List<BlockField> fields;
  final bool isNew;
  final String? Function(String text) onSave;

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  String? _error;

  void _save() {
    final empty = widget.fields.where((f) => f.value.isEmpty && f.label != 'Argumentos' && f.label != 'Incremento');
    if (empty.isNotEmpty) {
      setState(
        () => _error = widget.kind == BlockKind.salida ? 'Falta lo que quieres mostrar.' : 'Falta llenar: ${empty.first.label}.',
      );
      return;
    }
    final error = widget.onSave(blockText(widget.kind, widget.fields, isNew: widget.isNew));
    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    for (final field in widget.fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Row(
        children: [
          SizedBox(width: 34, height: 22, child: CustomPaint(painter: ShapeIconPainter(widget.kind.shape, scheme))),
          const SizedBox(width: 10),
          Text(widget.kind.label),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.kind.description, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 12),
            for (final (i, field) in widget.fields.indexed) ...[
              TextField(
                controller: field.controller,
                autofocus: i == 0,
                autocorrect: false,
                enableSuggestions: false,
                style: monoStyle.copyWith(letterSpacing: 0),
                decoration: InputDecoration(
                  labelText: field.label,
                  // "Ej.:" and a lighter, italic text, so the example is not
                  // mistaken for something already written.
                  hintText: field.hint == null ? null : 'Ej.: ${field.hint}',
                  hintStyle: monoStyle.copyWith(
                    letterSpacing: 0,
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  helperText: field.help,
                  helperMaxLines: 2,
                ),
                onSubmitted: (_) => _save(),
              ),
              if (field.examples.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final example in field.examples)
                      ActionChip(
                        label: Text(example, style: monoStyle.copyWith(letterSpacing: 0, fontSize: 12)),
                        onPressed: () => field.controller
                          ..text = example
                          ..selection = TextSelection.collapsed(offset: example.length),
                      ),
                  ],
                ),
              const SizedBox(height: 10),
            ],
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: TextStyle(color: scheme.onErrorContainer)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: Text(widget.isNew ? 'Agregar' : 'Guardar')),
      ],
    );
  }
}

/// A small drawing of a block's symbol, for the palette and the dialogs.
class ShapeIconPainter extends CustomPainter {
  ShapeIconPainter(this.shape, this.scheme, {this.selected = false});

  final BlockShape shape;
  final ColorScheme scheme;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(1.5);
    final path = _iconPath(shape, rect);
    canvas
      ..drawPath(path, Paint()..color = selected ? jaguarYellow : scheme.surfaceContainerHighest)
      ..drawPath(
        path,
        Paint()
          ..color = selected ? scheme.onSurface : scheme.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    if (shape == BlockShape.call) {
      final line = Paint()
        ..color = scheme.outline
        ..strokeWidth = 1.2;
      canvas
        ..drawLine(rect.topLeft + const Offset(4, 0), rect.bottomLeft + const Offset(4, 0), line)
        ..drawLine(rect.topRight - const Offset(4, 0), rect.bottomRight - const Offset(4, 0), line);
    }
  }

  Path _iconPath(BlockShape shape, Rect r) {
    switch (shape) {
      case BlockShape.terminal:
        return Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.height / 2)));
      case BlockShape.process || BlockShape.call:
        return Path()..addRect(r);
      case BlockShape.input || BlockShape.output:
        final skew = r.height * 0.4;
        return Path()
          ..moveTo(r.left + skew, r.top)
          ..lineTo(r.right, r.top)
          ..lineTo(r.right - skew, r.bottom)
          ..lineTo(r.left, r.bottom)
          ..close();
      case BlockShape.decision:
        return Path()
          ..moveTo(r.center.dx, r.top)
          ..lineTo(r.right, r.center.dy)
          ..lineTo(r.center.dx, r.bottom)
          ..lineTo(r.left, r.center.dy)
          ..close();
      case BlockShape.loop:
        final side = r.height * 0.45;
        return Path()
          ..moveTo(r.left + side, r.top)
          ..lineTo(r.right - side, r.top)
          ..lineTo(r.right, r.center.dy)
          ..lineTo(r.right - side, r.bottom)
          ..lineTo(r.left + side, r.bottom)
          ..lineTo(r.left, r.center.dy)
          ..close();
    }
  }

  @override
  bool shouldRepaint(ShapeIconPainter old) => old.shape != shape || old.selected != selected || old.scheme != scheme;
}
