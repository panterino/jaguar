// Genera web/privacidad.html a partir del texto de la app:
//   dart run tool/aviso_html.dart
import 'dart:io';

import 'package:jaguar/src/help/privacy_text.dart';

void main() => File('web/privacidad.html').writeAsStringSync(privacyHtml());
