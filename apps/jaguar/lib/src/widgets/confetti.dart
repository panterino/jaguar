import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A burst of confetti from a point, drawn over what is behind it. Pass a new
/// [trigger] number to play it again. With animations off in the system it
/// stays out of the way.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.trigger, this.origin = const Alignment(0, 0.2)});

  /// Play whenever this changes (and is above zero).
  final int trigger;

  /// Where the burst starts, in the widget's own area.
  final Alignment origin;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  final _random = math.Random();
  List<_Piece> _pieces = const [];

  static const _colors = [
    Color(0xFFF4B723),
    Color(0xFF00A8F0),
    Color(0xFF7BC043),
    Color(0xFFFF8AB8),
    Color(0xFFFFFFFF),
  ];

  @override
  void didUpdateWidget(Confetti old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger && widget.trigger > 0 && !MediaQuery.disableAnimationsOf(context)) {
      _pieces = List.generate(44, (i) {
        final angle = _random.nextDouble() * math.pi * 2;
        final force = 120 + _random.nextDouble() * 260;
        return _Piece(
          dx: math.cos(angle) * force,
          dy: math.sin(angle) * force - 120,
          spin: (_random.nextDouble() - 0.5) * 14,
          color: _colors[i % _colors.length],
          size: 7 + _random.nextDouble() * 6,
        );
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_pieces, _controller.value, widget.origin)),
      ),
    ),
  );
}

class _Piece {
  const _Piece({required this.dx, required this.dy, required this.spin, required this.color, required this.size});

  final double dx;
  final double dy;
  final double spin;
  final Color color;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t, this.origin);

  final List<_Piece> pieces;
  final double t;
  final Alignment origin;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final start = origin.alongSize(size);
    // Out fast, then gravity pulls it down; it fades at the end.
    final out = Curves.easeOutCubic.transform(t);
    final fall = t * t * 320;
    for (final p in pieces) {
      final paint = Paint()..color = p.color.withValues(alpha: (1 - t * t).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(start.dx + p.dx * out, start.dy + p.dy * out + fall);
      canvas.rotate(p.spin * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.4),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
