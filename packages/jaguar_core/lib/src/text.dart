import 'dart:math' as math;

const Map<String, String> _accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};

/// Lowercases and strips Spanish accents, so `Según`, `SEGUN` and `segun`
/// compare equal. PSeInt is case-insensitive for keywords and identifiers.
String normalize(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}

int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = math.min(math.min(current[j - 1] + 1, previous[j] + 1), previous[j - 1] + cost);
    }
    final swap = previous;
    previous = current;
    current = swap;
  }
  return previous[b.length];
}

/// Returns the candidate closest to [word] when it looks like a typo of it,
/// used for "¿Quisiste decir ...?" hints.
String? closestMatch(String word, Iterable<String> candidates) {
  final target = normalize(word);
  String? best;
  var bestDistance = 1 << 30;
  for (final candidate in candidates) {
    final distance = levenshtein(target, normalize(candidate));
    if (distance < bestDistance) {
      best = candidate;
      bestDistance = distance;
    }
  }
  final threshold = target.length <= 4 ? 1 : 2;
  return bestDistance > 0 && bestDistance <= threshold ? best : null;
}
