import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'share_codec.dart';

/// Only the phone apps: in a browser the phone's own camera already opens
/// the link of the QR, and the web scanner would need to download a library.
bool get canScanQr =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// Opens the camera to read the QR the teacher projects (or any Jaguar QR).
/// Returns what the QR carries, or null if the student leaves. Nothing is
/// saved or sent: the image never leaves the phone.
Future<SharedContent?> scanQr(BuildContext context) =>
    Navigator.push<SharedContent>(context, MaterialPageRoute(builder: (_) => const _ScanScreen()));

class _ScanScreen extends StatefulWidget {
  const _ScanScreen();

  @override
  State<_ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<_ScanScreen> {
  final _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _done = false;
  String? _lastWrong;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final content = contentFromLink(raw);
      if (content != null) {
        _done = true;
        Navigator.pop(context, content);
        return;
      }
      // Say it once per code, not on every frame.
      if (raw != _lastWrong) {
        _lastWrong = raw;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Ese QR no es de Jaguar. Busca el que proyecta tu profe.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => state.torchState == TorchState.unavailable
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: state.torchState == TorchState.on ? 'Apagar la luz' : 'Encender la luz',
                    icon: Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off),
                    onPressed: _controller.toggleTorch,
                  ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _CameraError(error: error),
          ),
          // A frame to aim at, only while the camera works.
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => state.error != null
                ? const SizedBox.shrink()
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Center(
                        child: Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 24,
                        right: 24,
                        bottom: 48,
                        child: Text(
                          'Apunta al QR del ejercicio. Se abre solo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, shadows: [Shadow(blurRadius: 6)]),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                denied
                    ? 'Jaguar necesita la cámara para leer el QR. Dale permiso en los ajustes del celular, '
                          'o abre el enlace del ejercicio desde el menú.'
                    : 'No se pudo abrir la cámara. Puedes abrir el enlace del ejercicio desde el menú.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
