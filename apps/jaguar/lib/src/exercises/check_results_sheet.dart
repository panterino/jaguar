import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

/// Shows which test cases passed. When all pass, [onShowTeacher] opens the
/// verified screen.
Future<void> showCheckResults(
  BuildContext context, {
  required CheckResult result,
  required VoidCallback onShowTeacher,
  ValueChanged<int>? onGoToLine,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _ResultsList(
        result: result,
        scrollController: scrollController,
        onShowTeacher: () {
          Navigator.pop(context);
          onShowTeacher();
        },
        onGoToLine: onGoToLine == null
            ? null
            : (line) {
                Navigator.pop(context);
                onGoToLine(line);
              },
      ),
    ),
  );
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.result,
    required this.scrollController,
    required this.onShowTeacher,
    required this.onGoToLine,
  });

  final CheckResult result;
  final ScrollController scrollController;
  final VoidCallback onShowTeacher;
  final ValueChanged<int>? onGoToLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final syntaxError = result.syntaxError;
    final total = result.cases.length;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            Icon(
              result.passed ? Icons.verified : Icons.pending_actions,
              color: result.passed ? Colors.green.shade600 : scheme.error,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                syntaxError != null
                    ? 'Tu programa tiene un error de sintaxis'
                    : result.passed
                    ? '¡Todos los casos son correctos!'
                    : '${result.passedCount} de $total casos correctos',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (result.passed)
          FilledButton.icon(
            onPressed: onShowTeacher,
            icon: const Icon(Icons.school_outlined),
            label: const Text('Mostrar al profesor'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        if (syntaxError != null) _ErrorBox(error: syntaxError, onGoToLine: onGoToLine),
        for (var i = 0; i < total; i++) _CaseTile(index: i + 1, result: result.cases[i], onGoToLine: onGoToLine),
      ],
    );
  }
}

class _CaseTile extends StatelessWidget {
  const _CaseTile({required this.index, required this.result, required this.onGoToLine});

  final int index;
  final CaseResult result;
  final ValueChanged<int>? onGoToLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final testCase = result.testCase;
    final passed = result.passed;

    final title = Text('Caso $index${testCase.hidden ? ' (oculto)' : ''}');
    final icon = Icon(passed ? Icons.check_circle : Icons.cancel, color: passed ? Colors.green.shade600 : scheme.error);

    if (passed) return ListTile(contentPadding: EdgeInsets.zero, leading: icon, title: title);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: icon,
      title: title,
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.only(left: 40, bottom: 12),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: testCase.hidden
          ? [
              Text(
                'Los datos de este caso son secretos. Prueba tu programa con otros valores, '
                'por ejemplo cero, negativos o números grandes.',
                style: theme.textTheme.bodyMedium,
              ),
              if (result.error != null) ...[
                const SizedBox(height: 8),
                _ErrorBox(error: result.error!, onGoToLine: onGoToLine),
              ],
            ]
          : [
              _Labeled(
                label: 'Datos de entrada',
                text: testCase.inputs.isEmpty ? '(ninguno)' : testCase.inputs.join('\n'),
              ),
              _Labeled(label: 'Se esperaba que mostrara', text: testCase.expected),
              _Labeled(label: 'Tu programa mostró', text: result.output.isEmpty ? '(nada)' : result.output.trimRight()),
              if (result.error != null) _ErrorBox(error: result.error!, onGoToLine: onGoToLine),
            ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(text, style: monoStyle.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error, required this.onGoToLine});

  final JaguarError error;
  final ValueChanged<int>? onGoToLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${error.title} en la línea ${error.line}: ${error.message}',
            style: TextStyle(color: scheme.onErrorContainer),
          ),
          if (error.hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Sugerencia: ${error.hint}', style: TextStyle(color: scheme.onErrorContainer)),
            ),
          if (onGoToLine != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () => onGoToLine!(error.line), child: Text('Ir a la línea ${error.line}')),
            ),
        ],
      ),
    );
  }
}
