import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Pieces for the teacher's side, so classes, tables and lists share one look:
/// who someone is, how a number compares, what state something is in, and the
/// class code in one readable line.

const _avatarTones = [
  Color(0xFF0B6BAF),
  Color(0xFF2E7D32),
  Color(0xFF7A4B00),
  Color(0xFF6A3FB5),
  Color(0xFFC2410C),
  Color(0xFF00796B),
];

/// The initials of [name] in a circle whose color depends on the name, so the
/// same student always looks the same.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 32});

  final String name;
  final double size;

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final first = words.first[0];
    final second = words.length > 1 ? words[1][0] : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;
    final tone = _avatarTones[name.codeUnits.fold<int>(0, (a, b) => a + b) % _avatarTones.length];
    final foreground = dark ? Color.lerp(tone, Colors.white, 0.5)! : tone;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.alphaBlend(tone.withValues(alpha: dark ? 0.28 : 0.16), surface),
        ),
        child: Text(
          _initials,
          style: TextStyle(color: foreground, fontSize: size * 0.38, fontWeight: FontWeight.w700, height: 1),
        ),
      ),
    );
  }
}

enum PillTone { good, warn, bad, info, neutral }

(Color background, Color foreground) pillColors(BuildContext context, PillTone tone) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  final base = switch (tone) {
    PillTone.good => const Color(0xFF2E7D32),
    PillTone.warn => const Color(0xFFB45309),
    PillTone.bad => scheme.error,
    PillTone.info => scheme.secondary,
    PillTone.neutral => scheme.onSurfaceVariant,
  };
  final foreground = dark ? Color.lerp(base, Colors.white, 0.45)! : base;
  return (Color.alphaBlend(base.withValues(alpha: dark ? 0.26 : 0.13), scheme.surface), foreground);
}

/// A short state ("4 de 4", "En camino") with its color and icon.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, this.icon, this.tone = PillTone.neutral});

  final String label;
  final IconData? icon;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = pillColors(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 15, color: foreground), const SizedBox(width: 5)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700, height: 1.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// A figure with what it measures, and optionally how far along it is.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.icon, required this.value, required this.label, this.progress});

  final IconData icon;
  final String value;
  final String label;

  /// 0 to 1: a bar under the figure.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.05),
            ),
            if (progress case final value?) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The class code on one line, big enough to read from the back of the room,
/// with a button that copies it.
class CodeBadge extends StatelessWidget {
  const CodeBadge({super.key, required this.code, this.large = true});

  final String code;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SelectableText(
                code,
                maxLines: 1,
                style: monoStyle.copyWith(
                  fontSize: large ? 26 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copiar código',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Código copiado')));
            },
          ),
        ],
      ),
    );
  }
}

/// A small heading over a block, with room for an action on the right.
class BlockHeading extends StatelessWidget {
  const BlockHeading(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                text.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A message with its icon, inside a dialog or a panel: what happened, or what
/// to look at.
class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key, required this.text, this.tone = PillTone.info, this.icon});

  final String text;
  final PillTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = pillColors(context, tone);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: foreground.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon ??
                  switch (tone) {
                    PillTone.good => Icons.check_circle_outline,
                    PillTone.warn => Icons.info_outline,
                    PillTone.bad => Icons.error_outline,
                    _ => Icons.info_outline,
                  },
              size: 20,
              color: foreground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface)),
            ),
          ],
        ),
      ),
    );
  }
}
