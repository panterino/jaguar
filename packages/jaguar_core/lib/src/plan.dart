/// The "planteamiento" of a program: what it receives, what it does and what
/// it shows, written before the code. It lives in the program itself as
/// comments at the top, so it travels with the `.psc` and PSeInt ignores it.
class ProgramPlan {
  const ProgramPlan({this.input = '', this.process = '', this.output = ''});

  final String input;
  final String process;
  final String output;

  bool get isEmpty => input.isEmpty && process.isEmpty && output.isEmpty;
}

const _labels = {'entrada': 'Entrada', 'proceso': 'Proceso', 'salida': 'Salida'};
final _planLine = RegExp(r'^\s*//\s*(entrada|proceso|salida)\s*:\s*(.*)$', caseSensitive: false);

/// Reads the plan from the comments at the top of [source].
ProgramPlan readPlan(String source) {
  final found = <String, String>{};
  for (final line in source.split('\n')) {
    if (line.trim().isEmpty) continue;
    final match = _planLine.firstMatch(line);
    if (match == null) {
      if (line.trimLeft().startsWith('//')) continue;
      break;
    }
    found[match[1]!.toLowerCase()] = match[2]!.trim();
  }
  return ProgramPlan(input: found['entrada'] ?? '', process: found['proceso'] ?? '', output: found['salida'] ?? '');
}

/// [source] with [plan] as its first lines, replacing a previous plan.
String writePlan(String source, ProgramPlan plan) {
  final lines = source.split('\n');
  // Drop the old plan lines from the leading comments.
  var start = 0;
  final kept = <String>[];
  for (; start < lines.length; start++) {
    final line = lines[start];
    if (_planLine.hasMatch(line)) continue;
    if (line.trimLeft().startsWith('//') || line.trim().isEmpty && kept.isNotEmpty) {
      kept.add(line);
      continue;
    }
    break;
  }
  String clean(String text) => text.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
  final header = [
    for (final MapEntry(:key, :value) in {
      'entrada': plan.input,
      'proceso': plan.process,
      'salida': plan.output,
    }.entries)
      if (clean(value).isNotEmpty) '// ${_labels[key]}: ${clean(value)}',
  ];
  return [...header, ...kept, ...lines.sublist(start)].join('\n');
}
