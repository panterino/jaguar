import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'share_codec.dart';

/// Shows the program as a QR and a link: scan it in the lab and keep working
/// on the phone, or the other way around.
Future<void> showShareDialog(BuildContext context, {required String name, required String source}) {
  final link = shareLink(source);
  final fitsInQr =
      QrValidator.validate(data: link, version: QrVersions.auto, errorCorrectionLevel: QrErrorCorrectLevel.L).status ==
      QrValidationStatus.valid;

  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return AlertDialog(
        title: Text('Compartir "$name"'),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fitsInQr) ...[
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(data: link, errorCorrectionLevel: QrErrorCorrectLevel.L, size: 260),
                ),
                const SizedBox(height: 12),
                Text(
                  'Escanéalo con la cámara del celular para abrir el programa.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ] else
                Text(
                  'El programa es demasiado largo para un código QR. Comparte el enlace o guarda el archivo .psc.',
                  style: theme.textTheme.bodyMedium,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado')));
              }
            },
            icon: const Icon(Icons.link),
            label: const Text('Copiar enlace'),
          ),
        ],
      );
    },
  );
}

/// Asks for a link made with Jaguar and returns the program or exercise
/// inside it.
Future<SharedContent?> showOpenLinkDialog(BuildContext context) =>
    showDialog<SharedContent>(context: context, builder: (_) => const _OpenLinkDialog());

class _OpenLinkDialog extends StatefulWidget {
  const _OpenLinkDialog();

  @override
  State<_OpenLinkDialog> createState() => _OpenLinkDialogState();
}

class _OpenLinkDialogState extends State<_OpenLinkDialog> {
  // Owned by the dialog so it outlives the closing animation.
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() {
    final content = contentFromLink(_controller.text);
    if (content == null) {
      setState(() => _error = 'Ese enlace no contiene un programa ni un ejercicio de Jaguar.');
    } else {
      Navigator.pop(context, content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Abrir enlace'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Pega aquí el enlace de Jaguar', errorText: _error),
          onSubmitted: (_) => _open(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(onPressed: _open, child: const Text('Abrir')),
      ],
    );
  }
}
