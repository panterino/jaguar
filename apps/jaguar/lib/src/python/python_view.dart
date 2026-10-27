import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';

import '../editor/syntax_controller.dart';
import '../theme.dart';

/// The program translated to Python, to read next to the pseudocode. It does
/// not run: Jaguar still runs the program. It follows the code as it changes
/// and keeps the last good translation while the code has an error.
class PythonView extends StatefulWidget {
  const PythonView({super.key, required this.code});

  final SyntaxController code;

  @override
  State<PythonView> createState() => _PythonViewState();
}

class _PythonViewState extends State<PythonView> {
  Timer? _errorTimer;
  String? _python;
  String? _parsedSource;
  JaguarError? _error;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    widget.code.addListener(_onCodeChanged);
    _translate();
  }

  @override
  void didUpdateWidget(PythonView old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code) {
      old.code.removeListener(_onCodeChanged);
      widget.code.addListener(_onCodeChanged);
      _translate();
    }
  }

  @override
  void dispose() {
    widget.code.removeListener(_onCodeChanged);
    _errorTimer?.cancel();
    super.dispose();
  }

  void _onCodeChanged() {
    if (widget.code.text != _parsedSource) _translate();
    setState(() {});
  }

  void _translate() {
    final source = widget.code.text;
    _parsedSource = source;
    try {
      _python = toPython(parse(source));
      _error = null;
      _showError = false;
      _errorTimer?.cancel();
    } on JaguarError catch (error) {
      _error = error;
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _showError = true);
      });
    }
  }

  Future<void> _copy() async {
    final python = _python;
    if (python == null) return;
    await Clipboard.setData(ClipboardData(text: python));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Python copiado')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final python = _python;
    if (python == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _showError && _error != null
                ? 'Aún no hay Python que mostrar: hay un error en la línea ${_error!.line}. Corrígelo en la vista Código.'
                : 'Escribe un programa y aquí verás cómo se escribe en Python.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final stale = _error != null && _showError;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          decoration: BoxDecoration(color: scheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  stale
                      ? 'Hay un error en la línea ${_error!.line}: ves el Python del último programa que funcionaba.'
                      : 'Tu mismo programa, escrito en Python. Solo se lee: Jaguar sigue ejecutando el pseudocódigo.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
                ),
              ),
              IconButton(
                tooltip: 'Copiar el Python',
                icon: Icon(Icons.copy_rounded, color: scheme.onSecondaryContainer),
                onPressed: _copy,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: scheme.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: SelectableText.rich(highlightPython(python, context)),
        ),
        const SizedBox(height: 12),
        Text(
          'Para fijarte: en Python no hay FinSi ni FinPara; el bloque se marca con la sangría. '
          'Las posiciones de un arreglo empiezan en 0, no en 1.',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

const _keywords = {
  'if', 'elif', 'else', 'while', 'for', 'in', 'def', 'return', 'break', 'continue', 'pass', 'import', 'and', 'or', //
  'not', 'True', 'False', 'None',
};
const _builtins = {'print', 'input', 'int', 'float', 'str', 'len', 'range', 'abs', 'round'};

/// Colors Python the way the editor colors pseudocode.
TextSpan highlightPython(String source, BuildContext context) {
  final colors = SyntaxColors.of(context);
  final base = monoStyle.copyWith(fontSize: 14, height: 1.5, color: Theme.of(context).colorScheme.onSurface);
  final spans = <TextSpan>[];
  final token = RegExp(
    r'(#[^\n]*)|("(?:[^"\\\n]|\\.)*")|(\b\d+(?:\.\d+)?\b)|([A-Za-zÁÉÍÓÚÜÑáéíóúüñ_][A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ_]*)',
  );
  var last = 0;
  for (final m in token.allMatches(source)) {
    if (m.start > last) spans.add(TextSpan(text: source.substring(last, m.start)));
    final text = m[0]!;
    final color = m[1] != null
        ? colors.comment
        : m[2] != null
        ? colors.string
        : m[3] != null
        ? colors.number
        : _keywords.contains(text)
        ? colors.keyword
        : _builtins.contains(text) || text == 'math' || text == 'random' || text == 'time'
        ? colors.builtin
        : null;
    spans.add(
      TextSpan(
        text: text,
        style: color == null ? null : TextStyle(color: color),
      ),
    );
    last = m.end;
  }
  if (last < source.length) spans.add(TextSpan(text: source.substring(last)));
  return TextSpan(style: base, children: spans);
}
