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
    this.onPlan,
    this.onHints,
    this.challenge = false,
  });

  final Exercise exercise;
  final bool checking;
  final VoidCallback onCheck;

  /// Desktop: the toolbar has the button next to Ejecutar.
  final bool showCheckButton;

  /// Opens the planteamiento: think the problem before the code.
  final VoidCallback? onPlan;

  /// Challenges have hints.
  final VoidCallback? onHints;

  /// A reto: its tests were written by us, not by a teacher.
  final bool challenge;

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

    final title = Text(
      exercise.title,
      style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
    // On a phone the buttons leave no room: the title goes on its own line.
    final narrow = MediaQuery.sizeOf(context).width < 480;
    // While typing on a phone the code needs the room: only the title and buttons.
    final typing = narrow && MediaQuery.viewInsetsOf(context).bottom > 0;

    return Material(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (narrow)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 8),
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(child: title),
                  ],
                ),
              ),
            Row(
              children: [
                if (!narrow) ...[
                  Icon(Icons.assignment_outlined, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(child: title),
                ] else
                  const Spacer(),
                if (exercise.statement.isNotEmpty)
                  IconButton(
                    tooltip: _expanded ? 'Ocultar enunciado' : 'Ver enunciado',
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                    color: scheme.onPrimaryContainer,
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                if (widget.onHints case final onHints?)
                  IconButton(
                    tooltip: 'Pistas',
                    icon: const Icon(Icons.lightbulb_outline),
                    color: scheme.onPrimaryContainer,
                    onPressed: onHints,
                  ),
                if (widget.onPlan case final onPlan?)
                  IconButton(
                    tooltip: 'Planteamiento: entrada, proceso y salida',
                    icon: const Icon(Icons.edit_note),
                    color: scheme.onPrimaryContainer,
                    onPressed: onPlan,
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
            if (_expanded && !typing && exercise.statement.isNotEmpty)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 4, right: 8, bottom: 4),
                  child: SelectableText(exercise.statement, style: TextStyle(color: scheme.onPrimaryContainer)),
                ),
              ),
            if (!typing)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  [
                    '${exercise.cases.length} ${exercise.cases.length == 1 ? 'prueba' : 'pruebas'}'
                        '${widget.challenge ? '' : ' del profesor'}',
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
