import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../share/share_codec.dart';
import '../widgets/pro_widgets.dart';

/// The class code as a QR the teacher projects: students read it with the
/// camera of the phone or with the scanner inside Jaguar, and the join form
/// opens with the code already written.
Future<void> showClassQr(BuildContext context, {required String className, required String code}) => showDialog<void>(
  context: context,
  builder: (context) {
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(className, maxLines: 2, overflow: TextOverflow.ellipsis),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Semantics(
                  label: 'QR para unirse a la clase $className',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: QrImageView(data: classLink(code), size: 260, backgroundColor: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              CodeBadge(code: code, large: false),
              const SizedBox(height: 12),
              Text(
                'Con la cámara del celular, o en Jaguar con Escanear QR. También pueden escribir el código en '
                'Unirme con código.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
    );
  },
);
