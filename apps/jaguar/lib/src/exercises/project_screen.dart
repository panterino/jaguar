import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../share/share_codec.dart';

/// Full-screen QR for the classroom projector.
class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = exerciseLink(exercise);
    final fitsInQr =
        QrValidator.validate(
          data: link,
          version: QrVersions.auto,
          errorCorrectionLevel: QrErrorCorrectLevel.L,
        ).status ==
        QrValidationStatus.valid;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.title),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Enlace copiado. Compártelo por WhatsApp o Classroom.')));
              }
            },
            icon: const Icon(Icons.link),
            label: const Text('Copiar enlace'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final qrSize = math.min(constraints.maxWidth - 48, constraints.maxHeight - 160).clamp(160.0, 640.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Text(
                    exercise.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  if (fitsInQr)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: QrImageView(
                        data: link,
                        errorCorrectionLevel: QrErrorCorrectLevel.L,
                        size: qrSize,
                        padding: EdgeInsets.zero,
                      ),
                    )
                  else
                    Text(
                      'El ejercicio es demasiado largo para un código QR. Acorta el enunciado o comparte el enlace.',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Escanéalo con la cámara del celular, o abre el enlace que compartió tu profesor.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
