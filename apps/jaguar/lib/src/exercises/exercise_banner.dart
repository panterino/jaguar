import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// The exercise the student is solving, shown above the editor.
class ExerciseBanner extends StatefulWidget {
  const ExerciseBanner({
    super.key,
    required this.exercise,
    required this.checking,
    required this.onCheck,
    this.showCheckButton = true,
  });

  final Exercise exercise;
  final bool checking;
  final VoidCallback onCheck;

  /// Desktop: the toolbar has the button next to Ejecutar.
  final bool showCheckButton;

  @override
  State<ExerciseBanner> createState() => _ExerciseBannerState();
}

class _ExerciseBannerState extends State<ExerciseBanner> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exercise = widget.exercise;
    final visibleCases = exercise.cases.where((c) => !c.hidden).length;
    final hiddenCases = exercise.cases.length - visibleCases;

    return Material(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_outlined, color: scheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.title,
                    style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (exercise.statement.isNotEmpty)
                  IconButton(
                    tooltip: _expanded ? 'Ocultar enunciado' : 'Ver enunciado',
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    color: scheme.onPrimaryContainer,
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                const SizedBox(width: 4),
                if (widget.showCheckButton)
                  FilledButton.icon(
                    onPressed: widget.checking ? null : widget.onCheck,
                    icon: widget.checking
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.fact_check_outlined),
                    label: const Text('Probar'),
                  ),
              ],
            ),
            if (_expanded && exercise.statement.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 4, right: 8, bottom: 4),
                  child: SelectableText(exercise.statement, style: TextStyle(color: scheme.onPrimaryContainer)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                [
                  '${exercise.cases.length} ${exercise.cases.length == 1 ? 'prueba' : 'pruebas'} del profesor',
                  if (hiddenCases > 0) '$hiddenCases ${hiddenCases == 1 ? 'oculta' : 'ocultas'}',
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimaryContainer.withValues(alpha: 0.75)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
