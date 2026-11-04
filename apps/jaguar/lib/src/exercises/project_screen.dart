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

    final wide = MediaQuery.sizeOf(context).width >= 900;

    Future<void> copyLink() async {
      await Clipboard.setData(ClipboardData(text: link));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enlace copiado. Compártelo por WhatsApp o Classroom.')));
      }
    }

    Widget qr(double size) => fitsInQr
        ? Semantics(
            label: 'Código QR del ejercicio ${exercise.title}',
            image: true,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: link,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                size: size,
                padding: EdgeInsets.zero,
              ),
            ),
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              'El ejercicio es demasiado largo para un código QR. Acorta el enunciado o comparte el enlace.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.title),
        // On a computer the big button next to the QR does this.
        actions: wide
            ? null
            : [
                TextButton.icon(onPressed: copyLink, icon: const Icon(Icons.link), label: const Text('Copiar enlace')),
                const SizedBox(width: 8),
              ],
      ),
      body: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.maybePop(context)},
        child: Focus(
          autofocus: true,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (wide) {
                // The QR as tall as the window allows, for the back row of
                // the classroom, and what to do beside it.
                final qrSize = math
                    .min(constraints.maxHeight - 32 - 48, constraints.maxWidth * 0.5 - 48 - 32)
                    .clamp(200.0, 760.0);
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        qr(qrSize),
                        const SizedBox(width: 48),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    exercise.title,
                                    style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Escanéalo con la cámara del celular, o abre el enlace que compartió tu profesor.',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 28),
                                FilledButton.icon(
                                  onPressed: copyLink,
                                  icon: const Icon(Icons.link),
                                  label: const Text('Copiar enlace'),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Pega el enlace en WhatsApp o Classroom si algún alumno no puede escanear.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
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
                      qr(qrSize),
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
        ),
      ),
    );
  }
}
