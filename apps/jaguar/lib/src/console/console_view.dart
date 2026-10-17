import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../settings.dart';
import '../theme.dart';
import 'console_session.dart';

class ConsoleView extends StatefulWidget {
  const ConsoleView({super.key, required this.session, required this.onGoToLine, this.fontSize = 14});

  final ConsoleSession session;
  final ValueChanged<int> onGoToLine;
  final double fontSize;

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _inputFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
  }

  @override
  void didUpdateWidget(ConsoleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session != widget.session) {
      oldWidget.session.removeListener(_onSessionChanged);
      widget.session.addListener(_onSessionChanged);
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _scroll.dispose();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (widget.session.state == RunState.waitingInput) _inputFocus.requestFocus();
    // Keep the newest output visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  void _submit() {
    widget.session.submitInput(_input.text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mono = monoStyle.copyWith(fontSize: widget.fontSize, height: 1.45, color: scheme.onSurface);

    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) {
        final session = widget.session;
        final isEmpty = session.segments.isEmpty && session.state == RunState.idle;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: isEmpty
                  ? const _EmptyConsole()
                  : SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SelectableText.rich(
                            TextSpan(
                              style: mono,
                              children: [
                                for (final segment in session.segments)
                                  TextSpan(
                                    text: segment.text,
                                    style: switch (segment.kind) {
                                      SegmentKind.output => null,
                                      SegmentKind.input => TextStyle(
                                        color: scheme.secondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      SegmentKind.info => TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _StatusLine(session: session, onGoToLine: widget.onGoToLine),
                        ],
                      ),
                    ),
            ),
            if (session.state == RunState.waitingInput)
              _InputBar(controller: _input, focusNode: _inputFocus, onSubmit: _submit),
            if (session.state == RunState.waitingKey)
              Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: session.continueAfterKey,
                  icon: const Icon(Icons.keyboard_return),
                  label: const Text('Continuar'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.focusNode, required this.onSubmit});

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              autocorrect: false,
              style: monoStyle,
              decoration: const InputDecoration(
                hintText: 'El programa espera un dato (Leer)…',
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          IconButton.filled(onPressed: onSubmit, icon: const Icon(Icons.send), tooltip: 'Enviar'),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.session, required this.onGoToLine});

  final ConsoleSession session;
  final ValueChanged<int> onGoToLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (session.state) {
      case RunState.finished:
        return _Chip(icon: Icons.check_circle, color: Colors.green.shade600, text: 'Programa terminado');
      case RunState.stopped:
        return _Chip(icon: Icons.stop_circle, color: scheme.onSurfaceVariant, text: 'Programa detenido');
      case RunState.failed:
        return _ErrorCard(error: session.error!, onGoToLine: onGoToLine);
      case RunState.running:
        return const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case RunState.idle || RunState.waitingInput || RunState.waitingKey || RunState.paused:
        return const SizedBox.shrink();
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error, required this.onGoToLine});

  final JaguarError error;
  final ValueChanged<int> onGoToLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.errorContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: scheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${error.title} en la línea ${error.line}',
                    style: theme.textTheme.titleSmall?.copyWith(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(error.message, style: TextStyle(color: scheme.onErrorContainer)),
            if (error.hint != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18, color: scheme.onErrorContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(error.hint!, style: TextStyle(color: scheme.onErrorContainer)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onGoToLine(error.line),
                icon: const Icon(Icons.my_location, size: 18),
                label: Text('Ir a la línea ${error.line}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConsole extends StatelessWidget {
  const _EmptyConsole();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/mascota.png', width: 96, height: 96),
            const SizedBox(height: 12),
            Text('Aquí verás lo que hace tu programa', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'Presiona Ejecutar (${shortcutLabel('Enter')})',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
