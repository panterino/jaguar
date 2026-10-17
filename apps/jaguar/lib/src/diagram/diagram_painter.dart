import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

const diagramFontSize = 13.0;
const _titleHeight = 30.0;
const _chartGap = 56.0;

/// Colors for one theme, so a chart can be drawn on screen (any theme) or
/// exported (always light, for printing).
class DiagramColors {
  DiagramColors.of(ColorScheme scheme)
    : background = scheme.surface,
      text = scheme.onSurface,
      line = scheme.onSurfaceVariant,
      label = scheme.onSurfaceVariant,
      highlight = scheme.primary,
      onHighlight = scheme.onPrimary,
      fills = {
        BlockShape.terminal: jaguarYellow.withValues(alpha: 0.45),
        BlockShape.process: scheme.surfaceContainerHighest,
        BlockShape.input: scheme.secondaryContainer,
        // Input and output share a shape: the color tells them apart.
        BlockShape.output: Color.alphaBlend(Colors.green.withValues(alpha: 0.22), scheme.surface),
        BlockShape.decision: scheme.tertiaryContainer,
        BlockShape.loop: scheme.primaryContainer,
        BlockShape.call: scheme.surfaceContainerHighest,
      },
      borders = scheme.outline;

  final Color background;
  final Color text;
  final Color line;
  final Color label;
  final Color highlight;
  final Color onHighlight;
  final Map<BlockShape, Color> fills;
  final Color borders;
}

/// Width of one character of the diagram's monospaced font.
double diagramCharWidth() => (TextPainter(
  text: TextSpan(
    text: 'M',
    style: monoStyle.copyWith(fontSize: diagramFontSize),
  ),
  textDirection: TextDirection.ltr,
)..layout()).width;

/// Several charts (Algoritmo and each SubProceso) side by side, each with
/// its title on top.
class DiagramSheet {
  DiagramSheet(this.charts) {
    var x = 0.0;
    for (final chart in charts) {
      offsets.add(Offset(x, _titleHeight));
      x += chart.width + _chartGap;
    }
    size = Size(charts.isEmpty ? 0 : x - _chartGap, _titleHeight + charts.fold(0.0, (h, c) => math.max(h, c.height)));
  }

  final List<Flowchart> charts;
  final List<Offset> offsets = [];
  late final Size size;

  /// The source line of the block at [position], if any.
  int? lineAt(Offset position) {
    final block = blockAt(position);
    return block != null && block.line > 0 ? block.line : null;
  }

  FlowBlock? blockAt(Offset position) {
    for (var i = 0; i < charts.length; i++) {
      final local = position - offsets[i];
      final block = charts[i].blockAt(local.dx, local.dy);
      if (block != null) return block;
    }
    return null;
  }

  /// The ＋ at [position], if any.
  FlowInsert? insertAt(Offset position) {
    for (var i = 0; i < charts.length; i++) {
      final local = position - offsets[i];
      final insert = charts[i].insertAt(local.dx, local.dy);
      if (insert != null) return insert;
    }
    return null;
  }

  /// The block that draws the statement on [line].
  FlowBlock? blockForLine(int line) {
    for (final chart in charts) {
      final block = chart.blockForLine(line);
      if (block != null) return block;
    }
    return null;
  }

  /// Where the block of [line] is, to bring it into view.
  Rect? rectForLine(int line) {
    for (var i = 0; i < charts.length; i++) {
      final block = charts[i].blockForLine(line);
      if (block != null) {
        final r = block.rect;
        return Rect.fromLTWH(r.left, r.top, r.width, r.height).shift(offsets[i]);
      }
    }
    return null;
  }
}

class DiagramPainter extends CustomPainter {
  DiagramPainter(
    this.sheet,
    this.colors, {
    this.highlightLine,
    this.executingLine,
    this.showInserts = false,
    this.toolSelected = false,
    this.hoveredInsert,
  });

  final DiagramSheet sheet;
  final DiagramColors colors;
  final int? highlightLine;

  /// Step by step: the block about to run.
  final int? executingLine;

  /// Editable diagram: a ＋ on every arrow, brighter while an object of the
  /// palette is chosen.
  final bool showInserts;
  final bool toolSelected;
  final FlowInsert? hoveredInsert;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < sheet.charts.length; i++) {
      final offset = sheet.offsets[i];
      final chart = sheet.charts[i];
      _text(
        canvas,
        chart.title,
        Offset(offset.dx + chart.width / 2, _titleHeight / 2),
        TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w700),
      );
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      _paintChart(canvas, chart);
      canvas.restore();
    }
  }

  void _paintChart(Canvas canvas, Flowchart chart) {
    final linePaint = Paint()
      ..color = colors.line
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (final line in chart.lines) {
      final path = Path()..moveTo(line.points.first.$1, line.points.first.$2);
      for (final (x, y) in line.points.skip(1)) {
        path.lineTo(x, y);
      }
      canvas.drawPath(path, linePaint);
      if (line.arrow && line.points.length >= 2) _arrow(canvas, line.points[line.points.length - 2], line.points.last);
    }
    for (final label in chart.labels) {
      _text(
        canvas,
        label.text,
        Offset(label.x, label.y),
        TextStyle(color: colors.label, fontSize: 11, fontWeight: FontWeight.w600),
        center: false,
      );
    }
    if (showInserts) {
      for (final insert in chart.inserts) {
        _plus(canvas, insert, hovered: identical(insert, hoveredInsert));
      }
    }
    for (final block in chart.blocks) {
      _block(
        canvas,
        block,
        highlighted: block.line > 0 && block.line == highlightLine,
        executing: block.line > 0 && block.line == executingLine,
      );
    }
  }

  void _plus(Canvas canvas, FlowInsert insert, {required bool hovered}) {
    final center = Offset(insert.x, insert.y);
    final strong = toolSelected || hovered;
    final radius = strong ? 9.0 : 7.0;
    canvas
      ..drawCircle(center, radius, Paint()..color = strong ? colors.highlight : colors.background)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = colors.highlight.withValues(alpha: strong ? 1 : 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    final plus = Paint()
      ..color = strong ? colors.onHighlight : colors.highlight
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final arm = radius * 0.5;
    canvas
      ..drawLine(center - Offset(arm, 0), center + Offset(arm, 0), plus)
      ..drawLine(center - Offset(0, arm), center + Offset(0, arm), plus);
  }

  void _arrow(Canvas canvas, (double, double) from, (double, double) to) {
    final angle = math.atan2(to.$2 - from.$2, to.$1 - from.$1);
    const length = 7.0;
    final tip = Offset(to.$1, to.$2);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx - length * math.cos(angle - 0.45), tip.dy - length * math.sin(angle - 0.45))
      ..lineTo(tip.dx - length * math.cos(angle + 0.45), tip.dy - length * math.sin(angle + 0.45))
      ..close();
    canvas.drawPath(path, Paint()..color = colors.line);
  }

  void _block(Canvas canvas, FlowBlock block, {required bool highlighted, required bool executing}) {
    final r = block.rect;
    final rect = Rect.fromLTWH(r.left, r.top, r.width, r.height);
    final path = shapePath(block.shape, rect);
    if (executing) {
      canvas.drawPath(
        path,
        Paint()
          ..color = jaguarYellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
    if (highlighted) {
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.highlight.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    canvas.drawPath(path, Paint()..color = executing ? jaguarYellow : colors.fills[block.shape]!);
    final border = Paint()
      ..color = highlighted ? colors.highlight : colors.borders
      ..style = PaintingStyle.stroke
      ..strokeWidth = highlighted ? 2.4 : 1.2;
    canvas.drawPath(path, border);
    if (block.shape == BlockShape.call) {
      canvas
        ..drawLine(rect.topLeft + const Offset(8, 0), rect.bottomLeft + const Offset(8, 0), border)
        ..drawLine(rect.topRight - const Offset(8, 0), rect.bottomRight - const Offset(8, 0), border);
    }
    _text(canvas, block.text, rect.center, monoStyle.copyWith(fontSize: diagramFontSize, color: colors.text));
  }

  void _text(Canvas canvas, String text, Offset at, TextStyle style, {bool center = true}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final origin = center ? at - Offset(painter.width / 2, painter.height / 2) : at;
    painter.paint(canvas, origin);
  }

  @override
  bool shouldRepaint(DiagramPainter old) =>
      old.sheet != sheet ||
      old.highlightLine != highlightLine ||
      old.executingLine != executingLine ||
      old.showInserts != showInserts ||
      old.toolSelected != toolSelected ||
      old.hoveredInsert != hoveredInsert ||
      old.colors.background != colors.background;
}

/// The outline of each symbol in the classic style.
Path shapePath(BlockShape shape, Rect r) {
  switch (shape) {
    case BlockShape.terminal:
      return Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(r.height / 2)));
    case BlockShape.process || BlockShape.call:
      return Path()..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)));
    case BlockShape.input || BlockShape.output:
      final skew = r.height * 0.35;
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
      final side = r.height * 0.4;
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
