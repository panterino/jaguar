import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../settings.dart';
import '../theme.dart';
import '../widgets/chunky.dart';
import '../widgets/confetti.dart';
import 'lessons.dart';
import '../widgets/mascota.dart';

/// Plays a lesson: one question at a time, an answer you check, and a panel
/// that says why. A wrong question comes back once at the end, so it gets
/// said twice. Finishing marks the lesson done.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson, required this.settings, this.onOpenNext, this.onOpenRoute});

  final Lesson lesson;
  final ViewSettings settings;

  /// Called after the lesson, to open the step that follows it.
  final void Function(RouteStep step)? onOpenNext;

  /// Called to show the whole path, with the step just done marked.
  final VoidCallback? onOpenRoute;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<Question> _queue = [...widget.lesson.questions];
  final _retried = <Question>{};
  int _index = 0;
  int _firstTry = 0;

  // The answer being built.
  int? _choice;
  final _order = <int>[];
  late List<int> _bank = _shuffled(_current);

  bool _checked = false;
  bool _ok = false;
  bool _finished = false;
  int _burst = 0;

  Question get _current => _queue[_index];

  List<int> _shuffled(Question q) {
    if (q is! OrderQuestion) return const [];
    final order = List.generate(q.lines.length, (i) => i);
    // The same shuffle for the same lesson, but never the right order.
    final random = math.Random(q.prompt.hashCode);
    do {
      order.shuffle(random);
    } while (order.length > 1 && _isSorted(order));
    return order;
  }

  bool _isSorted(List<int> order) {
    for (var i = 0; i < order.length; i++) {
      if (order[i] != i) return false;
    }
    return true;
  }

  void _choose(int i) => setState(() => _choice = i);

  /// Puts a line of an ordering question in your program, or takes it back.
  void _toggleLine(int line, {required bool placed}) => setState(() {
    if (placed) {
      _order.remove(line);
      _bank.add(line);
    } else {
      _bank.remove(line);
      _order.add(line);
    }
  });

  bool get _hasAnswer {
    final q = _current;
    return switch (q) {
      OrderQuestion() => _order.length == q.lines.length,
      _ => _choice != null,
    };
  }

  bool _isRight() {
    final q = _current;
    return switch (q) {
      ChoiceQuestion() => _choice == q.answer,
      FigureQuestion() => _choice == q.answer.index,
      OrderQuestion() => _isSorted(_order),
      FindErrorQuestion() => _choice == q.errorLine,
    };
  }

  void _check() {
    final ok = _isRight();
    setState(() {
      _checked = true;
      _ok = ok;
    });
    final q = _current;
    SemanticsService.announce(ok ? '¡Correcto! ${q.right}' : 'Casi. ${q.wrong}', TextDirection.ltr);
    if (!ok && _retried.add(q)) _queue.add(q);
    if (ok && !_retried.contains(q)) _firstTry++;
  }

  void _next() {
    if (_index + 1 >= _queue.length) {
      widget.settings.markLessonDone(widget.lesson.id);
      setState(() {
        _finished = true;
        _burst++;
      });
      return;
    }
    setState(() {
      _index++;
      _choice = null;
      _order.clear();
      _bank = _shuffled(_current);
      _checked = false;
    });
  }

  /// Where this lesson stands in the path, counting from 1.
  int? get _stepNumber {
    final i = mainSteps.indexWhere((s) => s.id == widget.lesson.id);
    return i < 0 ? null : i + 1;
  }

  RouteStep? get _following {
    final steps = routeSteps;
    final i = steps.indexWhere((s) => s.id == widget.lesson.id);
    return i < 0 || i + 1 >= steps.length ? null : steps[i + 1];
  }

  /// Leaving halfway loses the answers so far: ask first.
  Future<void> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la lección?'),
        content: const Text('Perderás tus respuestas de esta vez. La lección no se marca como hecha.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir aquí')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.pop(context);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: _finished || (_index == 0 && !_checked),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: _scaffold(context, scheme),
    );
  }

  Widget _scaffold(BuildContext context, ColorScheme scheme) {
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: motion(context, const Duration(milliseconds: 350)),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(animation),
                  child: child,
                ),
              ),
              child: _finished
                  ? _Result(key: const ValueKey('fin'), screen: this)
                  : _Playing(key: const ValueKey('juego'), screen: this),
            ),
            Positioned.fill(
              child: Confetti(trigger: _burst, origin: const Alignment(0, -0.35)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Playing extends StatelessWidget {
  const _Playing({super.key, required this.screen});

  final _LessonScreenState screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final q = screen._current;
    // The bar fills as soon as an answer is right, not on the next tap.
    final progress = (screen._index + (screen._checked && screen._ok ? 1 : 0)) / screen._queue.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 4),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Salir de la lección',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Semantics(
                  label: 'Progreso de la lección',
                  value: '${screen._index} de ${screen._queue.length}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: motion(context, const Duration(milliseconds: 500)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 14,
                        color: _green(context),
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pregunta ${math.min(screen._index + 1, screen._queue.length)} de ${screen._queue.length}',
                style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: motion(context, const Duration(milliseconds: 300)),
            // The default centers what it shows; a question starts at the top.
            layoutBuilder: (current, previous) =>
                Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: SingleChildScrollView(
              key: ValueKey('${screen._index}-${screen._queue.length}'),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (screen._stepNumber case final n?)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'RUTA · PASO $n DE ${mainSteps.length}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      Semantics(
                        header: true,
                        child: Text(
                          q.prompt,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (q is ChoiceQuestion && q.code != null) _CodeCard(q.code!),
                      if (q is ChoiceQuestion) _Options(screen: screen, question: q),
                      if (q is FigureQuestion) _Figures(screen: screen, question: q),
                      if (q is OrderQuestion) _Ordering(screen: screen, question: q),
                      if (q is FindErrorQuestion) _FindError(screen: screen, question: q),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _Footer(screen: screen),
      ],
    );
  }
}

/// The faces of the buttons keep 4.5:1 against their text: white on the
/// darker greens and reds of the light theme, dark text on the lighter ones
/// of the dark theme.
Color _green(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF7BC043) : const Color(0xFF3F8200);

Color _greenEdge(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFF4F8A24) : const Color(0xFF2D6100);

Color _red(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFF8A80) : const Color(0xFFC73A30);

Color _redEdge(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? const Color(0xFFC9483E) : const Color(0xFF96271F);

/// The text on a green or red face.
Color _onFace(BuildContext context, {required bool green}) => Theme.of(context).brightness == Brightness.dark
    ? (green ? const Color(0xFF17300A) : const Color(0xFF3A0B07))
    : Colors.white;

class _CodeCard extends StatelessWidget {
  const _CodeCard(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Semantics(
        label: 'Programa: $code',
        excludeSemantics: true,
        child: Text(code, style: monoStyle.copyWith(fontSize: 15, height: 1.6, color: scheme.onSurface)),
      ),
    );
  }
}

/// The colors of a tile for what it is now.
({Color fill, Color edge, Color outline, Color text}) _tileColors(
  BuildContext context, {
  required bool selected,
  bool? correct,
}) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  if (correct == true) {
    return (
      fill: dark ? const Color(0xFF1F3A14) : const Color(0xFFDDF6CB),
      edge: dark ? const Color(0xFF5BA02C) : const Color(0xFF7BC043),
      outline: dark ? const Color(0xFF5BA02C) : const Color(0xFF7BC043),
      text: dark ? const Color(0xFFB9F09A) : const Color(0xFF245A0E),
    );
  }
  if (correct == false) {
    return (
      fill: dark ? const Color(0xFF44201D) : const Color(0xFFFFE0DD),
      edge: dark ? const Color(0xFFC9483E) : const Color(0xFFE5574C),
      outline: dark ? const Color(0xFFC9483E) : const Color(0xFFE5574C),
      text: dark ? const Color(0xFFFFB4AC) : const Color(0xFF8E1F17),
    );
  }
  if (selected) {
    return (
      fill: scheme.primaryContainer,
      edge: scheme.primary,
      outline: scheme.primary,
      text: scheme.onPrimaryContainer,
    );
  }
  return (fill: scheme.surface, edge: scheme.outlineVariant, outline: scheme.outlineVariant, text: scheme.onSurface);
}

class _Options extends StatelessWidget {
  const _Options({required this.screen, required this.question});

  final _LessonScreenState screen;
  final ChoiceQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, option) in question.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Builder(
              builder: (context) {
                final checked = screen._checked;
                final selected = screen._choice == i;
                final correct = checked ? (i == question.answer ? true : (selected ? false : null)) : null;
                final c = _tileColors(context, selected: selected, correct: correct);
                return Chunky(
                  onTap: checked ? null : () => screen._choose(i),
                  fill: c.fill,
                  edge: c.edge,
                  outline: c.outline,
                  selected: selected,
                  minHeight: 58,
                  child: Row(
                    children: [
                      _Key(index: i, color: c.text),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: (question.mono ? monoStyle : theme.textTheme.titleMedium)?.copyWith(
                            color: c.text,
                            fontWeight: FontWeight.w700,
                            fontSize: question.mono ? 16 : null,
                          ),
                        ),
                      ),
                      if (correct == true) Icon(Icons.check_circle, color: c.text, semanticLabel: 'Correcta'),
                      if (correct == false) Icon(Icons.cancel, color: c.text, semanticLabel: 'Incorrecta'),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// The lines of a program, to tap the one that is wrong.
class _FindError extends StatelessWidget {
  const _FindError({required this.screen, required this.question});

  final _LessonScreenState screen;
  final FindErrorQuestion question;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, line) in question.lines.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Builder(
              builder: (context) {
                final checked = screen._checked;
                final selected = screen._choice == i;
                final correct = checked ? (i == question.errorLine ? true : (selected ? false : null)) : null;
                final c = _tileColors(context, selected: selected, correct: correct);
                return Chunky(
                  onTap: checked ? null : () => screen._choose(i),
                  fill: c.fill,
                  edge: c.edge,
                  outline: c.outline,
                  selected: selected,
                  minHeight: 48,
                  semanticsLabel: 'Línea ${i + 1}: $line',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text('${i + 1}', style: monoStyle.copyWith(color: c.text.withValues(alpha: 0.6))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          line,
                          style: monoStyle.copyWith(color: c.text, fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      if (correct == true) Icon(Icons.check_circle, color: c.text),
                      if (correct == false) Icon(Icons.cancel, color: c.text),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// The little number box of an option, like a key.
class _Key extends StatelessWidget {
  const _Key({required this.index, required this.color});

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '${index + 1}',
      style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13),
    ),
  );
}

class _Figures extends StatelessWidget {
  const _Figures({required this.screen, required this.question});

  final _LessonScreenState screen;
  final FigureQuestion question;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 4,
    crossAxisSpacing: 12,
    childAspectRatio: 1.45,
    children: [
      for (final figure in Figure.values)
        Builder(
          builder: (context) {
            final checked = screen._checked;
            final selected = screen._choice == figure.index;
            final correct = checked ? (figure == question.answer ? true : (selected ? false : null)) : null;
            final c = _tileColors(context, selected: selected, correct: correct);
            return Chunky(
              key: ValueKey(figure),
              onTap: checked ? null : () => screen._choose(figure.index),
              fill: c.fill,
              edge: c.edge,
              outline: c.outline,
              selected: selected,
              semanticsLabel: figure.label,
              child: CustomPaint(
                size: const Size(96, 56),
                painter: FigurePainter(figure, line: c.text, fill: c.text.withValues(alpha: 0.12)),
              ),
            );
          },
        ),
    ],
  );
}

/// Draws a flowchart shape.
class FigurePainter extends CustomPainter {
  FigurePainter(this.figure, {required this.line, required this.fill});

  final Figure figure;
  final Color line;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = switch (figure) {
      Figure.oval =>
        Path()
          ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, h * 0.14, w - 8, h * 0.72), Radius.circular(h * 0.36))),
      Figure.parallelogram =>
        Path()
          ..moveTo(w * 0.22, h * 0.14)
          ..lineTo(w - 4, h * 0.14)
          ..lineTo(w * 0.78, h * 0.86)
          ..lineTo(4, h * 0.86)
          ..close(),
      Figure.rectangle =>
        Path()
          ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(6, h * 0.14, w - 12, h * 0.72), const Radius.circular(3))),
      Figure.diamond =>
        Path()
          ..moveTo(w / 2, 2)
          ..lineTo(w - 4, h / 2)
          ..lineTo(w / 2, h - 2)
          ..lineTo(4, h / 2)
          ..close(),
    };
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(FigurePainter old) => old.figure != figure || old.line != line || old.fill != fill;
}

class _Ordering extends StatelessWidget {
  const _Ordering({required this.screen, required this.question});

  final _LessonScreenState screen;
  final OrderQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final checked = screen._checked;

    Widget chip(int line, {required bool placed, int? position}) {
      final c = _tileColors(context, selected: false, correct: checked ? screen._ok : null);
      return Chunky(
        onTap: checked ? null : () => screen._toggleLine(line, placed: placed),
        fill: placed ? c.fill : scheme.surface,
        edge: placed ? c.edge : scheme.outlineVariant,
        outline: placed ? c.outline : scheme.outlineVariant,
        minHeight: 46,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        semanticsLabel: placed
            ? 'Línea ${position! + 1}: ${question.lines[line].trim()}. Toca para quitarla'
            : question.lines[line].trim(),
        child: Text(
          question.lines[line].trim(),
          style: monoStyle.copyWith(
            fontSize: 14.5,
            color: placed ? c.text : scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Tu programa', style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: motion(context, const Duration(milliseconds: 200)),
          constraints: const BoxConstraints(minHeight: 110),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant, width: 2),
          ),
          child: screen._order.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text(
                      'Toca las líneas en orden',
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [for (final (i, line) in screen._order.indexed) chip(line, placed: true, position: i)],
                ),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 2, children: [for (final line in screen._bank) chip(line, placed: false)]),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.screen});

  final _LessonScreenState screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = screen._current;
    final checked = screen._checked;
    final ok = screen._ok;
    final c = _tileColors(context, selected: false, correct: checked ? ok : null);
    final last = screen._index + 1 >= screen._queue.length;
    return AnimatedContainer(
      duration: motion(context, const Duration(milliseconds: 250)),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: checked ? c.fill : theme.colorScheme.surface,
        border: Border(top: BorderSide(color: checked ? c.edge : theme.colorScheme.outlineVariant, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (checked)
                _Feedback(
                  key: ValueKey('${screen._index}-$ok'),
                  ok: ok,
                  color: c.text,
                  message: ok ? '¡Correcto!' : 'Casi',
                  detail: ok ? q.right : q.wrong,
                  solution: !ok
                      ? switch (q) {
                          OrderQuestion() => q.lines.join('\n'),
                          FindErrorQuestion() => q.fixed,
                          _ => null,
                        }
                      : null,
                ),
              Chunky(
                onTap: checked ? screen._next : (screen._hasAnswer ? screen._check : null),
                fill: !checked
                    ? (screen._hasAnswer ? _green(context) : theme.colorScheme.surfaceContainerHighest)
                    : (ok ? _green(context) : _red(context)),
                edge: !checked
                    ? (screen._hasAnswer ? _greenEdge(context) : theme.colorScheme.outlineVariant)
                    : (ok ? _greenEdge(context) : _redEdge(context)),
                minHeight: 54,
                child: Text(
                  checked ? (last ? 'Terminar' : 'Continuar') : 'Comprobar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: !checked && !screen._hasAnswer
                        ? theme.colorScheme.onSurfaceVariant
                        : _onFace(context, green: !checked || ok),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The panel that says if it was right and why, with the mascot reacting.
class _Feedback extends StatelessWidget {
  const _Feedback({
    super.key,
    required this.ok,
    required this.color,
    required this.message,
    required this.detail,
    this.solution,
  });

  final bool ok;
  final Color color;
  final String message;
  final String detail;
  final String? solution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: still ? Duration.zero : const Duration(milliseconds: 700),
            curve: Curves.linear,
            builder: (context, t, child) {
              // Right: a hop. Wrong: a small shake.
              final dy = ok ? -math.sin(t * math.pi) * 14 : 0.0;
              final dx = ok ? 0.0 : math.sin(t * math.pi * 6) * 5 * (1 - t);
              return Transform.translate(offset: Offset(dx, dy), child: child);
            },
            child: Mascota(pose: ok ? MascotPose.lograste : MascotPose.animo, size: 64),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(detail, style: theme.textTheme.bodyMedium?.copyWith(color: color)),
                if (solution != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(solution!, style: monoStyle.copyWith(fontSize: 13, color: color)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The end: how many came out right the first time, and where to go next.
class _Result extends StatelessWidget {
  const _Result({super.key, required this.screen});

  final _LessonScreenState screen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = screen.widget.lesson.questions.length;
    final good = screen._firstTry;
    final next = screen._following;
    final message = good == total
        ? '¡Perfecto! Ni un error.'
        : good >= total - 1
        ? '¡Muy bien! Casi perfecto.'
        : 'Lección completa. Repásala cuando quieras: se aprende repitiendo.';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: motion(context, const Duration(milliseconds: 900)),
                curve: Curves.elasticOut,
                builder: (context, t, child) => Transform.scale(scale: 0.5 + 0.5 * t, child: child),
                child: const Mascota(pose: MascotPose.lograste, size: 160),
              ),
              const SizedBox(height: 12),
              Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  '¡Lección completa!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                screen.widget.lesson.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '$good de $total',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _green(context),
                      ),
                    ),
                    Text('a la primera', style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Chunky(
                onTap: () {
                  Navigator.pop(context);
                  screen.widget.onOpenRoute?.call();
                },
                fill: _green(context),
                edge: _greenEdge(context),
                minHeight: 54,
                child: Text(
                  'Ver tu ruta',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _onFace(context, green: true),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (next != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    screen.widget.onOpenNext?.call(next);
                  },
                  child: Text('Seguir con: ${next.title}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
