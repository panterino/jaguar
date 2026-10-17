import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../editor/syntax_controller.dart';
import 'block_dialogs.dart';

/// Edits the program from its flowchart: every change rewrites only the
/// lines of that block, so the rest of the code (comments included) stays
/// as it was.
class DiagramEditing {
  DiagramEditing({required this.code, required this.notation});

  final SyntaxController code;
  final Notation notation;

  /// Adds a [kind] block at [point], after asking for its fields.
  Future<void> insert(BuildContext context, Program program, InsertPoint point, BlockKind kind) {
    return showBlockDialog(
      context,
      kind: kind,
      fields: fieldsFor(kind, notation: notation),
      isNew: true,
      onSave: (text) {
        final edit = insertStatement(code.text, program, point, text);
        final added = text.split('\n').length + (point.addElseTo != null ? 1 : 0);
        return _apply(edit, firstLine: edit.line, lineCount: added);
      },
    );
  }

  /// Opens the dialog of [block] to change it.
  Future<void> edit(BuildContext context, Program program, FlowBlock block) async {
    final stmt = block.stmt;
    if (stmt == null) {
      if (block.shape == BlockShape.terminal && block.text == 'Inicio') await _rename(context, program);
      return;
    }
    final kind = kindOf(stmt);
    if (kind == null) {
      // Definir, Dimension, Esperar…: edited as a line of pseudocode.
      final field = BlockField('Instrucción', initial: formatSimpleStmt(stmt));
      await showDialog<void>(
        context: context,
        builder: (context) => _LineDialog(
          field: field,
          onSave: (text) => _apply(replaceStatementHead(code.text, stmt, text), firstLine: stmt.line, lineCount: 1),
        ),
      );
      return;
    }
    await showBlockDialog(
      context,
      kind: kind,
      fields: fieldsFor(kind, stmt: stmt, notation: notation),
      isNew: false,
      onSave: (text) {
        if (stmt is RepeatStmt) {
          final edit = replaceRepeatCondition(code.text, program, stmt, text);
          return _apply(edit, firstLine: edit.line, lineCount: 1);
        }
        return _apply(replaceStatementHead(code.text, stmt, text), firstLine: stmt.line, lineCount: 1);
      },
    );
  }

  /// Removes [block] and everything inside it.
  void delete(Program program, FlowBlock block) {
    final stmt = block.stmt;
    if (stmt == null) return;
    final edit = deleteStatement(code.text, program, stmt);
    _setSource(edit.source, edit.line.clamp(1, '\n'.allMatches(edit.source).length + 1));
  }

  Future<void> _rename(BuildContext context, Program program) async {
    final main = program.main;
    final field = BlockField('Nombre del algoritmo', initial: main.name);
    await showDialog<void>(
      context: context,
      builder: (context) => _LineDialog(
        field: field,
        title: 'Nombre del algoritmo',
        onSave: (name) {
          if (!RegExp(r'^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*$').hasMatch(name)) {
            return 'Usa solo letras, números y _, sin espacios. Por ejemplo: area_del_circulo';
          }
          final header = code.text.split('\n')[main.line - 1];
          final keyword = header.trimLeft().split(RegExp(r'\s+')).first;
          final column = header.length - header.trimLeft().length + 1;
          return _apply(
            replaceLineFrom(code.text, main.line, column, '$keyword $name'),
            firstLine: main.line,
            lineCount: 1,
          );
        },
      ),
    );
  }

  /// Checks the edited program and applies it. Returns the error to show
  /// in the dialog when the new lines are wrong.
  String? _apply(SourceEdit edit, {required int firstLine, required int lineCount}) {
    Program program;
    try {
      program = parse(edit.source);
    } on JaguarError catch (error) {
      if (error.line >= firstLine && error.line < firstLine + lineCount) {
        return [error.message, if (error.hint != null) error.hint!].join(' ');
      }
      // The program already had an error somewhere else: keep the change.
      _setSource(edit.source, edit.line);
      return null;
    }
    _setSource(_canonical(edit.source, program, edit.line), edit.line);
    return null;
  }

  /// Rewrites the edited line in PSeInt notation, so typing `x ← SQRT(y)`
  /// in DFD style leaves `x <- Raiz(y)` in the pseudocode.
  String _canonical(String source, Program program, int line) {
    final stmt = _statementAt(program, line);
    if (stmt == null) return source;
    String e(Expr expr) => formatExpr(expr);
    if (stmt is RepeatStmt) {
      final condition = '${stmt.untilTrue ? 'Hasta Que' : 'Mientras Que'} ${e(stmt.condition)}';
      return replaceRepeatCondition(source, program, stmt, condition).source;
    }
    final head = switch (stmt) {
      IfStmt() => 'Si ${e(stmt.condition)} Entonces',
      WhileStmt() => 'Mientras ${e(stmt.condition)} Hacer',
      ForStmt(:final step) =>
        'Para ${stmt.variable} <- ${e(stmt.from)} Hasta ${e(stmt.to)}${step == null ? '' : ' Con Paso ${e(step)}'} Hacer',
      SwitchStmt() => 'Segun ${e(stmt.subject)} Hacer',
      ForEachStmt() => null,
      _ => formatSimpleStmt(stmt),
    };
    if (head == null) return source;
    return replaceStatementHead(source, stmt, head).source;
  }

  void _setSource(String source, int line) {
    code.value = TextEditingValue(text: source);
    code.selectLine(line);
  }
}

/// The statement that starts on [line], or the Repetir whose condition is
/// on it.
Stmt? _statementAt(Program program, int line) {
  Stmt? found;
  void visit(List<Stmt> body) {
    for (final stmt in body) {
      if (found != null) return;
      if (stmt.line == line || (stmt is RepeatStmt && stmt.condition.line == line)) {
        found = stmt;
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
        case WhileStmt(:final body) || RepeatStmt(:final body) || ForStmt(:final body) || ForEachStmt(:final body):
          visit(body);
        default:
          break;
      }
    }
  }

  visit(program.main.body);
  for (final function in program.functions.values) {
    visit(function.body);
  }
  return found;
}

class _LineDialog extends StatefulWidget {
  const _LineDialog({required this.field, required this.onSave, this.title = 'Instrucción'});

  final BlockField field;
  final String title;
  final String? Function(String text) onSave;

  @override
  State<_LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends State<_LineDialog> {
  String? _error;

  void _save() {
    final error = widget.onSave(widget.field.value);
    if (error == null) {
      Navigator.pop(context);
    } else {
      setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    widget.field.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: widget.field.controller,
          autofocus: true,
          autocorrect: false,
          decoration: InputDecoration(labelText: widget.field.label, errorText: _error, errorMaxLines: 3),
          onSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
