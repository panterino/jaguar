import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/mascota.dart';

/// What the student shows the teacher walking by: big, readable from a
/// distance, with a live clock so a screenshot of someone else's screen is
/// easy to spot.
class VerifiedScreen extends StatefulWidget {
  const VerifiedScreen({
    super.key,
    required this.exerciseTitle,
    required this.studentName,
    required this.passedCases,
    required this.verifiedAt,
    required this.source,
    this.pastedLines = 0,
  });

  final String exerciseTitle;
  final String studentName;
  final int passedCases;
  final DateTime verifiedAt;
  final String source;

  /// The most lines pasted at once while writing it: the teacher sees it here.
  final int pastedLines;

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> with SingleTickerProviderStateMixin {
  late final Timer _clock;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _clock.cancel();
    _pulse.dispose();
    super.dispose();
  }

  String _time(DateTime time, {bool seconds = false}) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}${seconds ? ':${two(time.second)}' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const green = Color(0xFF1B7F3B);
    const onGreen = Colors.white;

    return Scaffold(
      backgroundColor: green,
      appBar: AppBar(backgroundColor: green, foregroundColor: onGreen, title: const Text('Ejercicio verificado')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween(
                      begin: 0.92,
                      end: 1.06,
                    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const Mascota(pose: MascotPose.celebra, size: 120),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: onGreen,
                          child: Icon(Icons.check, color: green, size: 32),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.studentName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(color: onGreen, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.exerciseTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(color: onGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${widget.passedCases} de ${widget.passedCases} casos correctos',
                    style: theme.textTheme.titleLarge?.copyWith(color: onGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verificado a las ${_time(widget.verifiedAt)}',
                    style: theme.textTheme.titleMedium?.copyWith(color: onGreen.withValues(alpha: 0.85)),
                  ),
                  if (widget.pastedLines > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.content_paste, size: 18, color: onGreen.withValues(alpha: 0.85)),
                        const SizedBox(width: 6),
                        Text(
                          'Pegó ${widget.pastedLines} líneas de una vez',
                          style: theme.textTheme.titleMedium?.copyWith(color: onGreen.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, color: onGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ahora: ${_time(_now, seconds: true)}',
                          style: monoStyle.copyWith(color: onGreen, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: onGreen,
                      side: const BorderSide(color: onGreen),
                    ),
                    onPressed: () => _showCode(context),
                    icon: const Icon(Icons.code),
                    label: const Text('Ver el código'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCode(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.exerciseTitle),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(widget.source, style: monoStyle.copyWith(fontSize: 14)),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
      ),
    );
  }
}

/// Asks the student's name once; it's remembered on this device.
Future<String?> askStudentName(BuildContext context, {String? current}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(current: current),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({this.current});

  final String? current;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  // Owned by the dialog so it outlives the closing animation.
  late final _controller = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Cómo te llamas?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Nombre y apellido', helperText: 'Lo verá tu profesor'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _submit, child: const Text('Listo')),
      ],
    );
  }
}
