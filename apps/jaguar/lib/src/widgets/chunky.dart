import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// A button or option tile with weight: a flat face over a darker edge that
/// the face sinks into when pressed. Used where the lessons ask for a tap, so
/// answering feels like pressing something.
class Chunky extends StatefulWidget {
  const Chunky({
    super.key,
    required this.onTap,
    required this.child,
    required this.fill,
    required this.edge,
    this.outline,
    this.radius = 16,
    this.minHeight = 56,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.semanticsLabel,
    this.selected = false,
  });

  /// Null disables it.
  final VoidCallback? onTap;
  final Widget child;
  final Color fill;

  /// The darker edge under the face.
  final Color edge;

  /// A line around the face.
  final Color? outline;
  final double radius;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;
  final bool selected;

  @override
  State<Chunky> createState() => _ChunkyState();
}

class _ChunkyState extends State<Chunky> {
  bool _down = false;
  bool _hover = false;
  bool _focus = false;

  static const _depth = 4.0;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final sink = _down && enabled ? _depth : 0.0;
    final radius = BorderRadius.circular(widget.radius);
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticsLabel,
      excludeSemantics: widget.semanticsLabel != null,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (value) => setState(() => _hover = value),
        onShowFocusHighlight: (value) => setState(() => _focus = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                }
              : null,
          child: AnimatedContainer(
            duration: motion(context, const Duration(milliseconds: 90)),
            margin: EdgeInsets.only(top: sink, bottom: _depth - sink),
            constraints: BoxConstraints(minHeight: widget.minHeight),
            padding: widget.padding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hover && enabled ? Color.lerp(widget.fill, Colors.white, 0.08) : widget.fill,
              borderRadius: radius,
              border: _focus
                  ? Border.all(color: Theme.of(context).colorScheme.secondary, width: 3)
                  : (widget.outline == null ? null : Border.all(color: widget.outline!, width: 2)),
              boxShadow: sink > 0 ? null : [BoxShadow(color: widget.edge, offset: const Offset(0, _depth))],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
