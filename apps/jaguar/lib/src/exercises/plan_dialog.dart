import 'package:flutter/material.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// Asks for the "planteamiento" (input, process, output) before coding.
/// Returns null if cancelled.
Future<ProgramPlan?> showPlanDialog(BuildContext context, ProgramPlan current, {String? statement}) =>
    showDialog<ProgramPlan>(
      context: context,
      builder: (context) => _PlanDialog(current: current, statement: statement),
    );

class _PlanDialog extends StatefulWidget {
  const _PlanDialog({required this.current, this.statement});

  final ProgramPlan current;
  final String? statement;

  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  late final _input = TextEditingController(text: widget.current.input);
  late final _process = TextEditingController(text: widget.current.process);
  late final _output = TextEditingController(text: widget.current.output);

  @override
  void dispose() {
    _input.dispose();
    _process.dispose();
    _output.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController controller, String label, String hint) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: TextField(
      controller: controller,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Planteamiento'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.statement case final statement? when statement.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(child: Text(statement)),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Antes de programar, piensa el problema. Se guarda como comentario al inicio del programa.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              _field(_input, 'Entrada', '¿Qué datos necesita? Ej. dos números'),
              _field(_process, 'Proceso', '¿Qué hace con ellos? Ej. sumarlos'),
              _field(_output, 'Salida', '¿Qué muestra al final? Ej. la suma'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            ProgramPlan(input: _input.text.trim(), process: _process.text.trim(), output: _output.text.trim()),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
