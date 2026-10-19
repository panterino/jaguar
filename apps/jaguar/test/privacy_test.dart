import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/help/privacy_text.dart';

void main() {
  test('la página web del aviso es igual al de la app', () {
    expect(
      File('web/privacidad.html').readAsStringSync(),
      privacyHtml(),
      reason: 'Corre dart run tool/aviso_html.dart',
    );
  });
}
