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
    this.side = false,
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

  /// A column next to the code instead of a strip above it: the statement
  /// gets the whole height and the code keeps its own.
  final bool side;

  @override
  State<ExerciseBanner> createState() => _ExerciseBannerState();
}

class _ExerciseBannerState extends State<ExerciseBanner> {
  bool? _expandedChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final exercise = widget.exercise;
    final visibleCases = exercise.cases.where((c) => !c.hidden).length;
    final hiddenCases = exercise.cases.length - visibleCases;

    // On a phone the statement starts folded to two lines: the code gets the room.
    final compact = !widget.side && MediaQuery.sizeOf(context).width < 480;
    final expandedNow = _expandedChoice ?? !compact;
    if (compact) return _compact(context, exercise, visibleCases, hiddenCases, expandedNow);

    final title = Text(
      exercise.title,
      style: theme.textTheme.titleMedium?.copyWith(color: scheme.onPrimaryContainer),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
    // On a phone the buttons leave no room: the title goes on its own line.
    final narrow = widget.side || MediaQuery.sizeOf(context).width < 480;
    // While typing on a phone the code needs the room: only the title and buttons.
    final typing = narrow && MediaQuery.viewInsetsOf(context).bottom > 0;

    final statement = SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, right: 8, bottom: 4),
      child: SelectableText(exercise.statement, style: TextStyle(color: scheme.onPrimaryContainer)),
    );

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
                    tooltip: expandedNow ? 'Ocultar enunciado' : 'Ver enunciado',
                    icon: Icon(expandedNow ? Icons.expand_less : Icons.expand_more),
                    color: scheme.onPrimaryContainer,
                    onPressed: () => setState(() => _expandedChoice = !expandedNow),
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
            if (expandedNow && !typing && exercise.statement.isNotEmpty)
              if (widget.side)
                Expanded(child: statement)
              else
                ConstrainedBox(constraints: const BoxConstraints(maxHeight: 160), child: statement),
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

  /// The phone's banner: the statement (two lines, tap for the rest) and one
  /// row of tools. The title is already in the bar above, so it is not repeated.
  Widget _compact(BuildContext context, Exercise exercise, int visibleCases, int hiddenCases, bool expanded) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.onPrimaryContainer;
    // While typing the code needs the room: only the tools.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    final text = exercise.statement.isEmpty ? exercise.title : exercise.statement;
    // Short: the hidden ones are in the Pruebas tab.
    final cases =
        '${exercise.cases.length} ${exercise.cases.length == 1 ? 'prueba' : 'pruebas'}'
        '${widget.challenge ? '' : ' del profe'}';
    return Material(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!typing)
              InkWell(
                onTap: () => setState(() => _expandedChoice = !expanded),
                child: Semantics(
                  button: true,
                  label: expanded ? 'Ocultar el resto del enunciado' : 'Ver el enunciado completo',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: expanded
                              ? ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 190),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
                                        const SizedBox(height: 6),
                                        Text(
                                          cases,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: color.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Text(
                                  text.replaceAll('\n', ' '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: color),
                                ),
                        ),
                        Icon(expanded ? Icons.expand_less : Icons.expand_more, color: color, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                // Words, not bare icons: they are what a student needs when stuck.
                Expanded(
                  child: Wrap(
                    children: [
                      if (widget.onHints case final onHints?)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: color,
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: onHints,
                          icon: const Icon(Icons.lightbulb_outline, size: 20),
                          label: const Text('Pista'),
                        ),
                      if (widget.onPlan case final onPlan?)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: color,
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onPressed: onPlan,
                          icon: const Icon(Icons.edit_note, size: 22),
                          label: const Text('Planteamiento'),
                        ),
                    ],
                  ),
                ),
                if (widget.showCheckButton)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: widget.checking ? null : widget.onCheck,
                    icon: widget.checking
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text('Probar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
