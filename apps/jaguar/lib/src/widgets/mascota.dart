import 'package:flutter/material.dart';

/// The moods of the mascot. The art is one drawing; each mood repaints the
/// eyes and the mouth over it, in the same flat style, and adds a small prop.
enum MascotPose {
  /// The drawing as it is.
  normal,

  /// Eyes closed with joy, rosy cheeks and a star.
  feliz,

  /// An open smile and stars on both sides: something went very well.
  celebra,

  /// Wide eyes, a small round mouth: something unexpected.
  sorpresa,

  /// Looking up and to the side, a question mark.
  pensando,

  /// Slanted brows, a frown and a drop: it did not work, yet.
  triste,

  /// One eye closed and a heart: a friendly nudge.
  guino,

  /// Eyes closed, a tiny smile and a Z: nothing to do here yet.
  dormido,
}

/// The mascot in one of its [MascotPose]s. Decorative: screen readers skip it.
class Mascota extends StatelessWidget {
  const Mascota({super.key, this.pose = MascotPose.normal, required this.size});

  final MascotPose pose;

  /// Width and height: the drawing is square.
  final double size;

  static const asset = 'assets/images/mascota.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, width: size, height: size, fit: BoxFit.contain, excludeFromSemantics: true);
    if (pose == MascotPose.normal) return ExcludeSemantics(child: image);
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            image,
            Positioned.fill(child: CustomPaint(painter: _FacePainter(pose))),
            ..._props(size),
          ],
        ),
      ),
    );
  }

  Widget _z(double fontSize) => Text(
    'Z',
    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: const Color(0xFF0B6BAF), height: 1),
  );

  /// The small things around the head, placed in fractions of the drawing.
  List<Widget> _props(double size) {
    Widget prop(IconData icon, Color color, {required double right, required double top, double scale = 0.2}) =>
        Positioned(
          right: size * right,
          top: size * top,
          child: Icon(icon, size: size * scale, color: color),
        );
    const gold = Color(0xFFF4B723);
    return switch (pose) {
      MascotPose.feliz => [prop(Icons.star_rounded, gold, right: -0.04, top: 0.0, scale: 0.18)],
      MascotPose.celebra => [
        prop(Icons.star_rounded, gold, right: -0.06, top: -0.02, scale: 0.2),
        prop(Icons.star_rounded, gold, right: 0.86, top: 0.04, scale: 0.15),
        prop(Icons.star_rounded, gold, right: 0.02, top: 0.2, scale: 0.12),
      ],
      MascotPose.sorpresa => [prop(Icons.priority_high_rounded, const Color(0xFFE5574C), right: -0.04, top: -0.04)],
      MascotPose.pensando => [prop(Icons.question_mark_rounded, const Color(0xFF0B6BAF), right: -0.04, top: -0.04)],
      MascotPose.triste => [
        prop(Icons.water_drop_rounded, const Color(0xFF6CC4FF), right: 0.02, top: 0.2, scale: 0.14),
      ],
      MascotPose.guino => [prop(Icons.favorite_rounded, const Color(0xFFFF6F91), right: -0.02, top: 0.02, scale: 0.16)],
      MascotPose.dormido => [
        Positioned(right: size * -0.02, top: size * 0.0, child: _z(size * 0.2)),
        Positioned(right: size * 0.1, top: size * -0.1, child: _z(size * 0.13)),
      ],
      MascotPose.normal => const [],
    };
  }
}

/// Draws a mood over the 512 x 512 drawing: the eyes and the mouth are
/// covered with the color under them and drawn again.
class _FacePainter extends CustomPainter {
  const _FacePainter(this.pose);

  final MascotPose pose;

  static const _fur = Color(0xFFFFC936);
  static const _ink = Color(0xFF4A3A2A);
  static const _iris = Color(0xFF00B2F9);
  static const _brow = Color(0xFFB8741A);
  static const _left = Offset(149, 235);
  static const _right = Offset(362, 235);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 512);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 11
      ..color = _ink;

    switch (pose) {
      case MascotPose.feliz:
      case MascotPose.celebra:
        _happyEye(canvas, stroke, _left);
        _happyEye(canvas, stroke, _right);
        _blush(canvas);
      case MascotPose.sorpresa:
        _openEye(canvas, _left, iris: 27, sclera: 58);
        _openEye(canvas, _right, iris: 27, sclera: 58);
      case MascotPose.pensando:
        _openEye(canvas, _left, gaze: const Offset(15, -14));
        _openEye(canvas, _right, gaze: const Offset(15, -14));
        _brows(
          canvas,
          left: const [Offset(96, 160), Offset(150, 152)],
          right: const [Offset(362, 146), Offset(416, 156)],
        );
      case MascotPose.triste:
        _openEye(canvas, _left, gaze: const Offset(0, 10), iris: 34);
        _openEye(canvas, _right, gaze: const Offset(0, 10), iris: 34);
        _brows(
          canvas,
          left: const [Offset(94, 172), Offset(150, 150)],
          right: const [Offset(362, 150), Offset(418, 172)],
        );
      case MascotPose.guino:
        _openEye(canvas, _left);
        _happyEye(canvas, stroke, _right);
        _blush(canvas);
      case MascotPose.dormido:
        _sleepEye(canvas, stroke, _left);
        _sleepEye(canvas, stroke, _right);
      case MascotPose.normal:
        return;
    }

    // The muzzle is white: cover the old smile and draw the new mouth.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(255, 305), width: 104, height: 56),
        const Radius.circular(24),
      ),
      Paint()..color = Colors.white,
    );
    switch (pose) {
      case MascotPose.feliz:
      case MascotPose.guino:
        canvas.drawPath(
          Path()
            ..moveTo(228, 298)
            ..cubicTo(238, 322, 272, 322, 282, 298),
          stroke,
        );
      case MascotPose.celebra:
        final mouth = Path()
          ..moveTo(224, 292)
          ..cubicTo(228, 338, 282, 338, 286, 292)
          ..close();
        canvas.drawPath(mouth, Paint()..color = const Color(0xFF5A3A2A));
        canvas.save();
        canvas.clipPath(mouth);
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(255, 330), width: 40, height: 22),
          Paint()..color = const Color(0xFFFF8FA3),
        );
        canvas.restore();
      case MascotPose.sorpresa:
        canvas.drawOval(
          Rect.fromCenter(center: const Offset(255, 308), width: 26, height: 34),
          Paint()..color = const Color(0xFF5A3A2A),
        );
      case MascotPose.pensando:
        canvas.drawPath(
          Path()
            ..moveTo(236, 306)
            ..quadraticBezierTo(256, 316, 276, 298),
          stroke,
        );
      case MascotPose.triste:
        canvas.drawPath(
          Path()
            ..moveTo(228, 318)
            ..cubicTo(238, 296, 272, 296, 282, 318),
          stroke,
        );
      case MascotPose.dormido:
        canvas.drawPath(
          Path()
            ..moveTo(240, 300)
            ..cubicTo(246, 312, 264, 312, 270, 300),
          stroke..strokeWidth = 9,
        );
      case MascotPose.normal:
        break;
    }
  }

  void _openEye(Canvas canvas, Offset c, {Offset gaze = Offset.zero, double iris = 37, double sclera = 55}) {
    canvas.drawCircle(c, sclera, Paint()..color = Colors.white);
    final center = c + gaze;
    canvas.drawCircle(center, iris, Paint()..color = _iris);
    canvas.drawCircle(center + Offset(iris * 0.46, -iris * 0.5), iris * 0.27, Paint()..color = Colors.white);
    canvas.drawCircle(center + Offset(-iris * 0.36, iris * 0.44), iris * 0.12, Paint()..color = Colors.white);
  }

  void _happyEye(Canvas canvas, Paint stroke, Offset c) {
    canvas.drawCircle(c, 63, Paint()..color = _fur);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 34, c.dy + 12)
        ..quadraticBezierTo(c.dx, c.dy - 38, c.dx + 34, c.dy + 12),
      stroke,
    );
  }

  void _sleepEye(Canvas canvas, Paint stroke, Offset c) {
    canvas.drawCircle(c, 63, Paint()..color = _fur);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 34, c.dy - 6)
        ..quadraticBezierTo(c.dx, c.dy + 34, c.dx + 34, c.dy - 6),
      stroke,
    );
  }

  void _blush(Canvas canvas) {
    final paint = Paint()..color = const Color(0x66FF6F6F);
    canvas.drawOval(Rect.fromCenter(center: const Offset(112, 306), width: 48, height: 28), paint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(398, 306), width: 48, height: 28), paint);
  }

  void _brows(Canvas canvas, {required List<Offset> left, required List<Offset> right}) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10
      ..color = _brow;
    canvas.drawLine(left[0], left[1], paint);
    canvas.drawLine(right[0], right[1], paint);
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.pose != pose;
}
