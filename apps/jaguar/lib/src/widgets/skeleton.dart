import 'package:flutter/material.dart';

/// Placeholders with the shape of what is loading, instead of a spinner: the
/// page does not jump when the data arrives, and it is clear what is coming.
///
/// Wrap a group of [SkeletonBox] in one [SkeletonScope]; they shine together.
/// With animations off in the system they stay still.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({super.key, required this.child, this.label = 'Cargando'});

  final Widget child;

  /// What a screen reader says while it loads.
  final String label;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _running = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _running) {
      _controller.stop();
      _running = false;
    } else if (!still && !_running) {
      _controller.repeat();
      _running = true;
    }
    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: _Shine(animation: _controller, child: widget.child),
      ),
    );
  }
}

class _Shine extends InheritedNotifier<Animation<double>> {
  const _Shine({required Animation<double> animation, required super.child}) : super(notifier: animation);

  static double of(BuildContext context) {
    final shine = context.dependOnInheritedWidgetOfExactType<_Shine>();
    return shine?.notifier?.value ?? 0.5;
  }
}

/// A grey block that shines. [width] null takes all the width there is.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8, this.circle = false});

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = Color.alphaBlend(scheme.onSurface.withValues(alpha: 0.07), base);
    final t = _Shine.of(context) * 1.4 - 0.2;
    double stop(double v) => v.clamp(0.0, 1.0);
    return Container(
      width: circle ? height : width,
      height: height,
      decoration: BoxDecoration(
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        gradient: LinearGradient(colors: [base, highlight, base], stops: [stop(t - 0.25), stop(t), stop(t + 0.25)]),
      ),
    );
  }
}

/// A card for a class: a header with its name and the code, and some tasks.
class SkeletonClassCard extends StatelessWidget {
  const SkeletonClassCard({super.key, this.tasks = 2});

  final int tasks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SkeletonBox(height: 44, width: 44, radius: 12),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 170, height: 16),
                      SizedBox(height: 8),
                      SkeletonBox(width: 90, height: 12),
                    ],
                  ),
                ),
                SkeletonBox(width: 64, height: 24, radius: 12),
              ],
            ),
          ),
          for (var i = 0; i < tasks; i++) const SkeletonTaskRow(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// A row of a list: a marker, a title and a line of detail.
class SkeletonTaskRow extends StatelessWidget {
  const SkeletonTaskRow({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        SkeletonBox(height: 22, circle: true),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SkeletonBox(width: 150, height: 14), SizedBox(height: 8), SkeletonBox(width: 110, height: 11)],
          ),
        ),
      ],
    ),
  );
}

/// The list of classes while it loads.
class SkeletonClassList extends StatelessWidget {
  const SkeletonClassList({super.key, this.cards = 2});

  final int cards;

  @override
  Widget build(BuildContext context) => SkeletonScope(
    label: 'Cargando tus clases',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (var i = 0; i < cards; i++) SkeletonClassCard(tasks: i == 0 ? 2 : 1)],
    ),
  );
}

/// What the teacher's class looks like while it loads: the side panel and the
/// table.
class SkeletonClassBoard extends StatelessWidget {
  const SkeletonClassBoard({super.key, this.wide = true});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget table() => Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(flex: 2, child: SkeletonBox(width: 80, height: 14)),
              SizedBox(width: 16),
              Expanded(flex: 2, child: SkeletonBox(height: 14)),
              SizedBox(width: 16),
              Expanded(flex: 2, child: SkeletonBox(height: 14)),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 7; i++)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  SkeletonBox(height: 32, circle: true),
                  SizedBox(width: 12),
                  Expanded(flex: 2, child: SkeletonBox(width: 120, height: 14)),
                  SizedBox(width: 16),
                  Expanded(flex: 2, child: SkeletonBox(width: 70, height: 24, radius: 12)),
                  SizedBox(width: 16),
                  Expanded(flex: 2, child: SkeletonBox(width: 70, height: 24, radius: 12)),
                ],
              ),
            ),
        ],
      ),
    );
    Widget panel() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 110, height: 12),
              SizedBox(height: 12),
              SkeletonBox(height: 44, radius: 12),
              SizedBox(height: 14),
              SkeletonBox(width: 200, height: 12),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: SkeletonBox(height: 74, radius: 14)),
            SizedBox(width: 10),
            Expanded(child: SkeletonBox(height: 74, radius: 14)),
          ],
        ),
        const SizedBox(height: 10),
        const SkeletonBox(height: 74, radius: 14),
        const SizedBox(height: 14),
        const SkeletonBox(height: 42, radius: 21),
      ],
    );
    return SkeletonScope(
      label: 'Cargando la clase',
      child: wide
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 308, child: panel()),
                  const SizedBox(width: 16),
                  Expanded(child: table()),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              children: [panel(), const SizedBox(height: 16), table()],
            ),
    );
  }
}

/// Rows of text for anything else that loads: a list, a feed.
class SkeletonRows extends StatelessWidget {
  const SkeletonRows({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) =>
      SkeletonScope(child: Column(children: [for (var i = 0; i < count; i++) const SkeletonTaskRow()]));
}
