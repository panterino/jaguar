import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../theme.dart';

/// One of the three balloons of the first challenge: where to write, how to
/// run and where the tests are. It never blocks a touch (only the balloon
/// itself is tappable) and points at a widget through its [target] key.
class TourBalloon extends StatefulWidget {
  const TourBalloon({
    super.key,
    required this.target,
    required this.text,
    required this.arrow,
    required this.onSkip,
    this.onGotIt,
  });

  /// The widget the arrow points to.
  final GlobalKey target;
  final String text;

  /// Which side of the balloon holds the arrow: up when the target is above
  /// it, down when it is below.
  final TourArrow arrow;
  final VoidCallback onSkip;

  /// Shown as "Entendido" only on the first balloon.
  final VoidCallback? onGotIt;

  @override
  State<TourBalloon> createState() => _TourBalloonState();
}

enum TourArrow { up, down }

class _TourBalloonState extends State<TourBalloon> {
  Rect? _rect;

  void _measure() {
    final target = widget.target.currentContext?.findRenderObject();
    final own = context.findRenderObject();
    if (target is! RenderBox || own is! RenderBox || !target.attached || !own.attached) return;
    final topLeft = own.globalToLocal(target.localToGlobal(Offset.zero));
    final rect = topLeft & target.size;
    if (rect != _rect) setState(() => _rect = rect);
  }

  @override
  void initState() {
    super.initState();
    SemanticsService.announce(widget.text, TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });
    final rect = _rect;
    if (rect == null) return const SizedBox.shrink();
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 32).clamp(0.0, 320.0);
    final scheme = Theme.of(context).colorScheme;
    final left = (rect.center.dx - width / 2).clamp(8.0, size.width - width - 8);
    final arrowX = (rect.center.dx - left).clamp(24.0, width - 24);
    final down = widget.arrow == TourArrow.down;
    final balloon = SizedBox(
      width: width,
      child: Semantics(
        liveRegion: true,
        label: widget.text,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!down) _Arrow(x: arrowX, color: scheme.inverseSurface, up: true),
            Material(
              color: scheme.inverseSurface,
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 4, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.text, style: TextStyle(color: scheme.onInverseSurface, fontSize: 15)),
                            if (widget.onGotIt case final gotIt?)
                              TextButton(
                                onPressed: gotIt,
                                style: TextButton.styleFrom(
                                  foregroundColor: scheme.inversePrimary,
                                  minimumSize: const Size(48, 48),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text('Entendido'),
                              ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Saltar guía',
                      icon: Icon(Icons.close, size: 18, color: scheme.onInverseSurface),
                      onPressed: widget.onSkip,
                    ),
                  ],
                ),
              ),
            ),
            if (down) _Arrow(x: arrowX, color: scheme.inverseSurface, up: false),
          ],
        ),
      ),
    );
    final pop = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion(context, const Duration(milliseconds: 250)),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: balloon,
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (down)
          Positioned(left: left, bottom: size.height - rect.top + 2, child: pop)
        else
          Positioned(left: left, top: rect.bottom + 2, child: pop),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.x, required this.color, required this.up});

  final double x;
  final Color color;
  final bool up;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 8,
    width: double.infinity,
    child: CustomPaint(painter: _ArrowPainter(x, color, up)),
  );
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.x, this.color, this.up);

  final double x;
  final Color color;
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(x - 8, size.height)
        ..lineTo(x, 0)
        ..lineTo(x + 8, size.height);
    } else {
      path
        ..moveTo(x - 8, 0)
        ..lineTo(x, size.height)
        ..lineTo(x + 8, 0);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.x != x || old.color != color || old.up != up;
}
