import 'package:flutter/material.dart';

import '../cloud/task_store.dart';
import '../widgets/pro_widgets.dart';

const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// "4 nov, 18:30".
String deliveryDate(DateTime time) {
  final local = time.toLocal();
  return '${local.day} ${_months[local.month - 1]}, ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
}

/// The state of a task in short words, for the bar and the lists.
String taskStateLabel(TaskState state) => switch (state) {
  TaskState.todo => 'Sin entregar',
  TaskState.delivered => 'Entregada',
  TaskState.changed => 'Cambios sin entregar',
};

/// "Tu entrega": whether the work was handed in, and the one step to do it.
///
/// The work is done and kept on the device, with or without internet. Handing
/// it in is a step of its own, on purpose, and only that needs a connection.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.record,
    required this.source,
    required this.busy,
    required this.onDeliver,
  });

  final TaskRecord record;

  /// The program in the editor now, to see if it changed after the delivery.
  final String source;
  final bool busy;
  final VoidCallback onDeliver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = record.stateFor(source);
    final tone = switch (state) {
      TaskState.todo => PillTone.neutral,
      TaskState.delivered => PillTone.good,
      TaskState.changed => PillTone.warn,
    };
    final (background, foreground) = pillColors(context, tone);
    final deliveredAt = record.deliveredAt;
    final result = record.deliveredPassed == null || record.deliveredTotal == null
        ? null
        : '${record.deliveredPassed} de ${record.deliveredTotal} pruebas';
    final detail = switch (state) {
      TaskState.todo =>
        record.passed == null
            ? 'Tu trabajo se guarda en este dispositivo, con o sin internet. Cuando termines, entrégalo: para eso sí hace falta conexión.'
            : 'Última prueba: ${record.passed} de ${record.total}. Tu trabajo se guarda en este dispositivo; entrégalo cuando termines (hace falta internet).',
      TaskState.delivered =>
        'Entregaste${deliveredAt == null ? '' : ' el ${deliveryDate(deliveredAt)}'}${result == null ? '' : ' · $result'}. Tu profesor ya lo puede ver.',
      TaskState.changed =>
        'Cambiaste tu programa después de entregar. Tu profesor todavía ve la versión${deliveredAt == null ? '' : ' del ${deliveryDate(deliveredAt)}'}.',
    };
    final canDeliver = state != TaskState.delivered;
    return Semantics(
      container: true,
      label: 'Tu entrega: ${taskStateLabel(state)}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state == TaskState.todo ? scheme.outlineVariant : foreground.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: background, shape: BoxShape.circle),
                  child: Icon(
                    state == TaskState.delivered ? Icons.check : Icons.outbox_outlined,
                    size: 20,
                    color: foreground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu entrega', style: theme.textTheme.titleSmall),
                      if (record.className.isNotEmpty)
                        Text(
                          record.className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                StatusPill(
                  label: taskStateLabel(state),
                  tone: tone,
                  icon: switch (state) {
                    TaskState.todo => Icons.radio_button_unchecked,
                    TaskState.delivered => Icons.check_circle,
                    TaskState.changed => Icons.edit_outlined,
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(detail, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            if (canDeliver) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: busy ? null : onDeliver,
                icon: busy
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(state == TaskState.changed ? 'Entregar de nuevo' : 'Entregar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "¿Entregar?" with what will be sent. Returns true to go ahead.
Future<bool> showDeliveryConfirm(
  BuildContext context, {
  required String title,
  required int passed,
  required int total,
  required bool hasError,
}) async {
  final theme = Theme.of(context);
  final done = !hasError && passed == total && total > 0;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text('Entregar «$title»'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusPill(
              label: hasError ? 'El programa tiene un error' : '$passed de $total pruebas',
              tone: done ? PillTone.good : PillTone.warn,
              icon: done ? Icons.check_circle : Icons.timelapse,
            ),
            const SizedBox(height: 12),
            Text(
              done
                  ? 'Tu profesor recibirá tu programa tal como está ahora.'
                  : 'Todavía no pasa todas las pruebas. Puedes entregarlo así, o seguir trabajando y entregarlo después. '
                        'Tu profesor recibirá tu programa tal como está ahora.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Si lo cambias después, podrás entregarlo de nuevo.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Seguir trabajando')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Entregar')),
      ],
    ),
  );
  return ok ?? false;
}
