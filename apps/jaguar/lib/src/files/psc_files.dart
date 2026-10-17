import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:share_plus/share_plus.dart';

/// Opens a `.psc` made with PSeInt (or Jaguar). Returns its source, or null
/// if the user cancelled.
Future<String?> openPscFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['psc', 'txt'],
    withData: true,
  );
  final bytes = result?.files.single.bytes;
  if (bytes == null) return null;
  // Tabs from PSeInt files become spaces so the editor lines up.
  return decodeSource(bytes).replaceAll('\r\n', '\n').replaceAll('\t', '    ');
}

/// Saves [source] as `name.psc`. Returns false if the user cancelled.
///
/// Encoded in Latin-1 with Windows line endings when possible, which is how
/// PSeInt saves files on the lab's Windows computers.
Future<bool> savePscFile(String name, String source) async {
  final bytes = _pscBytes(source);
  final path = await FilePicker.saveFile(
    dialogTitle: 'Guardar programa',
    fileName: '$name.psc',
    type: FileType.custom,
    allowedExtensions: const ['psc'],
    bytes: bytes,
  );
  // On the web the browser downloads the file and there is no path.
  return path != null || kIsWeb;
}

/// Sends `name.psc` with the phone's share sheet (WhatsApp, email, Drive…),
/// which is how many students hand in their work.
Future<void> sendPscFile(String name, String source) => SharePlus.instance.share(
  ShareParams(
    files: [XFile.fromData(_pscBytes(source), mimeType: 'text/plain', name: '$name.psc')],
    fileNameOverrides: ['$name.psc'],
    subject: '$name.psc',
  ),
);

Uint8List _pscBytes(String source) {
  final text = source.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n');
  try {
    return latin1.encode(text);
  } on ArgumentError {
    return utf8.encode(text);
  }
}
