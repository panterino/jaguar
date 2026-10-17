import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:jaguar_core/jaguar_core.dart';

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
  final text = source.replaceAll('\r\n', '\n').replaceAll('\n', '\r\n');
  Uint8List bytes;
  try {
    bytes = latin1.encode(text);
  } on ArgumentError {
    bytes = utf8.encode(text);
  }
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
