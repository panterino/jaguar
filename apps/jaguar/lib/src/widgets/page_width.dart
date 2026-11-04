import 'package:flutter/material.dart';

/// How wide a screen's content gets on a big monitor. The same few widths
/// everywhere, so moving between screens does not make the content jump.
/// The Taller (the editor) has no limit: it uses the whole window.
///
/// The side bar and the app bars are not part of this: they stay at the
/// window's edge, only what is inside the screen is centered.

/// Rooms and pages of cards and lists: Inicio, Ruta, Clases, Comunidad, Ajustes.
const pageWidth = 960.0;

/// Screens that are mostly text: Acerca de, Privacidad, the guide.
const readingWidth = 760.0;

/// Dense desktop views: the teacher's deliveries table, Mis ejercicios and the
/// exercise editor.
const workWidth = 1440.0;

/// Centers [child] with at most [width] across, keeping the height it is given
/// (so a screen that fills the height still does).
class PageWidth extends StatelessWidget {
  const PageWidth({super.key, this.width = pageWidth, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.maxWidth.isFinite
          ? ((constraints.maxWidth - width) / 2).clamp(0.0, double.infinity)
          : 0.0;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: gutter),
        child: child,
      );
    },
  );
}
