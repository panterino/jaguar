import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:jaguar_core/jaguar_core.dart';

/// Where the web version is published. Links open there, so a QR scanned
/// with any phone camera works without installing anything.
const shareBaseUrl = 'https://jaguar-edu.web.app/';

/// What a Jaguar link carries.
sealed class SharedContent {
  const SharedContent();
}

final class SharedProgram extends SharedContent {
  const SharedProgram(this.source);

  final String source;
}

final class SharedExercise extends SharedContent {
  const SharedExercise(this.exercise);

  final Exercise exercise;
}

/// A link that carries the whole program, compressed, in the URL fragment.
/// The fragment never reaches a server, so sharing needs no backend.
String shareLink(String source) => _link('p', source);

/// A link with an exercise (statement and test cases) for the students.
String exerciseLink(Exercise exercise) => _link('e', jsonEncode(exercise.toJson()));

String _link(String kind, String text) {
  final compressed = ZLibEncoder().encodeBytes(utf8.encode(text));
  return '$shareBaseUrl#$kind=${base64Url.encode(compressed).replaceAll('=', '')}';
}

/// Reads a link made by [shareLink] or [exerciseLink]; null if it has no
/// Jaguar content or is damaged.
SharedContent? contentFromLink(String link) {
  final fragment = Uri.tryParse(link.trim())?.fragment ?? '';
  final separator = fragment.indexOf('=');
  if (separator != 1) return null;
  try {
    final data = base64Url.normalize(fragment.substring(2));
    final text = utf8.decode(ZLibDecoder().decodeBytes(base64Url.decode(data)));
    return switch (fragment[0]) {
      'p' => SharedProgram(text),
      'e' => SharedExercise(Exercise.fromJson((jsonDecode(text) as Map).cast<String, Object?>())),
      _ => null,
    };
  } on Object {
    return null;
  }
}
