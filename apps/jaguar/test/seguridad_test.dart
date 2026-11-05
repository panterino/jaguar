import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jaguar/src/cloud/cloud.dart';
import 'package:jaguar/src/cloud/memory_backend.dart';
import 'package:jaguar/src/exercises/exercise_store.dart';
import 'package:jaguar/src/share/share_codec.dart';
import 'package:jaguar_core/jaguar_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _exercise = Exercise(
  id: 'ej1',
  title: 'Doble',
  statement: 'x',
  cases: [
    TestCase(inputs: ['2'], expected: '4'),
  ],
);

void main() {
  group('enlaces', () {
    test('un enlace enorme no se lee (bomba de descompresión)', () {
      final bomb = base64Url.encode(ZLibEncoder().encodeBytes(List.filled(5000000, 65))).replaceAll('=', '');
      expect(contentFromLink('https://app.jaguarcode.org/#p=$bomb'), isNull);
      // Short in the link, but huge when opened.
      final inflates = base64Url.encode(ZLibEncoder().encodeBytes(List.filled(2000000, 65))).replaceAll('=', '');
      expect(inflates.length, lessThan(maxLinkFragment));
      expect(contentFromLink('https://app.jaguarcode.org/#p=$inflates'), isNull);
    });

    test('un programa normal sí se lee', () {
      final source = 'Algoritmo a\n${'    Escribir "hola"\n' * 200}FinAlgoritmo\n';
      expect((contentFromLink(shareLink(source))! as SharedProgram).source, source);
    });

    test('un enlace no pisa un ejercicio propio con el mismo id', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ExerciseStore(await SharedPreferences.getInstance());
      store.saveAuthored(_exercise, solution: 'Algoritmo a\nFinAlgoritmo');
      const crafted = Exercise(id: 'ej1', title: 'Cambiado', cases: []);
      final saved = store.saveReceived(crafted);
      expect(saved.id, isNot('ej1'));
      expect(store.byId('ej1')!.title, 'Doble', reason: 'el ejercicio propio sigue igual');
      expect(store.byId(saved.id)!.title, 'Cambiado');
    });

    test('un ejercicio recibido antes sí se actualiza con su versión nueva', () async {
      SharedPreferences.setMockInitialValues({});
      final store = ExerciseStore(await SharedPreferences.getInstance());
      store.saveReceived(_exercise);
      final fixed = store.saveReceived(
        const Exercise(
          id: 'ej1',
          title: 'Doble',
          statement: 'x',
          revision: 2,
          cases: [
            TestCase(inputs: ['3'], expected: '6'),
          ],
        ),
      );
      expect(fixed.id, 'ej1');
      expect(store.byId('ej1')!.cases.single.expected, '6');
    });
  });

  group('cuenta', () {
    test('al salir se olvidan el nombre y la copia de las clases', () async {
      SharedPreferences.setMockInitialValues({'jaguar.studentName': 'Luis Pérez'});
      final prefs = await SharedPreferences.getInstance();
      final backend = MemoryBackend();
      final cloud = Cloud(backend, prefs);
      await backend.registerTeacher(email: 'p@e.mx', password: 'secreto', alias: 'Profa');
      final room = await backend.createClass('3A');
      backend.actAs(null);
      await cloud.signInAnonymously(alias: 'Luis', role: CloudRole.alumno);
      await cloud.joinClass(code: room.code, name: 'Luis Pérez');
      await cloud.syncClasses();
      expect(cloud.tasks.cachedClasses(cloud.user!.uid), isNotNull);

      await cloud.signOut();
      expect(prefs.getString('jaguar.studentName'), isNull);
      expect(prefs.getString('jaguar.tasks.cache'), isNull);
    });

    test('el profesor puede quitar a un alumno y se van sus entregas', () async {
      final backend = MemoryBackend();
      final teacher = await backend.registerTeacher(email: 'p@e.mx', password: 'secreto', alias: 'Profa');
      final room = await backend.createClass('3A');
      final task = await backend.assign(room.id, _exercise);
      await backend.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
      final ana = backend.currentUser!;
      await backend.joinClass(code: room.code, name: 'Ana');
      await backend.submit(classId: room.id, assignmentId: task.id, name: 'Ana', source: 'x', passed: 1, total: 1);
      backend.actAs(teacher);
      expect(await backend.members(room.id), hasLength(1));
      await backend.removeMember(room.id, ana.uid);
      expect(await backend.members(room.id), isEmpty);
      expect(await backend.submissions(room.id, task.id), isEmpty);
    });

    test('un alumno no puede quitar a nadie', () async {
      final backend = MemoryBackend();
      await backend.registerTeacher(email: 'p@e.mx', password: 'secreto', alias: 'Profa');
      final room = await backend.createClass('3A');
      await backend.signInAnonymously(alias: 'Ana', role: CloudRole.alumno);
      await backend.joinClass(code: room.code, name: 'Ana');
      await expectLater(backend.removeMember(room.id, 'otro'), throwsA(isA<CloudException>()));
    });
  });

  group('web', () {
    final headers = File('../../cloudflare/app/_headers').readAsStringSync();

    test('la app trae las cabeceras de seguridad', () {
      for (final h in [
        'Content-Security-Policy',
        'frame-ancestors \'none\'',
        'Strict-Transport-Security',
        'X-Content-Type-Options: nosniff',
        'Referrer-Policy',
        'Permissions-Policy',
      ]) {
        expect(headers, contains(h));
      }
      // No unsafe-inline or unsafe-eval for scripts; only wasm for CanvasKit.
      final script = RegExp(r"script-src ([^;]*)").firstMatch(headers)!.group(1)!;
      final sources = script.split(' ');
      expect(sources, isNot(contains("'unsafe-inline'")));
      expect(sources, isNot(contains("'unsafe-eval'")));
      expect(sources, contains("'wasm-unsafe-eval'"));
    });

    test('index.html no tiene scripts en línea (la CSP no los permite)', () {
      final html = File('web/index.html').readAsStringSync();
      expect(RegExp(r'<script(?![^>]*\bsrc=)[^>]*>').hasMatch(html), isFalse);
    });

    test('la analítica no manda el fragmento de la URL', () {
      final script = File('web/analitica.js').readAsStringSync();
      expect(script, contains('page_location: location.origin + location.pathname'));
    });

    test('la fuente va dentro de la app, para no pedirla a Google', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: Roboto'));
      for (final w in ['Regular', 'Medium', 'Bold', 'Italic', 'Light']) {
        expect(File('assets/fonts/Roboto-$w.ttf').existsSync(), isTrue, reason: w);
      }
    });
  });
}
