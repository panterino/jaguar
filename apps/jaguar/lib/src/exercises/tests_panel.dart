import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../theme.dart';

/// The program's tests, next to the console: "if it gets these inputs, it
/// must show this". Run them all with Probar and see, in words, why one
/// fails.
class TestsPanel extends StatelessWidget {
  const TestsPanel({
    super.key,
    required this.exercise,
    required this.result,
    required this.running,
    required this.stale,
    required this.onRunTests,
    required this.onGoToLine,
    required this.onReplay,
    required this.onShowTeacher,
    this.challenge = false,
    this.onNextChallenge,
    this.onAllChallenges,
  });

  final Exercise exercise;

  /// Null until the student presses Probar.
  final CheckResult? result;
  final bool running;

  /// The code changed after the last run.
  final bool stale;
  final VoidCallback onRunTests;
  final ValueChanged<int> onGoToLine;

  /// Runs a visible test in the console, with its inputs already typed.
  final ValueChanged<TestCase> onReplay;
  final VoidCallback onShowTeacher;

  /// A reto for practicing alone: there is no teacher to show it to.
  final bool challenge;

  /// Opens the next reto; null on the last one.
  final VoidCallback? onNextChallenge;

  /// Opens the list of challenges, after the last one.
  final VoidCallback? onAllChallenges;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    final tests = exercise.cases;
    final syntaxError = result?.syntaxError;

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        _Summary(result: result, total: tests.length, running: running, stale: stale, onRunTests: onRunTests),
        const SizedBox(height: 12),
        if (result != null && result.passed && !stale) ...[
          _AllPassed(
            onShowTeacher: onShowTeacher,
            challenge: challenge,
            onNextChallenge: onNextChallenge,
            onAllChallenges: onAllChallenges,
          ),
          const SizedBox(height: 12),
        ],
        if (syntaxError != null) ...[
          _ErrorBox(
            error: syntaxError,
            intro: 'No se corrió ninguna prueba porque el programa tiene un error.',
            onGoToLine: onGoToLine,
          ),
          const SizedBox(height: 8),
        ],
        for (var i = 0; i < tests.length; i++)
          _TestTile(
            number: i + 1,
            hiddenNumber: tests.take(i + 1).where((t) => t.hidden).length,
            test: tests[i],
            result: result == null || syntaxError != null ? null : result.cases[i],
            stale: stale,
            onGoToLine: onGoToLine,
            onReplay: () => onReplay(tests[i]),
            challenge: challenge,
          ),
        const SizedBox(height: 8),
        Text(
          exercise.mode == MatchMode.flexible
              ? 'Comparación flexible: no importan mayúsculas, acentos, espacios de más ni los mensajes '
                    'que piden datos.'
              : 'Comparación exacta: tu programa debe mostrar exactamente lo mismo.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// "2 de 3 pruebas correctas" with the Probar button.
class _Summary extends StatelessWidget {
  const _Summary({
    required this.result,
    required this.total,
    required this.running,
    required this.stale,
    required this.onRunTests,
  });

  final CheckResult? result;
  final int total;
  final bool running;
  final bool stale;
  final VoidCallback onRunTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final result = this.result;
    final (text, detail) = switch (result) {
      null => (
        '$total ${total == 1 ? 'prueba' : 'pruebas'}',
        'Aún no has probado. Toca Probar para ver si tu programa las pasa.',
      ),
      CheckResult(syntaxError: _?) => ('Tu programa tiene un error', null),
      CheckResult(passed: true) => ('¡Pasa todas las pruebas!', null),
      _ => (
        '${result.passedCount} de $total pruebas correctas',
        result.passedCount > 0 ? 'Casi: revisa la prueba ${result.cases.indexWhere((c) => !c.passed) + 1}.' : null,
      ),
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: stale && result != null ? scheme.onSurfaceVariant : null,
                ),
              ),
              if (stale && result != null)
                Row(
                  children: [
                    Icon(Icons.history, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Desactualizado: cambiaste el código desde la última prueba.',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                )
              else if (detail != null)
                Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: running ? null : onRunTests,
          icon: running
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.fact_check_outlined, size: 18),
          label: Text(result == null ? 'Probar' : 'Probar de nuevo'),
        ),
      ],
    );
  }
}

/// The green card when everything passes: it grows in, the seal pops and a
/// ring spreads out. With animations off in the system it just fades.
class _AllPassed extends StatefulWidget {
  const _AllPassed({
    required this.onShowTeacher,
    required this.challenge,
    required this.onNextChallenge,
    required this.onAllChallenges,
  });

  final VoidCallback onShowTeacher;
  final bool challenge;
  final VoidCallback? onNextChallenge;
  final VoidCallback? onAllChallenges;

  @override
  State<_AllPassed> createState() => _AllPassedState();
}

class _AllPassedState extends State<_AllPassed> {
  String get _message => widget.challenge
      ? (widget.onNextChallenge == null ? '¡Terminaste el nivel 1!' : '¡Reto superado!')
      : '¡Todo correcto! Ya puedes mostrárselo al profesor.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SemanticsService.announce(_message, TextDirection.ltr);
      if (!MediaQuery.disableAnimationsOf(context)) HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final green = brightness == Brightness.dark ? Colors.green.shade300 : Colors.green.shade700;
    final still = MediaQuery.disableAnimationsOf(context);
    final next = widget.onNextChallenge;
    final all = widget.onAllChallenges;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motion(context, const Duration(milliseconds: 350)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Align(alignment: Alignment.topCenter, heightFactor: still ? 1 : t, child: child),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: green.withValues(alpha: 0.12),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Seal(color: green, animate: !still),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _message,
                      style: TextStyle(color: green, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!widget.challenge) ...[
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: widget.onShowTeacher,
                      icon: const Icon(Icons.school_outlined, size: 18),
                      label: const Text('Mostrar al profesor'),
                      style: FilledButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
                    ),
                  ],
                ],
              ),
              if (widget.challenge && next != null) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: next,
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text('Siguiente reto'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: green,
                    foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
                  ),
                ),
              ] else if (widget.challenge && all != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(onPressed: all, child: const Text('Ver todos los retos')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The verified seal: pops from small and a ring spreads out behind it.
class _Seal extends StatelessWidget {
  const _Seal({required this.color, required this.animate});

  final Color color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate) return Icon(Icons.verified, color: color, size: 32);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, t, _) {
        final ring = (t).clamp(0.0, 1.0);
        return SizedBox.square(
          dimension: 32,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: 1 + ring,
                child: Opacity(
                  opacity: (0.35 * (1 - ring)).clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                    child: const SizedBox.square(dimension: 28),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.4 + 0.6 * t,
                child: Icon(Icons.verified, color: color, size: 32),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({
    required this.number,
    required this.hiddenNumber,
    required this.test,
    required this.result,
    required this.stale,
    required this.onGoToLine,
    required this.onReplay,
    required this.challenge,
  });

  final bool challenge;

  /// The code changed after this result: shown in grey, never as a failure.
  final bool stale;
  final int number;
  final int hiddenNumber;
  final TestCase test;
  final CaseResult? result;
  final ValueChanged<int> onGoToLine;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final result = this.result;
    final failed = result != null && !result.passed && !stale;
    final name = test.hidden ? 'Prueba oculta $hiddenNumber' : (test.name.isNotEmpty ? test.name : 'Prueba $number');
    final (icon, color) = switch (result) {
      null => (Icons.radio_button_unchecked, scheme.onSurfaceVariant),
      _ when stale => (
        result.passed ? Icons.check_circle_outline : Icons.cancel_outlined,
        scheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      CaseResult(passed: true) => (Icons.check_circle, Colors.green.shade600),
      _ => (Icons.cancel, scheme.error),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: failed ? scheme.errorContainer.withValues(alpha: 0.35) : scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
                Tooltip(
                  message: challenge
                      ? 'Prueba del reto: no se puede cambiar'
                      : 'Prueba del profesor: no se puede cambiar',
                  child: Icon(Icons.lock_outline, size: 16, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (test.hidden)
              _HiddenDetail(result: result, onGoToLine: onGoToLine)
            else ...[
              _Line(label: 'Si escribes', text: test.inputs.isEmpty ? '(nada)' : test.inputs.join('  ·  ')),
              _Line(label: 'Debe mostrar', text: test.expected.trim().isEmpty ? '(nada)' : test.expected.trim()),
              if (failed) ..._failure(context, result),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _failure(BuildContext context, CaseResult result) {
    final mismatch = result.mismatch;
    final oneLine = test.expected.trim().split('\n').length == 1;
    return [
      const Divider(height: 16),
      switch (result.failure!) {
        // With one expected line, "Debe mostrar" already says what is missing.
        CaseFailure.wrongOutput when mismatch != null && oneLine => _Line(
          label: 'Tu programa mostró',
          text: result.output.trim().isEmpty ? '(nada)' : result.output.trim(),
          highlight: true,
        ),
        CaseFailure.wrongOutput when mismatch != null => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Line(label: 'Faltó esta línea', text: mismatch.expected, highlight: true),
            _Line(label: 'En su lugar mostró', text: mismatch.actual ?? '(ya no mostró nada más)', highlight: true),
          ],
        ),
        CaseFailure.wrongOutput => _Line(label: 'Tu programa mostró', text: result.output.trim()),
        CaseFailure.missingInput => _Explanation(
          'Tu programa usa Leer más veces de las que espera esta prueba '
          '(espera ${test.inputs.length} ${test.inputs.length == 1 ? 'dato' : 'datos'}).',
        ),
        CaseFailure.tooSlow => const _Explanation(
          'Tu programa tardó demasiado. ¿Hay un ciclo Mientras o Repetir que nunca termina?',
        ),
        CaseFailure.error => _ErrorBox(error: result.error!, onGoToLine: onGoToLine),
      },
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: onReplay,
          icon: const Icon(Icons.terminal, size: 18),
          label: const Text('Ver esta prueba en la consola'),
        ),
      ),
    ];
  }
}

/// A hidden test shows whether it passes, never its data.
class _HiddenDetail extends StatelessWidget {
  const _HiddenDetail({required this.result, required this.onGoToLine});

  final CaseResult? result;
  final ValueChanged<int> onGoToLine;

  @override
  Widget build(BuildContext context) {
    final result = this.result;
    if (result == null || result.passed) {
      return const _Explanation('Sus datos son secretos, para que tu programa funcione con cualquier dato.');
    }
    return switch (result.failure!) {
      CaseFailure.missingInput => const _Explanation('Tu programa usa Leer más veces de las que espera esta prueba.'),
      CaseFailure.tooSlow => const _Explanation('Tu programa tardó demasiado. ¿Un ciclo que nunca termina?'),
      CaseFailure.error => _ErrorBox(error: result.error!, onGoToLine: onGoToLine),
      CaseFailure.wrongOutput => const _Explanation(
        'Con estos datos secretos tu programa muestra otra cosa. Pruébalo con otros valores: '
        'cero, negativos, números grandes o iguales.',
      ),
    };
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.text, this.highlight = false});

  final String label;
  final String text;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: SelectableText(
              text,
              style: monoStyle.copyWith(
                fontSize: 13,
                color: highlight ? scheme.error : scheme.onSurface,
                fontWeight: highlight ? FontWeight.w700 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.bodyMedium);
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error, required this.onGoToLine, this.intro});

  final JaguarError error;
  final ValueChanged<int> onGoToLine;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(color: scheme.onErrorContainer);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (intro != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(intro!, style: style),
            ),
          Text('${error.title} en la línea ${error.line}: ${error.message}', style: style),
          if (error.hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Sugerencia: ${error.hint}', style: style),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => onGoToLine(error.line), child: Text('Ir a la línea ${error.line}')),
          ),
        ],
      ),
    );
  }
}
