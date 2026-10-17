import 'dart:math' as math;

import 'ast.dart';
import 'editing.dart';
import 'format.dart';

/// The symbol a block is drawn with. A style (classic, DFD) decides how
/// each one looks; the layout only needs their sizes.
enum BlockShape {
  /// Inicio / Fin.
  terminal,

  /// Assignment, Definir, Dimension, Esperar, Borrar Pantalla.
  process,

  /// Leer.
  input,

  /// Escribir.
  output,

  /// Si, Mientras, Repetir and Según.
  decision,

  /// Para and Para Cada.
  loop,

  /// Calling a SubProceso.
  call,
}

final class FlowRect {
  const FlowRect(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get centerX => left + width / 2;
  double get centerY => top + height / 2;

  bool contains(double x, double y) => x >= left && x <= right && y >= top && y <= bottom;

  FlowRect shift(double dx, double dy) => FlowRect(left + dx, top + dy, width, height);
}

final class FlowBlock {
  const FlowBlock(this.rect, this.shape, this.text, this.line, {this.stmt});

  final FlowRect rect;
  final BlockShape shape;
  final String text;

  /// The source line of the statement, 1-based. Inicio and Fin point at the
  /// Algoritmo and FinAlgoritmo lines (0 if unknown).
  final int line;

  /// The statement drawn, to edit or delete it; null for Inicio and Fin.
  final Stmt? stmt;

  FlowBlock shift(double dx, double dy) => FlowBlock(rect.shift(dx, dy), shape, text, line, stmt: stmt);
}

/// A ＋ on an arrow: tapping it adds a statement there.
final class FlowInsert {
  const FlowInsert(this.x, this.y, this.point);

  final double x;
  final double y;
  final InsertPoint point;
}

/// A connector; the last segment ends in an arrow when [arrow] is true.
final class FlowLine {
  const FlowLine(this.points, {this.arrow = true});

  /// x, y pairs.
  final List<(double, double)> points;
  final bool arrow;
}

/// A small text next to a line: Sí / No, or a case of Según.
final class FlowLabel {
  const FlowLabel(this.x, this.y, this.text);

  final double x;
  final double y;
  final String text;
}

/// A laid out flowchart of one Algoritmo, SubProceso or Funcion.
final class Flowchart {
  const Flowchart({
    required this.title,
    required this.width,
    required this.height,
    required this.blocks,
    required this.lines,
    required this.labels,
    this.inserts = const [],
  });

  final String title;
  final double width;
  final double height;
  final List<FlowBlock> blocks;
  final List<FlowLine> lines;
  final List<FlowLabel> labels;
  final List<FlowInsert> inserts;

  /// The ＋ at a point, if any.
  FlowInsert? insertAt(double x, double y, {double radius = 12}) {
    for (final insert in inserts) {
      if ((insert.x - x).abs() <= radius && (insert.y - y).abs() <= radius) return insert;
    }
    return null;
  }

  /// The innermost block at a point, for taps.
  FlowBlock? blockAt(double x, double y) {
    for (final block in blocks.reversed) {
      if (block.rect.contains(x, y)) return block;
    }
    return null;
  }

  FlowBlock? blockForLine(int line) {
    for (final block in blocks) {
      if (block.line == line) return block;
    }
    return null;
  }
}

/// Sizes used by the layout. Text is measured as monospaced: [charWidth]
/// per character, which is exact for the editor's font.
final class FlowMetrics {
  const FlowMetrics({
    this.charWidth = 7.8,
    this.blockHeight = 40,
    this.paddingX = 16,
    this.minBlockWidth = 90,
    this.gap = 28,
    this.branchGap = 36,
    this.loopMargin = 22,
    this.margin = 24,
  });

  final double charWidth;
  final double blockHeight;
  final double paddingX;
  final double minBlockWidth;

  /// Vertical space between consecutive blocks.
  final double gap;

  /// Horizontal space between the branches of a decision.
  final double branchGap;

  /// Room at the side of a loop for the line that goes back up.
  final double loopMargin;

  /// Empty space around the whole chart.
  final double margin;
}

/// One chart per Algoritmo, SubProceso and Funcion, main first.
List<Flowchart> flowchartsFor(
  Program program, {
  FlowMetrics metrics = const FlowMetrics(),
  Notation notation = Notation.pseint,
}) => [
  _chartFor(program.main, metrics, notation, program.spans),
  for (final function in program.functions.values) _chartFor(function, metrics, notation, program.spans),
];

Flowchart _chartFor(Subprogram sub, FlowMetrics m, Notation notation, SourceSpans? spans) {
  final title = sub.isMain
      ? 'Algoritmo ${sub.name}'
      : [
          if (sub.returnVar != null) 'Funcion ${sub.returnVar} <- ' else 'SubProceso ',
          '${sub.name}(${sub.params.map((p) => p.name).join(', ')})',
        ].join();
  final layout = _Layout(m, notation, spans);
  final start = layout.block(BlockShape.terminal, sub.isMain ? 'Inicio' : sub.name, sub.line);
  final piece = layout.sequence([
    start,
    layout.statements(sub.body, sub.line),
    layout.block(BlockShape.terminal, 'Fin', spans?.subprogramEnd(sub) ?? 0),
  ]);
  final placed = piece.shift(m.margin, m.margin);
  return Flowchart(
    title: title,
    width: piece.width + 2 * m.margin,
    height: piece.height + 2 * m.margin,
    blocks: placed.blocks,
    lines: placed.lines,
    labels: placed.labels,
    inserts: placed.inserts,
  );
}

/// A laid out part of a chart, in its own coordinates. It is entered at
/// the top and left at the bottom, both at x = [axis].
final class _Piece {
  _Piece(
    this.width,
    this.height,
    this.axis, {
    List<FlowBlock>? blocks,
    List<FlowLine>? lines,
    List<FlowLabel>? labels,
    List<FlowInsert>? inserts,
  }) : blocks = blocks ?? [],
       lines = lines ?? [],
       labels = labels ?? [],
       inserts = inserts ?? [];

  final double width;
  final double height;
  final double axis;
  final List<FlowBlock> blocks;
  final List<FlowLine> lines;
  final List<FlowLabel> labels;
  final List<FlowInsert> inserts;

  _Piece shift(double dx, double dy) => _Piece(
    width,
    height,
    axis,
    blocks: [for (final b in blocks) b.shift(dx, dy)],
    inserts: [for (final i in inserts) FlowInsert(i.x + dx, i.y + dy, i.point)],
    lines: [
      for (final l in lines) FlowLine([for (final (x, y) in l.points) (x + dx, y + dy)], arrow: l.arrow),
    ],
    labels: [for (final l in labels) FlowLabel(l.x + dx, l.y + dy, l.text)],
  );

  /// Adds [other]'s items placed at ([dx], [dy]).
  void add(_Piece other, double dx, double dy) {
    final moved = other.shift(dx, dy);
    blocks.addAll(moved.blocks);
    lines.addAll(moved.lines);
    labels.addAll(moved.labels);
    inserts.addAll(moved.inserts);
  }
}

class _Layout {
  _Layout(this.m, this.notation, this.spans);

  final FlowMetrics m;
  final Notation notation;
  final SourceSpans? spans;

  String _e(Expr expr) => formatExpr(expr, notation: notation);

  String _forText(String variable, Expr from, Expr to, Expr? step) => notation == Notation.dfd
      // DFD's Para object: contador ← inicial, final, incremento.
      ? '$variable ← ${_e(from)}, ${_e(to)}, ${step == null ? '1' : _e(step)}'
      : '$variable <- ${_e(from)} Hasta ${_e(to)}${step == null ? '' : ' Con Paso ${_e(step)}'}';

  double _textWidth(String text) => text.length * m.charWidth;

  _Piece block(BlockShape shape, String text, int line, [Stmt? stmt]) {
    // Slanted and pointed shapes need extra room for their sides.
    final extra = switch (shape) {
      BlockShape.input || BlockShape.output => 2 * m.blockHeight * 0.35,
      BlockShape.loop => m.blockHeight * 0.8,
      BlockShape.call => 16,
      _ => 0.0,
    };
    final width = math.max(m.minBlockWidth, _textWidth(text) + 2 * m.paddingX + extra);
    return _Piece(
      width,
      m.blockHeight,
      width / 2,
      blocks: [FlowBlock(FlowRect(0, 0, width, m.blockHeight), shape, text, line, stmt: stmt)],
    );
  }

  /// A body of statements, with a ＋ before, between and after them.
  /// [headerLine] opens the body (see [InsertPoint.headerLine]).
  _Piece statements(List<Stmt> body, int headerLine, {IfStmt? addElseTo}) {
    final pieces = [for (final s in body) statement(s)];
    final piece = sequence(pieces);
    InsertPoint at(int index) => InsertPoint(body, index, headerLine: headerLine, addElseTo: addElseTo);
    if (body.isEmpty) {
      piece.inserts.add(FlowInsert(piece.axis, 0, at(0)));
      return piece;
    }
    piece.inserts.add(FlowInsert(piece.axis, -10, at(0)));
    var y = 0.0;
    for (var i = 0; i < pieces.length; i++) {
      if (i > 0) {
        piece.inserts.add(FlowInsert(piece.axis, y + m.gap / 2, at(i)));
        y += m.gap;
      }
      y += pieces[i].height;
    }
    piece.inserts.add(FlowInsert(piece.axis, piece.height + 10, at(body.length)));
    return piece;
  }

  _Piece statement(Stmt stmt) => switch (stmt) {
    IfStmt() => _if(stmt),
    SwitchStmt() => _switch(stmt),
    WhileStmt(:final condition, :final body) => _pretestLoop(
      BlockShape.decision,
      _e(condition),
      stmt.line,
      statements(body, stmt.line),
      stmt: stmt,
      enterLabel: 'Sí',
      exitLabel: 'No',
    ),
    ForStmt(:final variable, :final from, :final to, :final step, :final body) => _pretestLoop(
      BlockShape.loop,
      _forText(variable, from, to, step),
      stmt.line,
      statements(body, stmt.line),
      stmt: stmt,
    ),
    ForEachStmt(:final variable, :final arrayName, :final body) => _pretestLoop(
      BlockShape.loop,
      'Para Cada $variable de $arrayName',
      stmt.line,
      statements(body, stmt.line),
      stmt: stmt,
    ),
    RepeatStmt() => _repeat(stmt),
    ReadStmt() => block(BlockShape.input, formatSimpleStmt(stmt, notation: notation), stmt.line, stmt),
    WriteStmt() => block(BlockShape.output, formatSimpleStmt(stmt, notation: notation), stmt.line, stmt),
    CallStmt() => block(BlockShape.call, formatSimpleStmt(stmt, notation: notation), stmt.line, stmt),
    _ => block(BlockShape.process, formatSimpleStmt(stmt, notation: notation), stmt.line, stmt),
  };

  /// Pieces one under the other, joined by arrows, on a common axis.
  _Piece sequence(List<_Piece> pieces) {
    if (pieces.isEmpty) return _Piece(m.minBlockWidth / 2, 0, m.minBlockWidth / 4);
    final left = pieces.map((p) => p.axis).reduce(math.max);
    final right = pieces.map((p) => p.width - p.axis).reduce(math.max);
    var y = 0.0;
    final result = _Piece(left + right, 0, left);
    for (var i = 0; i < pieces.length; i++) {
      final piece = pieces[i];
      if (i > 0) {
        result.lines.add(FlowLine([(left, y), (left, y + m.gap)]));
        y += m.gap;
      }
      result.add(piece, left - piece.axis, y);
      y += piece.height;
    }
    return _Piece(
      left + right,
      y,
      left,
      blocks: result.blocks,
      lines: result.lines,
      labels: result.labels,
      inserts: result.inserts,
    );
  }

  /// A decision: Sí to the right, No to the left, joined below.
  _Piece _if(IfStmt stmt) {
    final diamond = _diamond(_e(stmt.condition), stmt.line, stmt);
    final yes = statements(stmt.thenBody, stmt.line);
    final elseLine = spans?.elseLine(stmt);
    // Without SiNo, the No side is a new, empty body: adding to it writes
    // the SiNo too.
    final no = elseLine != null
        ? statements(stmt.elseBody ?? const [], elseLine)
        : statements(stmt.elseBody ?? <Stmt>[], stmt.line, addElseTo: stmt);
    return _branches(diamond, [(label: 'No', piece: no), (label: 'Sí', piece: yes)], sideExits: true);
  }

  _Piece _switch(SwitchStmt stmt) {
    final diamond = _diamond(_e(stmt.subject), stmt.line, stmt);
    return _branches(diamond, [
      for (final c in stmt.cases)
        (label: c.values.map(_e).join(', '), piece: statements(c.body, spans?.caseLine(c) ?? stmt.line)),
      if (stmt.otherwise != null)
        (label: 'De Otro Modo', piece: statements(stmt.otherwise!, spans?.otherwiseLine(stmt) ?? stmt.line)),
    ], sideExits: false);
  }

  _Piece _diamond(String text, int line, [Stmt? stmt]) {
    final width = math.max(m.minBlockWidth * 1.3, _textWidth(text) * 1.35 + 2 * m.paddingX + 24);
    final height = m.blockHeight * 1.4;
    return _Piece(
      width,
      height,
      width / 2,
      blocks: [FlowBlock(FlowRect(0, 0, width, height), BlockShape.decision, text, line, stmt: stmt)],
    );
  }

  /// [branches] side by side under [head], joined again below. With
  /// [sideExits] (two branches of a Si) the lines leave from the diamond's
  /// left and right corners; otherwise from its bottom, as in Según.
  _Piece _branches(_Piece head, List<({String label, _Piece piece})> branches, {required bool sideExits}) {
    final half = head.width / 2;
    // Branch axes, relative to the head's center.
    final axes = <double>[];
    if (sideExits && branches.length == 2) {
      final left = branches[0].piece;
      final right = branches[1].piece;
      axes
        ..add(math.min(-half, -m.branchGap / 2 - (left.width - left.axis)))
        ..add(math.max(half, m.branchGap / 2 + right.axis));
    } else {
      final total = branches.fold(0.0, (sum, b) => sum + b.piece.width) + m.branchGap * (branches.length - 1);
      var x = -total / 2;
      for (final b in branches) {
        axes.add(x + b.piece.axis);
        x += b.piece.width + m.branchGap;
      }
    }
    var leftExtent = half;
    var rightExtent = half;
    for (var i = 0; i < branches.length; i++) {
      final piece = branches[i].piece;
      leftExtent = math.max(leftExtent, -(axes[i] - piece.axis));
      rightExtent = math.max(rightExtent, axes[i] + piece.width - piece.axis);
    }
    final center = leftExtent;
    final result = _Piece(leftExtent + rightExtent, 0, center);
    result.add(head, center - half, 0);

    final top = head.height + (sideExits ? m.gap * 0.6 : m.gap * 1.2);
    final busY = head.height + m.gap * 0.5;
    var deepest = 0.0;
    for (var i = 0; i < branches.length; i++) {
      final (:label, :piece) = branches[i];
      final x = center + axes[i];
      if (sideExits) {
        final cornerX = i == 0 ? center - half : center + half;
        result.lines.add(FlowLine([(cornerX, head.height / 2), (x, head.height / 2), (x, top)]));
        result.labels.add(FlowLabel(i == 0 ? cornerX - 22 : cornerX + 6, head.height / 2 - 16, label));
      } else {
        result.lines.add(FlowLine([(center, head.height), (center, busY), (x, busY), (x, top)]));
        result.labels.add(FlowLabel(x + 4, busY + 2, label));
      }
      result.add(piece, x - piece.axis, top);
      deepest = math.max(deepest, piece.height);
    }
    final joinY = top + deepest + m.gap * 0.6;
    for (var i = 0; i < branches.length; i++) {
      final x = center + axes[i];
      result.lines.add(FlowLine([(x, top + branches[i].piece.height), (x, joinY), (center, joinY)], arrow: false));
    }
    return _Piece(
      result.width,
      joinY,
      center,
      blocks: result.blocks,
      lines: result.lines,
      labels: result.labels,
      inserts: result.inserts,
    );
  }

  /// Mientras and Para: the condition first, the body under it, a line back
  /// up on the left and the exit on the right.
  _Piece _pretestLoop(
    BlockShape shape,
    String text,
    int line,
    _Piece body, {
    required Stmt stmt,
    String? enterLabel,
    String? exitLabel,
  }) {
    final head = shape == BlockShape.decision ? _diamond(text, line, stmt) : block(shape, text, line, stmt);
    final half = head.width / 2;
    final leftExtent = math.max(half, body.axis) + m.loopMargin;
    final rightExtent = math.max(half, body.width - body.axis) + m.loopMargin;
    final center = leftExtent;
    final top = m.gap * 0.5; // room for the line coming back
    final result = _Piece(leftExtent + rightExtent, 0, center);
    result.lines.add(FlowLine([(center, 0), (center, top)]));
    result.add(head, center - half, top);
    final bodyTop = top + head.height + m.gap;
    result.lines.add(FlowLine([(center, top + head.height), (center, bodyTop)]));
    result.add(body, center - body.axis, bodyTop);
    final bodyBottom = bodyTop + body.height;
    final backY = bodyBottom + m.gap * 0.5;
    final backX = center - leftExtent + 4;
    result.lines.add(
      FlowLine([(center, bodyBottom), (center, backY), (backX, backY), (backX, top / 2), (center, top / 2)]),
    );
    final exitX = center + rightExtent - 4;
    final exitY = top + head.height / 2;
    final endY = backY + m.gap * 0.6;
    result.lines.add(FlowLine([(center + half, exitY), (exitX, exitY), (exitX, endY), (center, endY)], arrow: false));
    if (enterLabel != null) result.labels.add(FlowLabel(center + 6, top + head.height + 2, enterLabel));
    if (exitLabel != null) result.labels.add(FlowLabel(center + half + 6, exitY - 16, exitLabel));
    return _Piece(
      result.width,
      endY,
      center,
      blocks: result.blocks,
      lines: result.lines,
      labels: result.labels,
      inserts: result.inserts,
    );
  }

  /// Repetir: the body first, the condition under it and a line back up.
  _Piece _repeat(RepeatStmt stmt) {
    final body = statements(stmt.body, stmt.line);
    // The diamond is the Hasta Que line, where the condition is written.
    final head = _diamond(_e(stmt.condition), stmt.condition.line, stmt);
    final half = head.width / 2;
    final leftExtent = math.max(half, body.axis) + m.loopMargin;
    final rightExtent = math.max(half, body.width - body.axis);
    final center = leftExtent;
    final top = m.gap * 0.5;
    final result = _Piece(leftExtent + rightExtent, 0, center);
    result.lines.add(FlowLine([(center, 0), (center, top)]));
    result.add(body, center - body.axis, top);
    final headTop = top + body.height + m.gap;
    result.lines.add(FlowLine([(center, top + body.height), (center, headTop)]));
    result.add(head, center - half, headTop);
    final backX = center - leftExtent + 4;
    final cornerY = headTop + head.height / 2;
    result.lines.add(FlowLine([(center - half, cornerY), (backX, cornerY), (backX, top / 2), (center, top / 2)]));
    // Hasta Que leaves when the condition is true; Mientras Que, when false.
    final (stay, leave) = stmt.untilTrue ? ('No', 'Sí') : ('Sí', 'No');
    result.labels
      ..add(FlowLabel(center - half - 24, cornerY - 16, stay))
      ..add(FlowLabel(center + 6, headTop + head.height + 2, leave));
    final endY = headTop + head.height + m.gap * 0.6;
    result.lines.add(FlowLine([(center, headTop + head.height), (center, endY)], arrow: false));
    return _Piece(
      result.width,
      endY,
      center,
      blocks: result.blocks,
      lines: result.lines,
      labels: result.labels,
      inserts: result.inserts,
    );
  }
}
