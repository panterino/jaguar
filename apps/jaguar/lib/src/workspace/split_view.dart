import 'package:flutter/material.dart';

/// Two panes with a divider the user can drag. [fraction] is the share of
/// the first pane; [onChanged] reports it while dragging.
class SplitView extends StatelessWidget {
  const SplitView({
    super.key,
    required this.axis,
    required this.first,
    required this.second,
    required this.fraction,
    required this.onChanged,
    this.minFirst = 160,
    this.minSecond = 160,
    this.onReset,
  });

  final Axis axis;
  final Widget first;
  final Widget second;
  final double fraction;
  final ValueChanged<double> onChanged;
  final double minFirst;
  final double minSecond;

  /// Double-clicking the divider.
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = axis == Axis.horizontal;
        final total = horizontal ? constraints.maxWidth : constraints.maxHeight;
        final firstSize = _clamp(total * fraction, total);
        final children = [
          SizedBox(width: horizontal ? firstSize : null, height: horizontal ? null : firstSize, child: first),
          _Divider(
            axis: axis,
            onDrag: (delta) => onChanged(_clamp(firstSize + delta, total) / total),
            onReset: onReset,
          ),
          Expanded(child: second),
        ];
        return horizontal ? Row(children: children) : Column(children: children);
      },
    );
  }

  double _clamp(double size, double total) {
    final max = total - minSecond - _Divider.thickness;
    if (max < minFirst) return total / 2;
    return size.clamp(minFirst, max);
  }
}

class _Divider extends StatefulWidget {
  const _Divider({required this.axis, required this.onDrag, this.onReset});

  static const thickness = 7.0;

  final Axis axis;
  final ValueChanged<double> onDrag;
  final VoidCallback? onReset;

  @override
  State<_Divider> createState() => _DividerState();
}

class _DividerState extends State<_Divider> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final horizontal = widget.axis == Axis.horizontal;
    // A thin line inside a wider handle that is easy to grab.
    return SizedBox(
      width: horizontal ? _Divider.thickness : null,
      height: horizontal ? null : _Divider.thickness,
      child: ColoredBox(
        color: scheme.surfaceContainerLow,
        child: MouseRegion(
          cursor: horizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _active = true),
          onExit: (_) => setState(() => _active = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: widget.onReset,
            onHorizontalDragUpdate: horizontal ? (d) => widget.onDrag(d.delta.dx) : null,
            onVerticalDragUpdate: horizontal ? null : (d) => widget.onDrag(d.delta.dy),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: horizontal ? (_active ? 3 : 1) : double.infinity,
                height: horizontal ? double.infinity : (_active ? 3 : 1),
                color: _active ? scheme.primary : scheme.outlineVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
