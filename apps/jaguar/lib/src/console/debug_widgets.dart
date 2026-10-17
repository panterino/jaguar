import 'package:flutter/material.dart';

import '../theme.dart';
import 'console_session.dart';

/// The step-by-step controls: next step, play by itself, run to the end.
class DebugBar extends StatelessWidget {
  const DebugBar({super.key, required this.session, this.onRunToCursor});

  final ConsoleSession session;

  /// Ejecutar hasta aquí: up to the line of the cursor.
  final VoidCallback? onRunToCursor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final paused = session.state == RunState.paused;
    final line = session.currentLine;
    return Material(
      color: jaguarYellow.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.directions_walk, size: 18, color: scheme.onSurface),
            Text(line == null ? 'Paso a paso' : 'Paso a paso · línea $line', style: theme.textTheme.labelLarge),
            const SizedBox(width: 4),
            FilledButton.tonalIcon(
              onPressed: paused ? session.nextStep : null,
              icon: const Icon(Icons.skip_next, size: 18),
              label: const Text('Siguiente paso'),
              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            Tooltip(
              message: session.autoPlay ? 'Pausar' : 'Avanzar solo, un paso tras otro',
              child: IconButton.filledTonal(
                onPressed: session.isRunning ? session.togglePlay : null,
                icon: Icon(session.autoPlay ? Icons.pause : Icons.play_arrow, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (onRunToCursor != null)
              Tooltip(
                message: 'Ejecutar hasta la línea del cursor (F4)',
                child: IconButton(
                  onPressed: paused ? onRunToCursor : null,
                  icon: const Icon(Icons.vertical_align_bottom, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            Tooltip(
              message: 'Ejecutar el resto sin pausas',
              child: IconButton(
                onPressed: session.isRunning ? session.continueToEnd : null,
                icon: const Icon(Icons.fast_forward, size: 18),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The variables of the program and their values, the ones that just
/// changed marked.
class VariablesTable extends StatelessWidget {
  const VariablesTable({super.key, required this.variables, this.onEvaluate});

  final List<DebugVariable> variables;

  /// DFD's Evaluar: shown while the program is paused.
  final Future<String> Function(String expression)? onEvaluate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mono = monoStyle.copyWith(fontSize: 13, color: scheme.onSurface);
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'VARIABLES',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: variables.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Aún no hay variables. Aparecen cuando el programa les da un valor.',
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      for (final variable in variables)
                        Container(
                          color: variable.changed ? jaguarYellow.withValues(alpha: 0.25) : null,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  variable.name,
                                  style: mono.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(child: SelectableText(variable.value, style: mono)),
                              if (variable.changed)
                                Tooltip(
                                  message: 'Cambió en este paso',
                                  child: Icon(Icons.fiber_manual_record, size: 10, color: scheme.primary),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          if (onEvaluate != null) _Evaluator(onEvaluate: onEvaluate!),
        ],
      ),
    );
  }
}

/// Type an expression, see its value right now: `x * 2`, `n MOD 2 = 0`.
class _Evaluator extends StatefulWidget {
  const _Evaluator({required this.onEvaluate});

  final Future<String> Function(String expression) onEvaluate;

  @override
  State<_Evaluator> createState() => _EvaluatorState();
}

class _EvaluatorState extends State<_Evaluator> {
  final _field = TextEditingController();
  String? _result;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _evaluate() async {
    final text = _field.text.trim();
    if (text.isEmpty) return;
    final result = await widget.onEvaluate(text);
    if (mounted) setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mono = monoStyle.copyWith(fontSize: 13, letterSpacing: 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _field,
              style: mono,
              autocorrect: false,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Evaluar',
                hintText: 'x * 2',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _evaluate(),
            ),
          ),
          const SizedBox(width: 8),
          if (_result != null)
            Flexible(
              child: SelectableText(
                '= $_result',
                style: mono.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
          IconButton(tooltip: 'Evaluar (Enter)', icon: const Icon(Icons.calculate_outlined), onPressed: _evaluate),
        ],
      ),
    );
  }
}
