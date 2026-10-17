import 'dart:convert';
import 'dart:io';

import 'package:jaguar_core/jaguar_core.dart';

/// Runs a `.psc` file in the terminal: `dart run bin/jaguar.dart programa.psc`.
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('Uso: dart run bin/jaguar.dart programa.psc');
    exitCode = 64;
    return;
  }
  final file = File(args.single);
  if (!file.existsSync()) {
    stderr.writeln('No encontré el archivo ${args.single}');
    exitCode = 66;
    return;
  }
  final source = decodeSource(file.readAsBytesSync());
  try {
    await Interpreter(parse(source), _ConsoleIO()).run();
  } on JaguarError catch (error) {
    stderr.writeln();
    stderr.writeln(error.format(source));
    exitCode = 1;
  }
}

class _ConsoleIO implements JaguarIO {
  @override
  void write(String text) => stdout.write(text);

  @override
  Future<String?> read() async => stdin.readLineSync(encoding: utf8);

  @override
  void clear() => stdout.write('\x1B[2J\x1B[H');

  @override
  Future<void> waitForKey() async => stdin.readLineSync();

  @override
  Future<void> sleep(Duration duration) => Future<void>.delayed(duration);
}
